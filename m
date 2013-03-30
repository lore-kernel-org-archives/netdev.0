From: Artem Savkov <artem.savkov@gmail.com>
Subject: [PATCH] net/wireless/sme: sched_scan_mtx lock in cfg80211_conn_work()
Date: Sat, 30 Mar 2013 21:20:14 +0400
Message-ID: <1364664014-12304-1-git-send-email-artem.savkov@gmail.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Artem Savkov <artem.savkov@gmail.com>
To: johannes.berg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:59788 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756877Ab3C3RUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Mar 2013 13:20:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduced in f9f475292dbb0e7035fb6661d1524761ea0888d9

cfg80211_conn_scan() which requires sched_scan_mtx to be held can be called
from cfg80211_conn_work(). Without this we are hitting multiple warnings like
the following:

[   51.996440] ------------[ cut here ]------------
[   51.996484] WARNING: at net/wireless/sme.c:88 cfg80211_conn_scan+0x1dc/0x3a0 [cfg80211]()
[   51.996489] Hardware name: 0578A21
[   51.996492] Modules linked in: iwldvm mac80211 uvcvideo videobuf2_vmalloc
videobuf2_memops iwlwifi videobuf2_core videodev media cfg80211 ums_realtek
kvm_intel kvm intel_ips r8169 lpc_ich joydev crc32c_intel acpi_cpufreq mperf thinkpad_acpi
[   51.996533] Pid: 620, comm: kworker/3:1 Not tainted 3.9.0-rc4-next-20130328+ #326
[   51.996537] Call Trace:
[   51.996550]  [<c1036992>] warn_slowpath_common+0x72/0xa0
[   51.996583]  [<faa4b0ec>] ? cfg80211_conn_scan+0x1dc/0x3a0 [cfg80211]
[   51.996615]  [<faa4b0ec>] ? cfg80211_conn_scan+0x1dc/0x3a0 [cfg80211]
[   51.996622]  [<c10369e2>] warn_slowpath_null+0x22/0x30
[   51.996654]  [<faa4b0ec>] cfg80211_conn_scan+0x1dc/0x3a0 [cfg80211]
[   51.996662]  [<c109076c>] ? __lock_is_held+0x3c/0x60
[   51.996694]  [<faa4b344>] cfg80211_conn_do_work+0x94/0x380 [cfg80211]
[   51.996700]  [<c109175a>] ? __lock_acquire.isra.25+0x38a/0xc80
[   51.996711]  [<c109e679>] ? is_module_text_address+0x19/0x30
[   51.996720]  [<c10577cf>] ? __kernel_text_address+0x4f/0x70
[   51.996728]  [<c10052b1>] ? print_context_stack+0x41/0xd0
[   51.996763]  [<faa4c3b2>] cfg80211_conn_work+0xa2/0x130 [cfg80211]
[   51.996771]  [<c1051858>] process_one_work+0x198/0x450
[   51.996779]  [<c10517d0>] ? process_one_work+0x110/0x450
[   51.996787]  [<c10527c9>] worker_thread+0xf9/0x320
[   51.996795]  [<c10526d0>] ? manage_workers.isra.17+0x260/0x260
[   51.996803]  [<c105a3c4>] kthread+0x94/0xa0
[   51.996812]  [<c1060000>] ? profiling_show+0x10/0x30
[   51.996823]  [<c170c277>] ret_from_kernel_thread+0x1b/0x28
[   51.996830]  [<c105a330>] ? __init_kthread_worker+0x60/0x60
[   51.996835] ---[ end trace 6c56f7f4ff21820b ]---

Signed-off-by: Artem Savkov <artem.savkov@gmail.com>
---
 net/wireless/sme.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/wireless/sme.c b/net/wireless/sme.c
index 818ad63..a9dc5c7 100644
--- a/net/wireless/sme.c
+++ b/net/wireless/sme.c
@@ -228,6 +228,7 @@ void cfg80211_conn_work(struct work_struct *work)
 	rtnl_lock();
 	cfg80211_lock_rdev(rdev);
 	mutex_lock(&rdev->devlist_mtx);
+	mutex_lock(&rdev->sched_scan_mtx);
 
 	list_for_each_entry(wdev, &rdev->wdev_list, list) {
 		wdev_lock(wdev);
@@ -252,6 +253,7 @@ void cfg80211_conn_work(struct work_struct *work)
 		wdev_unlock(wdev);
 	}
 
+	mutex_unlock(&rdev->sched_scan_mtx);
 	mutex_unlock(&rdev->devlist_mtx);
 	cfg80211_unlock_rdev(rdev);
 	rtnl_unlock();
-- 
1.8.2
