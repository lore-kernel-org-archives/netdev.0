From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Wed, 28 Jun 2006 09:46:48 -0400
Message-ID: <1151502408.5203.94.camel@jzny2>
References: <20060626145446.948105000@postel.suug.ch>
	 <20060626145515.769648000@postel.suug.ch> <44A0138F.8050208@trash.net>
	 <20060626.104654.98552111.davem@davemloft.net>
	 <20060626184424.GT1376@postel.suug.ch> <44A05FE0.7070203@trash.net>
	 <20060627100309.GU1376@postel.suug.ch> <1151413670.6516.57.camel@jzny2>
	 <20060628101832.GW1376@postel.suug.ch> <1151497363.5203.47.camel@jzny2>
	 <20060628130124.GX1376@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:1968 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1423332AbWF1Nq7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 09:46:59 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1FvaNd-0008U6-D4
	for netdev@vger.kernel.org; Wed, 28 Jun 2006 09:46:57 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060628130124.GX1376@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-28-06 at 15:01 +0200, Thomas Graf wrote:
> * jamal <hadi@cyberus.ca> 2006-06-28 08:22
[..]
> > Note, in such a case: iflink rewriting will do it just fine
> > but then you loose the original info (I think it would be good to not
> > loose such info to know the origin). I dont know if cmsg uses iflink at
> > all - they probably look at the ifindex.
> 
> It's using rt_iif which is currently derived from skb->dev even
> though it would make sense to use skb->iif once that is well
> defined.
> 

Why not use iflink?
It exists, by definition, specifically as "the ifindex of the down muxed
netdevice" (should probably add that definition in the .h).

This is semantically different from a message to the stack which says
"this came to you from input device X" (represented by input_dev).

> > Ok, now question: why are you binding on top of ifb? we could have
> > redirected this to ipip, or tun0 or loopback or eql etc where it may
> > equally not have made sense to bind to. I can see something like this
> > making sense for bonding or bridging but not as a generic answer for all
> > netdevices.
> 
> What's special about that? It seems a perfectly fine and simple way
> to create namespaces for sockets without enforcing applications to
> bind to the correct vlan devices directly.
> 

Can you achieve the same by binding to any arbitrary netdevice? If you
can then i would agree.

> This is clear, my question was for you to explain when you intend
> to update input_dev etc. By overwriting it in ifb you enforce that
> valueable information is lost.

It is design intent for this field to carry information on where the
packet came from. We may loop many times between devices (between
ingress->egress or ingress->ingress, within the ttl limit) and each time
the only meaningful thing is which was the last netdevice that was
sending it.

> There is nothing wrong with updating iif to point to ifb under
> certain circumstances but it's not required to strictly enforce
> this. Having mirred do so conditionally is a lot more flexible
> without losing any value.
> 

Refer to what i said above.

> > Now that i pay attention to your patch i think i see the complications
> > it is introducing (i am not done yet)- and i did warn about this in the
> > discussion _and_ didnt we agree to leave this stuff alone? Can we drop
> > this change please?
> 
> This statement doesn't make sense, it merely transforms a device
> reference to a reference by interface index because the current
> method of handling it doesn't make sense at all since the region
> where input_dev stays valid without the risk of the device
> disappearing is very limited.
> 

Please refer to what i said above in that you could end up redirecting
many times. I have not added yet the code which allows mirred to also do
ingress redirection which would make it even more interesting.
The challenge is this, and if you can solve it we would be fine:
- I need to access both the input_dev and dev and their metadata.
I could clearly find them by their ifindices and then reference them
after that. For performance reasons that is not optimal in the fast
path.  
[Note, we have had this discussion before and even then we came to some
consensus that it would be hard to achieve that hence my view, again, to
drop this].

> > It does work as it is right now (I only notice a pull - there is no
> > push).
> 
> In order to pull in ifb you need to push in mirred, quite
> obvious, no?  

I think that my thinking at the time was that ifb can only receive
packets via mirred and therefore the pull on ingress at ifb may have
been to counter the push that occurs at mirred. Let me look at my notes
and testcases when i get back home; it may make sense not to have it at
ifb - the fact that it works as is tells me there is more to it than the
obvious.

> Why are you enforcing users of ifb to fake an
> ethernet header that is of no use at all?

This may just be an artifact of inheriting things from dummy device.
The answer will be clear when i look at my notes. 

cheers,
jamal

