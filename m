From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iptables]  xt_socket: add --nowildcard flag
Date: Thu, 20 Jun 2013 05:52:35 -0700
Message-ID: <1371732755.3252.409.camel@edumazet-glaptop>
References: <1370300249.24311.190.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Patrick McHardy <kaber@trash.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1370300249.24311.190.camel@edumazet-glaptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <edumazet@google.com>

xt_socket module can be a nice replacement to conntrack module
in some cases (SYN filtering for example)

But it lacks the ability to match the 3rd packet of TCP
handshake (ACK coming from the client).

Add a XT_SOCKET_NOWILDCARD flag to disable the wildcard mechanism

The wildcard is the legacy socket match behavior, that ignores
LISTEN sockets bound to INADDR_ANY (or ipv6 equivalent)

iptables -I INPUT -p tcp --syn -j SYN_CHAIN
iptables -I INPUT -m socket -j ACCEPT

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
---
 extensions/libxt_socket.c           |   62 ++++++++++++++++++++++++++
 include/linux/netfilter/xt_socket.h |    7 ++
 2 files changed, 69 insertions(+)

diff --git a/extensions/libxt_socket.c b/extensions/libxt_socket.c
index 3901649..f19c280 100644
--- a/extensions/libxt_socket.c
+++ b/extensions/libxt_socket.c
@@ -9,6 +9,7 @@
 
 enum {
 	O_TRANSPARENT = 0,
+	O_NOWILDCARD = 1,
 };
 
 static const struct xt_option_entry socket_mt_opts[] = {
@@ -16,6 +17,12 @@ static const struct xt_option_entry socket_mt_opts[] = {
 	XTOPT_TABLEEND,
 };
 
+static const struct xt_option_entry socket_mt_opts_v2[] = {
+	{.name = "transparent", .id = O_TRANSPARENT, .type = XTTYPE_NONE},
+	{.name = "nowildcard", .id = O_NOWILDCARD, .type = XTTYPE_NONE},
+	XTOPT_TABLEEND,
+};
+
 static void socket_mt_help(void)
 {
 	printf(
@@ -23,6 +30,14 @@ static void socket_mt_help(void)
 		"  --transparent    Ignore non-transparent sockets\n\n");
 }
 
+static void socket_mt_help_v2(void)
+{
+	printf(
+		"socket match options:\n"
+		"  --nowildcard     Do not ignore LISTEN sockets bound on INADDR_ANY\n"
+		"  --transparent    Ignore non-transparent sockets\n\n");
+}
+
 static void socket_mt_parse(struct xt_option_call *cb)
 {
 	struct xt_socket_mtinfo1 *info = cb->data;
@@ -35,6 +50,21 @@ static void socket_mt_parse(struct xt_option_call *cb)
 	}
 }
 
+static void socket_mt_parse_v2(struct xt_option_call *cb)
+{
+	struct xt_socket_mtinfo2 *info = cb->data;
+
+	xtables_option_parse(cb);
+	switch (cb->entry->id) {
+	case O_TRANSPARENT:
+		info->flags |= XT_SOCKET_TRANSPARENT;
+		break;
+	case O_NOWILDCARD:
+		info->flags |= XT_SOCKET_NOWILDCARD;
+		break;
+	}
+}
+
 static void
 socket_mt_save(const void *ip, const struct xt_entry_match *match)
 {
@@ -52,6 +82,25 @@ socket_mt_print(const void *ip, const struct xt_entry_match *match,
 	socket_mt_save(ip, match);
 }
 
+static void
+socket_mt_save_v2(const void *ip, const struct xt_entry_match *match)
+{
+	const struct xt_socket_mtinfo2 *info = (const void *)match->data;
+
+	if (info->flags & XT_SOCKET_TRANSPARENT)
+		printf(" --transparent");
+	if (info->flags & XT_SOCKET_NOWILDCARD)
+		printf(" --nowildcard");
+}
+
+static void
+socket_mt_print_v2(const void *ip, const struct xt_entry_match *match,
+		   int numeric)
+{
+	printf(" socket");
+	socket_mt_save_v2(ip, match);
+}
+
 static struct xtables_match socket_mt_reg[] = {
 	{
 		.name          = "socket",
@@ -74,6 +123,19 @@ static struct xtables_match socket_mt_reg[] = {
 		.x6_parse      = socket_mt_parse,
 		.x6_options    = socket_mt_opts,
 	},
+	{
+		.name          = "socket",
+		.revision      = 2,
+		.family        = NFPROTO_UNSPEC,
+		.version       = XTABLES_VERSION,
+		.size          = XT_ALIGN(sizeof(struct xt_socket_mtinfo2)),
+		.userspacesize = XT_ALIGN(sizeof(struct xt_socket_mtinfo2)),
+		.help          = socket_mt_help_v2,
+		.print         = socket_mt_print_v2,
+		.save          = socket_mt_save_v2,
+		.x6_parse      = socket_mt_parse_v2,
+		.x6_options    = socket_mt_opts_v2,
+	},
 };
 
 void _init(void)
diff --git a/include/linux/netfilter/xt_socket.h b/include/linux/netfilter/xt_socket.h
index 26d7217..6315e2a 100644
--- a/include/linux/netfilter/xt_socket.h
+++ b/include/linux/netfilter/xt_socket.h
@@ -5,10 +5,17 @@
 
 enum {
 	XT_SOCKET_TRANSPARENT = 1 << 0,
+	XT_SOCKET_NOWILDCARD = 1 << 1,
 };
 
 struct xt_socket_mtinfo1 {
 	__u8 flags;
 };
+#define XT_SOCKET_FLAGS_V1 XT_SOCKET_TRANSPARENT
+
+struct xt_socket_mtinfo2 {
+	__u8 flags;
+};
+#define XT_SOCKET_FLAGS_V2 (XT_SOCKET_TRANSPARENT | XT_SOCKET_NOWILDCARD)
 
 #endif /* _XT_SOCKET_H */


