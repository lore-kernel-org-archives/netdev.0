From: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
Subject: Re: [PATCH]: ipv6_skip_exthdr() may refer invalid memory area
Date: Thu, 26 Feb 2004 12:48:31 +0900 (JST)
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <200402260349.MAA22692@toshiba.co.jp>
References: <200402200534.OAA04081@toshiba.co.jp>
	<20040220093027.2c03f48c.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
 boundary="--Next_Part(Thu_Feb_26_12:48:31_2004_711)--"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org,
        usagi-core@linux-ipv6.org
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: davem@redhat.com
In-Reply-To: <20040220093027.2c03f48c.davem@redhat.com>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

----Next_Part(Thu_Feb_26_12:48:31_2004_711)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


Hi,

This patch is for linux 2.4.26-pre1 .

-----------------------------------------------------------------
Yasuyuki KOZAKAI @ USAGI Project <yasuyuki.kozakai@toshiba.co.jp>


From: "David S. Miller" <davem@redhat.com>
Date: Fri, 20 Feb 2004 09:30:27 -0800

> On Fri, 20 Feb 2004 14:33:59 +0900 (JST)
> Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp> wrote:
> 
> > ipv6_skip_exthdr() refer invalid memory area in the case
> > that packet includes Fragment Header.
> > 
> > please apply this patch.
> 
> Applied, thank you Yasuyuki-san.

----Next_Part(Thu_Feb_26_12:48:31_2004_711)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="linux-2.4.26-pre1-skip-exthdr.patch"

diff -Nur linux-2.4.26-pre1/net/ipv6/exthdrs.c linux-2.4.26-pre1-fixed/net/ipv6/exthdrs.c
--- linux-2.4.26-pre1/net/ipv6/exthdrs.c	2003-08-25 20:44:44.000000000 +0900
+++ linux-2.4.26-pre1-fixed/net/ipv6/exthdrs.c	2004-02-26 10:44:21.000000000 +0900
@@ -798,8 +798,16 @@
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

----Next_Part(Thu_Feb_26_12:48:31_2004_711)----
