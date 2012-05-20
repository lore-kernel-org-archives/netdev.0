From: Eldad Zack <eldad@fogrefinery.com>
Subject: [PATCH] ipv6/exthdrs: strict Pad1 and PadN check
Date: Sun, 20 May 2012 13:59:33 +0200
Message-ID: <1337515173-23648-1-git-send-email-eldad@fogrefinery.com>
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

The following tightens the padding check from commit
c1412fce7eccae62b4de22494f6ab3ff8a90c0c6 :

* Take into account combinations of consecutive Pad1 and PadN.

* Catch the corner case of when only padding is present in the
  header, when the extention header length is 0 (i.e., 8 bytes).
  In this case, the header would have exactly 6 bytes of padding:

+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
:  Next Header  : Hdr Ext Len=0 :                               :
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+                               +
:                        Padding (Pad1 or PadN)                 :
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

Signed-off-by: Eldad Zack <eldad@fogrefinery.com>
---
 net/ipv6/exthdrs.c |   15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 50ec95f..6447dc4 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -144,6 +144,7 @@ static bool ip6_parse_tlv(const struct tlvtype_proc *procs, struct sk_buff *skb)
 	const unsigned char *nh = skb_network_header(skb);
 	int off = skb_network_header_len(skb);
 	int len = (skb_transport_header(skb)[1] + 1) << 3;
+	int padlen = 0;
 
 	if (skb_transport_offset(skb) + len > skb_headlen(skb))
 		goto bad;
@@ -158,6 +159,9 @@ static bool ip6_parse_tlv(const struct tlvtype_proc *procs, struct sk_buff *skb)
 		switch (nh[off]) {
 		case IPV6_TLV_PAD1:
 			optlen = 1;
+			padlen++;
+			if (padlen > 7)
+				goto bad;
 			break;
 
 		case IPV6_TLV_PADN:
@@ -166,7 +170,8 @@ static bool ip6_parse_tlv(const struct tlvtype_proc *procs, struct sk_buff *skb)
 			 * of 8. 7 is therefore the highest valid value.
 			 * See also RFC 4942, Section 2.1.9.5.
 			 */
-			if (optlen > 7)
+			padlen += optlen;
+			if (padlen > 7)
 				goto bad;
 			/* RFC 4942 recommends receiving hosts to
 			 * actively check PadN payload to contain
@@ -195,11 +200,19 @@ static bool ip6_parse_tlv(const struct tlvtype_proc *procs, struct sk_buff *skb)
 				if (ip6_tlvopt_unknown(skb, off) == 0)
 					return false;
 			}
+			padlen = 0;
 			break;
 		}
 		off += optlen;
 		len -= optlen;
 	}
+	/* This case will not be caught by above check since its padding
+	 * length is smaller than 7:
+	 * 1 byte NH + 1 byte Length + 6 bytes Padding
+	 */
+	if ((padlen == 6) && ((off - skb_network_header_len(skb)) == 8))
+		goto bad;
+
 	if (len == 0)
 		return true;
 bad:
-- 
1.7.10
