From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 8/9] xfrm: align nlattr properly when needed
Date: Fri, 22 Apr 2016 17:31:23 +0200
Message-ID: <1461339084-3849-9-git-send-email-nicolas.dichtel@6wind.com>
References: <1461339084-3849-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	linux-wpan@vger.kernel.org, aar@pengutronix.de,
	pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	pshelar@nicira.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, netfilter-devel@vger.kernel.org,
	dev@openvswitch.org, steffen.klassert@secunet.com,
	herbert@gondor.apana.org.au, bsingharora@gmail.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:53597 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753811AbcDVPcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 11:32:05 -0400
In-Reply-To: <1461339084-3849-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/uapi/linux/xfrm.h |  1 +
 net/xfrm/xfrm_user.c      | 10 ++++++----
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/include/uapi/linux/xfrm.h b/include/uapi/linux/xfrm.h
index 2cd9e608d0d1..143338978b48 100644
--- a/include/uapi/linux/xfrm.h
+++ b/include/uapi/linux/xfrm.h
@@ -302,6 +302,7 @@ enum xfrm_attr_type_t {
 	XFRMA_SA_EXTRA_FLAGS,	/* __u32 */
 	XFRMA_PROTO,		/* __u8 */
 	XFRMA_ADDRESS_FILTER,	/* struct xfrm_address_filter */
+	XFRMA_PAD,
 	__XFRMA_MAX
 
 #define XFRMA_MAX (__XFRMA_MAX - 1)
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 2cc7af858c6f..d516845e16e3 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -809,7 +809,8 @@ static int copy_to_user_state_extra(struct xfrm_state *x,
 			goto out;
 	}
 	if (x->lastused) {
-		ret = nla_put_u64(skb, XFRMA_LASTUSED, x->lastused);
+		ret = nla_put_u64_64bit(skb, XFRMA_LASTUSED, x->lastused,
+					XFRMA_PAD);
 		if (ret)
 			goto out;
 	}
@@ -1813,7 +1814,7 @@ static inline size_t xfrm_aevent_msgsize(struct xfrm_state *x)
 
 	return NLMSG_ALIGN(sizeof(struct xfrm_aevent_id))
 	       + nla_total_size(replay_size)
-	       + nla_total_size(sizeof(struct xfrm_lifetime_cur))
+	       + nla_total_size_64bit(sizeof(struct xfrm_lifetime_cur))
 	       + nla_total_size(sizeof(struct xfrm_mark))
 	       + nla_total_size(4) /* XFRM_AE_RTHR */
 	       + nla_total_size(4); /* XFRM_AE_ETHR */
@@ -1848,7 +1849,8 @@ static int build_aevent(struct sk_buff *skb, struct xfrm_state *x, const struct
 	}
 	if (err)
 		goto out_cancel;
-	err = nla_put(skb, XFRMA_LTIME_VAL, sizeof(x->curlft), &x->curlft);
+	err = nla_put_64bit(skb, XFRMA_LTIME_VAL, sizeof(x->curlft), &x->curlft,
+			    XFRMA_PAD);
 	if (err)
 		goto out_cancel;
 
@@ -2617,7 +2619,7 @@ static inline size_t xfrm_sa_len(struct xfrm_state *x)
 		l += nla_total_size(sizeof(x->props.extra_flags));
 
 	/* Must count x->lastused as it may become non-zero behind our back. */
-	l += nla_total_size(sizeof(u64));
+	l += nla_total_size_64bit(sizeof(u64));
 
 	return l;
 }
-- 
2.8.1
