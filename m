From: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Subject: oops in tcp_xmit_retransmit_queue
Date: Wed, 22 Jan 2014 09:32:49 -0800 (PST)
Message-ID: <8d17033a-2ebb-4e8e-9a38-c80738286d2e@default>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:50811 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752538AbaAVRcx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 12:32:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We hit this crash in tcp_xmit_retransmit_queue.

@ BUG: unable to handle kernel NULL pointer dereference at (null) 
@ IP: [<ffffffff813fe792>] tcp_xmit_retransmit_queue+0x21e/0x25d 
@ . 
@ Call Trace: 
@  <IRQ> 
@  [<ffffffff813f9b25>] tcp_ack+0x1662/0x168d 
@  [<ffffffff813fbba5>] ? tcp_init_tso_segs+0x3a/0x51 
@  [<ffffffff813f9fbf>] ? tcp_validate_incoming+0x69/0x296 
@  [<ffffffff813fb1da>] tcp_rcv_established+0x4db/0x566 
@  [<ffffffff81401244>] tcp_v4_do_rcv+0x196/0x352 
@  [<ffffffff8105e007>] ? local_bh_enable+0x12/0x14 
@  [<ffffffff81402696>] tcp_v4_rcv+0x459/0x6d0 
@  [<ffffffff81043309>] ? test_tsk_thread_flag+0x12/0x14 
@  [<ffffffff8104536b>] ? select_idle_sibling+0x3a/0xe7 
@  [<ffffffff813e6b66>] ip_local_deliver_finish+0x152/0x1fa 
@  [<ffffffff813e6f61>] ip_local_deliver+0x72/0x7d 
@  [<ffffffff813e6992>] ip_rcv_finish+0x372/0x38c 
@  [<ffffffff813f341f>] ? tcp_gro_receive+0x7e/0x1e5 
@  [<ffffffff813e6eb0>] ip_rcv+0x2a2/0x2e1 
@  [<ffffffff813c11ab>] __netif_receive_skb+0x41b/0x440 
@  [<ffffffff813c1219>] netif_receive_skb+0x49/0x50 
@  [<ffffffff813c12b5>] napi_skb_finish+0x2b/0x42 
@  [<ffffffff813c172e>] napi_gro_receive+0x2f/0x34 
@  [<ffffffffa017b5e8>] igb_poll+0x808/0xb78 [igb] 
@  [<ffffffff8104505f>] ? __enqueue_entity+0x79/0x7b 
@  [<ffffffff813c42d9>] net_rx_action+0xc6/0x1cd 
@  [<ffffffff8105e8c1>] __do_softirq+0xd7/0x19e 
@  [<ffffffff810aee90>] ? handle_IRQ_event+0x10a/0x120 
@  [<ffffffff81012eec>] call_softirq+0x1c/0x30 
@  [<ffffffff81014695>] do_softirq+0x46/0x89 
@  [<ffffffff8105e746>] irq_exit+0x3b/0x7a 
@  [<ffffffff8145b5d1>] do_IRQ+0x99/0xb0 
@  [<ffffffff81012713>] ret_from_intr+0x0/0x11 
@  <EOI> 
@  [<ffffffff810199d2>] ? mwait_idle+0x74/0x7f 
@  [<ffffffff810199c5>] ? mwait_idle+0x67/0x7f 
@  [<ffffffff81010d6f>] ? cpu_idle+0xa5/0xd4 
@  [<ffffffff81450f2f>] ? start_secondary+0x1fd/0x23c 
@ . 
@ RIP  [<ffffffff813fe792>] tcp_xmit_retransmit_queue+0x21e/0x25d


tp->retransmit_skb_hint is non-NULL. retransmit_skb_hint->next is NULL.
It crashes while walking through this list:
tcp_for_write_queue_from(skb, sk) {
                __u8 sacked = TCP_SKB_CB(skb)->sacked;

retransmit_skb_hint is pointing to a seq# range that is quite before tp->snd_una.
Both "seq" and "end_seq" of tcp_skb_cb of retransmit_skb_hint are
before tp->snd_una. Looks like tp->retransmit_skb_hint is either not unset
in some path or gets set when it should not be.

Some more info of the Customer's environment: 
-sack is enabled
-this occurred on 2.6.32-400.1.1.el5uek which is based on linux-2.6.32
-is not re-creatable

Is this a known problem that has been fixed after 2.6.32 ?

Thanks.

Venkat
