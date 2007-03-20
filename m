From: Chris Madden <chris@reflexsecurity.com>
Subject: Re: Oops in filter add
Date: Tue, 20 Mar 2007 06:54:55 -0400
Message-ID: <45FFBD7F.4010005@reflexsecurity.com>
References: <45FEEE35.6090606@reflexsecurity.com>	 <20070319.192206.21926062.davem@davemloft.net>	 <1174373645.4895.15.camel@localhost>  <45FF8602.8040108@trash.net>	 <1174375109.4895.22.camel@localhost>  <45FF8D6A.4010308@trash.net> <1174382739.4864.11.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	tgraf@suug.ch
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from crown.reflexsecurity.com ([72.54.139.163]:58846 "EHLO
	crown.reflexsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753586AbXCTKy7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 06:54:59 -0400
In-Reply-To: <1174382739.4864.11.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks for all your replies!

One thing I did notice in examining tc_ctl_tfilter was that there is
something like:

        qdisc_lock_tree(dev);
        tp->next = *back;
        *back = tp;
        qdisc_unlock_tree(dev);

And then proceed to the data structure down below with:

err = tp->ops->change(tp, cl, t->tcm_handle, tca, &fh);

Simply reordering these seems to ameliorate the problem greatly.  I
don't know if this is a generic solution or something specific to the
basic filter only. 

Chris Madden

jamal wrote:
> On Tue, 2007-20-03 at 08:29 +0100, Patrick McHardy wrote:
>   
>> jamal wrote:
>>     
>>> On Tue, 2007-20-03 at 07:58 +0100, Patrick McHardy wrote:
>>>
>>> Ok. It certainly used to matter in the old days.
>>>       
>> Actually it has never been used anywhere else but in ing_filter,
>> it was introduced together with the TC actions.
>>
>>     
>
> You are correct. I looked at old 2.4 and all i saw was:
>
> ----------
> /* 
>  revisit later: Use a private since lock dev->queue_lock is also
>  used on the egress (might slow things for an iota)
> */
>  
>          if (dev->qdisc_ingress) {
>                  spin_lock(&dev->queue_lock);
>                  if ((q = dev->qdisc_ingress) != NULL)
>                          fwres = q->enqueue(skb, q);
>                  spin_unlock(&dev->queue_lock);
>          }
> ------
>
> So the resolution (as Dave points out) was wrong. In any case, restoring
> queue_lock for now would slow things but will remove the race.
>
>   
>> I'll try, but no promises, I'm a bit behind with various things myself.
>>     
>
> I will ping you in a few days and if you havent done anything i will
> take it up.
> I am almost tempted to make the ingress filters to not have any
> dependencies on egress whatsoever. It will create more locks but
> will make the datapath faster. Actions can still be shared, but thats
> lesser of an overhead.
>
> cheers,
> jamal
>
>   

