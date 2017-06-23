From: Jean-Philippe Menil <jpmenil@gmail.com>
Subject: Re: BUG: KASAN: use-after-free in free_old_xmit_skbs
Date: Fri, 23 Jun 2017 11:33:21 +0200
Message-ID: <c1271047-b836-5160-dcd8-717d32c5e9f0@gmail.com>
References: <d2e8cf65-ea3d-7db2-9382-a063daf1168a@gmail.com>
 <20170605050423-mutt-send-email-mst@kernel.org>
 <20170606024211-mutt-send-email-mst@kernel.org>
 <CAOTcU=u_HSMQiwDF3Snv5P8mT-b_Aepeb=Z9gbLd1j=2P+Yy+A@mail.gmail.com>
 <20170622215125-mutt-send-email-mst@kernel.org>
 <4f6d4342-8476-882e-e7a8-b3f0ebd20d95@redhat.com>
Reply-To: jpmenil@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
        John Fastabend <john.fastabend@gmail.com>,
        virtualization@lists.linux-foundation.org, qemu-devel@nongnu.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:36120 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754233AbdFWJdY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 05:33:24 -0400
Received: by mail-wr0-f195.google.com with SMTP id 77so11093122wrb.3
        for <netdev@vger.kernel.org>; Fri, 23 Jun 2017 02:33:23 -0700 (PDT)
In-Reply-To: <4f6d4342-8476-882e-e7a8-b3f0ebd20d95@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/23/2017 10:43 AM, Jason Wang wrote:
> 
> 
> On 2017年06月23日 02:53, Michael S. Tsirkin wrote:
>> On Thu, Jun 22, 2017 at 08:15:58AM +0200, jean-philippe menil wrote:
>>> 2017-06-06 1:52 GMT+02:00 Michael S. Tsirkin <mst@redhat.com>:
>>>
>>>      On Mon, Jun 05, 2017 at 05:08:25AM +0300, Michael S. Tsirkin wrote:
>>>      > On Mon, Jun 05, 2017 at 12:48:53AM +0200, Jean-Philippe Menil 
>>> wrote:
>>>      > > Hi,
>>>      > >
>>>      > > while playing with xdp and ebpf, i'm hitting the following:
>>>      > >
>>>      > > [  309.993136]
>>>      > > 
>>> ==================================================================
>>>      > > [  309.994735] BUG: KASAN: use-after-free in
>>>      > > free_old_xmit_skbs.isra.29+0x2b7/0x2e0 [virtio_net]
>>>      > > [  309.998396] Read of size 8 at addr ffff88006aa64220 by 
>>> task sshd/323
>>>      > > [  310.000650]
>>>      > > [  310.002305] CPU: 1 PID: 323 Comm: sshd Not tainted 
>>> 4.12.0-rc3+ #2
>>>      > > [  310.004018] Hardware name: QEMU Standard PC (i440FX + 
>>> PIIX, 1996),
>>>      BIOS
>>>      > > 1.10.2-20170228_101828-anatol 04/01/2014
>> ...
>>
>>>      >
>>>      > Since commit 680557cf79f82623e2c4fd42733077d60a843513
>>>      >     virtio_net: rework mergeable buffer handling
>>>      >
>>>      > we no longer must do the resets, we now have enough space
>>>      > to store a bit saying whether a buffer is xdp one or not.
>>>      >
>>>      > And that's probably a cleaner way to fix these issues than
>>>      > try to find and fix the race condition.
>>>      >
>>>      > John?
>>>      >
>>>      > --
>>>      > MST
>>>
>>>
>>>      I think I see the source of the race. virtio net calls
>>>      netif_device_detach and assumes no packets will be sent after
>>>      this point. However, all it does is stop all queues so
>>>      no new packets will be transmitted.
>>>
>>>      Try locking with HARD_TX_LOCK?
>>>
>>>      --
>>>      MST
>>>
>>>
>>> Hi Michael,
>>>
>>> from what i see, the race appear when we hit virtnet_reset in 
>>> virtnet_xdp_set.
>>> virtnet_reset
>>>    _remove_vq_common
>>>      virtnet_del_vqs
>>>        virtnet_free_queues
>>>          kfree(vi->sq)
>>> when the xdp program (with two instances of the program to trigger it 
>>> faster)
>>> is added or removed.
>>>
>>> It's easily repeatable, with 2 cpus and 4 queues on the qemu command 
>>> line,
>>> running the xdp_ttl tool from Jesper.
>>>
>>> For now, i'm able to continue my qualification, testing if xdp_qp is 
>>> not null,
>>> but do not seem to be a sustainable trick.
>>> if (xdp_qp && vi->xdp_queues_pairs != xdp_qp)
>>>
>>> Maybe it will be more clear to you with theses informations.
>>>
>>> Best regards.
>>>
>>> Jean-Philippe
>>
>> I'm pretty clear about the issue here, I was trying to figure out a fix.
>> Jason, any thoughts?
>>
>>
> 
> Hi Jean:
> 
> Does the following fix this issue? (I can't reproduce it locally through 
> xdp_ttl)
> 
> Thanks
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 1f8c15c..3e65c3f 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1801,7 +1801,9 @@ static void virtnet_freeze_down(struct 
> virtio_device *vdev)
>          /* Make sure no work handler is accessing the device */
>          flush_work(&vi->config_work);
> 
> +       netif_tx_lock_bh(vi->dev);
>          netif_device_detach(vi->dev);
> +       netif_tx_unlock_bh(vi->dev);
>          cancel_delayed_work_sync(&vi->refill);
> 

Hi Jason,

unfortunately, same crash on same place, the lock did not help.

[  574.522886] 
==================================================================
[  574.527393] BUG: KASAN: use-after-free in 
free_old_xmit_skbs.isra.28+0x29b/0x2b0 [virtio_net]
[  574.531934] Read of size 8 at addr ffff88005d220020 by task iperf/2252
[  574.536296]
[  574.539729] CPU: 1 PID: 2252 Comm: iperf Not tainted 4.12.0-rc5+ #5
[  574.543916] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), 
BIOS 1.10.2-20170228_101828-anatol 04/01/2014
[  574.552046] Call Trace:
[  574.555648]  dump_stack+0xb3/0x10b
[  574.559471]  ? free_old_xmit_skbs.isra.28+0x29b/0x2b0 [virtio_net]
[  574.563578]  print_address_description+0x6a/0x280
[  574.567253]  ? free_old_xmit_skbs.isra.28+0x29b/0x2b0 [virtio_net]
[  574.571223]  kasan_report+0x22b/0x340
[  574.574698]  __asan_report_load8_noabort+0x14/0x20
[  574.578490]  free_old_xmit_skbs.isra.28+0x29b/0x2b0 [virtio_net]
[  574.582586]  ? dev_queue_xmit_nit+0x5fb/0x850
[  574.586348]  ? virtnet_del_vqs+0xf0/0xf0 [virtio_net]
[  574.590153]  ? __skb_clone+0x24a/0x7d0
[  574.593835]  start_xmit+0x15a/0x1620 [virtio_net]
[  574.597939]  dev_hard_start_xmit+0x17f/0x7e0
[  574.601832]  sch_direct_xmit+0x2a8/0x5d0
[  574.605665]  ? dev_deactivate_queue.constprop.31+0x150/0x150
[  574.609827]  __dev_queue_xmit+0x1124/0x18b0
[  574.613595]  ? selinux_ip_postroute+0x4b2/0xa90
[  574.617928]  ? netdev_pick_tx+0x2d0/0x2d0
[  574.621852]  ? mark_held_locks+0xc8/0x120
[  574.625673]  ? ip_finish_output+0x626/0x9b0
[  574.631679]  ? ip_finish_output2+0xb44/0x1160
[  574.637642]  dev_queue_xmit+0x17/0x20
[  574.641693]  ip_finish_output2+0xcd1/0x1160
[  574.645621]  ? do_add_counters+0x480/0x480
[  574.649554]  ? do_add_counters+0x403/0x480
[  574.653209]  ? ip_copy_metadata+0x630/0x630
[  574.657066]  ip_finish_output+0x626/0x9b0
[  574.660482]  ? ip_finish_output+0x626/0x9b0
[  574.663905]  ip_output+0x1e2/0x580
[  574.667235]  ? ip_mc_output+0xe80/0xe80
[  574.670574]  ? ip_fragment.constprop.57+0x200/0x200
[  574.673949]  ip_local_out+0x95/0x160
[  574.677249]  ? __sk_dst_check+0xa7/0x260
[  574.680446]  ip_queue_xmit+0x889/0x17f0
[  574.683575]  ? __tcp_v4_send_check+0x1b8/0x350
[  574.686801]  tcp_transmit_skb+0x194a/0x2db0
[  574.689832]  ? __tcp_select_window+0x500/0x500
[  574.693310]  ? sched_clock_cpu+0x1b/0x190
[  574.696371]  ? tcp_grow_window.isra.24+0x2a8/0x4b0
[  574.699509]  tcp_send_ack+0x46f/0x710
[  574.702395]  __tcp_ack_snd_check+0x233/0x380
[  574.705365]  tcp_rcv_established+0x14eb/0x2230
[  574.708332]  ? trace_hardirqs_on_caller+0x3f4/0x560
[  574.711800]  ? tcp_data_queue+0x3e70/0x3e70
[  574.714761]  ? sk_wait_data+0x2af/0x400
[  574.719220]  tcp_v4_do_rcv+0x56c/0x820
[  574.724018]  tcp_prequeue_process+0x18f/0x2c0
[  574.729062]  tcp_recvmsg+0xff6/0x26a0
[  574.734615]  ? tcp_tx_timestamp.part.27+0x290/0x290
[  574.739519]  ? _copy_from_user+0x84/0xe0
[  574.744115]  ? rw_copy_check_uvector+0x1f6/0x290
[  574.748722]  ? sock_has_perm+0x1e4/0x270
[  574.751537]  ? selinux_tun_dev_create+0xc0/0xc0
[  574.754068]  inet_recvmsg+0x117/0x530
[  574.756823]  ? memzero_page+0x130/0x130
[  574.759503]  ? inet_sk_rebuild_header+0x1880/0x1880
[  574.762303]  ? selinux_socket_recvmsg+0x36/0x40
[  574.765114]  ? security_socket_recvmsg+0x8f/0xc0
[  574.768156]  ? inet_sk_rebuild_header+0x1880/0x1880
[  574.771181]  sock_recvmsg+0xd7/0x110
[  574.773972]  ? __sock_recv_wifi_status+0x180/0x180
[  574.777002]  ___sys_recvmsg+0x24d/0x560
[  574.779789]  ? ___sys_sendmsg+0x920/0x920
[  574.782734]  ? __fget+0x200/0x380
[  574.785657]  ? lock_downgrade+0x650/0x650
[  574.788584]  ? __fget+0x229/0x380
[  574.791362]  ? __fget_light+0xa1/0x1f0
[  574.794162]  ? __fdget+0x18/0x20
[  574.796832]  __sys_recvmsg+0xce/0x170
[  574.799572]  ? __sys_recvmsg+0xce/0x170
[  574.802695]  ? SyS_sendmmsg+0x60/0x60
[  574.805461]  ? __schedule+0x7cb/0x1a70
[  574.808211]  ? retint_kernel+0x10/0x10
[  574.810922]  ? trace_hardirqs_on_caller+0x3f4/0x560
[  574.813890]  ? trace_hardirqs_on_thunk+0x1a/0x1c
[  574.816783]  ? trace_hardirqs_on_caller+0x3f4/0x560
[  574.819693]  SyS_recvmsg+0x2d/0x50
[  574.822829]  entry_SYSCALL_64_fastpath+0x1f/0xbe
[  574.825697] RIP: 0033:0x7f7fbd77e3c0
[  574.828366] RSP: 002b:00007f7fba39ed50 EFLAGS: 00000293 ORIG_RAX: 
000000000000002f
[  574.833588] RAX: ffffffffffffffda RBX: 0000000000000008 RCX: 
00007f7fbd77e3c0
[  574.838882] RDX: 0000000000000000 RSI: 00007f7fba39edb0 RDI: 
0000000000000008
[  574.844377] RBP: 0000000000000046 R08: 0000000000000000 R09: 
000000a0ff7159c1
[  574.849937] R10: 00143f7b62d9620b R11: 0000000000000293 R12: 
0000000000000000
[  574.855391] R13: 0000000004000000 R14: 00007f7fa0000b10 R15: 
0000000000000001
[  574.860146]
[  574.862738] Allocated by task 2291:
[  574.865528]  save_stack_trace+0x16/0x20
[  574.868370]  save_stack+0x46/0xd0
[  574.871096]  kasan_kmalloc+0xad/0xe0
[  574.873838]  __kmalloc+0x115/0x2d0
[  574.876524]  __vring_new_virtqueue+0x6a/0x790
[  574.879432]  vring_create_virtqueue+0x203/0x380
[  574.882367]  setup_vq+0x159/0x660
[  574.885115]  vp_setup_vq+0xbe/0x390
[  574.887802]  vp_find_vqs_msix+0x568/0xb90
[  574.890494]  vp_find_vqs+0x93/0x460
[  574.893175]  vp_modern_find_vqs+0x44/0x170
[  574.895932]  init_vqs+0x8eb/0x1150 [virtio_net]
[  574.898778]  virtnet_restore_up+0x4c/0x5c0 [virtio_net]
[  574.901889]  virtnet_xdp+0x820/0xd00 [virtio_net]
[  574.904858]  dev_change_xdp_fd+0x1bb/0x340
[  574.907708]  do_setlink+0x23fb/0x2c00
[  574.910491]  rtnl_setlink+0x280/0x340
[  574.913448]  rtnetlink_rcv_msg+0x288/0x680
[  574.916348]  netlink_rcv_skb+0x340/0x470
[  574.919165]  rtnetlink_rcv+0x2a/0x40
[  574.922027]  netlink_unicast+0x58d/0x860
[  574.924897]  netlink_sendmsg+0x8d2/0xca0
[  574.927815]  sock_sendmsg+0xca/0x110
[  574.930708]  SYSC_sendto+0x20d/0x340
[  574.933562]  SyS_sendto+0x40/0x50
[  574.936380]  entry_SYSCALL_64_fastpath+0x1f/0xbe
[  574.939322]
[  574.941724] Freed by task 2291:
[  574.944389]  save_stack_trace+0x16/0x20
[  574.947107]  save_stack+0x46/0xd0
[  574.949893]  kasan_slab_free+0x72/0xc0
[  574.952526]  kfree+0xe6/0x2c0
[  574.955082]  vring_del_virtqueue+0xef/0x220
[  574.957773]  del_vq+0x126/0x270
[  574.960283]  vp_del_vqs+0x1f5/0xa30
[  574.962743]  virtnet_del_vqs+0xb7/0xf0 [virtio_net]
[  574.965930]  virtnet_xdp+0x7b8/0xd00 [virtio_net]
[  574.968762]  dev_change_xdp_fd+0x309/0x340
[  574.971487]  do_setlink+0x23fb/0x2c00
[  574.974041]  rtnl_setlink+0x280/0x340
[  574.976727]  rtnetlink_rcv_msg+0x288/0x680
[  574.979366]  netlink_rcv_skb+0x340/0x470
[  574.981949]  rtnetlink_rcv+0x2a/0x40
[  574.984462]  netlink_unicast+0x58d/0x860
[  574.987151]  netlink_sendmsg+0x8d2/0xca0
[  574.989736]  sock_sendmsg+0xca/0x110
[  574.992351]  SYSC_sendto+0x20d/0x340
[  574.995262]  SyS_sendto+0x40/0x50
[  574.998959]  entry_SYSCALL_64_fastpath+0x1f/0xbe
[  575.001625]
[  575.003976] The buggy address belongs to the object at ffff88005d220000
[  575.003976]  which belongs to the cache kmalloc-8192 of size 8192
[  575.010183] The buggy address is located 32 bytes inside of
[  575.010183]  8192-byte region [ffff88005d220000, ffff88005d222000)
[  575.016265] The buggy address belongs to the page:
[  575.019125] page:ffffea0001748800 count:1 mapcount:0 mapping: 
  (null) index:0x0 compound_mapcount: 0
[  575.025320] flags: 0x100000000008100(slab|head)
[  575.028167] raw: 0100000000008100 0000000000000000 0000000000000000 
0000000100030003
[  575.031632] raw: dead000000000100 dead000000000200 ffff88006c802280 
0000000000000000
[  575.035447] page dumped because: kasan: bad access detected
[  575.039170]
[  575.041893] Memory state around the buggy address:
[  575.045408]  ffff88005d21ff00: fc fc fc fc fc fc fc fc fc fc fc fc fc 
fc fc fc
[  575.051399]  ffff88005d21ff80: fc fc fc fc fc fc fc fc fc fc fc fc fc 
fc fc fc
[  575.057558] >ffff88005d220000: fb fb fb fb fb fb fb fb fb fb fb fb fb 
fb fb fb
[  575.063760]                                ^
[  575.069310]  ffff88005d220080: fb fb fb fb fb fb fb fb fb fb fb fb fb 
fb fb fb
[  575.075359]  ffff88005d220100: fb fb fb fb fb fb fb fb fb fb fb fb fb 
fb fb fb
[  575.081461] 
==================================================================
[  575.086914] Disabling lock debugging due to kernel taint
[  575.090717] virtio_net virtio1: output.0:id 31 is not a head!
[  575.096336] net enp0s4: Unexpected TXQ (0) queue failure: -5
[  575.102000] net enp0s4: Unexpected TXQ (0) queue failure: -5
[  575.107383] net enp0s4: Unexpected TXQ (0) queue failure: -5
[  575.112785] net enp0s4: Unexpected TXQ (0) queue failure: -5
[  575.118228] net enp0s4: Unexpected TXQ (0) queue failure: -5


(gdb) l *(free_old_xmit_skbs+0x29b)
0x20db is in free_old_xmit_skbs (drivers/net/virtio_net.c:1051).
1046	
1047	static void free_old_xmit_skbs(struct send_queue *sq)
1048	{
1049		struct sk_buff *skb;
1050		unsigned int len;
1051		struct virtnet_info *vi = sq->vq->vdev->priv;
1052		struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
1053		unsigned int packets = 0;
1054		unsigned int bytes = 0;
1055

Best regards,

Jean-Philippe
