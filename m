From: Alexei Starovoitov <ast@plumgrid.com>
Subject: unregister_netdevice: waiting for lo to become free
Date: Sat, 16 Nov 2013 18:18:35 -0800
Message-ID: <CAMEtUuwKd-2YZBF8BtKFaKvgb8MgwTfJKz3KkkzVYkhJPNNXzw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:58214 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753352Ab3KQCSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Nov 2013 21:18:36 -0500
Received: by mail-wi0-f181.google.com with SMTP id f4so2485104wiw.14
        for <netdev@vger.kernel.org>; Sat, 16 Nov 2013 18:18:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

once every 24 hr we're hitting namespace cleanup bug:

[53432.230745] unregister_netdevice: waiting for lo to become free.
Usage count = 2
[53442.456822] unregister_netdevice: waiting for lo to become free.
Usage count = 2
[53452.646927] unregister_netdevice: waiting for lo to become free.
Usage count = 2
[53462.861009] unregister_netdevice: waiting for lo to become free.
Usage count = 2
[53468.423648] INFO: task ip:1444 blocked for more than 120 seconds.
[53468.423650] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
disables this message.
[53468.423651] ip              D ffff88082fb13280     0  1444   1443 0x00000000
[53468.423653]  ffff8806e0b19dd8 0000000000000002 ffff880754b0aee0
ffff8806e0b19fd8
[53468.423655]  ffff8806e0b19fd8 ffff8806e0b19fd8 ffff880803d8ddc0
ffff880754b0aee0
[53468.423657]  0000000000000002 ffffffff81cbe060 ffffffff81cbe064
ffff880754b0aee0
[53468.423658] Call Trace:
[53468.423663]  [<ffffffff8164a7b9>] schedule+0x29/0x70
[53468.423664]  [<ffffffff8164aace>] schedule_preempt_disabled+0xe/0x10
[53468.423666]  [<ffffffff81648b8f>] __mutex_lock_slowpath+0x11f/0x1e0
[53468.423668]  [<ffffffff8152b6f1>] ? net_alloc_generic+0x21/0x30
[53468.423670]  [<ffffffff8164851a>] mutex_lock+0x2a/0x50
[53468.423671]  [<ffffffff8152be20>] copy_net_ns+0x70/0x110
[53468.423674]  [<ffffffff81073261>] create_new_namespaces+0x101/0x1b0
[53468.423676]  [<ffffffff810734ee>] unshare_nsproxy_namespaces+0x6e/0xb0
[53468.423678]  [<ffffffff81047809>] SyS_unshare+0x189/0x2b0

It's reproducible on 3.10.xx
Not clear whether net-next still has it. May be we just didn't run it
long enough.

We've tried to narrow it down over the last month, but didn't go too far.
It can happen on any of our tests. Most of them do: create namespaces,
veth, bridges, run iperf in namespaces, kill them, disconnect
interfaces and so on.

We tried numerous netns specific stress tests, but they all seem to be ok.
It's not clear what combination is causing wrong refcnt.

We tried to add debugging into dst_ifdown() thinking that dev_hold(),
dev_put() combination is causing it somehow, but amount of logs over
24hr is too much.

Similar bug description have been reported on ubuntu forums few times
without real solution. It's not 6549dd43c043

Inside VM with one virtual cpu it hits every 12hr or so.
On physical machine every 24hr or so.

Any advice on where to look or what to try would be greatly appreciated.

Thanks
Alexei
