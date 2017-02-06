From: Jon Mason <jon.mason@broadcom.com>
Subject: Re: [PATCH 3/3] net: ethernet: bgmac: driver power manangement
Date: Mon, 6 Feb 2017 11:30:18 -0500
Message-ID: <CAC3K-4rMxYgLEN3Y2Cq-+Otm-eZfY5jZJ7yEMwA_H_g3bEWYbw@mail.gmail.com>
References: <1486157970-6315-1-git-send-email-jon.mason@broadcom.com>
 <1486157970-6315-4-git-send-email-jon.mason@broadcom.com> <74efc661-f07d-93d5-613d-7f563c0fe732@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <rafal@milecki.pl>,
        BCM Kernel Feedback <bcm-kernel-feedback-list@broadcom.com>,
        Network Development <netdev@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>,
        Joey Zhong <zhongx@broadcom.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <74efc661-f07d-93d5-613d-7f563c0fe732@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 3, 2017 at 9:16 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 02/03/2017 01:39 PM, Jon Mason wrote:
>> From: Joey Zhong <zhongx@broadcom.com>
>>
>> Implements suspend/resume, external phy 54810 is assumed
>> to remain powered up during deep-sleep for wake-on-lane.
>
> s/wake-on-lane/Wake-on-LAN, are you positive phy_stop() is not
> suspending the PHY and issuing BMCR_PWRDOWN write?
>
> This also seems incomplete in that, if the device is really configured
> for Wake-on-LAN (through ethtool) you should call
> device_set_wakeup_capable() and then check for device_may_wakeup()
> during suspend or resume to know which part of the suspend/resume
> portion should be done. You could refer to bcmgenet for an example.

After some internal discussion, WOL is not supported by our SVK.  So,
we have no way of testing it.  Given this limitation, I'm removing the
WOL comment until such time as we can actually test the logic.

>>
>> +int bgmac_enet_suspend(struct bgmac *bgmac)
>> +{
>> +     netdev_info(bgmac->net_dev, "Suspending\n");
>
> remove that message
>
>> +
>> +     if (netif_running(bgmac->net_dev)) {
>> +             netif_stop_queue(bgmac->net_dev);
>> +
>> +             napi_disable(&bgmac->napi);
>> +
>> +             netif_tx_lock(bgmac->net_dev);
>> +             netif_device_detach(bgmac->net_dev);
>> +             netif_tx_unlock(bgmac->net_dev);
>> +
>> +             bgmac_chip_intrs_off(bgmac);
>> +             bgmac_chip_reset(bgmac);
>> +             bgmac_dma_cleanup(bgmac);
>> +     }
>
> Can you change the indentation to test for netiff_running() first and
> return 0 in that case?
>
>> +
>> +     phy_stop(bgmac->net_dev->phydev);
>> +
>> +     return 0;
>> +}
>> +EXPORT_SYMBOL_GPL(bgmac_enet_suspend);
>> +
>> +int bgmac_enet_resume(struct bgmac *bgmac)
>> +{
>> +     int rc;
>> +
>> +     netdev_info(bgmac->net_dev, "Resuming\n");
>
> Same here, this needs to be removed.

Will do this and above.

Thanks,
Jon

>
>> +
>> +     phy_start(bgmac->net_dev->phydev);
>> +
>> +     if (netif_running(bgmac->net_dev)) {
>> +             rc = bgmac_dma_init(bgmac);
>> +             if (rc)
>> +                     return rc;
>> +
>> +             bgmac_chip_init(bgmac);
>> +
>> +             napi_enable(&bgmac->napi);
>> +
>> +             netif_tx_lock(bgmac->net_dev);
>> +             netif_device_attach(bgmac->net_dev);
>> +             netif_tx_unlock(bgmac->net_dev);
>> +
>> +             netif_start_queue(bgmac->net_dev);
>> +     }
> --
> Florian
