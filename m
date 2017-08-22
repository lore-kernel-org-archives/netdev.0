From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 0/2] net: Fix crashes due to activity during suspend
Date: Tue, 22 Aug 2017 11:49:53 -0700
Message-ID: <757f672b-d3cf-9189-0533-cb45e325c6b8@gmail.com>
References: <1503427046-17618-1-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Lukas Wunner <lukas@wunner.de>,
        "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>,
        netdev@vger.kernel.org, linux-pm@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org, linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert+renesas@glider.be>,
        "David S . Miller" <davem@davemloft.net>,
        Steve Glendinning <steve.glendinning@shawell.net>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <1503427046-17618-1-git-send-email-geert+renesas@glider.be>
Content-Language: en-US
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/22/2017 11:37 AM, Geert Uytterhoeven wrote:
> 	Hi all,
> 
> If an Ethernet device is used while the device is suspended, the system may
> crash.
> 
> E.g. on sh73a0/kzm9g and r8a73a4/ape6evm, the external Ethernet chip is
> driven by a PM controlled clock.  If the Ethernet registers are accessed
> while the clock is not running, the system will crash with an imprecise
> external abort.
> 
> This patch series fixes two of such crashes:
>   1. The first patch prevents the PHY polling state machine from accessing
>      PHY registers while a device is suspended,
>   2. The second patch prevents the net core from trying to transmit packets
>      when an smsc911x device is suspended.
> 
> Both crashes can be reproduced on sh73a0/kzm9g and r8a73a4/ape6evm during
> s2ram (rarely), or by using pm_test (more likely to trigger):
> 
>     # echo 0 > /sys/module/printk/parameters/console_suspend
>     # echo platform > /sys/power/pm_test
>     # echo mem > /sys/power/state
> 
> With this series applied, my test systems survive a loop of 100 test
> suspends.

It seems to me like part, if not the entire problem is that smsc91xx's
suspend and resume functions are way too simplistic and absolutely do
not manage the PHY during suspend/resume, the PHY state machine is not
even stopped, so of course, this will cause bus errors if you access
those registers.

You are addressing this as part of patch 2, but this seems to me like
this is still a bit incomplete and you'd need at least phy_stop() and/or
phy_suspend() (does a power down of the PHY) and phy_start() and/or
phy_resume() calls to complete the PHY state machine shutdown during
suspend.

Have you tried that?
-- 
Florian
