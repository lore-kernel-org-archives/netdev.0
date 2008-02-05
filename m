From: akpm@linux-foundation.org
Subject: [patch 2/2] tun: impossible to deassert IFF_ONE_QUEUE or IFF_NO_PI
Date: Mon, 04 Feb 2008 23:45:21 -0800
Message-ID: <200802050745.m157j2vh010306@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	nwfilardo@gmail.com, jeff@garzik.org, maxk@qualcomm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:36839 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751136AbYBEHpU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 02:45:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Nathaniel Filardo" <nwfilardo@gmail.com>

Taken from http://bugzilla.kernel.org/show_bug.cgi?id=9806

The TUN/TAP driver only permits one-way transitions of IFF_NO_PI or
IFF_ONE_QUEUE during the lifetime of a tap/tun interface.  Note that
tun_set_iff contains

 541         if (ifr->ifr_flags & IFF_NO_PI)
 542                 tun->flags |= TUN_NO_PI;
 543 
 544         if (ifr->ifr_flags & IFF_ONE_QUEUE)
 545                 tun->flags |= TUN_ONE_QUEUE;

This is easily fixed by adding else branches which clear these bits.

Steps to reproduce:

This is easily reproduced by setting an interface persistant using tunctl then
attempting to open it as IFF_TAP or IFF_TUN, without asserting the IFF_NO_PI
flag.  The ioctl() will succeed and the ifr.flags word is not modified, but the
interface remains in IFF_NO_PI mode (as it was set by tunctl).

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Jeff Garzik <jeff@garzik.org>
Acked-by: Maxim Krasnyansky <maxk@qualcomm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/tun.c |    4 ++++
 1 file changed, 4 insertions(+)

diff -puN drivers/net/tun.c~tun-dev-impossible-to-deassert-iff_one_queue-or-iff_no_pi drivers/net/tun.c
--- a/drivers/net/tun.c~tun-dev-impossible-to-deassert-iff_one_queue-or-iff_no_pi
+++ a/drivers/net/tun.c
@@ -529,9 +529,13 @@ static int tun_set_iff(struct file *file
 
 	if (ifr->ifr_flags & IFF_NO_PI)
 		tun->flags |= TUN_NO_PI;
+	else
+		tun->flags &= ~TUN_NO_PI;
 
 	if (ifr->ifr_flags & IFF_ONE_QUEUE)
 		tun->flags |= TUN_ONE_QUEUE;
+	else
+		tun->flags &= ~TUN_ONE_QUEUE;
 
 	file->private_data = tun;
 	tun->attached = 1;
_
