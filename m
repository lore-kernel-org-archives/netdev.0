From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/8] xfrm: removes a superfluous check and add a statistic
Date: Wed, 23 Jan 2013 09:18:57 +0100
Message-ID: <1358929144-17806-2-git-send-email-steffen.klassert@secunet.com>
References: <1358929144-17806-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:50714 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753995Ab3AWITY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 03:19:24 -0500
In-Reply-To: <1358929144-17806-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

Remove the check if x->km.state equal to XFRM_STATE_VALID in
xfrm_state_check_expire(), which will be done before call
xfrm_state_check_expire().

add a LINUX_MIB_XFRMOUTSTATEINVALID statistic to record the
outbound error due to invalid xfrm state.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/uapi/linux/snmp.h |    1 +
 net/xfrm/xfrm_output.c    |    6 ++++++
 net/xfrm/xfrm_proc.c      |    1 +
 net/xfrm/xfrm_state.c     |    3 ---
 4 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/snmp.h b/include/uapi/linux/snmp.h
index fdfba23..b49eab8 100644
--- a/include/uapi/linux/snmp.h
+++ b/include/uapi/linux/snmp.h
@@ -278,6 +278,7 @@ enum
 	LINUX_MIB_XFRMOUTPOLDEAD,		/* XfrmOutPolDead */
 	LINUX_MIB_XFRMOUTPOLERROR,		/* XfrmOutPolError */
 	LINUX_MIB_XFRMFWDHDRERROR,		/* XfrmFwdHdrError*/
+	LINUX_MIB_XFRMOUTSTATEINVALID,		/* XfrmOutStateInvalid */
 	__LINUX_MIB_XFRMMAX
 };
 
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 95a338c..3670526 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -61,6 +61,12 @@ static int xfrm_output_one(struct sk_buff *skb, int err)
 		}
 
 		spin_lock_bh(&x->lock);
+
+		if (unlikely(x->km.state != XFRM_STATE_VALID)) {
+			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTSTATEINVALID);
+			goto error_nolock;
+		}
+
 		err = xfrm_state_check_expire(x);
 		if (err) {
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTSTATEEXPIRED);
diff --git a/net/xfrm/xfrm_proc.c b/net/xfrm/xfrm_proc.c
index d0a1af8..6039038 100644
--- a/net/xfrm/xfrm_proc.c
+++ b/net/xfrm/xfrm_proc.c
@@ -43,6 +43,7 @@ static const struct snmp_mib xfrm_mib_list[] = {
 	SNMP_MIB_ITEM("XfrmOutPolDead", LINUX_MIB_XFRMOUTPOLDEAD),
 	SNMP_MIB_ITEM("XfrmOutPolError", LINUX_MIB_XFRMOUTPOLERROR),
 	SNMP_MIB_ITEM("XfrmFwdHdrError", LINUX_MIB_XFRMFWDHDRERROR),
+	SNMP_MIB_ITEM("XfrmOutStateInvalid", LINUX_MIB_XFRMOUTSTATEINVALID),
 	SNMP_MIB_SENTINEL
 };
 
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 3459692..05db236 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1370,9 +1370,6 @@ int xfrm_state_check_expire(struct xfrm_state *x)
 	if (!x->curlft.use_time)
 		x->curlft.use_time = get_seconds();
 
-	if (x->km.state != XFRM_STATE_VALID)
-		return -EINVAL;
-
 	if (x->curlft.bytes >= x->lft.hard_byte_limit ||
 	    x->curlft.packets >= x->lft.hard_packet_limit) {
 		x->km.state = XFRM_STATE_EXPIRED;
-- 
1.7.9.5
