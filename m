From: Fan Du <fan.du@windriver.com>
Subject: [PATCH net-next 3/3] xfrm: Restrict "level use" for IPComp configuration
Date: Thu, 28 Nov 2013 10:52:41 +0800
Message-ID: <1385607161-27597-4-git-send-email-fan.du@windriver.com>
References: <1385607161-27597-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:62467 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758668Ab3K1Cwv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Nov 2013 21:52:51 -0500
In-Reply-To: <1385607161-27597-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quote from RFC3173:
2.2. Non-Expansion Policy

   If the total size of a compressed payload and the IPComp header, as
   defined in section 3, is not smaller than the size of the original
   payload, the IP datagram MUST be sent in the original non-compressed
   form.  To clarify: If an IP datagram is sent non-compressed, no

   IPComp header is added to the datagram.  This policy ensures saving
   the decompression processing cycles and avoiding incurring IP
   datagram fragmentation when the expanded datagram is larger than the
   MTU.

   Small IP datagrams are likely to expand as a result of compression.
   Therefore, a numeric threshold should be applied before compression,
   where IP datagrams of size smaller than the threshold are sent in the
   original form without attempting compression.  The numeric threshold
   is implementation dependent.

Current IPComp implementation is indeed by the book, whileas in practice
when sending non-compressed packet to the peer(whether or not packet len
is smaller than the threshold or the compressed len is large than orignal
packet len), the packet is dropped when checking the policy as this packet
matches the selector but not coming from any XFRM layer, i.e., with no
security path. Such naked packet will not evently make it to upper layer 4.
The result is much more wired to the user when ping peer with different
palyload lenght.

Fixing this by chanlledging IPComp level against "level use" to cure this
problem.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 net/key/af_key.c     |    6 ++++++
 net/xfrm/xfrm_user.c |    4 ++++
 2 files changed, 10 insertions(+)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 911ef03..d37a2c1 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1895,6 +1895,12 @@ parse_ipsecrequest(struct xfrm_policy *xp, struct sadb_x_ipsecrequest *rq)
 			return -ENOBUFS;
 	}
 
+	/* IPComp requires level use option to accomodate both compressed
+	 * and non-compressed packet when checking policy.
+	 */
+	if ((t->id.proto == IPPROTO_COMP) && (t->optional == 0))
+		return -EINVAL;
+
 	/* addresses present only in tunnel mode */
 	if (t->mode == XFRM_MODE_TUNNEL) {
 		u8 *sa = (u8 *) (rq + 1);
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 52efe71..d7216ea 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1293,6 +1293,10 @@ static int validate_tmpl(int nr, struct xfrm_user_tmpl *ut, u16 family)
 		default:
 			return -EINVAL;
 		}
+
+		/* Refuse any IPComp conf that missing "level use" */
+		if ((ut[i].id.proto == IPPROTO_COMP) && (ut[i].optional == 0))
+			return -EINVAL;
 	}
 
 	return 0;
-- 
1.7.9.5
