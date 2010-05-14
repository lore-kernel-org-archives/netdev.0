From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: [PATCH] netfilter: Remove skb_is_nonlinear check from
	nf_conntrack_sip
Date: Thu, 13 May 2010 18:38:34 -0600
Message-ID: <20100514003834.GY15969@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

At least the XEN net front driver always produces non linear skbs,
so the SIP module does nothing at all when used with that NIC.

Copy the hacky technique for accessing SKB data from the ftp conntrack,
better than nothing..

Signed-off-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
---
 net/netfilter/nf_conntrack_sip.c |   21 ++++++++++++++-------
 1 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index 4b57216..37dd7a4 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -30,6 +30,10 @@ MODULE_DESCRIPTION("SIP connection tracking helper");
 MODULE_ALIAS("ip_conntrack_sip");
 MODULE_ALIAS_NFCT_HELPER("sip");
 
+/* This is slow, but it's simple. --RR */
+static char *sip_buffer;
+static DEFINE_SPINLOCK(nf_sip_lock);
+
 #define MAX_PORTS	8
 static unsigned short ports[MAX_PORTS];
 static unsigned int ports_c;
@@ -1275,17 +1279,14 @@ static int sip_help(struct sk_buff *skb,
 
 	nf_ct_refresh(ct, skb, sip_timeout * HZ);
 
-	if (!skb_is_nonlinear(skb))
-		dptr = skb->data + dataoff;
-	else {
-		pr_debug("Copy of skbuff not supported yet.\n");
-		return NF_ACCEPT;
-	}
-
 	datalen = skb->len - dataoff;
 	if (datalen < strlen("SIP/2.0 200"))
 		return NF_ACCEPT;
 
+	spin_lock_bh(&nf_sip_lock);
+	dptr = skb_header_pointer(skb, dataoff, datalen, sip_buffer);
+	BUG_ON(dptr == NULL);
+
 	if (strnicmp(dptr, "SIP/2.0 ", strlen("SIP/2.0 ")) != 0)
 		ret = process_sip_request(skb, &dptr, &datalen);
 	else
@@ -1297,6 +1298,7 @@ static int sip_help(struct sk_buff *skb,
 			ret = NF_DROP;
 	}
 
+	spin_unlock_bh(&nf_sip_lock);
 	return ret;
 }
 
@@ -1329,6 +1331,7 @@ static void nf_conntrack_sip_fini(void)
 			nf_conntrack_helper_unregister(&sip[i][j]);
 		}
 	}
+	kfree(sip_buffer);
 }
 
 static int __init nf_conntrack_sip_init(void)
@@ -1336,6 +1339,10 @@ static int __init nf_conntrack_sip_init(void)
 	int i, j, ret;
 	char *tmpname;
 
+	sip_buffer = kmalloc(65536, GFP_KERNEL);
+	if (!sip_buffer)
+		return -ENOMEM;
+
 	if (ports_c == 0)
 		ports[ports_c++] = SIP_PORT;
 
-- 
1.6.0.4

