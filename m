From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Mon, 11 Feb 2008 22:19:35 +0000
Message-ID: <47B0C9F7.5040200@katalix.com>
References: <200802110922.m1B9MKQ4003674@quickie.katalix.com> <47B09A90.7040508@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:46267 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752741AbYBKWTk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Feb 2008 17:19:40 -0500
In-Reply-To: <47B09A90.7040508@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> James Chapman wrote, On 02/11/2008 10:22 AM:
> 
>> Fix locking issues in the pppol2tp driver which can cause a kernel
>> crash on SMP boxes when hundreds of L2TP sessions are created/deleted
>> simultaneously (ISP environment). The driver was violating read_lock()
>> and write_lock() scheduling rules so we now consistently use the _irq
>> variants of the lock functions.
> ... 
> 
> Hi,
> 
> Could you explain what exactly scheduling rules do you mean here,
> and why disabling interrupts is the best solution for this?

Below is example output from lockdep. The oops is reproducible when 
creating/deleting lots of sessions while passing data. The lock is being 
acquired for read and write in softirq contexts.

Is there a better way to fix this?

=================================
[ INFO: inconsistent lock state ]
2.6.24-core2 #1
---------------------------------
inconsistent {in-softirq-R} -> {softirq-on-W} usage.
openl2tpd/3215 [HC0[0]:SC0[0]:HE1:SE1] takes:
   (&tunnel->hlist_lock){---?}, at: [<f8eea157>]
pppol2tp_connect+0x517/0x6d0 [pppol2tp]
{in-softirq-R} state was registered at:
    [<c014edaf>] __lock_acquire+0x6bf/0x10a0
    [<c03ee75b>] fn_hash_lookup+0x1b/0xe0
    [<c014f804>] lock_acquire+0x74/0xa0
    [<f8ee859f>] pppol2tp_session_find+0x1f/0x80 [pppol2tp]
    [<c040427a>] _read_lock+0x2a/0x40
    [<f8ee859f>] pppol2tp_session_find+0x1f/0x80 [pppol2tp]
    [<f8ee859f>] pppol2tp_session_find+0x1f/0x80 [pppol2tp]
    [<f8ee8dc8>] pppol2tp_recv_core+0xd8/0x960 [pppol2tp]
    [<f8d3f72a>] ipt_do_table+0x23a/0x500 [ip_tables]
    [<f8ee967e>] pppol2tp_udp_encap_recv+0x2e/0x70 [pppol2tp]
    [<c0403fb4>] _read_unlock+0x14/0x20
    [<c03dd696>] udp_queue_rcv_skb+0x106/0x2a0
    [<c03ddc5a>] __udp4_lib_rcv+0x42a/0x7e0
    [<f8d57090>] ipt_hook+0x0/0x20 [iptable_filter]
    [<c03bc2da>] ip_local_deliver_finish+0xca/0x1c0
    [<c03bc23e>] ip_local_deliver_finish+0x2e/0x1c0
    [<c03bbfaf>] ip_rcv_finish+0xff/0x360
    [<c03bc6dc>] ip_rcv+0x20c/0x2a0
    [<c03bbeb0>] ip_rcv_finish+0x0/0x360
    [<c039ad87>] netif_receive_skb+0x317/0x4b0
    [<c039ab70>] netif_receive_skb+0x100/0x4b0
    [<f8d9627a>] e1000_clean_rx_irq_ps+0x28a/0x560 [e1000]
    [<f8d95ff0>] e1000_clean_rx_irq_ps+0x0/0x560 [e1000]
    [<f8d9384d>] e1000_clean+0x5d/0x290 [e1000]
    [<c039d580>] net_rx_action+0x1a0/0x2a0
    [<c039d43f>] net_rx_action+0x5f/0x2a0
    [<c0131e72>] __do_softirq+0x92/0x120
    [<c0131f78>] do_softirq+0x78/0x80
    [<c010b15a>] do_IRQ+0x4a/0xa0
    [<c0108dcc>] common_interrupt+0x24/0x34
    [<c0108dd6>] common_interrupt+0x2e/0x34
    [<c01062d6>] mwait_idle_with_hints+0x46/0x60
    [<c0106550>] mwait_idle+0x0/0x20
    [<c0106694>] cpu_idle+0x74/0xe0
    [<c0536a9a>] start_kernel+0x30a/0x3a0
    [<c0536150>] unknown_bootoption+0x0/0x1f0
    [<ffffffff>] 0xffffffff
irq event stamp: 275
hardirqs last  enabled at (275): [<c0132317>] local_bh_enable_ip+0xa7/0x120
hardirqs last disabled at (273): [<c01322a6>] local_bh_enable_ip+0x36/0x120
softirqs last  enabled at (274): [<f8eab8bc>]
ppp_register_channel+0xdc/0xf0 [ppp_generic]
softirqs last disabled at (272): [<c040410b>] _spin_lock_bh+0xb/0x40


-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

