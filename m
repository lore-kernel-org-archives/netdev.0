From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v2 7/9] net: isdn: use sk_unattached_filter api
Date: Tue, 25 Mar 2014 16:05:10 +0100
Message-ID: <1395759910-18147-1-git-send-email-dborkman@redhat.com>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61069 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752600AbaCYPFT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Mar 2014 11:05:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similarly as in ppp, we need to migrate the ISDN/PPP code to make use
of the sk_unattached_filter api in order to decouple having direct
filter structure access. By using sk_unattached_filter_{create,destroy},
we can allow for the possibility to jit compile filters for faster
filter verdicts as well.

Joint work with Alexei Starovoitov.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
Cc: Karsten Keil <isdn@linux-pingi.de>
Cc: isdn4linux@listserv.isdn4linux.de
---
 drivers/isdn/i4l/isdn_ppp.c | 61 ++++++++++++++++++++++++++++++---------------
 include/linux/isdn_ppp.h    |  5 ++--
 2 files changed, 43 insertions(+), 23 deletions(-)

diff --git a/drivers/isdn/i4l/isdn_ppp.c b/drivers/isdn/i4l/isdn_ppp.c
index 38ceac5..a5da511 100644
--- a/drivers/isdn/i4l/isdn_ppp.c
+++ b/drivers/isdn/i4l/isdn_ppp.c
@@ -378,10 +378,15 @@ isdn_ppp_release(int min, struct file *file)
 	is->slcomp = NULL;
 #endif
 #ifdef CONFIG_IPPP_FILTER
-	kfree(is->pass_filter);
-	is->pass_filter = NULL;
-	kfree(is->active_filter);
-	is->active_filter = NULL;
+	if (is->pass_filter) {
+		sk_unattached_filter_destroy(is->pass_filter);
+		is->pass_filter = NULL;
+	}
+
+	if (is->active_filter) {
+		sk_unattached_filter_destroy(is->active_filter);
+		is->active_filter = NULL;
+	}
 #endif
 
 /* TODO: if this was the previous master: link the stuff to the new master */
@@ -629,25 +634,41 @@ isdn_ppp_ioctl(int min, struct file *file, unsigned int cmd, unsigned long arg)
 #ifdef CONFIG_IPPP_FILTER
 	case PPPIOCSPASS:
 	{
+		struct sock_fprog fprog;
 		struct sock_filter *code;
-		int len = get_filter(argp, &code);
+		int err, len = get_filter(argp, &code);
+
 		if (len < 0)
 			return len;
-		kfree(is->pass_filter);
-		is->pass_filter = code;
-		is->pass_len = len;
-		break;
+
+		fprog.len = len;
+		fprog.filter = code;
+
+		if (is->pass_filter)
+			sk_unattached_filter_destroy(is->pass_filter);
+		err = sk_unattached_filter_create(&is->pass_filter, &fprog);
+		kfree(code);
+
+		return err;
 	}
 	case PPPIOCSACTIVE:
 	{
+		struct sock_fprog fprog;
 		struct sock_filter *code;
-		int len = get_filter(argp, &code);
+		int err, len = get_filter(argp, &code);
+
 		if (len < 0)
 			return len;
-		kfree(is->active_filter);
-		is->active_filter = code;
-		is->active_len = len;
-		break;
+
+		fprog.len = len;
+		fprog.filter = code;
+
+		if (is->active_filter)
+			sk_unattached_filter_destroy(is->active_filter);
+		err = sk_unattached_filter_create(&is->active_filter, &fprog);
+		kfree(code);
+
+		return err;
 	}
 #endif /* CONFIG_IPPP_FILTER */
 	default:
@@ -1147,14 +1168,14 @@ isdn_ppp_push_higher(isdn_net_dev *net_dev, isdn_net_local *lp, struct sk_buff *
 	}
 
 	if (is->pass_filter
-	    && sk_run_filter(skb, is->pass_filter) == 0) {
+	    && SK_RUN_FILTER(is->pass_filter, skb) == 0) {
 		if (is->debug & 0x2)
 			printk(KERN_DEBUG "IPPP: inbound frame filtered.\n");
 		kfree_skb(skb);
 		return;
 	}
 	if (!(is->active_filter
-	      && sk_run_filter(skb, is->active_filter) == 0)) {
+	      && SK_RUN_FILTER(is->active_filter, skb) == 0)) {
 		if (is->debug & 0x2)
 			printk(KERN_DEBUG "IPPP: link-active filter: resetting huptimer.\n");
 		lp->huptimer = 0;
@@ -1293,14 +1314,14 @@ isdn_ppp_xmit(struct sk_buff *skb, struct net_device *netdev)
 	}
 
 	if (ipt->pass_filter
-	    && sk_run_filter(skb, ipt->pass_filter) == 0) {
+	    && SK_RUN_FILTER(ipt->pass_filter, skb) == 0) {
 		if (ipt->debug & 0x4)
 			printk(KERN_DEBUG "IPPP: outbound frame filtered.\n");
 		kfree_skb(skb);
 		goto unlock;
 	}
 	if (!(ipt->active_filter
-	      && sk_run_filter(skb, ipt->active_filter) == 0)) {
+	      && SK_RUN_FILTER(ipt->active_filter, skb) == 0)) {
 		if (ipt->debug & 0x4)
 			printk(KERN_DEBUG "IPPP: link-active filter: resetting huptimer.\n");
 		lp->huptimer = 0;
@@ -1490,9 +1511,9 @@ int isdn_ppp_autodial_filter(struct sk_buff *skb, isdn_net_local *lp)
 	}
 
 	drop |= is->pass_filter
-		&& sk_run_filter(skb, is->pass_filter) == 0;
+		&& SK_RUN_FILTER(is->pass_filter, skb) == 0;
 	drop |= is->active_filter
-		&& sk_run_filter(skb, is->active_filter) == 0;
+		&& SK_RUN_FILTER(is->active_filter, skb) == 0;
 
 	skb_push(skb, IPPP_MAX_HEADER - 4);
 	return drop;
diff --git a/include/linux/isdn_ppp.h b/include/linux/isdn_ppp.h
index d5f62bc..8e10f57 100644
--- a/include/linux/isdn_ppp.h
+++ b/include/linux/isdn_ppp.h
@@ -180,9 +180,8 @@ struct ippp_struct {
   struct slcompress *slcomp;
 #endif
 #ifdef CONFIG_IPPP_FILTER
-  struct sock_filter *pass_filter;	/* filter for packets to pass */
-  struct sock_filter *active_filter;	/* filter for pkts to reset idle */
-  unsigned pass_len, active_len;
+  struct sk_filter *pass_filter;   /* filter for packets to pass */
+  struct sk_filter *active_filter; /* filter for pkts to reset idle */
 #endif
   unsigned long debug;
   struct isdn_ppp_compressor *compressor,*decompressor;
-- 
1.7.11.7
