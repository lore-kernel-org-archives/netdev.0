From: Arend Van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: [4.9.13] brcmf use-after-free on resume
Date: Mon, 27 Mar 2017 11:24:57 +0200
Message-ID: <CAF7Mx6pjfhPrLf0V4HKYDqrQ_32Qbvh_4161EfbYr7XBA2EMRg@mail.gmail.com>
References: <CAMVG2sv4CFvCBUZFnbTzoX5M+_FCcrojrCnZMGx6iSKPcTTvow@mail.gmail.com>
 <c0e2de87-eb19-22bd-290a-a914ea18e52f@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        linux-wireless <linux-wireless@vger.kernel.org>,
        "open list:BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER"
        <brcm80211-dev-list.pdl@broadcom.com>
To: Daniel J Blueman <daniel@quora.org>,
        Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:34091 "EHLO
        mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751406AbdC0JZN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 05:25:13 -0400
Received: by mail-qk0-f170.google.com with SMTP id d10so27004484qke.1
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 02:25:12 -0700 (PDT)
In-Reply-To: <c0e2de87-eb19-22bd-290a-a914ea18e52f@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

+ Johannes

On 6-3-2017 11:48, Arend Van Spriel wrote:
> + linux-wireless
>
> On 6-3-2017 8:04, Daniel J Blueman wrote:
>> When resuming from suspend with a BCM43602 on Ubuntu 16.04 with
>> 4.9.13, we see use after free [1].
>>
>> We see the struct cfg80211_ops is accessed in the resume path, after
>> it was previously freed:
>>
>> (gdb) list *(brcmf_cfg80211_attach+0x10b)
>> 0x1d77b is in brcmf_cfg80211_attach
>> (drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c:6861).
>> 6856            brcmf_err("ndev is invalid\n");
>> 6857            return NULL;
>> 6858        }
>> 6859
>> 6860        ops = kmemdup(&brcmf_cfg80211_ops, sizeof(*ops), GFP_KERNEL);
>> 6861        if (!ops)
>> 6862            return NULL;
>> 6863
>> 6864        ifp = netdev_priv(ndev);
>> 6865    #ifdef CONFIG_PM
>>
>> (gdb) list *(wiphy_resume+0x591)
>> 0xb751 is in wiphy_resume (net/wireless/sysfs.c:133).
>> 128        int ret = 0;
>> 129
>> 130        /* Age scan results with time spent in suspend */
>> 131        cfg80211_bss_age(rdev, get_seconds() - rdev->suspend_at);
>> 132
>> 133        if (rdev->ops->resume) {
>> 134            rtnl_lock();
>> 135            if (rdev->wiphy.registered)
>> 136                ret = rdev_resume(rdev);
>> 137            rtnl_unlock();
>>
>> I'm unsure if this relates to the ordering of callbacks processed by
>> dpm_run_callback.
>
> The problem is that our driver can not access the device as it has been
> powered off during suspend. So in the resume we cleanup everything
> calling wiphy_unregister() and wiphy_free(). This means the rdev in
> wiphy_resume() above is already freed. Not sure how to handle this
> properly. Probably we should do a proper rebind.
>
> Regards,
> Arend
>
>> Thanks,
>>   Daniel
>>
>> -- [1]
>>
>> BUG: KASAN: use-after-free in wiphy_resume+0x591/0x5a0 [cfg80211] at
>> addr ffff8803fefebb30
>> Read of size 8 by task kworker/u16:15/3066
>> CPU: 0 PID: 3066 Comm: kworker/u16:15 Not tainted 4.9.13-debug+ #7
>> Hardware name: Dell Inc. XPS 15 9550/0N7TVV, BIOS 1.2.19 12/22/2016
>> Workqueue: events_unbound async_run_entry_fn
>>  ffff8803bffdf9d8 ffffffff880db6e1 ffff88042740ef00 ffff8803fefebb28
>>  ffff8803bffdfa00 ffffffff87a4d941 ffff8803bffdfa98 ffff8803fefebb20
>>  ffff88042740ef00 ffff8803bffdfa88 ffffffff87a4dbda ffff8803fb132360
>> Call Trace:
>>  [<ffffffff880db6e1>] dump_stack+0x85/0xc4
>>  [<ffffffff87a4d941>] kasan_object_err+0x21/0x70
>>  [<ffffffff87a4dbda>] kasan_report_error+0x1fa/0x500
>>  [<ffffffff8768d47e>] ? trace_hardirqs_on_caller+0x3fe/0x580
>>  [<ffffffffc151783a>] ? cfg80211_bss_age+0x9a/0xc0 [cfg80211]
>>  [<ffffffff8768d60d>] ? trace_hardirqs_on+0xd/0x10
>>  [<ffffffffc14f31c0>] ? wiphy_suspend+0xc70/0xc70 [cfg80211]
>>  [<ffffffff87a4e091>] __asan_report_load8_noabort+0x61/0x70
>>  [<ffffffffc14f3100>] ? wiphy_suspend+0xbb0/0xc70 [cfg80211]
>>  [<ffffffffc14f3751>] ? wiphy_resume+0x591/0x5a0 [cfg80211]
>>  [<ffffffffc14f3751>] wiphy_resume+0x591/0x5a0 [cfg80211]
>>  [<ffffffffc14f31c0>] ? wiphy_suspend+0xc70/0xc70 [cfg80211]
>>  [<ffffffff885b220e>] dpm_run_callback+0x6e/0x4f0
>>  [<ffffffff885b3352>] device_resume+0x1c2/0x670
>>  [<ffffffff885b381d>] async_resume+0x1d/0x50
>>  [<ffffffff875ee9ee>] async_run_entry_fn+0xfe/0x610
>>  [<ffffffff875d0806>] process_one_work+0x716/0x1a50
>>  [<ffffffff875d0769>] ? process_one_work+0x679/0x1a50
>>  [<ffffffff88fd7bad>] ? _raw_spin_unlock_irq+0x3d/0x60
>>  [<ffffffff875d00f0>] ? pwq_dec_nr_in_flight+0x2b0/0x2b0
>>  [<ffffffff875d1c20>] worker_thread+0xe0/0x1460
>>  [<ffffffff875d1b40>] ? process_one_work+0x1a50/0x1a50
>>  [<ffffffff875e5662>] kthread+0x222/0x2e0
>>  [<ffffffff875e5440>] ? kthread_park+0x80/0x80
>>  [<ffffffff875e5440>] ? kthread_park+0x80/0x80
>>  [<ffffffff875e5440>] ? kthread_park+0x80/0x80
>>  [<ffffffff88fd86ea>] ret_from_fork+0x2a/0x40

So the wiphy instance is unregistered *and* freed in our
brcmf_pcie_resume() callback. However, the wiphy_resume() for this
instance still comes right after that. I tried several fixes using API
calls into driver core, but to no avail. So I came up with the fix
below.

Regards,
Arend
---
Sorry about the whitespace issues below (if any). My favorite mail
client went haywire and I had to use gmail web interface and it looks
like tabs are gone.
---
diff --git a/net/wireless/core.c b/net/wireless/core.c
index d888613..3af9c2e 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -1096,6 +1096,17 @@ void cfg80211_stop_iface(struct wiphy *wiphy,
struct wireless_dev *wdev,
 }
 EXPORT_SYMBOL(cfg80211_stop_iface);

+bool cfg80211_dev_in_list_rtnl(struct cfg80211_registered_device *rdev)
+{
+ struct cfg80211_registered_device *item;
+
+ list_for_each_entry(item, &cfg80211_rdev_list, list) {
+ if (item == rdev)
+ return true;
+ }
+ return false;
+}
+
 static int cfg80211_netdev_notifier_call(struct notifier_block *nb,
  unsigned long state, void *ptr)
 {
diff --git a/net/wireless/core.h b/net/wireless/core.h
index e9afbc7..0407841 100644
--- a/net/wireless/core.h
+++ b/net/wireless/core.h
@@ -286,6 +286,7 @@ struct cfg80211_cqm_config {

 int cfg80211_dev_rename(struct cfg80211_registered_device *rdev,
  char *newname);
+bool cfg80211_dev_in_list_rtnl(struct cfg80211_registered_device *rdev);

 void ieee80211_set_bitrate_flags(struct wiphy *wiphy);

diff --git a/net/wireless/sysfs.c b/net/wireless/sysfs.c
index 16b6b59..e92459f 100644
--- a/net/wireless/sysfs.c
+++ b/net/wireless/sysfs.c
@@ -129,16 +129,19 @@ static int wiphy_resume(struct device *dev)
  struct cfg80211_registered_device *rdev = dev_to_rdev(dev);
  int ret = 0;

+ rtnl_lock();
+ if (!cfg80211_dev_in_list_rtnl(rdev))
+ goto done;
+
  /* Age scan results with time spent in suspend */
  cfg80211_bss_age(rdev, get_seconds() - rdev->suspend_at);

  if (rdev->ops->resume) {
- rtnl_lock();
  if (rdev->wiphy.registered)
  ret = rdev_resume(rdev);
- rtnl_unlock();
  }
-
+done:
+ rtnl_unlock();
  return ret;
 }
