From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH 1/1 v2 net] net: fec: fix kernel oops when plug/unplug
 cable many times
Date: Thu, 2 May 2013 10:08:10 +0800
Message-ID: <CAHrpEqTPE9Defo7gDdUnM8B40XVKd13=RE9qrU=to4AtS4BQWg@mail.gmail.com>
References: <1367118508-12340-1-git-send-email-Frank.Li@freescale.com>
	<1367243240.4100.14.camel@weser.hi.pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Frank Li <Frank.Li@freescale.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Robert Schwebel <r.schwebel@pengutronix.de>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Fabio Estevam <festevam@gmail.com>,
	Shawn Guo <shawn.guo@linaro.org>
To: Lucas Stach <l.stach@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:55157 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751790Ab3EBCIM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 22:08:12 -0400
Received: by mail-we0-f174.google.com with SMTP id z2so84194wey.19
        for <netdev@vger.kernel.org>; Wed, 01 May 2013 19:08:10 -0700 (PDT)
In-Reply-To: <1367243240.4100.14.camel@weser.hi.pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/4/29 Lucas Stach <l.stach@pengutronix.de>:
> Hi Frank,
>
> Am Sonntag, den 28.04.2013, 11:08 +0800 schrieb Frank Li:
>> reproduce steps
>>  1. flood ping from other machine
>>       ping -f -s 41000 IP
>>  2. run below script
>>     while [ 1 ]; do ethtool -s eth0 autoneg off;
>>     sleep 3;ethtool -s eth0 autoneg on; sleep 4; done;
>>
>> You can see oops in one hour.
>>
>> The reason is fec_restart clear BD but NAPI may use it.
>> The solution is disable NAPI and stop xmit when reset BD.
>> disable NAPI may sleep, so fec_restart can't be call in
>> atomic context.
>>
>> Signed-off-by: Frank Li <Frank.Li@freescale.com>
>> ---
>>
>> Change from V1 to V2
>>       Add netif_tx_lock(ndev) to avoid xmit runing when reset hardware
>>
>>  drivers/net/ethernet/freescale/fec.c |   41 +++++++++++++++++++++++++++++-----
>>  drivers/net/ethernet/freescale/fec.h |    3 +-
>>  2 files changed, 37 insertions(+), 7 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
>> index 73195f6..d140b50 100644
>> --- a/drivers/net/ethernet/freescale/fec.c
>> +++ b/drivers/net/ethernet/freescale/fec.c
>> @@ -403,6 +403,12 @@ fec_restart(struct net_device *ndev, int duplex)
>>       const struct platform_device_id *id_entry =
>>                               platform_get_device_id(fep->pdev);
>>       int i;
>> +     if (netif_running(ndev)) {
>> +             napi_disable(&fep->napi);
>> +             netif_stop_queue(ndev);
>> +             netif_tx_lock(ndev);
>> +     }
>> +
>>       u32 temp_mac[2];
>>       u32 rcntl = OPT_FRAME_SIZE | 0x04;
>>       u32 ecntl = 0x2; /* ETHEREN */
>> @@ -559,6 +565,12 @@ fec_restart(struct net_device *ndev, int duplex)
>>
>>       /* Enable interrupts we wish to service */
>>       writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
>> +
>> +     if (netif_running(ndev)) {
>> +             napi_enable(&fep->napi);
>> +             netif_wake_queue(ndev);
>> +             netif_tx_unlock(ndev);
>> +     }
>>  }
>>
>>  static void
>> @@ -598,8 +610,20 @@ fec_timeout(struct net_device *ndev)
>>
>>       ndev->stats.tx_errors++;
>>
>> -     fec_restart(ndev, fep->full_duplex);
>> -     netif_wake_queue(ndev);
>> +     fep->timeout = 1;
>> +     schedule_delayed_work(&fep->delay_work, msecs_to_jiffies(1));
>> +}
>
> Why are you using delayed work here? I don't see a reason why we would
> like to defer execution here. Just use schedule_work().
>

There are a silicon bug, which need delay work to workaround it.
So we can share a delay work in future.

>> +
>> +static void fec_enet_work(struct work_struct *work)
>> +{
>> +     struct fec_enet_private *fep =
>> +             container_of(work, struct fec_enet_private, delay_work.work);
>> +
>> +     if (fep->timeout) {
>> +             fep->timeout = 0;
>> +             fec_restart(fep->netdev, fep->full_duplex);
>> +             netif_wake_queue(fep->netdev);
>> +     }
>>  }
>>
>>  static void
>> @@ -996,9 +1020,6 @@ static void fec_enet_adjust_link(struct net_device *ndev)
>>                       status_change = 1;
>>               }
>>
>> -             /* if any of the above changed restart the FEC */
>> -             if (status_change)
>> -                     fec_restart(ndev, phy_dev->duplex);
>>       } else {
>>               if (fep->link) {
>>                       fec_stop(ndev);
>> @@ -1010,8 +1031,14 @@ static void fec_enet_adjust_link(struct net_device *ndev)
>>  spin_unlock:
>>       spin_unlock_irqrestore(&fep->hw_lock, flags);
>>
>> -     if (status_change)
>> +     if (status_change) {
>> +             /* if any of the above changed restart the FEC,
>> +              * fec_restart may sleep. can't call it in spin_lock
>> +              */
>> +             if (phy_dev->link)
>> +                     fec_restart(ndev, phy_dev->duplex);
>>               phy_print_status(phy_dev);
>> +     }
>>  }
>
> Don't complicate things unnecessarily. Just put a patch in front of this
> one to remove the spinlock. As you removed it already from the RX and TX
> paths it doesn't protect anything anymore.
>
>>
>>  static int fec_enet_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
>> @@ -1882,6 +1909,7 @@ fec_probe(struct platform_device *pdev)
>>       if (ret)
>>               goto failed_register;
>>
>> +     INIT_DELAYED_WORK(&fep->delay_work, fec_enet_work);
>>       return 0;
>>
>>  failed_register:
>> @@ -1918,6 +1946,7 @@ fec_drv_remove(struct platform_device *pdev)
>>       struct resource *r;
>>       int i;
>>
>> +     cancel_delayed_work_sync(&fep->delay_work);
>>       unregister_netdev(ndev);
>>       fec_enet_mii_remove(fep);
>>       del_timer_sync(&fep->time_keep);
>> diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
>> index eb43729..a367b21 100644
>> --- a/drivers/net/ethernet/freescale/fec.h
>> +++ b/drivers/net/ethernet/freescale/fec.h
>> @@ -260,7 +260,8 @@ struct fec_enet_private {
>>       int hwts_rx_en;
>>       int hwts_tx_en;
>>       struct timer_list time_keep;
>> -
>> +     struct delayed_work delay_work;
>> +     int timeout;
>>  };
>>
>>  void fec_ptp_init(struct net_device *ndev, struct platform_device *pdev);
>
> --
> Pengutronix e.K.                           | Lucas Stach                 |
> Industrial Linux Solutions                 | http://www.pengutronix.de/  |
> Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-5076 |
> Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
>
