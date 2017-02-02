From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next v2 5/6] gtp: add socket to pdp context
Date: Thu, 2 Feb 2017 15:46:06 +0100
Message-ID: <20170202144606.GA19992@salvia>
References: <20170130163713.17524-1-aschultz@tpip.net>
 <20170130163713.17524-6-aschultz@tpip.net>
 <20170202135656.GA23901@salvia>
 <858150010.730228.1486044775198.JavaMail.zimbra@tpip.net>
 <20170202142842.GA19643@salvia>
 <249401941.730762.1486046287023.JavaMail.zimbra@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, laforge <laforge@gnumonks.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc <openbsc@lists.osmocom.org>
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45892 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751837AbdBBOqs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 2 Feb 2017 09:46:48 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 7ED26E04C7
        for <netdev@vger.kernel.org>; Thu,  2 Feb 2017 15:46:24 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 70D6ADA859
        for <netdev@vger.kernel.org>; Thu,  2 Feb 2017 15:46:24 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 3547EDA84B
        for <netdev@vger.kernel.org>; Thu,  2 Feb 2017 15:46:22 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <249401941.730762.1486046287023.JavaMail.zimbra@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 02, 2017 at 03:38:07PM +0100, Andreas Schultz wrote:
> 
> 
> ----- On Feb 2, 2017, at 3:28 PM, pablo pablo@netfilter.org wrote:
> 
> > On Thu, Feb 02, 2017 at 03:12:55PM +0100, Andreas Schultz wrote:
> >> Hi,
> >> 
> >> ----- On Feb 2, 2017, at 2:56 PM, pablo pablo@netfilter.org wrote:
> >> 
> >> > On Mon, Jan 30, 2017 at 05:37:12PM +0100, Andreas Schultz wrote:
> >> >> Having the socket present in context simplifies the sending logic.
> >> >> It also fixes the invalid assumption that we have to use the same
> >> >> sending socket for all client IP's on a specific gtp interface.
> >> >> 
> >> >> Signed-off-by: Andreas Schultz <aschultz@tpip.net>
> >> >> ---
> >> >>  drivers/net/gtp.c | 72 ++++++++++++++++++++++++++++++-------------------------
> >> >>  1 file changed, 39 insertions(+), 33 deletions(-)
> >> >> 
> >> >> diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
> >> >> index 68c6c9b..ff00597 100644
> >> >> --- a/drivers/net/gtp.c
> >> >> +++ b/drivers/net/gtp.c
> >> > [...]
> >> >> @@ -984,16 +966,26 @@ static int ipv4_pdp_add(struct gtp_dev *gtp, struct
> >> >> genl_info *info)
> >> >>  	return 0;
> >> >>  }
> >> >>  
> >> >> +static void pdp_context_free(struct rcu_head *head)
> >> >> +{
> >> >> +	struct pdp_ctx *pctx = container_of(head, struct pdp_ctx, rcu_head);
> >> >> +
> >> >> +	sock_put(pctx->sk);
> >> >> +	kfree(pctx);
> >> >> +}
> >> >> +
> >> >>  static void pdp_context_delete(struct pdp_ctx *pctx)
> >> >>  {
> >> >>  	hlist_del_rcu(&pctx->hlist_tid);
> >> >>  	hlist_del_rcu(&pctx->hlist_addr);
> >> >> -	kfree(pctx);
> >> >> +	call_rcu(&pctx->rcu_head, pdp_context_free);
> >> > 
> >> > This is fixing incorrect rcu conversion in 4/6. Please, fix this there.
> >> 
> >> Ehm, right, but the kfree in 4/6 could have been a kfree_rcu instead without
> >> the call_rcu.
> >> 
> >> Do you prefer to introduce the call_rcu in 4/6 and then just add the sock_put
> >> in this patch or should I change 4/6 to kfree_rcu and do the call_rcu
> >> conversion here?
> > 
> > I suggest you just call kfree_rcu() from 4/6.
> > 
> > Regarding holding socket reference, see my comment for patch 1/6.
> 
> This is going to be a problem at this stage of the changes.
> 
> The final goal is to have a reference from the socket to the pdp context.

Is this just a cleanup? Or you need this sk caching for some follow up
work?

> Then, when the socket is closed, the pdp context can be destroyed.
>
> However, at this point, only the netdevice knows about the contexts. So
> when the socket is closed, the pdp context would have a dangling reference
> to the socket.
>
> I can integrate this change into the later one. But it will make that
> change larger and more difficult to review.
> 
> I guess, I'm going to drop this change from this series and see if can
> reorder the next part so that it still makes and I easy to review....

Agreed. Thanks.
