From: Andrei Vagin <avagin@gmail.com>
Subject: Re: linux-next: net->netns_ids is used after calling idr_destroy for it
Date: Tue, 15 Nov 2016 12:48:28 -0800
Message-ID: <CANaxB-ysMU+QG=warwiQdC5pfXRjrSY7WOqJk0fcj-UMpipSZQ@mail.gmail.com>
References: <CANaxB-x7FgxpAwpa-RgOvUptrCRUmAE6NFm3As+LuXUE=fHJyA@mail.gmail.com>
 <CAM_iQpUQOCsVkaRPU3OkmNvyOLDtmRRK1G3uzvi9URSVEbapJQ@mail.gmail.com> <CAM_iQpU=DXKEboYHi4yO3m6VuUm1RoDRD26ZK-pVY--yUE0wNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:36293 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751749AbcKOUsa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 15:48:30 -0500
Received: by mail-oi0-f67.google.com with SMTP id 128so3989061oih.3
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 12:48:30 -0800 (PST)
In-Reply-To: <CAM_iQpU=DXKEboYHi4yO3m6VuUm1RoDRD26ZK-pVY--yUE0wNA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 15, 2016 at 10:50 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Tue, Nov 15, 2016 at 10:04 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> On Mon, Nov 14, 2016 at 10:23 PM, Andrei Vagin <avagin@gmail.com> wrote:
>>> Hi Nicolas,
>>>
>>> cleanup_net() calls idr_destroy(net->netns_ids) for network namespaces
>>> and then it calls unregister_netdevice_many() which calls
>>> idr_alloc(net0>netns_ids). It looks wrong, doesn't it?
>>>
>>
>> netns id is designed to allocate lazily, but yeah it makes no sense
>> to allocate id for the netns being destroyed, not to mention idr is freed.
>>
>> I will send a patch.
>
> Could you try the attached patch? I just did some quick netns creation/destroy
> tests.

Here is another fail:

unreferenced object 0xffff94153912a0c0 (size 2096):
  comm "ip", pid 29175, jiffies 4294954213 (age 137.624s)
  hex dump (first 32 bytes):
    00 00 00 00 00 00 00 00 00 b2 3b 1d 15 94 ff ff  ..........;.....
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
  backtrace:
    [<ffffffffac865c1a>] kmemleak_alloc+0x4a/0xa0
    [<ffffffffac243b38>] kmem_cache_alloc+0x128/0x280
    [<ffffffffac42f5ab>] idr_layer_alloc+0x2b/0x90
    [<ffffffffac42f9cd>] idr_get_empty_slot+0x34d/0x370
    [<ffffffffac42fa4e>] idr_alloc+0x5e/0x110
    [<ffffffffac70ac3d>] __peernet2id_alloc+0x6d/0x90
    [<ffffffffac70bda5>] peernet2id_alloc+0x55/0xb0
    [<ffffffffac731246>] rtnl_fill_ifinfo+0xaa6/0x10a0
    [<ffffffffac7330a3>] rtmsg_ifinfo_build_skb+0x73/0xd0
    [<ffffffffac7125e1>] rollback_registered_many+0x2a1/0x3a0
    [<ffffffffac712779>] __unregister_netdevice_many+0x29/0x80
    [<ffffffffac7127e3>] unregister_netdevice_many+0x13/0x20
    [<ffffffffc02dc4ce>] macvlan_device_event+0x13e/0x235 [macvlan]
    [<ffffffffac0bef2a>] notifier_call_chain+0x4a/0x70
    [<ffffffffac0bf066>] raw_notifier_call_chain+0x16/0x20
    [<ffffffffac710205>] call_netdevice_notifiers_info+0x35/0x60


What do you think about calling idr_destroy() at the final step in
cleanup_net()? In this case we can avoid this sort of problems in a
future.

@@ -422,21 +425,6 @@ static void cleanup_net(struct work_struct *work)
        list_for_each_entry(net, &net_kill_list, cleanup_list) {
                list_del_rcu(&net->list);
                list_add_tail(&net->exit_list, &net_exit_list);
-               for_each_net(tmp) {
-                       int id;
-
-                       spin_lock_irq(&tmp->nsid_lock);
-                       id = __peernet2id(tmp, net);
-                       if (id >= 0)
-                               idr_remove(&tmp->netns_ids, id);
-                       spin_unlock_irq(&tmp->nsid_lock);
-                       if (id >= 0)
-                               rtnl_net_notifyid(tmp, RTM_DELNSID, id);
-               }
-               spin_lock_irq(&net->nsid_lock);
-               idr_destroy(&net->netns_ids);
-               spin_unlock_irq(&net->nsid_lock);
-
        }
        rtnl_unlock();

@@ -464,6 +452,22 @@ static void cleanup_net(struct work_struct *work)

        /* Finally it is safe to free my network namespace structure */
        list_for_each_entry_safe(net, tmp, &net_exit_list, exit_list) {
+               rtnl_lock();
+               for_each_net(tmp) {
+                       int id;
+
+                       spin_lock_irq(&tmp->nsid_lock);
+                       id = __peernet2id(tmp, net);
+                       if (id >= 0)
+                               idr_remove(&tmp->netns_ids, id);
+                       spin_unlock_irq(&tmp->nsid_lock);
+                       if (id >= 0)
+                               rtnl_net_notifyid(tmp, RTM_DELNSID, id);
+               }
+               rtnl_unlock();
+
+               idr_destroy(&net->netns_ids);
+
                list_del_init(&net->exit_list);
                dec_net_namespaces(net->ucounts);
                put_user_ns(net->user_ns);
>
> Thanks!
