From: Eldad Zack <eldad@fogrefinery.com>
Subject: [PATCH] net/ipv6/exthdrs.c: Strict PadN option checking
Date: Thu, 12 Apr 2012 23:31:59 +0200
Message-ID: <1334266320-12297-1-git-send-email-eldad@fogrefinery.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eldad Zack <eldad@fogrefinery.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Added strict checking of PadN, as PadN can be used to increase header
size and thus push the protocol header into the 2nd fragment.

PadN is used to align the options within the Hop-by-Hop or
Destination Options header to 64-bit boundaries. The maximum valid
size is thus 7 bytes.
RFC 4942 recommends to actively check the "payload" itself and
ensure that it contains only zeroes.

See also RFC 4942 section 2.1.9.5.

Signed-off-by: Eldad Zack <eldad@fogrefinery.com>
---
 net/ipv6/exthdrs.c |   14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index c486b8e..63f6e87 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -153,6 +153,7 @@ static int ip6_parse_tlv(struct tlvtype_proc *procs, struct sk_buff *skb)
 
 	while (len > 0) {
 		int optlen = nh[off + 1] + 2;
+		int i;
 
 		switch (nh[off]) {
 		case IPV6_TLV_PAD0:
@@ -160,6 +161,19 @@ static int ip6_parse_tlv(struct tlvtype_proc *procs, struct sk_buff *skb)
 			break;
 
 		case IPV6_TLV_PADN:
+			/* RFC 2460 states that the purpose of PadN is
+			   to align the containing header to multiples
+			   of 8. 7 is therefore the highest valid value.
+			   See also RFC 4942, Section 2.1.9.5.*/
+			if (optlen > 7)
+				goto bad;
+			/* RFC 4942 recommends receiving hosts to
+			   actively check PadN payload to contain
+			   only zeroes. */
+			for (i = 2; i < optlen; i++) {
+				if (nh[off + i] != 0)
+					goto bad;
+			}
 			break;
 
 		default: /* Other TLV code so scan list */
-- 
1.7.9.5
