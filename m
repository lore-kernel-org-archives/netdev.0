From: Yotam Gigi <yotam.gi@gmail.com>
Subject: [PATCH net v3 2/2] act_ife: Fix false encoding
Date: Mon, 26 Sep 2016 13:45:26 +0300
Message-ID: <1474886726-56363-3-git-send-email-yotamg@mellanox.com>
References: <1474886726-56363-1-git-send-email-yotamg@mellanox.com>
Cc: Yotam Gigi <yotamg@mellanox.com>
To: jhs@mojatatu.com, davem@davemloft.net, netdev@vger.kernel.org,
        mlxsw@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34739 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034079AbcIZKnr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 06:43:47 -0400
Received: by mail-wm0-f66.google.com with SMTP id l132so13409247wmf.1
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 03:43:46 -0700 (PDT)
In-Reply-To: <1474886726-56363-1-git-send-email-yotamg@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On ife encode side, the action stores the different tlvs inside the ife
header, where each tlv length field should refer to the length of the
whole tlv (without additional padding) and not just the data length.

On ife decode side, the action iterates over the tlvs in the ife header
and parses them one by one, where in each iteration the current pointer is
advanced according to the tlv size.

Before, the encoding encoded only the data length inside the tlv, which led
to false parsing of ife the header. In addition, due to the fact that the
loop counter was unsigned, it could lead to infinite parsing loop.

This fix changes the loop counter to be signed and fixes the encoding to
take into account the tlv type and size.

Fixes: 28a10c426e81 ("net sched: fix encoding to use real length")
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
---

v2->v3
 - Fix the encode side instead of the decode side

---
 net/sched/act_ife.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/act_ife.c b/net/sched/act_ife.c
index b949d97..95c463c 100644
--- a/net/sched/act_ife.c
+++ b/net/sched/act_ife.c
@@ -53,7 +53,7 @@ int ife_tlv_meta_encode(void *skbdata, u16 attrtype, u16 dlen, const void *dval)
 	u32 *tlv = (u32 *)(skbdata);
 	u16 totlen = nla_total_size(dlen);	/*alignment + hdr */
 	char *dptr = (char *)tlv + NLA_HDRLEN;
-	u32 htlv = attrtype << 16 | dlen;
+	u32 htlv = attrtype << 16 | (dlen + NLA_HDRLEN);
 
 	*tlv = htonl(htlv);
 	memset(dptr, 0, totlen - NLA_HDRLEN);
@@ -653,7 +653,7 @@ static int tcf_ife_decode(struct sk_buff *skb, const struct tc_action *a,
 	struct tcf_ife_info *ife = to_ife(a);
 	int action = ife->tcf_action;
 	struct ifeheadr *ifehdr = (struct ifeheadr *)skb->data;
-	u16 ifehdrln = ifehdr->metalen;
+	int ifehdrln = (int)ifehdr->metalen;
 	struct meta_tlvhdr *tlv = (struct meta_tlvhdr *)(ifehdr->tlv_data);
 
 	spin_lock(&ife->tcf_lock);
-- 
2.4.11
