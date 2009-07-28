From: Eric Miao <eric.y.miao@gmail.com>
Subject: Re: [PATCH] pxaficp-ir - remove incorrect net_device_ops
Date: Tue, 28 Jul 2009 11:01:14 +0800
Message-ID: <4A6E69FA.9010903@gmail.com>
References: <200907240257.10906.marek.vasut@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020907040803060505080205"
Cc: linux-arm-kernel@lists.arm.linux.org.uk,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	samuel@sortiz.org, netdev@vger.kernel.org,
	Alexander Beregalov <a.beregalov@gmail.com>
To: Marek Vasut <marek.vasut@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.168]:28983 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751387AbZG1DBZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 23:01:25 -0400
Received: by wf-out-1314.google.com with SMTP id 26so957636wfd.4
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2009 20:01:24 -0700 (PDT)
In-Reply-To: <200907240257.10906.marek.vasut@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020907040803060505080205
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Marek Vasut wrote:
> Hi!
> 
> This patch fixes broken pxaficp-ir. The problem was in incorrect
> net_device_ops being specified which prevented the driver from
> operating. The symptoms were:
>  - failing ifconfig for IrLAN, resulting in
> 	SIOCSIFFLAGS: Cannot assign requested address
>  - irattach working for IrCOMM, but the port stayed disabled
> 
> Moreover this patch corrects missing sysfs device link.
> 
> btw. guys, be honest, when did you last tested pxaficp-ir on real hardware? ;-)
> 

Well, this seems to be brought by the net_device_ops change, which seems
to happen silently without any of us being notified.

OK, netdev and Alex are copied, so that we can look into this issue a bit
deeper:

1. it looks to me that SIOCSIFFLAGS actually returned -EADDRNOTAVAIL, which
   is likely caused by eth_validate_addr, the default eth_addr comes with
   irda should be "00:00:00:00:00:00" if not explicitly specified (kzalloc),
   and this should be the problem, solution ?  Either give a valid address
   to the irda net_device or remove this 'ndo_validate_addr'. And which is
   a correct fix will impact on the .ndo_set_mac_address

2. '.ndo_change_mtu' ? It looks to me that Irda device doesn't care too much
   about the MTU, eth_change_mtu is supposed to work just fine and not to
   cause any side effects, and may just benefit later irda device drivers if
   there is a weird device happens to care about MTU

- eric

Marek's original patch in attachment.

--------------020907040803060505080205
Content-Type: text/x-diff;
 name="0001-pxaficp-ir-remove-incorrect-net_device_ops.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0001-pxaficp-ir-remove-incorrect-net_device_ops.patch"

>From 28b229f0f3f807d775a7e70b96c018eef935a24a Mon Sep 17 00:00:00 2001
From: Marek Vasut <marek.vasut@gmail.com>
Date: Fri, 24 Jul 2009 02:44:02 +0200
Subject: [PATCH] pxaficp-ir - remove incorrect net_device_ops

This patch fixes broken pxaficp-ir. The problem was in incorrect
net_device_ops being specified which prevented the driver from
operating. The symptoms were:
 - failing ifconfig for IrLAN, resulting in
	SIOCSIFFLAGS: Cannot assign requested address
 - irattach working for IrCOMM, but the port stayed disabled

Moreover this patch corrects missing sysfs device link.

Signed-off-by: Marek Vasut <marek.vasut@gmail.com>
---
 drivers/net/irda/pxaficp_ir.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/irda/pxaficp_ir.c b/drivers/net/irda/pxaficp_ir.c
index 4edbdbe..f5b7d83 100644
--- a/drivers/net/irda/pxaficp_ir.c
+++ b/drivers/net/irda/pxaficp_ir.c
@@ -820,9 +820,6 @@ static const struct net_device_ops pxa_irda_netdev_ops = {
 	.ndo_stop		= pxa_irda_stop,
 	.ndo_start_xmit		= pxa_irda_hard_xmit,
 	.ndo_do_ioctl		= pxa_irda_ioctl,
-	.ndo_change_mtu		= eth_change_mtu,
-	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_mac_address	= eth_mac_addr,
 };
 
 static int pxa_irda_probe(struct platform_device *pdev)
@@ -847,6 +844,7 @@ static int pxa_irda_probe(struct platform_device *pdev)
 	if (!dev)
 		goto err_mem_3;
 
+	SET_NETDEV_DEV(dev, &pdev->dev);
 	si = netdev_priv(dev);
 	si->dev = &pdev->dev;
 	si->pdata = pdev->dev.platform_data;
-- 
1.6.3.3


--------------020907040803060505080205--
