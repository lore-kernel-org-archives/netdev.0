From: Jim <jim876@xs4all.nl>
Subject: tap0 device stopped working in 2.6.36 (ok in 2.6.35)
Date: Sat, 23 Oct 2010 14:55:08 +0200
Message-ID: <4CC2DB2C.3060908@xs4all.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: nolan@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-vbr5.xs4all.nl ([194.109.24.25]:4861 "EHLO
	smtp-vbr5.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755065Ab0JWMzM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Oct 2010 08:55:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


My tap0 device stopped working with 2.6.36, seems it couldn't
send any packets anymore (receiving was still fine).

After some checking noticed that apparently link isn't ready:
 modprobe tun
 tunctl -b
 ifconfig tap0 192.168.20.1 up
Gives:
[   26.411932] ADDRCONF(NETDEV_UP): tap0: link is not ready

Bisected it all the way to this commit:

=================

# git bisect good
bee31369ce16fc3898ec9a54161248c9eddb06bc is the first bad commit
commit bee31369ce16fc3898ec9a54161248c9eddb06bc
Author: Nolan Leake <nolan@cumulusnetworks.com>
Date:   Tue Jul 27 13:53:43 2010 +0000

    tun: keep link (carrier) state up to date

    Currently, only ethtool can get accurate link state of a tap device.
    With this patch, IFF_RUNNING and IF_OPER_UP/DOWN are kept up to date as
    well.

    Signed-off-by: Nolan Leake <nolan@cumulusnetworks.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

:040000 040000 6f2464fe2c604079908afc677522bd396b40db9a
0d144f138fe93ffbe3da7ce31951855c60b51510 M      drivers

===================

Apply-ing this patch on top of vanilla 2.6.36 makes the tap device
working again for me (strangely in the function __tun_detach):
--- tun.c.ORIG  2010-10-21 18:08:12.404276662 +0200
+++ tun.c       2010-10-23 14:22:58.056366365 +0200
@@ -163,7 +163,7 @@
 {
        /* Detach from net device */
        netif_tx_lock_bh(tun->dev);
-       netif_carrier_off(tun->dev);
+//     netif_carrier_off(tun->dev);
        tun->tfile = NULL;
        tun->socket.file = NULL;
        netif_tx_unlock_bh(tun->dev);

====
Strangely that's in the function __tun_detach, it appears the functions
do the opposite of what is expected, when deleting the the tap0 device
it becomes ready!?

# tunctl -d tap0
Set 'tap0' nonpersistent
[ 1000.945790] ADDRCONF(NETDEV_CHANGE): tap0: link becomes ready

So to me it seems the netif_carrier_on / netif_carrier_off from the
commit should be reversed ??


_
Jim
