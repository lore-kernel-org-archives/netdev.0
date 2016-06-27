From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] mlx4: set csum_complete_sw bit when fixing complete csum
Date: Mon, 27 Jun 2016 14:44:34 -0700
Message-ID: <CAM_iQpUBQqV3oC7=WqyNtu58HmbJbV29yz6_r_ib6XqWpw7VGg@mail.gmail.com>
References: <1467051724-8314-1-git-send-email-xiyou.wangcong@gmail.com> <CAJ3xEMjgb6K1QeWZKNLWJWk4Ch++FmcV-PPWp7VJzWLYSHo8YQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Shani Michaeli <shanim@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Carol L Soto <clsoto@us.ibm.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:32920 "EHLO
	mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751749AbcF0Voz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 17:44:55 -0400
Received: by mail-qk0-f194.google.com with SMTP id n132so3903357qka.0
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 14:44:54 -0700 (PDT)
In-Reply-To: <CAJ3xEMjgb6K1QeWZKNLWJWk4Ch++FmcV-PPWp7VJzWLYSHo8YQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 27, 2016 at 2:08 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Mon, Jun 27, 2016 at 9:22 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> The stack doesn't trust the complete csum by hardware
>> even when it is correct.
>
> Can you explain that a little further?

Sure, here is the code in __skb_checksum_complete():

        /* skb->csum holds pseudo checksum */
        sum = csum_fold(csum_add(skb->csum, csum));
        if (likely(!sum)) {
                if (unlikely(skb->ip_summed == CHECKSUM_COMPLETE) &&
                    !skb->csum_complete_sw)
                        netdev_rx_csum_fault(skb->dev);
        }

So when sum == 0, it means the checksum is correct. And
we already set ->ip_summed to CHECKSUM_COMPLETE
after check_csum(), and ->csum_complete_sw is initialized
to 0 when we allocate the skb. This is why we trigger
netdev_rx_csum_fault().


>
>> In the case we fix csum by ourself
>> probably it is safe to just mark it as completed by software.
>
>> This should shut up a kernel warning from netdev_rx_csum_fault()
>> with mlx4 driver for ICMP packets.
>
> can you point/paste the exact warning and how to reproduce that? is
> that as simple as running ping and/or ping6?

Yes, ping is enough to reproduce it every time.

The warning is below:

[ 8693.680997] eth0: hw csum failure
[ 8693.681003] CPU: 5 PID: 34 Comm: ksoftirqd/5 Not tainted 4.1.20-t6.el5 #1
[ 8693.681005] Hardware name: SYNNEX HYVE-ZEUS/X9DRD-iF, BIOS 3.0.4 12/06/2013
[ 8693.681008]  0000000000000000 ffff88085c15fae8 ffffffff81502872
ffff881051397800
[ 8693.681011]  ffff881054c08b01 ffff88085c15fb08 ffffffff814569c5
0000000000000000
[ 8693.681014]  ffff8808572d7200 ffff88085c15fb38 ffffffff81450738
ffff8808572d7200
[ 8693.681017] Call Trace:
[ 8693.681025]  [<ffffffff81502872>] dump_stack+0x4d/0x63
[ 8693.681030]  [<ffffffff814569c5>] netdev_rx_csum_fault+0x38/0x3c
[ 8693.681033]  [<ffffffff81450738>] __skb_checksum_complete+0x6e/0xb6
[ 8693.681036]  [<ffffffff814b65d8>] icmp_rcv+0x17a/0x32f
[ 8693.681040]  [<ffffffff8148b7f0>] ip_local_deliver_finish+0xd1/0x153
[ 8693.681042]  [<ffffffff8148b9f7>] ip_local_deliver+0x8d/0x94
[ 8693.681045]  [<ffffffff8148b71f>] ? xfrm4_policy_check.constprop.6+0x55/0x55
[ 8693.681048]  [<ffffffff8148b651>] ip_rcv_finish+0x289/0x2cc
[ 8693.681050]  [<ffffffff8148bc7b>] ip_rcv+0x27d/0x30a
[ 8693.681053]  [<ffffffff81457e01>] __netif_receive_skb_core+0x3f2/0x483
[ 8693.681056]  [<ffffffff81457eaa>] __netif_receive_skb+0x18/0x5a
[ 8693.681058]  [<ffffffff81457f7c>] process_backlog+0x90/0x10c
[ 8693.681061]  [<ffffffff814596e0>] net_rx_action+0x101/0x2aa
[ 8693.681066]  [<ffffffff8106c39f>] __do_softirq+0x10c/0x26d
[ 8693.681068]  [<ffffffff8106c51a>] run_ksoftirqd+0x1a/0x2f
[ 8693.681071]  [<ffffffff81083675>] smpboot_thread_fn+0x149/0x167
[ 8693.681074]  [<ffffffff8108352c>] ? sort_range+0x24/0x24
[ 8693.681076]  [<ffffffff8108352c>] ? sort_range+0x24/0x24
[ 8693.681080]  [<ffffffff81080d9c>] kthread+0xae/0xb6
[ 8693.681082]  [<ffffffff81080303>] ? add_sysfs_param.isra.4+0xe1/0x18c
[ 8693.681085]  [<ffffffff81080cee>] ? __kthread_parkme+0x61/0x61
[ 8693.681088]  [<ffffffff81508152>] ret_from_fork+0x42/0x70
[ 8693.681090]  [<ffffffff81080cee>] ? __kthread_parkme+0x61/0x61
