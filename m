From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/2] net: phy: leds: Clear phy_num_led_triggers on failure
 to avoid crash
Date: Tue, 24 Jan 2017 12:52:02 -0800
Message-ID: <858caf82-b49e-96d9-98a5-32be915c3f74@gmail.com>
References: <1485272470-3497-1-git-send-email-geert+renesas@glider.be>
 <1485272470-3497-2-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>,
        =?UTF-8?Q?Magnus_=c3=96berg?= <magnus.oberg@westermo.se>,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert+renesas@glider.be>,
        "David S. Miller" <davem@davemloft.net>,
        Zach Brown <zach.brown@ni.com>,
        Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1485272470-3497-2-git-send-email-geert+renesas@glider.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/24/2017 07:41 AM, Geert Uytterhoeven wrote:
> phy_attach_direct() ignores errors returned by
> phy_led_triggers_register(). I think that's OK, as LED triggers can be
> considered a non-critical feature.
> 
> However, this causes problems later:
>   - phy_led_trigger_change_speed() will access the array
>     phy_device.phy_led_triggers, which has been freed in the error path
>     of phy_led_triggers_register(), which may lead to a crash.
> 
>   - phy_led_triggers_unregister() will access the same array, leading to
>     crashes during s2ram or poweroff, like:
> 
> 	Unable to handle kernel NULL pointer dereference at virtual address
> 	00000000
> 	...
> 	[<c04116d4>] (__list_del_entry_valid) from [<c05e8948>] (led_trigger_unregister+0x34/0xcc)
> 	[<c05e8948>] (led_trigger_unregister) from [<c05336c4>] (phy_led_triggers_unregister+0x28/0x34)
> 	[<c05336c4>] (phy_led_triggers_unregister) from [<c0531d44>] (phy_detach+0x30/0x74)
> 	[<c0531d44>] (phy_detach) from [<c0538bdc>] (sh_eth_close+0x64/0x9c)
> 	[<c0538bdc>] (sh_eth_close) from [<c04d4ce0>] (dpm_run_callback+0x48/0xc8)
> 
>     or:
> 
> 	list_del corruption. prev->next should be dede6540, but was 2e323931
> 	------------[ cut here ]------------
> 	kernel BUG at lib/list_debug.c:52!
> 	...
> 	[<c02f6d70>] (__list_del_entry_valid) from [<c0425168>] (led_trigger_unregister+0x34/0xcc)
> 	[<c0425168>] (led_trigger_unregister) from [<c03a05a0>] (phy_led_triggers_unregister+0x28/0x34)
> 	[<c03a05a0>] (phy_led_triggers_unregister) from [<c039ec04>] (phy_detach+0x30/0x74)
> 	[<c039ec04>] (phy_detach) from [<c03a4fc0>] (sh_eth_close+0x6c/0xa4)
> 	[<c03a4fc0>] (sh_eth_close) from [<c0483234>] (__dev_close_many+0xac/0xd0)
> 
> To fix this, clear phy_device.phy_num_led_triggers in the error path of
> phy_led_triggers_register() fails.
> 
> Note that the "No phy led trigger registered for speed" message will
> still be printed on link speed changes, which is a good cue that
> something went wrong with the LED triggers.
> 
> Fixes: 2e0bc452f4721520 ("net: phy: leds: add support for led triggers on phy link state change")
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
