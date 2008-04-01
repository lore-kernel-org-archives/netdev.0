From: Patrick McHardy <kaber@trash.net>
Subject: [SKFILTER]: Add SKF_ADF_NLATTR instruction
Date: Tue, 01 Apr 2008 14:31:38 +0200
Message-ID: <47F22B2A.2000209@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080500050506010209010103"
Cc: Stephen Hemminger <shemminger@vyatta.com>, jamal <hadi@cyberus.ca>,
	Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60531 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753462AbYDAMbm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 08:31:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080500050506010209010103
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

This patch on top of Stephens netlink filter patches add
a new filter instruction for locating netlink attributes.
An example how it is used is contained in the changelog
entry.


--------------080500050506010209010103
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit c86e6a8977eb8d0e1b1bb2346042221d1af0d82c
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue Apr 1 14:29:31 2008 +0200

    [SKFILTER]: Add SKF_ADF_NLATTR instruction
    
    SKF_ADF_NLATTR searches for a netlink attribute, which avoids manually
    parsing and walking attributes. It takes the offset at which to start
    searching in the 'A' register and the attribute type in the 'X' register
    and returns the offset in the 'A' register. When the attribute is not
    found it returns zero.
    
    A top-level attribute can be located using a filter like this
    (example for nfnetlink, using struct nfgenmsg):
    
    	...
    	{
    		/* A = offset of first attribute */
    		.code	= BPF_LD | BPF_IMM,
    		.k	= sizeof(struct nlmsghdr) + sizeof(struct nfgenmsg)
    	},
    	{
    		/* X = CTA_PROTOINFO */
    		.code	= BPF_LDX | BPF_IMM,
    		.k	= CTA_PROTOINFO,
    	},
    	{
    		/* A = netlink attribute offset */
    		.code	= BPF_LD | BPF_B | BPF_ABS,
    		.k	= SKF_AD_OFF + SKF_AD_NLATTR
    	},
    	{
    		/* Exit if not found */
    		.code   = BPF_JMP | BPF_JEQ | BPF_K,
    		.k	= 0,
    		.jt	= <error>
    	},
    	...
    
    A nested attribute below the CTA_PROTOINFO attribute would then
    be parsed like this:
    
    	...
    	{
    		/* A += sizeof(struct nlattr) */
    		.code	= BPF_ALU | BPF_ADD | BPF_K,
    		.k	= sizeof(struct nlattr),
    	},
    	{
    		/* X = CTA_PROTOINFO_TCP */
    		.code	= BPF_LDX | BPF_IMM,
    		.k	= CTA_PROTOINFO_TCP,
    	},
    	{
    		/* A = netlink attribute offset */
    		.code	= BPF_LD | BPF_B | BPF_ABS,
    		.k	= SKF_AD_OFF + SKF_AD_NLATTR
    	},
    	...
    
    The data of an attribute can be loaded into 'A' like this:
    
    	...
    	{
    		/* X = A (attribute offset) */
    		.code	= BPF_MISC | BPF_TAX,
    	},
    	{
    		/* A = skb->data[X + k] */
    		.code 	= BPF_LD | BPF_B | BPF_IND,
    		.k	= sizeof(struct nlattr),
    	},
    	...
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/filter.h b/include/linux/filter.h
index ddfa037..0e39016 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -136,7 +136,8 @@ static inline unsigned int sk_filter_len(struct sk_filter *fp)
 #define SKF_AD_PROTOCOL 0
 #define SKF_AD_PKTTYPE 	4
 #define SKF_AD_IFINDEX 	8
-#define SKF_AD_MAX 	12
+#define SKF_AD_NLATTR	12
+#define SKF_AD_MAX 	16
 #define SKF_NET_OFF   (-0x100000)
 #define SKF_LL_OFF    (-0x200000)
 
diff --git a/net/core/filter.c b/net/core/filter.c
index e0a0694..20ed056 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -27,6 +27,7 @@
 #include <linux/if_packet.h>
 #include <net/ip.h>
 #include <net/protocol.h>
+#include <net/netlink.h>
 #include <linux/skbuff.h>
 #include <net/sock.h>
 #include <linux/errno.h>
@@ -268,6 +269,22 @@ load_b:
 		case SKF_AD_IFINDEX:
 			A = skb->dev->ifindex;
 			continue;
+		case SKF_AD_NLATTR: {
+			struct nlattr *nla;
+
+			if (skb_is_nonlinear(skb))
+				return 0;
+			if (A > skb->len - sizeof(struct nlattr))
+				return 0;
+
+			nla = nla_find((struct nlattr *)&skb->data[A],
+				       skb->len - A, X);
+			if (nla)
+				A = (void *)nla - (void *)skb->data;
+			else
+				A = 0;
+			continue;
+		}
 		default:
 			return 0;
 		}

--------------080500050506010209010103--
