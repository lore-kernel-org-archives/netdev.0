From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: more driver shutdown WoL regression.
Date: Wed, 9 Nov 2011 23:25:56 +0100
Message-ID: <20111109222556.GA8226@electric-eye.fr.zoreil.com>
References: <20111108223502.GA20437@electric-eye.fr.zoreil.com> <E6A5E7482020466E82FD141C8CD92D9A@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "'Stefan Becker'" <chemobejk@gmail.com>,
	"'David Miller'" <davem@davemloft.net>
To: hayeswang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:53607 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750961Ab1KIWar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 17:30:47 -0500
Content-Disposition: inline
In-Reply-To: <E6A5E7482020466E82FD141C8CD92D9A@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hayeswang <hayeswang@realtek.com> :
[...]
> I am confused with your results. According to the information from hw and my
> tests, the chips which need enable RxConfig for WOL are 8105e series, 8168e
> series, 8168evl, and 8168f series. The previous chips, include 8168d, work fine
> for WOL without enabling RxConfig.
> PS. I test 8111d (RTL_GIGA_MAC_VER_25) and 8111e (RTL_GIGA_MAC_VER_33) with
> kernel 3.1.0.

I tested in the following order
RTL_GIGA_MAC_VER_26 (ko)
RTL_GIGA_MAC_VER_25 (ko)
RTL_GIGA_MAC_VER_12 (ko)
RTL_GIGA_MAC_VER_34 (ok)
RTL_GIGA_MAC_VER_33 (ok)
RTL_GIGA_MAC_VER_35 (ok)
RTL_GIGA_MAC_VER_09 (ko)
RTL_GIGA_MAC_VER_09 (ko)
RTL_GIGA_MAC_VER_30 (ok)
RTL_GIGA_MAC_VER_30 (ok)
RTL_GIGA_MAC_VER_06 (ok)

Each test:
- proceeded from a fresh boot
- dmesg | grep XID; ip link show
  -> check MAC address (devices were set through udev long beforehand)
- ip link set dev xyz up
- ethtool xyz
  -> check link status up
- ethtool peer
  -> check link status up, 1000 Mbps or 100 Mbps
- ethtool -s xyz wol g; ethtool xyz
- telinit 0
- ethtool peer
  -> check link status up, 10 Mbps
- ether-wake -i peer mac_addr (triple check the mac address here)

(stop, power off, unplug, plug, power on, repeat)

Once the whole set of chipset was tested, I patched, built, and test again.

It was post 3.1. I'll sample again a few offenders with 3.2-rc1 tomorrow
but it is not only me : Stefan noticed the same behavior with his 8168c
(I have neither 8168c nor 8168cp).

> Besides, I find rtl_shutdown would call rtl8169_net_suspend, rtl8169_net_suspend
> would call rtl_pll_power_down, and rtl_pll_power_down would call
> r810x_pll_power_down or r8168_pll_power_down. Finally, I find
> rtl_wol_suspend_quirk would be called. Is it necessary to call
> rtl_wol_suspend_quirk again in rtl_shutdown?

Yes, due to rtl8169_hw_reset in rtl_shutdown.

static void rtl_shutdown(struct pci_dev *pdev)
{
        struct net_device *dev = pci_get_drvdata(pdev);
        struct rtl8169_private *tp = netdev_priv(dev);

        rtl8169_net_suspend(dev);
[...]
        rtl8169_hw_reset(tp);      <- resets RxConfig

        spin_unlock_irq(&tp->lock);

        if (system_state == SYSTEM_POWER_OFF) {
                if (__rtl8169_get_wol(tp) & WAKE_ANY) {
                        rtl_wol_suspend_quirk(tp);
                        rtl_wol_shutdown_quirk(tp);
                }

I'll add a netif_device_detach + netif_stop_queue helper for both
rtl8169_net_suspend and rtl_shutdown to avoid the first call to
rtl_wol_suspend_quirk in rtl_shutdown now that -next is open.

-- 
Ueimor
