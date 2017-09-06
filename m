From: Matteo Croce <mcroce@redhat.com>
Subject: hung task in mac80211
Date: Wed, 6 Sep 2017 13:57:47 +0200
Message-ID: <CAGnkfhwi9MmtLneeU23iWEGLj9cb1ODb3KzzOqTDvA6nNVsugg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I have an hung task on vanilla 4.13 kernel which I haven't on 4.12.
The problem is present both on my AP and on my notebook,
so it seems it affects AP and STA mode as well.
The generated messages are:

INFO: task kworker/u16:6:120 blocked for more than 120 seconds.
      Not tainted 4.13.0 #57
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
kworker/u16:6   D    0   120      2 0x00000000
Workqueue: phy0 ieee80211_ba_session_work [mac80211]
Call Trace:
 ? __schedule+0x174/0x5b0
 ? schedule+0x31/0x80
 ? schedule_preempt_disabled+0x9/0x10
 ? __mutex_lock.isra.2+0x163/0x480
 ? select_task_rq_fair+0xb9f/0xc60
 ? __ieee80211_start_rx_ba_session+0x135/0x4d0 [mac80211]
 ? __ieee80211_start_rx_ba_session+0x135/0x4d0 [mac80211]
 ? try_to_wake_up+0x1f1/0x340
 ? update_curr+0x88/0xd0
 ? ieee80211_ba_session_work+0x148/0x230 [mac80211]
 ? process_one_work+0x1a5/0x330
 ? worker_thread+0x42/0x3c0
 ? create_worker+0x170/0x170
 ? kthread+0x10d/0x130
 ? kthread_create_on_node+0x40/0x40
 ? ret_from_fork+0x22/0x30

I did a bisect and the offending commit is:

commit 699cb58c8a52ff39bf659bff7971893ebe111bf2
Author: Johannes Berg <johannes.berg@intel.com>
Date:   Tue May 30 16:34:46 2017 +0200

    mac80211: manage RX BA session offload without SKB queue

    Instead of using the SKB queue with the fake pkt_type for the
    offloaded RX BA session management, also handle this with the
    normal aggregation state machine worker. This also makes the
    use of this more reliable since it gets rid of the allocation
    of the fake skb.

    Combined with the previous patch, this finally allows us to
    get rid of the pkt_type hack entirely, so do that as well.

    Signed-off-by: Johannes Berg <johannes.berg@intel.com>

Regards,
-- 
Matteo Croce
per aspera ad upstream
