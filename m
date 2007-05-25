From: David Miller <davem@davemloft.net>
Subject: [PATCH]: Make XFRM_ACQ_EXPIRES tweakable
Date: Thu, 24 May 2007 22:13:04 -0700 (PDT)
Message-ID: <20070524.221304.36926453.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59820
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752022AbXEYFNB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 May 2007 01:13:01 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 516BC29002D
	for <netdev@vger.kernel.org>; Thu, 24 May 2007 22:13:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I've had several requests for the capability to change this
timeout, which I think is perfectly reasonable.

So I intend to merge the following upstream unless I hear
some objections :-)

commit 7191f131aff4797f2a906495c7b285d8adf47da2
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Thu May 24 21:28:00 2007 -0700

    [XFRM]: Allow XFRM_ACQ_EXPIRES to be tunable via sysctl.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 39ef925..90185e8 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -237,7 +237,6 @@ extern int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo);
 extern int xfrm_policy_unregister_afinfo(struct xfrm_policy_afinfo *afinfo);
 extern void km_policy_notify(struct xfrm_policy *xp, int dir, struct km_event *c);
 extern void km_state_notify(struct xfrm_state *x, struct km_event *c);
-#define XFRM_ACQ_EXPIRES	30
 
 struct xfrm_tmpl;
 extern int km_query(struct xfrm_state *x, struct xfrm_tmpl *t, struct xfrm_policy *pol);
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index f34aca0..6d5ea97 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -25,6 +25,7 @@ extern int sysctl_core_destroy_delay;
 extern u32 sysctl_xfrm_aevent_etime;
 extern u32 sysctl_xfrm_aevent_rseqth;
 extern int sysctl_xfrm_larval_drop;
+extern u32 sysctl_xfrm_acq_expires;
 #endif
 
 ctl_table core_table[] = {
@@ -127,6 +128,14 @@ ctl_table core_table[] = {
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec
 	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "xfrm_acq_expires",
+		.data		= &sysctl_xfrm_acq_expires,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec
+	},
 #endif /* CONFIG_XFRM */
 #endif /* CONFIG_NET */
 	{
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 9955ff4..715ab12 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -33,6 +33,8 @@ EXPORT_SYMBOL(sysctl_xfrm_aevent_etime);
 u32 sysctl_xfrm_aevent_rseqth = XFRM_AE_SEQT_SIZE;
 EXPORT_SYMBOL(sysctl_xfrm_aevent_rseqth);
 
+u32 sysctl_xfrm_acq_expires = 30;
+
 /* Each xfrm_state may be linked to two tables:
 
    1. Hash table by (spi,daddr,ah/esp) to find SA by SPI. (input,ctl)
@@ -622,8 +624,8 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 				h = xfrm_spi_hash(&x->id.daddr, x->id.spi, x->id.proto, family);
 				hlist_add_head(&x->byspi, xfrm_state_byspi+h);
 			}
-			x->lft.hard_add_expires_seconds = XFRM_ACQ_EXPIRES;
-			x->timer.expires = jiffies + XFRM_ACQ_EXPIRES*HZ;
+			x->lft.hard_add_expires_seconds = sysctl_xfrm_acq_expires;
+			x->timer.expires = jiffies + sysctl_xfrm_acq_expires*HZ;
 			add_timer(&x->timer);
 			xfrm_state_num++;
 			xfrm_hash_grow_check(x->bydst.next != NULL);
@@ -772,9 +774,9 @@ static struct xfrm_state *__find_acq_core(unsigned short family, u8 mode, u32 re
 		x->props.family = family;
 		x->props.mode = mode;
 		x->props.reqid = reqid;
-		x->lft.hard_add_expires_seconds = XFRM_ACQ_EXPIRES;
+		x->lft.hard_add_expires_seconds = sysctl_xfrm_acq_expires;
 		xfrm_state_hold(x);
-		x->timer.expires = jiffies + XFRM_ACQ_EXPIRES*HZ;
+		x->timer.expires = jiffies + sysctl_xfrm_acq_expires*HZ;
 		add_timer(&x->timer);
 		hlist_add_head(&x->bydst, xfrm_state_bydst+h);
 		h = xfrm_src_hash(daddr, saddr, family);
