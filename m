From: "Michael S. Tsirkin" <m.s.tsirkin@gmail.com>
Subject: possible recursive locking in udp4_lib_rcv
Date: Fri, 8 Aug 2008 02:46:14 +0300
Message-ID: <20080807234613.GA9598@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: LKML <linux-kernel@vger.kernel.org>, davem@davemloft.net,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:50818 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753207AbYHGXq2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 19:46:28 -0400
Received: by nf-out-0910.google.com with SMTP id d3so306103nfc.21
        for <netdev@vger.kernel.org>; Thu, 07 Aug 2008 16:46:25 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!
I noticed the following warnings when running on 2.6.27-rc2
with lockdep checker enabled:

[ 2912.004106] Initializing XFRM netlink socket
[ 2922.009629]
[ 2922.009632] =============================================
[ 2922.009640] [ INFO: possible recursive locking detected ]
[ 2922.009643] 2.6.27-rc2-mst-suspend #32
[ 2922.009645] ---------------------------------------------
[ 2922.009648] Xorg/5958 is trying to acquire lock:
[ 2922.009650]  (slock-AF_INET/1){-+..}, at: [<c02f105a>] __udp4_lib_rcv+0x34a/0x920
[ 2922.009660]
[ 2922.009661] but task is already holding lock:
[ 2922.009663]  (slock-AF_INET/1){-+..}, at: [<c02f105a>] __udp4_lib_rcv+0x34a/0x920
[ 2922.009669]
[ 2922.009669] other info that might help us debug this:
[ 2922.009672] 4 locks held by Xorg/5958:
[ 2922.009674]  #0:  (rcu_read_lock){..--}, at: [<c02af476>] netif_receive_skb+0x66/0x390
[ 2922.009681]  #1:  (rcu_read_lock){..--}, at: [<c02d1cc0>] ip_local_deliver_finish+0x30/0x1f0
[ 2922.009688]  #2:  (slock-AF_INET/1){-+..}, at: [<c02f105a>] __udp4_lib_rcv+0x34a/0x920
[ 2922.009694]  #3:  (rcu_read_lock){..--}, at: [<c02d1cc0>] ip_local_deliver_finish+0x30/0x1f0
[ 2922.009700]
 2922.009701] stack backtrace:
[ 2922.009704] Pid: 5958, comm: Xorg Not tainted 2.6.27-rc2-mst-suspend #32
[ 2922.009707]  [<c014acc6>] __lock_acquire+0xee6/0x1130
[ 2922.009713]  [<c014af71>] lock_acquire+0x61/0x80
[ 2922.009717]  [<c02f105a>] ? __udp4_lib_rcv+0x34a/0x920
[ 2922.009721]  [<c033008a>] _spin_lock_nested+0x2a/0x40
[ 2922.009726]  [<c02f105a>] ? __udp4_lib_rcv+0x34a/0x920
[ 2922.009731]  [<c02f105a>] __udp4_lib_rcv+0x34a/0x920
[ 2922.009738]  [<f8c81360>] ? ipv4_confirm+0x0/0xe0 [nf_conntrack_ipv4]
[ 2922.009746]  [<c02cb549>] ? nf_iterate+0x59/0x80
[ 2922.009751]  [<c02f1642>] udp_rcv+0x12/0x20
[ 2922.009755]  [<c02d1d3a>] ip_local_deliver_finish+0xaa/0x1f0
[ 2922.009758]  [<c02d1cc0>] ? ip_local_deliver_finish+0x30/0x1f0
[ 2922.009763]  [<c02d2250>] ip_local_deliver+0x30/0xa0
[ 2922.009766]  [<c02d1c90>] ? ip_local_deliver_finish+0x0/0x1f0
[ 2922.009770]  [<c030943b>] xfrm4_transport_finish+0x6b/0xf0
[ 2922.009776]  [<c0309170>] ? xfrm4_rcv_encap_finish+0x0/0x60
[ 2922.009780]  [<c031099d>] xfrm_input+0x22d/0x360
[ 2922.009784]  [<c03091f3>] xfrm4_rcv_encap+0x23/0x30
[ 2922.009788]  [<c030939b>] xfrm4_udp_encap_rcv+0x16b/0x1a0
[ 2922.009792]  [<c02f0bc4>] udp_queue_rcv_skb+0x174/0x2c0
[ 2922.009795]  [<c0330091>] ? _spin_lock_nested+0x31/0x40
[ 2922.009800]  [<c02f148e>] __udp4_lib_rcv+0x77e/0x920
[ 2922.009805]  [<f8c81360>] ? ipv4_confirm+0x0/0xe0 [nf_conntrack_ipv4]
[ 2922.009811]  [<c02cb549>] ? nf_iterate+0x59/0x80
[ 2922.009816]  [<c02f1642>] udp_rcv+0x12/0x20
[ 2922.009819]  [<c02d1d3a>] ip_local_deliver_finish+0xaa/0x1f0
[ 2922.009822]  [<c02d1cc0>] ? ip_local_deliver_finish+0x30/0x1f0
[ 2922.009827]  [<c02d2250>] ip_local_deliver+0x30/0xa0
[ 2922.009830]  [<c02d1c90>] ? ip_local_deliver_finish+0x0/0x1f0
[ 2922.009834]  [<c02d1a3e>] ip_rcv_finish+0xfe/0x350
[ 2922.009838]  [<c02cb719>] ? nf_hook_slow+0xd9/0x100
[ 2922.009842]  [<c02d1940>] ? ip_rcv_finish+0x0/0x350
[ 2922.009846]  [<c02d2136>] ip_rcv+0x1a6/0x290
[ 2922.009849]  [<c02d1940>] ? ip_rcv_finish+0x0/0x350
[ 2922.009853]  [<c02d1f90>] ? ip_rcv+0x0/0x290
[ 2922.009857]  [<c02af638>] netif_receive_skb+0x228/0x390
[ 2922.009860]  [<c02af476>] ? netif_receive_skb+0x66/0x390
[ 2922.009865]  [<f8cb9550>] ? packet_rcv_spkt+0x0/0x110 [af_packet]
[ 2922.009872]  [<c02b1fcc>] process_backlog+0x7c/0xe0
[ 2922.009876]  [<c02b1887>] net_rx_action+0xa7/0x150
[ 2922.009879]  [<c012ca47>] __do_softirq+0x87/0x100
[ 2922.009883]  [<c012cb17>] do_softirq+0x57/0x60
[ 2922.009887]  [<c012cea7>] irq_exit+0x77/0x90
[ 2922.009890]  [<c01060c5>] do_IRQ+0x45/0x80
[ 2922.009894]  [<c01498f4>] ? trace_hardirqs_on_caller+0xc4/0x150
[ 2922.009899]  [<c010463c>] common_interrupt+0x28/0x30
[ 2922.009903]  =======================
[ 2922.277171] PPP generic driver version 2.4.2

(I'm not sure what I did, something related to ipsec and/or ppp).

I have not seen this with v2.6.26 or earlier.
Any idea whether this is a real bug or lockdep false positive?

-- 
MST
