From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH v2 net-next] tipc: correctly unlink packets from deferred
 queue
Date: Tue, 17 Dec 2013 12:27:18 -0500
Message-ID: <52B08976.8070700@windriver.com>
References: <1387282132-27291-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <ying.xue@windriver.com>, <tipc-discussion@lists.sourceforge.net>
To: <erik.hugne@ericsson.com>, <netdev@vger.kernel.org>,
	<jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:56064 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751279Ab3LQR0y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 12:26:54 -0500
In-Reply-To: <1387282132-27291-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-12-17 07:08 AM, erik.hugne@ericsson.com wrote:
> From: Erik Hugne <erik.hugne@ericsson.com>
> 
> When we pull a packet from the deferred queue, the next
> pointer for the current packet being processed might still
> refer to deferred packets. This is incorrect, and will
> lead to an oops if the last fragment have once been put on
> the deferred queue, and at least one packet have been
> deferred after this fragment. What we have seen as a result
> of this is that after successful delivery of a fragmented
> message, the last packet in the fragment chain will point
> into the deferred queue. When we later free the chain,
> kfree_skb_list will also free packets from the defer-queue.
> It is our understanding that this problem has always existed,
> however, with the recent change of commit 40ba3cdf5
> ("tipc: message reassembly using fragment chain"), the window
> for it possibly happening has increased.

For the above:

se tw=68
gqap

In addition to that, adding a paragraph break between the problem
description and the symptom description, and the impacted version
description would improve readability nicely (and then gqap each
paragraph, of course.)

> 
> We fix this by clearing the next pointer for the current
> packet being processed.

The below oops appears to be mailer mangled, with extra line
wrapping introduced where there should be none.  Please
fix and resend.  Ideally use git send-email vs. composing
in a GUI will avoid such things in the future.

Thanks,
Paul.
--

> 
>  general protection fault: 0000 [#1] SMP DEBUG_PAGEALLOC
>  Modules linked in: tipc
>  CPU: 4 PID: 0 Comm: swapper/4 Tainted: G        W
>  3.13.0-rc2+ #6
>  Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
>  task: ffff880017af4880 ti: ffff880017aee000 task.ti:
>  ffff880017aee000
>  RIP: 0010:[<ffffffff81710694>]  [<ffffffff81710694>]
>  skb_try_coalesce+0x44/0x3d0
>  RSP: 0018:ffff880016603a78  EFLAGS: 00010212
>  RAX: 6b6b6b6bd6d6d6d6 RBX: ffff880013106ac0 RCX:
>  ffff880016603ad0
>  RDX: ffff880016603ad7 RSI: ffff88001223ed00 RDI:
>  ffff880013106ac0
>  RBP: ffff880016603ab8 R08: 0000000000000000 R09:
>  0000000000000000
>  R10: 0000000000000001 R11: 0000000000000000 R12:
>  ffff88001223ed00
>  R13: ffff880016603ad0 R14: 000000000000058c R15:
>  ffff880012297650
>  FS:  0000000000000000(0000) GS:ffff880016600000(0000)
>  knlGS:0000000000000000
>  CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>  CR2: 000000000805b000 CR3: 0000000011f5d000 CR4:
>  00000000000006e0
>  Stack:
>  ffff880016603a88 ffffffff810a38ed ffff880016603aa8
>  ffff88001223ed00
>  0000000000000001 ffff880012297648 ffff880016603b68
>  ffff880012297650
>  ffff880016603b08 ffffffffa0006c51 ffff880016603b08
>  00ffffffa00005fc
>  Call Trace:
>  <IRQ>
>  [<ffffffff810a38ed>] ? trace_hardirqs_on+0xd/0x10
>  [<ffffffffa0006c51>] tipc_link_recv_fragment+0xd1/0x1b0 [tipc]
>  [<ffffffffa0007214>] tipc_recv_msg+0x4e4/0x920 [tipc]
>  [<ffffffffa00016f0>] ? tipc_l2_rcv_msg+0x40/0x250 [tipc]
>  [<ffffffffa000177c>] tipc_l2_rcv_msg+0xcc/0x250 [tipc]
>  [<ffffffffa00016f0>] ? tipc_l2_rcv_msg+0x40/0x250 [tipc]
>  [<ffffffff8171e65b>] __netif_receive_skb_core+0x80b/0xd00
>  [<ffffffff8171df94>] ? __netif_receive_skb_core+0x144/0xd00
>  [<ffffffff8171eb76>] __netif_receive_skb+0x26/0x70
>  [<ffffffff8171ed6d>] netif_receive_skb+0x2d/0x200
>  [<ffffffff8171fe70>] napi_gro_receive+0xb0/0x130
>  [<ffffffff815647c2>] e1000_clean_rx_irq+0x2c2/0x530
>  [<ffffffff81565986>] e1000_clean+0x266/0x9c0
>  [<ffffffff81985f7b>] ? notifier_call_chain+0x2b/0x160
>  [<ffffffff8171f971>] net_rx_action+0x141/0x310
>  [<ffffffff81051c1b>] __do_softirq+0xeb/0x480
>  [<ffffffff819817bb>] ? _raw_spin_unlock+0x2b/0x40
>  [<ffffffff810b8c42>] ? handle_fasteoi_irq+0x72/0x100
>  [<ffffffff81052346>] irq_exit+0x96/0xc0
>  [<ffffffff8198cbc3>] do_IRQ+0x63/0xe0
>  [<ffffffff81981def>] common_interrupt+0x6f/0x6f
>  <EOI>
> 
> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
> Reported-by: Ying Xue <ying.xue@windriver.com>
> ---
> v2: revised commit message based on comments from Paul G. 
> 
>  net/tipc/link.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/tipc/link.c b/net/tipc/link.c
> index 3d73144..447e2c4 100644
> --- a/net/tipc/link.c
> +++ b/net/tipc/link.c
> @@ -1444,6 +1444,7 @@ void tipc_recv_msg(struct sk_buff *head, struct tipc_bearer *b_ptr)
>  		int type;
>  
>  		head = head->next;
> +		buf->next = NULL;
>  
>  		/* Ensure bearer is still enabled */
>  		if (unlikely(!b_ptr->active))
> 
