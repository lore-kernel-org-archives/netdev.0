From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: NMI lockup, 2.6.26 release
Date: Thu, 14 Aug 2008 18:07:12 +0300
Message-ID: <200808141807.13265.denys@visp.net.lb>
References: <200807222142.23710.denys@visp.net.lb> <200808131102.34988.denys@visp.net.lb> <20080813084931.GC5367@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:57059 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755257AbYHNPIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 11:08:18 -0400
In-Reply-To: <20080813084931.GC5367@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2.6.27 rc3-git2 i am getting softlockup after 60-120 seconds after running.
Netconsole is almost dead, i tried to use it get stacktrace, but it is sending 
few lines of header only.

It happens when many tc sessions running in parallel, thats only info i have now.

Update: got interesting info, maybe this is the issue:


Aug 14 18:07:09 194.146.153.146 [   41.496997]
Aug 14 18:07:09 194.146.153.146 [   41.496997] =============================================
Aug 14 18:07:09 194.146.153.146 [   41.496997] [ INFO: possible recursive locking detected ]
Aug 14 18:07:09 194.146.153.146 [   41.496997] 2.6.27-rc3-git2-build-0030 #5
Aug 14 18:07:09 194.146.153.146 [   41.496997] ---------------------------------------------
Aug 14 18:07:09 194.146.153.146 [   41.496997] swapper/0 is trying to acquire lock:
Aug 14 18:07:09 194.146.153.146 [   41.496997]  (&list->lock
Aug 14 18:07:09 194.146.153.146 #2
Aug 14 18:07:09 194.146.153.146 ){-+..}
Aug 14 18:07:09 194.146.153.146 , at:
Aug 14 18:07:09 194.146.153.146 [<c02617d4>] dev_queue_xmit+0x31f/0x481
Aug 14 18:07:09 194.146.153.146 [   41.496997]
Aug 14 18:07:09 194.146.153.146 [   41.496997] but task is already holding lock:
Aug 14 18:07:09 194.146.153.146 [   41.496997]  (&list->lock
Aug 14 18:07:09 194.146.153.146 #2
Aug 14 18:07:09 194.146.153.146 ){-+..}
Aug 14 18:07:09 194.146.153.146 , at:
Aug 14 18:07:09 194.146.153.146 [<c0260d17>] netif_receive_skb+0x26e/0x3f6
Aug 14 18:07:09 194.146.153.146 [   41.496997]
Aug 14 18:07:09 194.146.153.146 [   41.496997] other info that might help us debug this:
Aug 14 18:07:09 194.146.153.146 [   41.496997] 5 locks held by swapper/0:
Aug 14 18:07:09 194.146.153.146 [   41.496997]  #0:
Aug 14 18:07:09 194.146.153.146 (rcu_read_lock
Aug 14 18:07:09 194.146.153.146 ){..--}
Aug 14 18:07:09 194.146.153.146 , at:
Aug 14 18:07:09 194.146.153.146 [<c025f873>] net_rx_action+0x54/0x1e5
Aug 14 18:07:09 194.146.153.146 [   41.496997]  #1:
Aug 14 18:07:09 194.146.153.146 (rcu_read_lock
Aug 14 18:07:09 194.146.153.146 ){..--}
Aug 14 18:07:09 194.146.153.146 , at:
Aug 14 18:07:09 194.146.153.146 [<c0260bb5>] netif_receive_skb+0x10c/0x3f6
Aug 14 18:07:09 194.146.153.146 [   41.496997]  #2:
Aug 14 18:07:09 194.146.153.146 (&list->lock
Aug 14 18:07:09 194.146.153.146 #2
Aug 14 18:07:09 194.146.153.146 ){-+..}
Aug 14 18:07:09 194.146.153.146 , at:
Aug 14 18:07:09 194.146.153.146 [<c0260d17>] netif_receive_skb+0x26e/0x3f6
Aug 14 18:07:09 194.146.153.146 [   41.496997]  #3:
Aug 14 18:07:09 194.146.153.146 (&p->tcfc_lock
Aug 14 18:07:09 194.146.153.146 ){-+..}
Aug 14 18:07:09 194.146.153.146 , at:
Aug 14 18:07:09 194.146.153.146 [<f8a602fc>] tcf_mirred+0x1f/0x14b [act_mirred]
Aug 14 18:07:09 194.146.153.146 [   41.496997]  #4:
Aug 14 18:07:09 194.146.153.146 (rcu_read_lock
Aug 14 18:07:09 194.146.153.146 ){..--}
Aug 14 18:07:09 194.146.153.146 , at:
Aug 14 18:07:09 194.146.153.146 [<c0261635>] dev_queue_xmit+0x180/0x481
Aug 14 18:07:09 194.146.153.146 [   41.496997]
Aug 14 18:07:09 194.146.153.146 [   41.496997] stack backtrace:
Aug 14 18:07:09 194.146.153.146 [   41.496997] Pid: 0, comm: swapper Not tainted 2.6.27-rc3-git2-build-0030 #5
Aug 14 18:07:09 194.146.153.146 [   41.496997]  [<c02ba433>]
Aug 14 18:07:09 194.146.153.146 ?
Aug 14 18:07:09 194.146.153.146 printk+0xf/0x14
Aug 14 18:07:09 194.146.153.146 [   41.496997]  [<c013ed12>]
Aug 14 18:07:09 194.146.153.146 __lock_acquire+0xb3a/0x118a
Aug 14 18:07:09 194.146.153.146 [   41.496997]  [<c013f3aa>]
Aug 14 18:07:09 194.146.153.146 lock_acquire+0x48/0x64
Aug 14 18:07:09 194.146.153.146 [   41.496997]  [<c02617d4>]
Aug 14 18:07:09 194.146.153.146 ?
Aug 14 18:07:09 194.146.153.146 dev_queue_xmit+0x31f/0x481
Aug 14 18:07:09 194.146.153.146 [   41.496997]  [<c02bc901>]
Aug 14 18:07:09 194.146.153.146 _spin_lock+0x1b/0x2a
Aug 14 18:07:09 194.146.153.146 [   41.496997]  [<c02617d4>]
Aug 14 18:07:09 194.146.153.146 ?
Aug 14 18:07:09 194.146.153.146 dev_queue_xmit+0x31f/0x481
Aug 14 18:07:09 194.146.153.146 [   41.496997]  [<c02617d4>]
Aug 14 18:07:09 194.146.153.146 dev_queue_xmit+0x31f/0x481
Aug 14 18:07:09 194.146.153.146 [   41.496997]  [<f8a60408>]
Aug 14 18:07:09 194.146.153.146 tcf_mirred+0x12b/0x14b [act_mirred]
Aug 14 18:07:09 194.146.153.146 [   41.496997]  [<f8a602dd>]
Aug 14 18:07:09 194.146.153.146 ?
Aug 14 18:07:09 194.146.153.146 tcf_mirred+0x0/0x14b [act_mirred]
Aug 14 18:07:09 194.146.153.146 [   41.496997]  [<c027102b>]
Aug 14 18:07:09 194.146.153.146 tcf_action_exec+0x43/0x72
Aug 14 18:07:09 194.146.153.146 [   41.496997]  [<f8a92cd5>]
Aug 14 18:07:09 194.146.153.146 u32_classify+0xf4/0x20b [cls_u32]
Aug 14 18:07:09 194.146.153.146 [   41.496997]  [<c013dabf>]
Aug 14 18:07:09 194.146.153.146 ?
Aug 14 18:07:09 194.146.153.146 trace_hardirqs_on+0xb/0xd
Aug 14 18:07:09 194.146.153.146 [   41.496997]  [<c026ea85>]
Aug 14 18:07:09 194.146.153.146 tc_classify_compat+0x2e/0x5d
Aug 14 18:07:09 194.146.153.146 [   41.496997]  [<c026ebcd>]
Aug 14 18:07:09 194.146.153.146 tc_classify+0x17/0x72
Aug 14 18:07:09 194.146.153.146 [   41.496997]  [<f8a9c0b2>]
Aug 14 18:07:09 194.146.153.146 ingress_enqueue+0x1a/0x54 [sch_ingress]
Aug 14 18:07:09 194.146.153.146 [   41.496997]  [<c0260d31>]
Aug 14 18:07:09 194.146.153.146 netif_receive_skb+0x288/0x3f6
Aug 14 18:07:09 194.146.153.146 [   41.496997]  [<c0260f13>]
Aug 14 18:07:09 194.146.153.146 process_backlog+0x74/0xcb
Aug 14 18:07:09 194.146.153.146 [   41.496997]  [<c025f8da>]
Aug 14 18:07:09 194.146.153.146 net_rx_action+0xbb/0x1e5
Aug 14 18:07:09 194.146.153.146 [   41.496997]  [<c0126203>]
Aug 14 18:07:09 194.146.153.146 __do_softirq+0x7b/0xf4
Aug 14 18:07:09 194.146.153.146 [   41.496997]  [<c0126188>]
Aug 14 18:07:09 194.146.153.146 ?
Aug 14 18:07:09 194.146.153.146 __do_softirq+0x0/0xf4
Aug 14 18:07:09 194.146.153.146 [   41.496997]  [<c01060b3>]
Aug 14 18:07:09 194.146.153.146 do_softirq+0x65/0xb6
Aug 14 18:07:09 194.146.153.146 [   41.496997]  [<c014a35d>]
Aug 14 18:07:09 194.146.153.146 ?
Aug 14 18:07:09 194.146.153.146 handle_fasteoi_irq+0x0/0xb6
Aug 14 18:07:09 194.146.153.146 [   41.496997]  [<c0125e28>]
Aug 14 18:07:09 194.146.153.146 irq_exit+0x44/0x79
Aug 14 18:07:09 194.146.153.146 [   41.496997]  [<c0106038>]
Aug 14 18:07:09 194.146.153.146 do_IRQ+0xae/0xc4
Aug 14 18:07:09 194.146.153.146 [   41.496997]  [<c0104288>]
Aug 14 18:07:09 194.146.153.146 common_interrupt+0x28/0x30
Aug 14 18:07:09 194.146.153.146 [   41.496997]  [<c013007b>]
Aug 14 18:07:09 194.146.153.146 ?
Aug 14 18:07:09 194.146.153.146 find_get_pid+0x2e/0x4d
Aug 14 18:07:09 194.146.153.146 [   41.496997]  [<c0108d8a>]
Aug 14 18:07:09 194.146.153.146 ?
Aug 14 18:07:09 194.146.153.146 mwait_idle+0x39/0x43
Aug 14 18:07:09 194.146.153.146 [   41.496997]  [<c01029ee>]
Aug 14 18:07:09 194.146.153.146 cpu_idle+0xbf/0xe1
Aug 14 18:07:09 194.146.153.146 [   41.496997]  [<c02afc5e>]
Aug 14 18:07:09 194.146.153.146 rest_init+0x4e/0x50
Aug 14 18:07:09 194.146.153.146 [   41.496997]  =======================
