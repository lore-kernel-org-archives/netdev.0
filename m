From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Thu, 29 Jun 2006 19:23:14 -0400
Message-ID: <1151623394.8922.27.camel@jzny2>
References: <44A0138F.8050208@trash.net>
	 <20060626.104654.98552111.davem@davemloft.net>
	 <20060626184424.GT1376@postel.suug.ch> <44A05FE0.7070203@trash.net>
	 <20060627100309.GU1376@postel.suug.ch> <1151413670.6516.57.camel@jzny2>
	 <20060628101832.GW1376@postel.suug.ch> <1151497363.5203.47.camel@jzny2>
	 <20060628130124.GX1376@postel.suug.ch> <1151502408.5203.94.camel@jzny2>
	 <20060629085111.GY1376@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:59310 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S933091AbWF2XXS
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 19:23:18 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1Fw5r1-0003L1-JC
	for netdev@vger.kernel.org; Thu, 29 Jun 2006 19:23:23 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060629085111.GY1376@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I noticed the other email carrying a patch. Let me respond to this email
and hopefully that will address the patch.

On Thu, 2006-29-06 at 10:51 +0200, Thomas Graf wrote: 
> * jamal <hadi@cyberus.ca> 2006-06-28 09:46
[..] 
> I disagree, iflink information is bogus once we start redirecting.

After redirecting, iflink is "available" i.e it doesnt make any
more sense and therefore it should be (ab)usable to carry other info.
But the more i think about it, using skb->dev is just fine for 
finding the device you are looking for even when it gets redirected.
 
I am assuming you still want to find out - in the case of a topology
which constitutes more than one netdevice - the second last netdevice,
correct?

> > 
> > Can you achieve the same by binding to any arbitrary netdevice? If you
> > can then i would agree.
> 
> It was your request to not update input_dev in netif_receive_skb()
> but rather have each netdevice handle it manually. 

For good reasons of course.

note: you didnt answer the question i asked, but probably the answer
doesnt matter.

> What's currently
> done in ifb:
> 
> 	skb->dev = skb->input_dev;
> 	skb->input_dev = dev;
> 
> Confusing, isn't it? 

not at all. Let me explain the design intent further below.

> I really don't get input_dev/iif is supposed to
> be updated in ifb. If a packet is to be redirected, the mirred action
> shall take care of providing this information to the next netdevice.

ifb is a special purpose device.
Think of it as a redirector, or injector if you want a better noun. If
you are going to inject packets back to the stack at arbitrary points,
then you need to reflect that in the packet metadata implying where it
came from. Likewise if you are going to redirect packets into arbitrary
points in the stack (as mirred does), you need to do the same. 
I dont know if that makes sense. 

> My additional request is to provide a flag to disable this for special
> purposes not hurting anyone.

I am failing to see the purpose. 
With all due respect, you are changing the design intent, Thomas.

I know your intent is noble in trying to save the 32 bits on 64 bit
machines (at least thats where your patch seems to have started) but the
cost:benefit ratio as i have pointed out is unreasonable. 
If you can meet the requirements i have specified (I am leaving them
below) i will be a happy camper.

> > The challenge is this, and if you can solve it we would be fine:
> > - I need to access both the input_dev and dev and their metadata.
> > I could clearly find them by their ifindices and then reference them
> > after that. For performance reasons that is not optimal in the fast
> > path.  
> 

So just we are clear: I have strong desire to save compute rather than
than saving 32 bits per skb on 64 bit machine. 

> Nice, you forget that while redirecting the device pointed to by
> input_dev can disappear leaving behind an illegal reference. 

We have had this discussion before - that is resolvable via
dev_put/hold.

> The purpose of this patch is to fix this.

Appreciated - but can you do it without replacing the input_dev?

cheers,
jamal

