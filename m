From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net 1/3] r8169:fix nic sometimes doesn't work after
 changing the mac address.
Date: Sat, 27 Feb 2016 00:31:58 +0100
Message-ID: <20160226233158.GA26088@electric-eye.fr.zoreil.com>
References: <1456476046-5436-1-git-send-email-hau@realtek.com>
 <1456476046-5436-2-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org
To: Chunhao Lin <hau@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1456476046-5436-2-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chunhao Lin <hau@realtek.com> :
> When there is no AC power, NIC doesn't work after changing mac address.
> Please refer to following link.
> http://www.spinics.net/lists/netdev/msg356572.html
> 
> This issue is caused by runtime power management. When there is no AC power, if we
> put NIC down (ifconfig down), the driver will be put in runtime suspend state and
> device will in D3 state. In this time, driver cannot access hardware regisers. So
> if you set new mac address during this time, it will not work. And then, after
> resume, the NIC will keep using the old mac address and so the network will not
> work normally.
> 
> In this patch I add detecting runtime pm state when setting mac address. If
> driver is in runtime suspend, I will skip setting mac address and  set the new
> mac address during runtime resume.

Instead of taking the device out of suspended mode to perform the required
action, the driver is moving to a model where 1) said action may be scheduled
to a later time - or result from past time work - and 2) rpm handler must
handle a lot of pm unrelated work.

rtl8169_ethtool_ops.{get_wol, get_regs, get_settings} aren't even fixed
yet (what about the .set_xyz handlers ?).

I can't help thinking that the driver should return to a state where it
stupidly does what it is asked to. No software caching, plain device
access, resume when needed, suspend as "suspend" instead of suspend as
"anticipate whatever may happen to avoid waking up".

-- 
Ueimor
