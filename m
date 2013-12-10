From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2] xen-netback: improve guest-receive-side flow
 control
Date: Mon, 09 Dec 2013 20:33:37 -0500 (EST)
Message-ID: <20131209.203337.29960384465506678.davem@davemloft.net>
References: <1386347767-9819-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	wei.liu2@citrix.com, ian.campbell@citrix.com,
	david.vrabel@citrix.com, annie.li@oracle.com,
	konrad.wilk@oracle.com
To: paul.durrant@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44879 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751442Ab3LJBdj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 20:33:39 -0500
In-Reply-To: <1386347767-9819-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Durrant <paul.durrant@citrix.com>
Date: Fri, 6 Dec 2013 16:36:07 +0000

> The way that flow control works without this patch is that, in start_xmit()
> the code uses xenvif_count_skb_slots() to predict how many slots
> xenvif_gop_skb() will consume and then adds this to a 'req_cons_peek'
> counter which it then uses to determine if the shared ring has that amount
> of space available by checking whether 'req_prod' has passed that value.
> If the ring doesn't have space the tx queue is stopped.
> xenvif_gop_skb() will then consume slots and update 'req_cons' and issue
> responses, updating 'rsp_prod' as it goes. The frontend will consume those
> responses and post new requests, by updating req_prod. So, req_prod chases
> req_cons which chases rsp_prod, and can never exceed that value. Thus if
> xenvif_count_skb_slots() ever returns a number of slots greater than
> xenvif_gop_skb() uses, req_cons_peek will get to a value that req_prod cannot
> possibly achieve (since it's limited by the 'real' req_cons) and, if this
> happens enough times, req_cons_peek gets more than a ring size ahead of
> req_cons and the tx queue then remains stopped forever waiting for an
> unachievable amount of space to become available in the ring.
> 
> Having two routines trying to calculate the same value is always going to be
> fragile, so this patch does away with that. All we essentially need to do is
> make sure that we have 'enough stuff' on our internal queue without letting
> it build up uncontrollably. So start_xmit() makes a cheap optimistic check
> of how much space is needed for an skb and only turns the queue off if that
> is unachievable. net_rx_action() is the place where we could do with an
> accurate predicition but, since that has proven tricky to calculate, a cheap
> worse-case (but not too bad) estimate is all we really need since the only
> thing we *must* prevent is xenvif_gop_skb() consuming more slots than are
> available.
> 
> Without this patch I can trivially stall netback permanently by just doing
> a large guest to guest file copy between two Windows Server 2008R2 VMs on a
> single host.
> 
> Patch tested with frontends in:
> - Windows Server 2008R2
> - CentOS 6.0
> - Debian Squeeze
> - Debian Wheezy
> - SLES11
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>

Applied, thanks.
