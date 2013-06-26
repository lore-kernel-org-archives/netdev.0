From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH] xfrm: add LINUX_MIB_XFRMACQUIREERROR statistic counter
Date: Wed, 26 Jun 2013 14:01:38 +0200
Message-ID: <1372248098-19876-2-git-send-email-steffen.klassert@secunet.com>
References: <1372248098-19876-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:54339 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752018Ab3FZMCI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jun 2013 08:02:08 -0400
In-Reply-To: <1372248098-19876-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>

When host ping its peer, ICMP echo request packet triggers IPsec
policy, then host negotiates SA secret with its peer. After IKE
installed SA for OUT direction, but before SA for IN direction
installed, host get ICMP echo reply from its peer. At the time
being, the SA state for IN direction could be XFRM_STATE_ACQ,
then the received packet will be dropped after adding
LINUX_MIB_XFRMINSTATEINVALID statistic.

Adding a LINUX_MIB_XFRMACQUIREERROR statistic counter for such
scenario when SA in larval state is much clearer for user than
LINUX_MIB_XFRMINSTATEINVALID which indicates the SA is totally
bad.

Signed-off-by: Fan Du <fan.du@windriver.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/uapi/linux/snmp.h |    1 +
 net/xfrm/xfrm_input.c     |    5 +++++
 net/xfrm/xfrm_proc.c      |    1 +
 3 files changed, 7 insertions(+)

diff --git a/include/uapi/linux/snmp.h b/include/uapi/linux/snmp.h
index df2e8b4..ea17542 100644
--- a/include/uapi/linux/snmp.h
+++ b/include/uapi/linux/snmp.h
@@ -287,6 +287,7 @@ enum
 	LINUX_MIB_XFRMOUTPOLERROR,		/* XfrmOutPolError */
 	LINUX_MIB_XFRMFWDHDRERROR,		/* XfrmFwdHdrError*/
 	LINUX_MIB_XFRMOUTSTATEINVALID,		/* XfrmOutStateInvalid */
+	LINUX_MIB_XFRMACQUIREERROR,		/* XfrmAcquireError */
 	__LINUX_MIB_XFRMMAX
 };
 
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index ab2bb42..8884399 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -163,6 +163,11 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 		skb->sp->xvec[skb->sp->len++] = x;
 
 		spin_lock(&x->lock);
+		if (unlikely(x->km.state == XFRM_STATE_ACQ)) {
+			XFRM_INC_STATS(net, LINUX_MIB_XFRMACQUIREERROR);
+			goto drop_unlock;
+		}
+
 		if (unlikely(x->km.state != XFRM_STATE_VALID)) {
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMINSTATEINVALID);
 			goto drop_unlock;
diff --git a/net/xfrm/xfrm_proc.c b/net/xfrm/xfrm_proc.c
index c721b0d..80cd1e5 100644
--- a/net/xfrm/xfrm_proc.c
+++ b/net/xfrm/xfrm_proc.c
@@ -44,6 +44,7 @@ static const struct snmp_mib xfrm_mib_list[] = {
 	SNMP_MIB_ITEM("XfrmOutPolError", LINUX_MIB_XFRMOUTPOLERROR),
 	SNMP_MIB_ITEM("XfrmFwdHdrError", LINUX_MIB_XFRMFWDHDRERROR),
 	SNMP_MIB_ITEM("XfrmOutStateInvalid", LINUX_MIB_XFRMOUTSTATEINVALID),
+	SNMP_MIB_ITEM("XfrmAcquireError", LINUX_MIB_XFRMACQUIREERROR),
 	SNMP_MIB_SENTINEL
 };
 
-- 
1.7.9.5
