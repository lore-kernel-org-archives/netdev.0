From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH net-next] tipc: correctly unlink
 packets from deferred queue
Date: Mon, 16 Dec 2013 10:30:42 -0500
Message-ID: <52AF1CA2.6000406@windriver.com>
References: <1387187185-6914-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
To: <erik.hugne@ericsson.com>, <netdev@vger.kernel.org>,
	<jon.maloy@ericsson.com>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1387187185-6914-1-git-send-email-erik.hugne@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 13-12-16 04:46 AM, erik.hugne@ericsson.com wrote:
> From: Erik Hugne <erik.hugne@ericsson.com>
> 
> When we pull a packet from the deferred queue, the next
> pointer for the current packet being processed might still
> refer to deferred packets. This is incorrect, and will
> lead to an oops if the last fragment have once been put on
> the deferred queue, and at least one packet have been

Once again, I have to ask when this behaviour was introduced.
This should always be a question that you ask yourself, and
that you consider putting in the commit log.  Please add it
to your self-check list.

So, is this a fail we introduce with the pending two series,
or with the series already taken by DaveM?

Otherwise, if it is an older problem than that, then why
is this tagged net-next?  It looks like a genuine bug fix
for an oops, if the existing mainline code has this bug.

> deferred after this fragment. The result of this is that
> the fragment chain linked together with the defer-queue.

"...chain is linked ..."   ?

> 
> We fix this by clearing the next pointer for the current
> packet being processed.
> 
> [...] general protection fault: 0000

Was this all that was in the header?  Seems overly edited, and
missing content (registers, EIP, etc.)

> [...]
> [...] ? trace_hardirqs_on+0xd/0x10
> [...] tipc_link_recv_fragment+0xd1/0x1b0 [tipc]
> [...] tipc_recv_msg+0x4e4/0x920 [tipc]
> [...] ? tipc_l2_rcv_msg+0x40/0x250 [tipc]
> [...] tipc_l2_rcv_msg+0xcc/0x250 [tipc]
> [...] ? tipc_l2_rcv_msg+0x40/0x250 [tipc]
> [...] __netif_receive_skb_core+0x80b/0xd00
> [...] ? __netif_receive_skb_core+0x144/0xd00
> [...] __netif_receive_skb+0x26/0x70
> [...] netif_receive_skb+0x2d/0x200

Same here, why have you bothered to clobber the addresses?
Deleting the printk time prefix from non-time critical bugs is
fine, but don't delete the addresses, since they convey some
relative information about functions nearby etc.

Paul.
--

> 
> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
> Reported-by: Ying Xue <ying.xue@windriver.com>
> ---
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

------------------------------------------------------------------------------
Rapidly troubleshoot problems before they affect your business. Most IT 
organizations don't have a clear picture of how application performance 
affects their revenue. With AppDynamics, you get 100% visibility into your 
Java,.NET, & PHP application. Start your 15-day FREE TRIAL of AppDynamics Pro!
http://pubads.g.doubleclick.net/gampad/clk?id=84349831&iu=/4140/ostg.clktrk
