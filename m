From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: IPv6 oops on ifup in latest BK
Date: Tue, 24 Aug 2004 17:22:07 +0900 (JST)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040824.172207.109934952.yoshfuji@linux-ipv6.org>
References: <412ADB20.5000901@pobox.com>
	<20040823235123.71f18c04.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
	yoshfuji@linux-ipv6.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S266758AbUHXIVh@vger.kernel.org>
To: davem@redhat.com, jgarzik@pobox.com
In-Reply-To: <20040823235123.71f18c04.davem@redhat.com>
List-Id: netdev.vger.kernel.org

In article <20040823235123.71f18c04.davem@redhat.com> (at Mon, 23 Aug 2004 23:51:23 -0700), "David S. Miller" <davem@redhat.com> says:

> > Attached minicom.cap.txt gives the ksymoops output and dmesg output. 
> > Appears to die in ipv6_get_hoplimit.
> 
> Yoshifuji-san, it is rt6i_dev changes.  The problem is that
> ipv6_get_hoplimit() gets called with NULL dev.
:
> It is this piece of code in ip6_route_add():
> 
> 		if (dev && dev != &loopback_dev) {
> 
> It does not handle the case where dev == NULL correctly.
> Original code did do the right thing:
> 
> 		if (dev)
> 			dev_put(dev);
> 		dev = &loopback_dev;
> 		dev_hold(dev);

Good catch and spotting.  Please try this patch.
Thank you.

===== net/ipv6/route.c 1.88 vs edited =====
--- 1.88/net/ipv6/route.c	2004-08-17 11:25:06 +09:00
+++ edited/net/ipv6/route.c	2004-08-24 17:09:10 +09:00
@@ -820,9 +820,12 @@
 	 */
 	if ((rtmsg->rtmsg_flags&RTF_REJECT) ||
 	    (dev && (dev->flags&IFF_LOOPBACK) && !(addr_type&IPV6_ADDR_LOOPBACK))) {
-		if (dev && dev != &loopback_dev) {
-			dev_put(dev);
-			in6_dev_put(idev);
+		/* hold loopback dev/idev if we haven't done so. */
+		if (dev != &loopback_dev) {
+			if (dev) {
+				dev_put(dev);
+				in6_dev_put(idev);
+			}
 			dev = &loopback_dev;
 			dev_hold(dev);
 			idev = in6_dev_get(dev);


-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
