From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH]: Fix myri10ge NAPI oops & warnings
Date: Wed, 31 Oct 2007 14:44:12 -0700
Message-ID: <20071031144412.723910ba@freepuppy.rosehill>
References: <4728F636.9080505@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:47319 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754608AbXJaVps (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 17:45:48 -0400
In-Reply-To: <4728F636.9080505@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 31 Oct 2007 17:40:06 -0400
Andrew Gallatin <gallatin@myri.com> wrote:

> 
> When testing the myri10ge driver with 2.6.24-rc1, I found
> that the machine crashed under heavy load:
> 
> Unable to handle kernel paging request at 0000000000100108 RIP:
>   [<ffffffff803cc8dd>] net_rx_action+0x11b/0x184
> 
> The address corresponds to the list_move_tail() in
> netif_rx_complete():
>                      if (unlikely(work == weight))
>                              list_move_tail(&n->poll_list, list);
> 
> Eventually, I traced the crashes to calling netif_rx_complete() with
> work_done == budget.  From looking at other drivers, it appears that
> one should only call netif_rx_complete() when work_done < budget.
> 
> To fix it, I changed the test in myri10ge_poll() so that it refers
> to to work_done rather than looking at the rx ring status.  If
> work_done is < budget, then that implies we have no more packets to
> process. Any races will be resolved by the NIC when the write to
> irq_claim is made.
> 
> In myri10ge_clean_rx_done(), if we ever exceeded our budget, it would
> report a work_done one larger than was acutally done.  This is because
> the increment was done in the conditional, so work_done would be
> incremented regardless of whether or not the test passed or failed.
> This would lead to the WARN_ON_ONCE(work > weight); warning in
> net_rx_action triggering.  I've moved the increment of work_done
> inside the loop.  Note that this would only be a problem when we had
> exceeded our budget.
> 
> Signed off by: Andrew Gallatin <gallatin@myri.com>
> 
> Andrew Gallatin Myricom Inc
> 
> 

Yes, this looks right.
How could the check in netif_rx_complete be changed to catch this better?

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
