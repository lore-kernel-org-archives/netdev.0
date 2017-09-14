From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH v2] net: smsc911x: Quieten netif during suspend
Date: Thu, 14 Sep 2017 11:09:54 +0200
Message-ID: <CAMuHMdXev3_a_RY2GRGtj9ck2+FYg0pwdtfMu_v+62J7xaXXnw@mail.gmail.com>
References: <1505324525-9998-1-git-send-email-geert+renesas@glider.be> <16f16af0-383b-9089-93c7-75494ec5031e@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Geert Uytterhoeven <geert+renesas@glider.be>,
        "David S . Miller" <davem@davemloft.net>,
        Steve Glendinning <steve.glendinning@shawell.net>,
        Andrew Lunn <andrew@lunn.ch>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux PM list <linux-pm@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <16f16af0-383b-9089-93c7-75494ec5031e@gmail.com>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

On Thu, Sep 14, 2017 at 1:28 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 09/13/2017 10:42 AM, Geert Uytterhoeven wrote:
>> If the network interface is kept running during suspend, the net core
>> may call net_device_ops.ndo_start_xmit() while the Ethernet device is
>> still suspended, which may lead to a system crash.
>>
>> E.g. on sh73a0/kzm9g and r8a73a4/ape6evm, the external Ethernet chip is
>> driven by a PM controlled clock.  If the Ethernet registers are accessed
>> while the clock is not running, the system will crash with an imprecise
>> external abort.
>>
>> As this is a race condition with a small time window, it is not so easy
>> to trigger at will.  Using pm_test may increase your chances:
>>
>>     # echo 0 > /sys/module/printk/parameters/console_suspend
>>     # echo platform > /sys/power/pm_test
>>     # echo mem > /sys/power/state
>>
>> To fix this, make sure the network interface is quietened during
>> suspend.
>>
>> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>

> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

Thank you!

> You may want to take the opportunity to suspend the PHY device
> (conversely resume it) if WoL is not enabled on this device.

Despite the WoL comment visible in the context below, I believe this driver
doesn't support WoL yet (ethtool_ops.[gs]et_wol() not implemented).

>> --- a/drivers/net/ethernet/smsc/smsc911x.c
>> +++ b/drivers/net/ethernet/smsc/smsc911x.c
>> @@ -2595,6 +2595,11 @@ static int smsc911x_suspend(struct device *dev)
>>       struct net_device *ndev = dev_get_drvdata(dev);
>>       struct smsc911x_data *pdata = netdev_priv(ndev);
>>
>> +     if (netif_running(ndev)) {
>> +             netif_stop_queue(ndev);
>> +             netif_device_detach(ndev);
>> +     }
>> +
>>       /* enable wake on LAN, energy detection and the external PME
>>        * signal. */
>>       smsc911x_reg_write(pdata, PMT_CTRL,

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
