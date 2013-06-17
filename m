From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: Modify the condition for the first skb to collapse
Date: Mon, 17 Jun 2013 06:21:21 -0700
Message-ID: <1371475281.3252.198.camel@edumazet-glaptop>
References: <1371478739.10495.5.camel@chenjun-workstation>
	 <1371456935.3252.177.camel@edumazet-glaptop>
	 <1371490190.28418.6.camel@chenjun-workstation>
	 <1371464962.3252.181.camel@edumazet-glaptop>
	 <1371495133.28418.19.camel@chenjun-workstation>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ycheng@google.com, ncardwell@google.com, edumazet@google.com,
	netdev@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>
To: Jun Chen <jun.d.chen@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:48627 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933038Ab3FQNV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 09:21:26 -0400
In-Reply-To: <1371495133.28418.19.camel@chenjun-workstation>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-06-17 at 14:52 -0400, Jun Chen wrote:
> On Mon, 2013-06-17 at 03:29 -0700, Eric Dumazet wrote:
> > On Mon, 2013-06-17 at 13:29 -0400, Jun Chen wrote:
> > > > 
> > > hi,
> > > When the condition of tcp_win_from_space(skb->truesize) > skb->len is
> > > true but the before(start, TCP_SKB_CB(skb)->seq) is also true, the final
> > > condition will be true. The follow line:
> > > int offset = start - TCP_SKB_CB(skb)->seq;
> > > BUG_ON(offset < 0);
> > > this BUG_ON will be triggered.
> > > 
> > 
> > Really this should never happen, we must track what's happening here.
> It's very very rare, but the logic of codes have such a little hole.
> > 
> > Are you using a pristine kernel, without any patches ?
> The based kernel version is 3.4.  
> > 
> > Are you able to reproduce this bug in a short amount of time ?
> I can't reproduce it in short time, this log had just been found once
> for long long time tests on many devices . 
> > 
> > What kind of driver is in use ? (your stack trace was truncated)
> 
> I attach the whole stack traces for you.
> 
> <0>[ 7736.348788] Call Trace:
> 
> <4>[ 7736.348861]  [<c18addd0>] tcp_prune_queue+0x120/0x2f0
> 
> <4>[ 7736.348984]  [<c18aea27>] tcp_data_queue+0x777/0xf00
> 
> <4>[ 7736.349055]  [<c18dc8f8>] ? ipt_do_table+0x1f8/0x480
> 
> <4>[ 7736.349126]  [<c18dc8f8>] ? ipt_do_table+0x1f8/0x480
> 
> <4>[ 7736.349196]  [<c18b2e84>] tcp_rcv_established+0x114/0x680
> 
> <4>[ 7736.349269]  [<c18bb034>] tcp_v4_do_rcv+0x164/0x350
> 
> <4>[ 7736.349396]  [<c18de301>] ? nf_nat_fn+0xb1/0x1d0
> 
> <4>[ 7736.349470]  [<c18bc0c1>] tcp_v4_rcv+0x6f1/0x7a0
> 
> <4>[ 7736.349599]  [<c1881dad>] ? nf_hook_slow+0x10d/0x150
> 
> <4>[ 7736.349673]  [<c189b30b>] ip_local_deliver_finish+0x8b/0x200
> 
> <4>[ 7736.349796]  [<c189b60f>] ip_local_deliver+0x8f/0xa0
> 
> <4>[ 7736.349867]  [<c189b280>] ? ip_rcv_finish+0x300/0x300
> 
> <4>[ 7736.349937]  [<c189b05f>] ip_rcv_finish+0xdf/0x300
> 
> <4>[ 7736.350062]  [<c189b878>] ip_rcv+0x258/0x330
> 
> <4>[ 7736.350132]  [<c189af80>] ? inet_del_protocol+0x30/0x30
> 
> <4>[ 7736.350258]  [<c1864175>] __netif_receive_skb+0x325/0x410
> 
> <4>[ 7736.350331]  [<c1864956>] process_backlog+0x96/0x150
> 
> <4>[ 7736.350455]  [<c1864ba5>] net_rx_action+0x115/0x210
> 
> <4>[ 7736.350525]  [<c18b7680>] ? tcp_out_of_resources+0xb0/0xb0
> 
> <4>[ 7736.350652]  [<c123dc0b>] __do_softirq+0x9b/0x220
> 
> <4>[ 7736.350723]  [<c123db70>] ? local_bh_enable_ip+0xd0/0xd0
> 

Any other suspect messages before this, a memory allocation error for
example ?

I believe we have a bug in tcp_collapse() if one alloc_skb() returns
NULL while we were in the middle of collapsing a big GRO packet.

gro_skb needed 3 skb to be rebuilt, and only two skbs could be allocated

skb1: seq=X  end_seq=X+4000
skb2: seq=X+4000 end_seq=X+8000
<missing>
grp_skb: seq=X end_seq=X+16000

Next time we call tcp_collapse(), we might split again the GRO packet
and get following incorrect queue :

skb1: seq=X  end_seq=X+4000
skb2: seq=X+4000 end_seq=X+8000
skb3: seq=X  end_seq=X+4000
skb4: seq=X+4000 end_seq=X+8000
skb5: seq=X+8000 end_seq=X+12000
skb6: seq=X+12000 end_seq=X+16000


I would use the following patch instead, to narrow the problem

If we really find in the ofo queue a skb with a lower seq than the
previous one, we should complain instead of lowering @start, since
this is going to crash later.

receive_queue / ofo_queue should contain monotonically increasing
skb->seq.

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 46271cdc..5507a09 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4513,8 +4513,10 @@ static void tcp_collapse_ofo_queue(struct sock *sk)
 			start = TCP_SKB_CB(skb)->seq;
 			end = TCP_SKB_CB(skb)->end_seq;
 		} else {
-			if (before(TCP_SKB_CB(skb)->seq, start))
-				start = TCP_SKB_CB(skb)->seq;
+			if (before(TCP_SKB_CB(skb)->seq, start)) {
+				pr_err_once("tcp_collapse_ofo_queue() : seq %08x before start %08X\n",
+					    TCP_SKB_CB(skb)->seq, start);
+			}
 			if (after(TCP_SKB_CB(skb)->end_seq, end))
 				end = TCP_SKB_CB(skb)->end_seq;
 		}
