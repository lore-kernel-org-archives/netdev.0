From: =?ISO-8859-1?Q?Mart=EDn?= Ferrari <martin.ferrari@gmail.com>
Subject: [patch] make real promisc status visible
Date: Sat, 19 May 2007 08:49:35 -0300
Message-ID: <1179575375.3557.47.camel@abraxas.dyn-o-saur.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Os7WYcV2SeVaXjDwkmkx"
Cc: 222676@bugs.debian.org, dviano@damianv.com.ar
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.234]:9600 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757444AbXESLtt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2007 07:49:49 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1161237wxd
        for <netdev@vger.kernel.org>; Sat, 19 May 2007 04:49:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Os7WYcV2SeVaXjDwkmkx
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

Some weeks ago, I posted [0] asking for help about current handling of
promisc mode. I didn't have any answer but I kept researching on this.

I found that the new mechanism for using promisc mode (PACKET_{ADD|
REMOVE}_MEMBERSHIP) modify the dev->promiscuity counter and set the
IFF_PROMISC bit in dev->flags if that counter is over zero. 

To keep backward compatibility, an additional field was added to the
device structure: gflags, which is what is seen when issuing ifconfig or
ip link show. If the user tries to modify this, the promiscuity counter
is incremented or decremented, without interfering with processes using
the other method.

I also found that dev->promiscuity is not accesible from anywhere, nor
is the IFF_PROMISC bit from dev->flags, as it's masked out in
dev_get_flags() and dev-gflags is shown in its place.

I propose the following change: instead of masking out dev->flags'
IFF_PROMISC and showing only dev->gflags', ORing the both bits, so the
actual state is shown. I think this is the most unobtrusive way of
fixing this; and the only side effect would be that you will see that
the interface is in promisc mode but you won't be able to disable it
from ifconfig, while something like tcpdump is running.

ip is affected by this, as it checks the current status before trying to
change that. But that's trivially fixable. ifconfig is not affected.

In the patch, I do the same for IFF_ALLMULTI which has the same issue.

Please, I'd like to know your opinions on this. 

[0]: http://lists.openwall.net/netdev/2007/05/01/63



-- 
Martín Ferrari <martin.ferrari@gmail.com>

--=-Os7WYcV2SeVaXjDwkmkx
Content-Disposition: attachment; filename=dev.c.patch
Content-Type: text/x-patch; name=dev.c.patch; charset=UTF-8
Content-Transfer-Encoding: 7bit

--- net/core/dev.c.orig	2007-05-19 07:06:34.000000000 -0300
+++ net/core/dev.c	2007-05-19 07:08:06.000000000 -0300
@@ -2357,9 +2357,7 @@
 {
 	unsigned flags;
 
-	flags = (dev->flags & ~(IFF_PROMISC |
-				IFF_ALLMULTI |
-				IFF_RUNNING |
+	flags = (dev->flags & ~(IFF_RUNNING |
 				IFF_LOWER_UP |
 				IFF_DORMANT)) |
 		(dev->gflags & (IFF_PROMISC |

--=-Os7WYcV2SeVaXjDwkmkx--

