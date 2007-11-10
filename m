From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Oops preceded by WARNING: at net/ipv4/tcp_input.c:1571
 tcp_remove_reno_sacks()
Date: Sun, 11 Nov 2007 01:13:35 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0711102336310.17415@kivilampi-30.cs.helsinki.fi>
References: <3d8471ca0711100325l7745707dn7a2cb28a488a9b02@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1996032725-1194736415=:17415"
Cc: Netdev <netdev@vger.kernel.org>
To: Guillaume Chazarain <guichaz@yahoo.fr>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:38378 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755499AbXKJXNi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Nov 2007 18:13:38 -0500
In-Reply-To: <3d8471ca0711100325l7745707dn7a2cb28a488a9b02@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1996032725-1194736415=:17415
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Sat, 10 Nov 2007, Guillaume Chazarain wrote:

> Doing some bittorrent with linux-2.6.24-rc2, my box crashed with this
> in the log:
> 
> <4>WARNING: at net/ipv4/tcp_input.c:1571 tcp_remove_reno_sacks()

This gets triggered when SACKED + LOST marked are more than packets_out.
sacked_out is dealt (bounded) in the tcp_check_reno_reordering(), so the 
failing one seems to be the lost_out, like this already informs...:

> <3>KERNEL: assertion ((int)tp->lost_out >= 0) failed at
> net/ipv4/tcp_input.c (2761)

...I'll check if GSO can cause some nasty things to that one so that 
newreno's only head lost assumption get broken and lost_out
underflows somehow...

Do you have GSO enabled?

> <4>WARNING: at net/ipv4/tcp_input.c:2405 tcp_fastretrans_alert()

This is reporting the same as the first one in remove_reno_sacks.


> <1>BUG: unable to handle kernel NULL pointer dereference at virtual
> address 00000045
> <1>printing eip: c02f7452 *pde = 00000000
> <0>Oops: 0000 [#1] PREEMPT

...snip...

> <4>
> <4>Pid: 0, comm: swapper Not tainted (2.6.24-rc2-gc #173)
> <4>EIP: 0060:[<c02f7452>] EFLAGS: 00010246 CPU: 0
> <4>EIP is at tcp_xmit_retransmit_queue+0x61/0x252
> <4>EAX: e43a04b0 EBX: e43a0440 ECX: 00000000 EDX: e43a04b0
> <4>ESI: 00000000 EDI: 00000000 EBP: c046dd80 ESP: c046dd70
> <4> DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
> <0>Process swapper (pid: 0, ti=c046d000 task=c040a2e0 task.ti=c0439000)
> <0>Stack: e43a04b0 00000002 e43a0440 0000040e c046de08 c02f298a
> c03b5888 c03f077d
> <0>       00000965 c034e8bf c75720c0 00000000 00000000 00000001
> 781b775e f1185f51
> <0>       781b7767 ffffffff 00000000 00000000 00000001 00000006
> 781b7767 86000000
> <0>Call Trace:
> <0> [<c0104cb3>] show_trace_log_lvl+0x1a/0x2f
> <0> [<c0104d65>] show_stack_log_lvl+0x9d/0xa5
> <0> [<c0104e0f>] show_registers+0xa2/0x1b8
> <0> [<c010501c>] die+0xf7/0x1d3
> <0> [<c0328537>] do_page_fault+0x520/0x60e
> <0> [<c0326d72>] error_code+0x6a/0x70
> <0> [<c02f298a>] tcp_ack+0x15a3/0x176b
> <0> [<c02f5208>] tcp_rcv_established+0xdb/0x5f3
> <0> [<c02fa711>] tcp_v4_do_rcv+0x2b/0x310
> <0> [<c02fc557>] tcp_v4_rcv+0x82b/0x89d
> <0> [<c02e4961>] ip_local_deliver_finish+0x124/0x1ba
> <0> [<c02e4d64>] ip_local_deliver+0x72/0x7e
> <0> [<c02e481d>] ip_rcv_finish+0x299/0x2b9
> <0> [<c02e4cd4>] ip_rcv+0x1e1/0x1ff
> <0> [<c02c9062>] netif_receive_skb+0x37d/0x401
> <0> [<c02cae8e>] process_backlog+0x5b/0xa6
> <0> [<c02cab3f>] net_rx_action+0x87/0x156
> <0> [<c0121d17>] __do_softirq+0x38/0x7a
> <0> [<c0105975>] do_softirq+0x41/0x92
> <0> =======================
> <0>Code: 00 00 e9 ff 00 00 00 c7 83 a0 03 00 00 00 00 00 00 e9 00 02
> 00 00 c7 83 a4 03 00 00 00 00 00 00 e9 f1 01 00 00 3b b3 10 01 00 00
> <8a> 56 45 0f 84 d2 00 00 00 8b 83 fc 02 00 00 03 83 00 03 00 00
> <0>EIP: [<c02f7452>] tcp_xmit_retransmit_queue+0x61/0x252 SS:ESP 0068:c046dd70

This could be due to tcp_write_queue_head(sk) returning NULL to skb if 
write queue is empty. Then a corrupted lost_out would cause entry to the 
loop and boom it goes when accessing skb->next...

Meanwhile, I'm starting to be a bit skeptical whether tcp_write_queue_head 
should return NULL ever as that's incompatible with 
tcp_for_write_queue_from and would require explicit checking then... Dave?
(Yes, I know it's there for clean_rtx_queue but it could do the same check 
by other means). I think I actually hit this same feature in sacktag 
recode test today (just discovered that while thinking this one), 
probably a DSACK arriving when packets_out was zero... 

I rechecked the clean_rtx_queue changes, and they seemed to be in order
so that they shouldn't corrupt the queue... But it still remains open what 
caused the lost_out corruption in the first place, maybe I find something 
later...


Is this reproducable? You can try to provoke it by setting tcp_sack sysctl 
to 0 as this seems to be non-SACK related... If so, you could try the 
debug patch below (because I couldn't immediately see what could prevent 
tcp_is_reno from going to tcp_xmit_retransmit_queue when queue is empty), 
it should get rid of the crash and get the lost_out value for us as 
well...


> .config:

...snip...

> # CONFIG_DEBUG_LIST is not set

Could you please add this one too, as there could be some list corruption 
in this... I checked every place that is touching lost_out, and all seemed 
to be in order... Have you run memtest recently?


--
[PATCH] TCP DEBUG

- Check if empty queue is passed to xmit_retrans...
- Print lost_out underflow value

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index ca9590f..ac54517 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2521,6 +2521,12 @@ tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
 	if (do_lost || tcp_head_timedout(sk))
 		tcp_update_scoreboard(sk);
 	tcp_cwnd_down(sk, flag);
+	
+	if (WARN_ON(tcp_write_queue_head(sk) == NULL))
+		return;
+	if (WARN_ON(!tp->packets_out))
+		return;
+	
 	tcp_xmit_retransmit_queue(sk);
 }
 
@@ -2759,6 +2765,8 @@ static int tcp_clean_rtx_queue(struct sock *sk, s32 *seq_rtt_p)
 #if FASTRETRANS_DEBUG > 0
 	BUG_TRAP((int)tp->sacked_out >= 0);
 	BUG_TRAP((int)tp->lost_out >= 0);
+	if (tp->lost_out > tp->packets_out)
+		printk(KERN_ERR "Lost underflowed to %u\n", tp->lost_out);
 	BUG_TRAP((int)tp->retrans_out >= 0);
 	if (!tp->packets_out && tcp_is_sack(tp)) {
 		icsk = inet_csk(sk);
-- 
1.5.0.6

---696243703-1996032725-1194736415=:17415--
