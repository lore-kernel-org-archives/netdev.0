From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH resend 1/3] Revert "net: fec: fix missing napi_disable call"
Date: Sat, 27 Apr 2013 18:26:57 +0800
Message-ID: <CAHrpEqSi+caO5gSo1BZRGqytxhCOs-OuyjiCaG+7fnsnFBj77g@mail.gmail.com>
References: <1366966330-5181-1-git-send-email-l.stach@pengutronix.de>
	<CAHrpEqQLkjCOq0doaM0zNMkgjNkE_pOLxjoFJWNPuQ6CRHCbBw@mail.gmail.com>
	<20130426134415.GS1366@pengutronix.de>
	<20130426.143309.1011152996477262852.davem@davemloft.net>
	<20130427090545.GY1366@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Lucas Stach <l.stach@pengutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	Fabio Estevam <festevam@gmail.com>,
	Shawn Guo <shawn.guo@linaro.org>
To: Robert Schwebel <r.schwebel@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:60273 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752319Ab3D0K07 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Apr 2013 06:26:59 -0400
Received: by mail-wi0-f176.google.com with SMTP id hj19so1379792wib.3
        for <netdev@vger.kernel.org>; Sat, 27 Apr 2013 03:26:58 -0700 (PDT)
In-Reply-To: <20130427090545.GY1366@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/4/27 Robert Schwebel <r.schwebel@pengutronix.de>:
> On Fri, Apr 26, 2013 at 02:33:09PM -0400, David Miller wrote:
>> From: Robert Schwebel <r.schwebel@pengutronix.de>
>> Date: Fri, 26 Apr 2013 15:44:15 +0200
>>
>> > Seriously - it's friday, and 3.9 is expected to come out this
>> > weekend.
>>
>> Seriously, it took you how long to notice the breakage and report
>> it in sufficient detail for the author to make an attempt at a fix?
>>
>> I thnk Frank's request is reasonable given the circumstances, please
>> work closely with him on the fix.
>
> The FEC driver has worked fine in 3.8.x.
>
> Frank's patches for the 3.9 cycle...
>
> - remove locking in a way that memory is freed which is in use

The purpose of remove lock is that fix dead lock.
It is true I miss a execute path to reset BD descript.
But the possibility is very low.

You report this problem without detail reproduce steps.

> - break the driver, up to a point where the kernel oopses when the link
>   goes away

run script while [ 1 ]; do ethtool -s eth0 autoneg off;sleep 3;ethtool
-s eth0 autoneg on; sleep 4; done;

I just capture one oops during 1 hours.
I am try to fix this issue without add back lock.

I plan use below way to fix this issue.  I am running my stress test.
if you have time, you can run it at your sit.

diff --git a/drivers/net/ethernet/freescale/fec.c
b/drivers/net/ethernet/freescale/fe
index 73195f6..c945bb7 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -403,6 +403,11 @@ fec_restart(struct net_device *ndev, int duplex)
        const struct platform_device_id *id_entry =
                                platform_get_device_id(fep->pdev);
        int i;
+       if (netif_running(ndev)) {
+               napi_disable(&fep->napi);
+               netif_stop_queue(ndev);
+       }
+
        u32 temp_mac[2];
        u32 rcntl = OPT_FRAME_SIZE | 0x04;
        u32 ecntl = 0x2; /* ETHEREN */
@@ -559,6 +564,11 @@ fec_restart(struct net_device *ndev, int duplex)

        /* Enable interrupts we wish to service */
        writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
+
+       if (netif_running(ndev)) {
+               napi_enable(&fep->napi);
+               netif_wake_queue(ndev);
+       }
 }


> - mix up different changes (queue handling) and should have been split up
>   into separate patches
>
> Unfortunately, the breakage happens only on multicore (MX6Q) and if you
> change the link status; that's probably the reason why it hasn't been
> noticed earlier.
>
> We have really tried to find a "quick fix which does it right", but it
> has turned out that this isn't possible in such a short time, because it
> is more complex than just re-adding locks. We feel that the results of
> last week's activities are not good enough that they could be merged
> without further breakage.
>
> Please consider to merge the reverts. Otherwhise FEC will be broken in 3.9.
>
> Of course, we can help with a real solution, but please after 3.9.final.
>
> Thanks,
> Robert
> --
> Pengutronix e.K.                           |                             |
> Industrial Linux Solutions                 | http://www.pengutronix.de/  |
> Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
> Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
