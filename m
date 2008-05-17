From: Tobias Diedrich <ranma+kernel@tdiedrich.de>
Subject: hibernate event order question
Date: Sat, 17 May 2008 19:50:46 +0200
Message-ID: <20080517175046.GA9032__4715.59615475616$1211050712$gmane$org@yamamaya.is-a-geek.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
To: linux-netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yumi.tdiedrich.de ([85.10.210.183]:59455 "EHLO mx.tdiedrich.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752005AbYEQS5F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 May 2008 14:57:05 -0400
Received: from nukunuku.yamamaya.is-a-geek.org (nukunuku-vpn [192.168.8.240])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(Client CN "nukunuku.yamamaya.is-a-geek.org", Issuer "Tobias Diedrich CA" (verified OK))
	by mx.tdiedrich.de (Postfix) with ESMTP id F2A8A500E0
	for <netdev@vger.kernel.org>; Sat, 17 May 2008 20:29:17 +0200 (CEST)
Received: from melchior.yamamaya.is-a-geek.org (melchior.yamamaya.is-a-geek.org [IPv6:fec0:c0a8:800::f1])
	by nukunuku.yamamaya.is-a-geek.org (Postfix) with ESMTP id 9C5D5C804B
	for <netdev@vger.kernel.org>; Sat, 17 May 2008 20:28:36 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

for some time now I had the problem that after a suspend to disk
network connectivitiy was down and also wake-on-lan would not work.

First a bit of information, for the real question please see (*)
below.

Now I just found the ethtool -d (register dump) option
and decided I want to try to debug this long-standing bug:
http://bugzilla.kernel.org/show_bug.cgi?id=8381

I already found out why network connectivity is down after resume:

The interfaces eth0 and eth1 are bridged into br0.
The bridging code sets the interfaces into promiscous mode, but this
is not properly restored after resume.
This bug is easily fixable by calling nv_set_multicast(dev) either
from within nv_open() or after nv_open() in nv_resume().

The second problem (does not wol after s2disk) is still unsolved
though.  However I have found that wake-on-lan works fine if I
"rmmod forcedeth" before suspending.  This is even a usable
workaround for me, since the bridge device stays configured and I
just have to reload forcedeth and readd the interfaces to the bridge
after resume.

(*)
Now for my question:
AFAICS the ordering of events is as follows:
1) User reqests hibernate
2) Tasks are frozen
3) Device suspend callbacks get called
4) Device resume callbacks get called
5) Memory image is written to disk

Now, the problem I see with this is that while step 3) prepares the
device for suspend (and wake-on-lan), step 4) may undo some of this
preparation.

In my case, I think the fix for the first bug (promiscous mode does
not get restored on resume) breaks wake-on-lan (since the new value
of NvRegPacketFilterFlags may be incompatible with wake-on-lan).

Shouldn't there be a 'prepare for poweroff'-callback, which gets called
before the system is powered off for real?

--- linux-2.6.26-rc2/drivers/net/forcedeth.c	2008-05-17 14:22:06.000000000 +0200
+++ linux-2.6.26-rc2/drivers/net/forcedeth.c	2008-05-17 19:48:56.000000000 +0200
@@ -5823,6 +5823,7 @@
 	writel(txreg, base + NvRegTransmitPoll);
 
 	rc = nv_open(dev);
+	nv_set_multicast(dev);
 out:
 	return rc;
 }

-- 
Tobias						PGP: http://9ac7e0bc.uguu.de
このメールは十割再利用されたビットで作られています。
