From: Ferenc Wagner <wferi@niif.hu>
Subject: mac80211 regression (deadlock) with built-in ipw2200
Date: Sat, 17 Sep 2011 12:23:18 +0200
Message-ID: <877h57jwmh.fsf@tac.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

As pointed out by git-bisect, commit ecb44335 (mac80211: fix
suspend/resume races with unregister hw) broke booting on my ThinkPad
R50e. Looks like the rtnl_lock() around rdev->wiphy.registered = true
leads to a deadlock, possibly because ipw2200 is built-in in my
config.  Testing with the additional debug patch

--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -616,9 +616,8 @@ int wiphy_register(struct wiphy *wiphy)
        if (res)
                goto out_rm_dev;
 
-       rtnl_lock();
+       WARN_ON(rtnl_is_locked());
        rdev->wiphy.registered = true;
-       rtnl_unlock();
        return 0;
 
on top of c455ea4f (rc6+) leads to a working system with

[    1.020738] ipw2200: Intel(R) PRO/Wireless 2200/2915 Network Driver, 1.2.2kmpr
[    1.020812] ipw2200: Copyright(c) 2003-2006 Intel Corporation
[    1.023406] ACPI: PCI Interrupt Link [LNKF] enabled at IRQ 11
[    1.025717] ipw2200 0000:02:02.0: PCI INT A -> Link[LNKF] -> GSI 11 (level, low
) -> IRQ 11
[    1.028048] ipw2200: Detected Intel PRO/Wireless 2200BG Network Connection
[    1.148058] ------------[ cut here ]------------
[    1.150393] WARNING: at net/wireless/core.c:619 wiphy_register+0x4c1/0x58c()
[    1.152781] Hardware name: 1834S5G
[    1.155126] Pid: 1, comm: swapper Not tainted 3.1.0-rc6+ #86
[    1.157520] Call Trace:
[    1.159871]  [<c1028b98>] warn_slowpath_common+0x69/0x90
[    1.162241]  [<c13ee7a8>] ? wiphy_register+0x4c1/0x58c
[    1.164617]  [<c13ee7a8>] ? wiphy_register+0x4c1/0x58c
[    1.166924]  [<c1028be1>] warn_slowpath_null+0x22/0x24
[    1.169230]  [<c13ee7a8>] wiphy_register+0x4c1/0x58c
[    1.171564]  [<c12daad0>] ? ipw_net_init+0x1e6/0x2d0
[    1.173890]  [<c12da995>] ipw_net_init+0xab/0x2d0
[    1.176173]  [<c1375032>] register_netdevice+0x70/0x271
[    1.178446]  [<c137524e>] register_netdev+0x1b/0x28
[    1.180688]  [<c142f5b8>] ipw_pci_probe+0x7c3/0x891
[    1.182892]  [<c11a6f93>] local_pci_probe+0x40/0x9a
[    1.185086]  [<c11a7c98>] pci_device_probe+0x56/0x71
[    1.187259]  [<c128c902>] driver_probe_device+0x6c/0x177
[    1.189453]  [<c11a6ed9>] ? pci_match_device+0x80/0x85
[    1.191615]  [<c128ca79>] __driver_attach+0x6c/0x6e
[    1.193794]  [<c128c257>] bus_for_each_dev+0x4a/0x68
[    1.195936]  [<c128c7b4>] driver_attach+0x1e/0x20
[    1.198043]  [<c128ca0d>] ? driver_probe_device+0x177/0x177
[    1.200151]  [<c128bce5>] bus_add_driver+0x186/0x231
[    1.202247]  [<c11a7b3c>] ? pci_dev_put+0x16/0x16
[    1.204320]  [<c128cfac>] driver_register+0x6a/0x118
[    1.206386]  [<c120665f>] ? misc_register+0xc2/0x133
[    1.208425]  [<c15ee31e>] ? parse_early_options+0x25/0x25
[    1.210423]  [<c11a7e66>] __pci_register_driver+0x33/0x8c
[    1.212393]  [<c15ee31e>] ? parse_early_options+0x25/0x25
[    1.214384]  [<c160e0e8>] ipw_init+0x30/0x75
[    1.216356]  [<c15ee24c>] do_one_initcall+0x86/0x133
[    1.218340]  [<c160e0b8>] ? tun_init+0x8b/0x8b
[    1.220315]  [<c15ee31e>] ? parse_early_options+0x25/0x25
[    1.222270]  [<c15ee393>] kernel_init+0x75/0x10c
[    1.224214]  [<c14349b6>] kernel_thread_helper+0x6/0x10
[    1.226124] ---[ end trace 4ef665623022622c ]---
[    1.228121] ipw2200: Detected geography ZZR (14 802.11bg channels, 0 802.11a channels)

in dmesg.  It's a shoot in the dark, but register_netdev() issues
rtnl_lock() before calling register_netdevice(), so wiphy_register()
can't possibly acquire the rtnl mutex in the same call chain, or can
it?
-- 
Thanks,
Feri.
