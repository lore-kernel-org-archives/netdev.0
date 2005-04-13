From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPV6_CHECKSUM socket option can corrupt kernel memory
Date: Wed, 13 Apr 2005 09:53:08 +0900 (JST)
Message-ID: <20050413.095308.124546011.yoshfuji@linux-ipv6.org>
References: <OF618A0572.CA254DA0-ON88256FE1.0080DB81-88256FE1.0082220B@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: dlstevens@us.ibm.com, davem@davemloft.net
In-Reply-To: <OF618A0572.CA254DA0-ON88256FE1.0080DB81-88256FE1.0082220B@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <OF618A0572.CA254DA0-ON88256FE1.0080DB81-88256FE1.0082220B@us.ibm.com> (at Tue, 12 Apr 2005 17:41:25 -0600), David Stevens <dlstevens@us.ibm.com> says:

> I don't know if it is possible, after the fix for the second problem, to 
> get an
> skb with nonzero nr_frags in rawv6_push_pending_frames() (maybe with
> corking? or maybe via MSG_MORE?), but this patch includes support for
> non-linear skbs as well as the missing flush on error that caused the 
> problem
> to begin with.

Please geive up the "singed-off" line.
Anyway, how about this?

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

===== net/ipv6/raw.c 1.80 vs edited =====
--- 1.80/net/ipv6/raw.c	2005-03-27 08:04:35 +09:00
+++ edited/net/ipv6/raw.c	2005-04-13 09:49:37 +09:00
@@ -456,7 +456,7 @@
 {
 	struct sk_buff *skb;
 	int err = 0;
-	u16 *csum;
+	u16 csum_buff, *csum;
 	u32 tmp_csum;
 
 	if (!rp->checksum)
@@ -465,12 +465,13 @@
 	if ((skb = skb_peek(&sk->sk_write_queue)) == NULL)
 		goto out;
 
-	if (rp->offset + 1 < len)
-		csum = (u16 *)(skb->h.raw + rp->offset);
-	else {
-		err = -EINVAL;
+	err = -EINVAL;
+	if (rp->offset + 1 >= len)
+		goto out;
+
+	csum = skb_header_pointer(skb, skb->h.raw - skb->data + rp->offset, sizeof(csum_buff), &csum_buff);
+	if (!csum)
 		goto out;
-	}
 
 	/* should be check HW csum miyazawa */
 	if (skb_queue_len(&sk->sk_write_queue) == 1) {

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
Homepage: http://www.yoshifuji.org/~hideaki/
GPG FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
