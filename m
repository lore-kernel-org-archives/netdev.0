From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 0/2] net: Fix crashes due to activity during suspend
Date: Wed, 23 Aug 2017 13:45:57 +0200
Message-ID: <CAMuHMdVMuW+5UQc3Tg5bWkix_PLEaxsoGA6sgSdVz0fV6UsO6Q@mail.gmail.com>
References: <1503427046-17618-1-git-send-email-geert+renesas@glider.be> <757f672b-d3cf-9189-0533-cb45e325c6b8@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Geert Uytterhoeven <geert+renesas@glider.be>,
        "David S . Miller" <davem@davemloft.net>,
        Steve Glendinning <steve.glendinning@shawell.net>,
        Andrew Lunn <andrew@lunn.ch>, Lukas Wunner <lukas@wunner.de>,
        "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux PM list <linux-pm@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <757f672b-d3cf-9189-0533-cb45e325c6b8@gmail.com>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

On Tue, Aug 22, 2017 at 8:49 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 08/22/2017 11:37 AM, Geert Uytterhoeven wrote:
>> If an Ethernet device is used while the device is suspended, the system may
>> crash.
>>
>> E.g. on sh73a0/kzm9g and r8a73a4/ape6evm, the external Ethernet chip is
>> driven by a PM controlled clock.  If the Ethernet registers are accessed
>> while the clock is not running, the system will crash with an imprecise
>> external abort.
>>
>> This patch series fixes two of such crashes:
>>   1. The first patch prevents the PHY polling state machine from accessing
>>      PHY registers while a device is suspended,
>>   2. The second patch prevents the net core from trying to transmit packets
>>      when an smsc911x device is suspended.
>>
>> Both crashes can be reproduced on sh73a0/kzm9g and r8a73a4/ape6evm during
>> s2ram (rarely), or by using pm_test (more likely to trigger):
>>
>>     # echo 0 > /sys/module/printk/parameters/console_suspend
>>     # echo platform > /sys/power/pm_test
>>     # echo mem > /sys/power/state
>>
>> With this series applied, my test systems survive a loop of 100 test
>> suspends.
>
> It seems to me like part, if not the entire problem is that smsc91xx's
> suspend and resume functions are way too simplistic and absolutely do
> not manage the PHY during suspend/resume, the PHY state machine is not
> even stopped, so of course, this will cause bus errors if you access
> those registers.
>
> You are addressing this as part of patch 2, but this seems to me like
> this is still a bit incomplete and you'd need at least phy_stop() and/or
> phy_suspend() (does a power down of the PHY) and phy_start() and/or
> phy_resume() calls to complete the PHY state machine shutdown during
> suspend.
>
> Have you tried that?

Unfortunately that doesn't help.
In state PHY_HALTED, the PHY state machine still calls the .adjust_link()
callback while the device is suspended.

Do you have a clue? This is too far beyond my phy-foo...

Thanks!

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
