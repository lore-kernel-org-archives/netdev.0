From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH 9/9] ethernet: sun8i-emac: add pm_runtime support
Date: Sat, 17 Sep 2016 09:50:21 -0700
Message-ID: <da20e175-f178-3f63-102f-b84f3ecd5913@gmail.com>
References: <1473425117-18645-1-git-send-email-clabbe.montjoie@gmail.com>
 <1473425117-18645-10-git-send-email-clabbe.montjoie@gmail.com>
 <20160912204451.GO9449@lukather> <20160914140304.GA27639@Red>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
        linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: LABBE Corentin <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160914140304.GA27639@Red>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/14/2016 07:03 AM, LABBE Corentin wrote:
> On Mon, Sep 12, 2016 at 10:44:51PM +0200, Maxime Ripard wrote:
>>> +static int __maybe_unused sun8i_emac_resume(struct platform_device *pdev)
>>> +{
>>> +	struct net_device *ndev = platform_get_drvdata(pdev);
>>> +	struct sun8i_emac_priv *priv = netdev_priv(ndev);
>>> +
>>> +	phy_start(ndev->phydev);
>>> +
>>> +	sun8i_emac_start_tx(ndev);
>>> +	sun8i_emac_start_rx(ndev);
>>> +
>>> +	if (netif_running(ndev))
>>> +		netif_device_attach(ndev);
>>> +
>>> +	netif_start_queue(ndev);
>>> +
>>> +	napi_enable(&priv->napi);
>>> +
>>> +	return 0;
>>> +}
>>
>> The main idea behind the runtime PM hooks is that they bring the
>> device to a working state and shuts it down when it's not needed
>> anymore.
>>
> 
> I expect that the first part (all pm_runtime_xxx) of the patch bring that.
> When the interface is not opened:
> cat /sys/devices/platform/soc/1c30000.ethernet/power/runtime_status 
> suspended

If your interface is not open, it should be in a low power state, only
when it gets open (which means it is used) should you make it
functional, that's pretty much the same thing as the runtime PM
reference count usage here.

I don't see a lot of value for using runtime_pm_* hooks here except
calling into the existing suspend/resume functions that you have defined
already, but then again, the code should be modular enough already in
the driver.

Runtime PM for network devices cannot be used as efficiently as you
would with any kind of host-initiated bus/controller because your device
needs to be able to receive packets without the host's ability to wake
up the device to receive packets, so, with the exception of MDIO (which
is host initiated), everything else besides except packet transmission
(then again, I would not want to wait N ms to bring the interface in a
state where it can now transmit packets, that's terrible for latency) is
pretty much impossible to fully suspend due to its asynchronous nature.
-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
