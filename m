From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH nft] src: add netdev family support
Date: Mon, 25 May 2015 14:46:44 +0200
Message-ID: <1432558004-13481-6-git-send-email-pablo@netfilter.org>
References: <1432558004-13481-1-git-send-email-pablo@netfilter.org>
Cc: kaber@trash.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56579 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752669AbbEYMl4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 May 2015 08:41:56 -0400
In-Reply-To: <1432558004-13481-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for the new 'netdev' table. So far, this table allows
you to create filter chains from ingress.

The following example shows a very simple base configuration with one table that
is bound to device 'eth0' with a single ingress chain:

 # nft list table netdev eth0
 table netdev eth0 {
	device eth0;

	chain ingress {
		type filter hook ingress priority 0; policy accept;
	}
 }

The selected table name is 'eth0' but you could have selected any name.

You can test that this works by adding a simple rule with counters:

 # nft add rule netdev eth0 ingress counter

or a bit more elaborated test like:

 http://people.netfilter.org/pablo/nft-ingress.ruleset

More information will be available at the nftables documentation site [1].

[1] http://wiki.nftables.org/

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 doc/nft.xml               |   41 +++++++++++++++++++++++++++++++++++++++++
 include/linux/netfilter.h |    8 ++++++++
 include/rule.h            |    2 ++
 src/evaluate.c            |    4 ++++
 src/netlink.c             |   11 +++++++++--
 src/parser_bison.y        |    7 +++++++
 src/payload.c             |    1 +
 src/proto.c               |    1 +
 src/rule.c                |   23 +++++++++++++++++++++++
 src/scanner.l             |    2 ++
 10 files changed, 98 insertions(+), 2 deletions(-)

diff --git a/doc/nft.xml b/doc/nft.xml
index 8d79016..1172c43 100644
--- a/doc/nft.xml
+++ b/doc/nft.xml
@@ -267,6 +267,14 @@ filter input iif $int_ifs accept
 						</para>
 					</listitem>
 				</varlistentry>
+				<varlistentry>
+					<term><option>netdev</option></term>
+					<listitem>
+						<para>
+							Netdev address family, handling packets from ingress.
+						</para>
+					</listitem>
+				</varlistentry>
 			</variablelist>
 		</para>
 		<para>
@@ -373,6 +381,38 @@ filter input iif $int_ifs accept
 				The bridge address family handles ethernet packets traversing bridge devices.
 			</para>
 		</refsect2>
+		<refsect2>
+			<title>Netdev address family</title>
+			<para>
+				The Netdev address family handles packets from ingress.
+			</para>
+			<para>
+				<table frame="all">
+					<title>Netdev address family hooks</title>
+					<tgroup cols='2' align='left' colsep='1' rowsep='1' pgwide="1">
+						<colspec colname='c1' colwidth="1*"/>
+						<colspec colname='c2' colwidth="5*"/>
+						<thead>
+							<row>
+								<entry>Hook</entry>
+								<entry>Description</entry>
+							</row>
+						</thead>
+						<tbody>
+							<row>
+								<entry>ingress</entry>
+								<entry>
+									All packets entering the system are processed by this hook. It is invoked
+									before layer 3 protocol handlers and it can be used for early filtering and
+									policing.
+								</entry>
+							</row>
+						</tbody>
+					</tgroup>
+				</table>
+			</para>
+		</refsect2>
+
 	</refsect1>
 
 	<refsect1>
@@ -401,6 +441,7 @@ filter input iif $int_ifs accept
 				<member><literal>inet</literal></member>
 				<member><literal>arp</literal></member>
 				<member><literal>bridge</literal></member>
+				<member><literal>netdev</literal></member>
 			</simplelist>.
 
 			The <literal>inet</literal> address family is a dummy family which is used to create
diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index be0bc18..18075f9 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -32,6 +32,7 @@
 #define NF_DROP_ERR(x) (((-x) << 16) | NF_DROP)
 
 /* only for userspace compatibility */
+#ifndef __KERNEL__
 /* Generic cache responses from hook functions.
    <= 0x2000 is used for protocol-flags. */
 #define NFC_UNKNOWN 0x4000
@@ -39,6 +40,7 @@
 
 /* NF_VERDICT_BITS should be 8 now, but userspace might break if this changes */
 #define NF_VERDICT_BITS 16
+#endif
 
 enum nf_inet_hooks {
 	NF_INET_PRE_ROUTING,
@@ -49,11 +51,17 @@ enum nf_inet_hooks {
 	NF_INET_NUMHOOKS
 };
 
+enum nf_dev_hooks {
+	NF_NETDEV_INGRESS,
+	NF_NETDEV_NUMHOOKS
+};
+
 enum {
 	NFPROTO_UNSPEC =  0,
 	NFPROTO_INET   =  1,
 	NFPROTO_IPV4   =  2,
 	NFPROTO_ARP    =  3,
+	NFPROTO_NETDEV =  5,
 	NFPROTO_BRIDGE =  7,
 	NFPROTO_IPV6   = 10,
 	NFPROTO_DECNET = 12,
diff --git a/include/rule.h b/include/rule.h
index 97959f7..06ec2ff 100644
--- a/include/rule.h
+++ b/include/rule.h
@@ -72,6 +72,7 @@ enum table_flags {
  *
  * @list:	list node
  * @handle:	table handle
+ * @dev:	network device name (only for netdev family)
  * @location:	location the table was defined at
  * @chains:	chains contained in the table
  * @sets:	sets contained in the table
@@ -80,6 +81,7 @@ enum table_flags {
 struct table {
 	struct list_head	list;
 	struct handle		handle;
+	const char		*dev;
 	struct location		location;
 	struct scope		scope;
 	struct list_head	chains;
diff --git a/src/evaluate.c b/src/evaluate.c
index 7ecb793..a0344de 100644
--- a/src/evaluate.c
+++ b/src/evaluate.c
@@ -1795,6 +1795,10 @@ static uint32_t str2hooknum(uint32_t family, const char *hook)
 		else if (!strcmp(hook, "output"))
 			return NF_ARP_OUT;
 		break;
+	case NFPROTO_NETDEV:
+		if (!strcmp(hook, "ingress"))
+			return NF_NETDEV_INGRESS;
+		break;
 	default:
 		break;
 	}
diff --git a/src/netlink.c b/src/netlink.c
index 343d8be..bb1cd7d 100644
--- a/src/netlink.c
+++ b/src/netlink.c
@@ -816,10 +816,14 @@ static int netlink_add_table_batch(struct netlink_ctx *ctx,
 	int err;
 
 	nlt = alloc_nft_table(h);
-	if (table != NULL)
+	if (table != NULL) {
 		nft_table_attr_set_u32(nlt, NFT_TABLE_ATTR_FLAGS, table->flags);
-	else
+		if (table->dev != NULL)
+			nft_table_attr_set_str(nlt, NFT_TABLE_ATTR_DEV,
+					       table->dev);
+	} else {
 		nft_table_attr_set_u32(nlt, NFT_TABLE_ATTR_FLAGS, 0);
+	}
 
 	err = mnl_nft_table_batch_add(nlt, excl ? NLM_F_EXCL : 0,
 				      ctx->seqnum);
@@ -910,6 +914,8 @@ static struct table *netlink_delinearize_table(struct netlink_ctx *ctx,
 		xstrdup(nft_table_attr_get_str(nlt, NFT_TABLE_ATTR_NAME));
 	table->flags	     =
 		nft_table_attr_get_u32(nlt, NFT_TABLE_ATTR_FLAGS);
+	if (nft_table_attr_is_set(nlt, NFT_TABLE_ATTR_DEV))
+		table->dev   = xstrdup(nft_table_attr_get_str(nlt, NFT_TABLE_ATTR_DEV));
 
 	return table;
 }
@@ -963,6 +969,7 @@ int netlink_get_table(struct netlink_ctx *ctx, const struct handle *h,
 
 	ntable = netlink_delinearize_table(ctx, nlt);
 	table->flags = ntable->flags;
+	table->dev   = ntable->dev;
 	xfree(ntable);
 out:
 	nft_table_free(nlt);
diff --git a/src/parser_bison.y b/src/parser_bison.y
index b86381d..18034ce 100644
--- a/src/parser_bison.y
+++ b/src/parser_bison.y
@@ -165,6 +165,7 @@ static void location_update(struct location *loc, struct location *rhs, int n)
 %token DEFINE			"define"
 
 %token HOOK			"hook"
+%token DEVICE			"device"
 %token TABLE			"table"
 %token TABLES			"tables"
 %token CHAIN			"chain"
@@ -179,6 +180,7 @@ static void location_update(struct location *loc, struct location *rhs, int n)
 %token RULESET			"ruleset"
 
 %token INET			"inet"
+%token NETDEV			"netdev"
 
 %token ADD			"add"
 %token CREATE			"create"
@@ -863,6 +865,10 @@ table_options		:	FLAGS		STRING
 					YYERROR;
 				}
 			}
+			|	DEVICE		string
+			{
+				$<table>0->dev = $2;
+			}
 			;
 
 table_block		:	/* empty */	{ $$ = $<table>-1; }
@@ -1102,6 +1108,7 @@ family_spec_explicit	:	IP		{ $$ = NFPROTO_IPV4; }
 			|	INET		{ $$ = NFPROTO_INET; }
 			|	ARP		{ $$ = NFPROTO_ARP; }
 			|	BRIDGE		{ $$ = NFPROTO_BRIDGE; }
+			|	NETDEV		{ $$ = NFPROTO_NETDEV; }
 			;
 
 table_spec		:	family_spec	identifier
diff --git a/src/payload.c b/src/payload.c
index 08578fd..1a9d491 100644
--- a/src/payload.c
+++ b/src/payload.c
@@ -215,6 +215,7 @@ int payload_gen_dependency(struct eval_ctx *ctx, const struct expr *expr,
 			}
 			break;
 		case NFPROTO_BRIDGE:
+		case NFPROTO_NETDEV:
 			switch (expr->payload.base) {
 			case PROTO_BASE_LL_HDR:
 				desc = &proto_eth;
diff --git a/src/proto.c b/src/proto.c
index 7dc7b3e..dc671bd 100644
--- a/src/proto.c
+++ b/src/proto.c
@@ -123,6 +123,7 @@ const struct proto_desc *proto_dev_desc(uint16_t type)
 
 const struct hook_proto_desc hook_proto_desc[] = {
 	[NFPROTO_BRIDGE]	= HOOK_PROTO_DESC(PROTO_BASE_LL_HDR,	  &proto_eth),
+	[NFPROTO_NETDEV]	= HOOK_PROTO_DESC(PROTO_BASE_LL_HDR,	  &proto_eth),
 	[NFPROTO_INET]		= HOOK_PROTO_DESC(PROTO_BASE_LL_HDR,	  &proto_inet),
 	[NFPROTO_IPV4]		= HOOK_PROTO_DESC(PROTO_BASE_NETWORK_HDR, &proto_ip),
 	[NFPROTO_IPV6]		= HOOK_PROTO_DESC(PROTO_BASE_NETWORK_HDR, &proto_ip6),
diff --git a/src/rule.c b/src/rule.c
index 7114380..5e91bf2 100644
--- a/src/rule.c
+++ b/src/rule.c
@@ -312,6 +312,7 @@ static const char *chain_hookname_str_array[] = {
 	"forward",
 	"postrouting",
 	"output",
+	"ingress",
 	NULL,
 };
 
@@ -377,6 +378,8 @@ const char *family2str(unsigned int family)
 			return "ip6";
 		case NFPROTO_INET:
 			return "inet";
+		case NFPROTO_NETDEV:
+			return "netdev";
 		case NFPROTO_ARP:
 			return "arp";
 		case NFPROTO_BRIDGE:
@@ -420,6 +423,13 @@ static const char *hooknum2str(unsigned int family, unsigned int hooknum)
 		default:
 			break;
 		}
+		break;
+	case NFPROTO_NETDEV:
+		switch (hooknum) {
+		case NF_NETDEV_INGRESS:
+			return "ingress";
+		}
+		break;
 	default:
 		break;
 	};
@@ -525,6 +535,7 @@ const char *table_flags_name[TABLE_FLAGS_MAX] = {
 static void table_print_options(const struct table *table, const char **delim)
 {
 	uint32_t flags = table->flags;
+	bool newline = false;
 	int i;
 
 	if (flags) {
@@ -537,6 +548,18 @@ static void table_print_options(const struct table *table, const char **delim)
 			if (flags)
 				printf(",");
 		}
+		newline = true;
+	}
+	if (table->dev) {
+		if (!newline)
+			printf("\t");
+		else
+			printf(" ");
+
+		printf("device %s;", table->dev);
+		newline = true;
+	}
+	if (newline) {
 		printf("\n");
 		*delim = "\n";
 	}
diff --git a/src/scanner.l b/src/scanner.l
index 73c4f8b..2de9cbc 100644
--- a/src/scanner.l
+++ b/src/scanner.l
@@ -231,6 +231,7 @@ addrstring	({macaddr}|{ip4addr}|{ip6addr})
 "describe"		{ return DESCRIBE; }
 
 "hook"			{ return HOOK; }
+"device"		{ return DEVICE; }
 "table"			{ return TABLE; }
 "tables"		{ return TABLES; }
 "chain"			{ return CHAIN; }
@@ -253,6 +254,7 @@ addrstring	({macaddr}|{ip4addr}|{ip6addr})
 "to"			{ return TO; }
 
 "inet"			{ return INET; }
+"netdev"		{ return NETDEV; }
 
 "add"			{ return ADD; }
 "create"		{ return CREATE; }
-- 
1.7.10.4
