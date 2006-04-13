From: jamal <hadi@cyberus.ca>
Subject: Re: tc actions like pass,drop executed at a given percentage, not
	every nth
Date: Thu, 13 Apr 2006 09:17:47 -0400
Message-ID: <1144934267.5262.22.camel@jzny2>
References: <20060411154259.77190.qmail@web54301.mail.yahoo.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:28886 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S964924AbWDMNRu
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 09:17:50 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1FU1hp-0007h2-4B
	for netdev@vger.kernel.org; Thu, 13 Apr 2006 09:17:53 -0400
To: pfer <forgamedev@yahoo.com>
In-Reply-To: <20060411154259.77190.qmail@web54301.mail.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-11-04 at 08:42 -0700, pfer wrote:
> Hi all!
> 
> Can you give me some guideline about how and where
> netrand ... influences an action in the tc sources?
> 
> (I've also tried LARTC mailing list, but did not get
>  any response)
> 

Did you look at the docs included in iproute2?

> When I last checked, iproute2 sources had a tc gact
> module with 2 statistical netrand methods:
> 
>  - random
>  - determ
> 
> and both are followed by an integer, saying what to do
> with every n-th packet (if I get it right from docs
> and tc filter show)
> 
> Problem is, I would need % of packets to do actions
> on, not on every n-th. This limits me to
> 50,33,25,20,... etc % ratios, because I cannot write
> for. ex. 
> 
> action drop random determ 1.23 ok
> 

right.

> So, basically I believe I would need something like
> this in pseudo:
> 
> for every packet
>     if(rand()<(percent/100))
>          do_action
> 
> ,where rand() gives a float of 0..1
> 

We dont like floats in the kernel - but i think i understand the 
gist of what you want to achieve.

> Or if doing a rand() for every packet is costy,
> then I could decrease granularity by 2 or 5, etc.
> Still,I would get the ratio.
> 
> I delved into the sources, but was unable to find
> where 
> this conditional (for every n-th packet) tc action
> execution occurs.
> 

The control code is in iproute2: 
iproute2/tc/m_gact.c
The mechanisms are implemented in the kernel:
net/sched/act_gact.c

Just follow the trail of #ifdef CONFIG_GACT_PROB 
both in user space and in the kernel.

You would need to add another method for % in addition to
gact_net_rand() and gact_determ()
You may actually be able to achieve your goal by picking the right
number for determ (we restrict the max to be 10000)
If you cant achieve your goal with determ - I would be more than happy
to ACK a patch that does percentages.

> (If anyone is interested, I need this for a  protocol
> that uses a strange congestion signaling method to let
> intra-domain nodes notify edges, based on packet ratio
> having different DSCP. The name is RMD-QoS-NSLP)
> 

Cool.
Shoot me private email if you need help since this is really out of
scope of netdev

cheers,
jamal

