From: Erik Hugne <erik.hugne@ericsson.com>
Subject: Re: [PATCH net-next] tipc: correctly unlink packets from deferred
 queue
Date: Mon, 16 Dec 2013 17:35:18 +0100
Message-ID: <20131216163518.GB20740@eerihug-hybrid.rnd.ki.sw.ericsson.se>
References: <1387187185-6914-1-git-send-email-erik.hugne@ericsson.com>
 <52AF1CA2.6000406@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <jon.maloy@ericsson.com>,
	<ying.xue@windriver.com>, <tipc-discussion@lists.sourceforge.net>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg20.ericsson.net ([193.180.251.56]:43425 "EHLO
	sesbmg20.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754527Ab3LPQfV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 11:35:21 -0500
Content-Disposition: inline
In-Reply-To: <52AF1CA2.6000406@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 16, 2013 at 10:30:42AM -0500, Paul Gortmaker wrote:
> On 13-12-16 04:46 AM, erik.hugne@ericsson.com wrote:
> > From: Erik Hugne <erik.hugne@ericsson.com>
> > 
> > When we pull a packet from the deferred queue, the next
> > pointer for the current packet being processed might still
> > refer to deferred packets. This is incorrect, and will
> > lead to an oops if the last fragment have once been put on
> > the deferred queue, and at least one packet have been
> 
> Once again, I have to ask when this behaviour was introduced.
> This should always be a question that you ask yourself, and
> that you consider putting in the commit log.  Please add it
> to your self-check list.
> 
> So, is this a fail we introduce with the pending two series,
> or with the series already taken by DaveM?

The problem have always been there, but the window for when
it may occur increased after commit 40ba3cdf5
tipc: message reassembly using fragment chain

> 
> Otherwise, if it is an older problem than that, then why
> is this tagged net-next?  It looks like a genuine bug fix
> for an oops, if the existing mainline code has this bug.
> 
> > deferred after this fragment. The result of this is that
> > the fragment chain linked together with the defer-queue.
> 
> "...chain is linked ..."   ?
What we have seen is that after successful delivery of a 
fragmented message, the last packet in the fragment chain
will point into the deferred queue. When we later free the
chain, kfree_skb_list will also free packets from the defer-queue.

In theory, the same thing can occur for non-fragmented traffic
aswell.

> 
> > 
> > We fix this by clearing the next pointer for the current
> > packet being processed.
> > 
> > [...] general protection fault: 0000
> 
> Was this all that was in the header?  Seems overly edited, and
> missing content (registers, EIP, etc.)
> 
> > [...]
> > [...] ? trace_hardirqs_on+0xd/0x10
> > [...] tipc_link_recv_fragment+0xd1/0x1b0 [tipc]
> > [...] tipc_recv_msg+0x4e4/0x920 [tipc]
> > [...] ? tipc_l2_rcv_msg+0x40/0x250 [tipc]
> > [...] tipc_l2_rcv_msg+0xcc/0x250 [tipc]
> > [...] ? tipc_l2_rcv_msg+0x40/0x250 [tipc]
> > [...] __netif_receive_skb_core+0x80b/0xd00
> > [...] ? __netif_receive_skb_core+0x144/0xd00
> > [...] __netif_receive_skb+0x26/0x70
> > [...] netif_receive_skb+0x2d/0x200
> 
> Same here, why have you bothered to clobber the addresses?
> Deleting the printk time prefix from non-time critical bugs is
> fine, but don't delete the addresses, since they convey some
> relative information about functions nearby etc.

Just trying to avoid an unnecessarily verbose commit message.
As the oops was from Ying's test system with non-upstream tipc
code i didn't think the addresses added any value

Should i do an edit/resend anyway?

//E
