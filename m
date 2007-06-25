From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Mon, 25 Jun 2007 12:47:31 -0400
Message-ID: <1182790051.5184.29.camel@localhost>
References: <466DEF9D.9070509@trash.net>
	 <1181615384.4071.121.camel@localhost>	<466E9DF2.9010505@trash.net>
	 <20070612.140240.00078635.davem@davemloft.net> <466F0D74.5030308@trash.net>
	 <1181714168.4758.57.camel@debian.sh.intel.com>
	 <1181737935.4050.87.camel@localhost>
	 <1181789064.4758.127.camel@debian.sh.intel.com>
	 <1181821707.4091.32.camel@localhost>
	 <1181870826.4092.29.camel@debian.sh.intel.com>
	 <1181904575.4102.31.camel@localhost>
	 <1182129521.4092.77.camel@debian.sh.intel.com>
	 <1182179770.4063.26.camel@localhost>
	 <1182219120.4092.143.camel@debian.sh.intel.com>
	 <1182269060.4968.45.camel@localhost>
	 <1182318706.4092.255.camel@debian.sh.intel.com>
	 <1182440388.5017.31.camel@localhost>
	 <1182475614.30969.102.camel@debian.sh.intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, auke-jan.h.kok@intel.com
To: Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.226]:8189 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752495AbXFYQrf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 12:47:35 -0400
Received: by wx-out-0506.google.com with SMTP id t15so1509470wxc
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2007 09:47:34 -0700 (PDT)
In-Reply-To: <1182475614.30969.102.camel@debian.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-22-06 at 09:26 +0800, Zhu Yi wrote:
> On Thu, 2007-06-21 at 11:39 -0400, jamal wrote:

> It sounds stupid I'm still trying to convince you why we need multiqueue
> support in Qdisc when everybody else are already working on the code,

If you go back historically (maybe 2 years ago on netdev?) - i was a big
fan of the scheme used in those patches ;->
In a Xcracy like Linux, you have to agree to disagree at some point and
move on.  I dont need any core changes to deploy what i am suggesting.

> fixing bugs and preparing for merge. The only reason I keep the
> conversation is that I think you _might_ have some really good points
> that buried under everybody else's positive support for multiqueue. But
> with the conversation goes on, it turns out not the truth.

We have come a long way and maybe you just didnt understand me
initially.

> We don't have THL and THH in our driver. They are what you suggested.
> The queue wakeup number is 1/4 of the ring size.

So how did you pick 1/4? Experimentation? If you look at tg3 its much
higher for example.

> > The timer fires only if a ring shuts down the interface. Where is the
> > busy loop? If packets go out, there is no timer.
> 
> The busy loop happens in the period after the ring is shut down and
> before it is opened again. During this period, the Qdisc will keep
> dequeuing and requeuing PL packets in the Tx SoftIRQ, where the busy
> loop happens.

Ok, sure - this boils to what Patrick pointed out as well. I would see
this as being similar to any other corner case you meet. You may be able
to convince me otherwise if you can show me some numbers, for example:
how often this would happen, and how long would a LP be disallowed from
sending on the wire when the ring is full. I have read a few papers (i
posted one or two on the list) and none seem to have come across this as
an issue. You may have better insight. 
So to me this is a corner case which is resolvable. I wouldnt consider
this to be any different than say dealing with failed allocs.You have to
deal with them.

So lets make this an engineering challenge and try to see how many ways
we can solve it ...
Here's one:
Use an exponentially backoff timer. i.e if you decide that you will open
the path every 1 sec or X packets, then the next time it turns to be a
false positive, increment the timer; upto an upper bound ( a lot of
protocols do this). That should cut down substantially how many times
you open up and finding no HP packets.

> > I dont think you understood: Whatever value you choose for THL and THH
> > today, keep those. OTOH, the wake threshold is what i was refering to.
> 
> I don't even care about the threshold. Even you set it to 1, there is
> still busy loop during the period before this first packet is sent out
> in the air. But you cannot ignore this small time, because it could be
> longer when the wireless medium is congested with high prio packets.

Give me some numbers and you may be able to convince me that this may
not be so good for wireless. I have had no problems with prescribed
scheme for multiqueue ethernet chips.

cheers,
jamal


