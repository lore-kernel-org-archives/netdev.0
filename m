From: Daniel J Blueman <daniel@quora.org>
Subject: [4.9.13] brcmf use-after-free on resume
Date: Mon, 6 Mar 2017 15:04:19 +0800
Message-ID: <CAMVG2sv4CFvCBUZFnbTzoX5M+_FCcrojrCnZMGx6iSKPcTTvow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>
To: Wright Feng <wright.feng@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Arend Van Spriel <arend.vanspriel@broadcom.com>,
        Pieter-Paul Giesberts <pieterpg@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f172.google.com ([209.85.217.172]:35636 "EHLO
        mail-ua0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752557AbdCFHLn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 02:11:43 -0500
Received: by mail-ua0-f172.google.com with SMTP id q7so122771474uaf.2
        for <netdev@vger.kernel.org>; Sun, 05 Mar 2017 23:11:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When resuming from suspend with a BCM43602 on Ubuntu 16.04 with
4.9.13, we see use after free [1].

We see the struct cfg80211_ops is accessed in the resume path, after
it was previously freed:

(gdb) list *(brcmf_cfg80211_attach+0x10b)
0x1d77b is in brcmf_cfg80211_attach
(drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c:6861).
6856            brcmf_err("ndev is invalid\n");
6857            return NULL;
6858        }
6859
6860        ops = kmemdup(&brcmf_cfg80211_ops, sizeof(*ops), GFP_KERNEL);
6861        if (!ops)
6862            return NULL;
6863
6864        ifp = netdev_priv(ndev);
6865    #ifdef CONFIG_PM

(gdb) list *(wiphy_resume+0x591)
0xb751 is in wiphy_resume (net/wireless/sysfs.c:133).
128        int ret = 0;
129
130        /* Age scan results with time spent in suspend */
131        cfg80211_bss_age(rdev, get_seconds() - rdev->suspend_at);
132
133        if (rdev->ops->resume) {
134            rtnl_lock();
135            if (rdev->wiphy.registered)
136                ret = rdev_resume(rdev);
137            rtnl_unlock();

I'm unsure if this relates to the ordering of callbacks processed by
dpm_run_callback.

Thanks,
  Daniel

-- [1]

BUG: KASAN: use-after-free in wiphy_resume+0x591/0x5a0 [cfg80211] at
addr ffff8803fefebb30
Read of size 8 by task kworker/u16:15/3066
CPU: 0 PID: 3066 Comm: kworker/u16:15 Not tainted 4.9.13-debug+ #7
Hardware name: Dell Inc. XPS 15 9550/0N7TVV, BIOS 1.2.19 12/22/2016
Workqueue: events_unbound async_run_entry_fn
 ffff8803bffdf9d8 ffffffff880db6e1 ffff88042740ef00 ffff8803fefebb28
 ffff8803bffdfa00 ffffffff87a4d941 ffff8803bffdfa98 ffff8803fefebb20
 ffff88042740ef00 ffff8803bffdfa88 ffffffff87a4dbda ffff8803fb132360
Call Trace:
 [<ffffffff880db6e1>] dump_stack+0x85/0xc4
 [<ffffffff87a4d941>] kasan_object_err+0x21/0x70
 [<ffffffff87a4dbda>] kasan_report_error+0x1fa/0x500
 [<ffffffff8768d47e>] ? trace_hardirqs_on_caller+0x3fe/0x580
 [<ffffffffc151783a>] ? cfg80211_bss_age+0x9a/0xc0 [cfg80211]
 [<ffffffff8768d60d>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffffc14f31c0>] ? wiphy_suspend+0xc70/0xc70 [cfg80211]
 [<ffffffff87a4e091>] __asan_report_load8_noabort+0x61/0x70
 [<ffffffffc14f3100>] ? wiphy_suspend+0xbb0/0xc70 [cfg80211]
 [<ffffffffc14f3751>] ? wiphy_resume+0x591/0x5a0 [cfg80211]
 [<ffffffffc14f3751>] wiphy_resume+0x591/0x5a0 [cfg80211]
 [<ffffffffc14f31c0>] ? wiphy_suspend+0xc70/0xc70 [cfg80211]
 [<ffffffff885b220e>] dpm_run_callback+0x6e/0x4f0
 [<ffffffff885b3352>] device_resume+0x1c2/0x670
 [<ffffffff885b381d>] async_resume+0x1d/0x50
 [<ffffffff875ee9ee>] async_run_entry_fn+0xfe/0x610
 [<ffffffff875d0806>] process_one_work+0x716/0x1a50
 [<ffffffff875d0769>] ? process_one_work+0x679/0x1a50
 [<ffffffff88fd7bad>] ? _raw_spin_unlock_irq+0x3d/0x60
 [<ffffffff875d00f0>] ? pwq_dec_nr_in_flight+0x2b0/0x2b0
 [<ffffffff875d1c20>] worker_thread+0xe0/0x1460
 [<ffffffff875d1b40>] ? process_one_work+0x1a50/0x1a50
 [<ffffffff875e5662>] kthread+0x222/0x2e0
 [<ffffffff875e5440>] ? kthread_park+0x80/0x80
 [<ffffffff875e5440>] ? kthread_park+0x80/0x80
 [<ffffffff875e5440>] ? kthread_park+0x80/0x80
 [<ffffffff88fd86ea>] ret_from_fork+0x2a/0x40
Object at ffff8803fefebb28, in cache kmalloc-1024 size: 1024
Allocated:
PID = 431
 save_stack_trace+0x1b/0x20
 save_stack+0x46/0xd0
 kasan_kmalloc+0xad/0xe0
 kasan_slab_alloc+0x12/0x20
 __kmalloc_track_caller+0x134/0x360
 kmemdup+0x20/0x50
 brcmf_cfg80211_attach+0x10b/0x3a90 [brcmfmac]
 brcmf_bus_start+0x19a/0x9a0 [brcmfmac]
 brcmf_pcie_setup+0x1f1a/0x3680 [brcmfmac]
 brcmf_fw_request_nvram_done+0x44c/0x11b0 [brcmfmac]
 request_firmware_work_func+0x135/0x280
 process_one_work+0x716/0x1a50
 worker_thread+0xe0/0x1460
 kthread+0x222/0x2e0
 ret_from_fork+0x2a/0x40
Freed:
PID = 3101
 save_stack_trace+0x1b/0x20
 save_stack+0x46/0xd0
 kasan_slab_free+0x71/0xb0
 kfree+0xe8/0x2e0
 brcmf_cfg80211_detach+0x62/0xf0 [brcmfmac]
 brcmf_detach+0x14a/0x2b0 [brcmfmac]
 brcmf_pcie_remove+0x140/0x5d0 [brcmfmac]
 brcmf_pcie_pm_leave_D3+0x198/0x2e0 [brcmfmac]
 pci_pm_resume+0x186/0x220
 dpm_run_callback+0x6e/0x4f0
 device_resume+0x1c2/0x670
 async_resume+0x1d/0x50
 async_run_entry_fn+0xfe/0x610
 process_one_work+0x716/0x1a50
 worker_thread+0xe0/0x1460
 kthread+0x222/0x2e0
 ret_from_fork+0x2a/0x40
Memory state around the buggy address:
 ffff8803fefeba00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
 ffff8803fefeba80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>ffff8803fefebb00: fc fc fc fc fc fb fb fb fb fb fb fb fb fb fb fb
                   ^
 ffff8803fefebb80: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff8803fefebc00: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
-- 
Daniel J Blueman
