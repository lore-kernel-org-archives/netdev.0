From: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
Subject: [PATCH]: ipv6_skip_exthdr() may refer invalid memory area
Date: Fri, 20 Feb 2004 14:33:59 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402200534.OAA04081@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
 boundary="--Next_Part(Fri_Feb_20_14:33:59_2004_524)--"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@lists.netfilter.org, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

----Next_Part(Fri_Feb_20_14:33:59_2004_524)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


Hello,

ipv6_skip_exthdr() refer invalid memory area in the case
that packet includes Fragment Header.

please apply this patch.

Regards,

-----------------------------------------------------------------
Yasuyuki KOZAKAI @ USAGI Project <yasuyuki.kozakai@toshiba.co.jp>


----Next_Part(Fri_Feb_20_14:33:59_2004_524)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="linux-2.6.3-skip-exthdr.patch"

diff -Nur linux-2.6.3/net/ipv6/exthdrs.c linux-2.6.3-fixed/net/ipv6/exthdrs.c
--- linux-2.6.3/net/ipv6/exthdrs.c	2004-02-18 12:57:13.000000000 +0900
+++ linux-2.6.3-fixed/net/ipv6/exthdrs.c	2004-02-19 18:04:59.000000000 +0900
@@ -709,8 +709,16 @@
 		if (skb_copy_bits(skb, start, &hdr, sizeof(hdr)))
 			BUG();
 		if (nexthdr == NEXTHDR_FRAGMENT) {
-			struct frag_hdr *fhdr = (struct frag_hdr *) &hdr;
-			if (ntohs(fhdr->frag_off) & ~0x7)
+			unsigned short frag_off;
+			if (skb_copy_bits(skb,
+					  start+offsetof(struct frag_hdr,
+							 frag_off),
+					  &frag_off,
+					  sizeof(frag_off))) {
+				return -1;
+			}
+
+			if (ntohs(frag_off) & ~0x7)
 				break;
 			hdrlen = 8;
 		} else if (nexthdr == NEXTHDR_AUTH)

----Next_Part(Fri_Feb_20_14:33:59_2004_524)----
