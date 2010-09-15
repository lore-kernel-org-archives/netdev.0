From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2] net: af_packet: don't call tpacket_destruct_skb()
 until the skb is sent out
Date: Wed, 15 Sep 2010 07:23:32 +0200
Message-ID: <20100915052332.GB25340@redhat.com>
References: <1284175403-3228-1-git-send-email-xiaosuo@gmail.com>
 <20100912121349.GD22982@redhat.com>
 <20100914.202023.193706826.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xiaosuo@gmail.com, eric.dumazet@gmail.com, socketcan@hartkopp.net,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50120 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751216Ab0IOF3g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Sep 2010 01:29:36 -0400
Content-Disposition: inline
In-Reply-To: <20100914.202023.193706826.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 14, 2010 at 08:20:23PM -0700, David Miller wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
> Date: Sun, 12 Sep 2010 14:13:49 +0200
> 
> > On Sat, Sep 11, 2010 at 11:23:23AM +0800, Changli Gao wrote:
> >> @@ -799,7 +806,9 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
> >>  
> >>  	memcpy((struct skb_shared_info *)(data + size),
> >>  	       skb_shinfo(skb),
> >> -	       offsetof(struct skb_shared_info, frags[skb_shinfo(skb)->nr_frags]));
> >> +	       offsetof(struct skb_shared_info,
> >> +			frags[skb_shinfo(skb)->nr_frags]));
> >> +	skb_shinfo(skb)->destructor = NULL;
> >>  
> >>  	/* Check if we can avoid taking references on fragments if we own
> >>  	 * the last reference on skb->head. (see skb_release_data())
> > 
> > So it looks like pskb_expand_head will prevent the shinfo desctructor
> > from being called, ever? If so, won't this break af_packet?
> 
> >From what I read, he is propagating it into the new SKB data blob
> with expanded head area.  It would get invoked when the skb's
> new data is put.
> 
> I am not sure this is correct, however.
> 
> Destructor register only cares about original data area, but what
> constitutes "original data" is ambiguous.  In fact it seems
> impossible to catch the freeing of all parts properly.
> 
> When pskb_expand_head() is invoked we get new linear part, but
> non-linear part stays the same.  However, entity which registered
> skb data destructor cares about old linear data lifetime, which
> we will no longer track after destructor is propagated only to
> the new shinfo.
> 
> So we need to do something different here.  I bet original code
> overriding socket destructor semantics had a similar problem.
> 
> Changli, I have one other minor request, please name this something
> like "shinfo->data_destructor" and "shinfo->data_destructor_arg".
> 
> I think that will make it easier for other humans to understand :)
> 
> Thank you.

Hmm, and there's another issue I think I see here:
destructor_arg now points to a socket.
What happens if the skb gets queued on an interface for a very long time
(as can be the case with e.g. tap), and meanwhile
you try to kill the task that owns the socket, which
will try to destroy the socket?

Original code handles this by relevant devices orphaning an skb
if it's queued indefinitely.

-- 
MST
