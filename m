From: jamal <hadi@cyberus.ca>
Subject: Re: Multiqueue and virtualization WAS(Re: [PATCH 3/3] NET: [SCHED]
	Qdisc changes and sch_rr added for multiqueue
Date: Fri, 06 Jul 2007 10:39:15 -0400
Message-ID: <1183732755.5155.85.camel@localhost>
References: <1183215164.5165.13.camel@localhost>
	 <20070630.133357.77057070.davem@davemloft.net>
	 <1183466553.5159.51.camel@localhost>
	 <20070703.142431.49854676.davem@davemloft.net>
	 <1183515611.5174.34.camel@localhost>
	 <1183707166.6005.172.camel@localhost.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, auke-jan.h.kok@intel.com
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.233]:7363 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753900AbXGFOjU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2007 10:39:20 -0400
Received: by wx-out-0506.google.com with SMTP id h31so203688wxd
        for <netdev@vger.kernel.org>; Fri, 06 Jul 2007 07:39:19 -0700 (PDT)
In-Reply-To: <1183707166.6005.172.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-06-07 at 17:32 +1000, Rusty Russell wrote:

[..some good stuff deleted here ..]

> Hope that adds something,

It does - thanks. 
 
I think i was letting my experience pollute my thinking earlier when
Dave posted. The copy-avoidance requirement is clear to me[1].

I had another issue which wasnt clear but you touched on it so this
breaks the ice for me - be gentle please, my asbestos suit is full of
dust these days ;->:

The first thing that crossed my mind was "if you want to select a
destination port based on a destination MAC you are talking about a
switch/bridge". You bring up the issue of "a huge number of virtual NICs
if you wanted arbitrary guests" which is a real one[2]. 
Lets take the case of a small number of guests; a bridge of course would
solve the problem with the copy-avoidance with the caveat being:
- you now have N bridges and their respective tables for N domains i.e
one on each domain 
- N netdevices on each domain as well (of course you could say that is
not very different resourcewise from N queues instead). 

If i got this right, still not answering the netif_stop question posed:
the problem you are also trying to resolve now is get rid of N
netdevices on each guest for a usability reason; i.e have one netdevice,
move the bridging/switching functionality/tables into the driver;
replace the ports with queues instead of netdevices. Did i get that
right? 
If the issue is usability of listing 1024 netdevices, i can think of
many ways to resolve it.
One way we can resolve the listing is with a simple tag to the netdev
struct i could say "list netdevices for guest 0-10" etc etc.

I am having a little problem differentiating conceptually the case of a
guest being different from the host/dom0 if you want to migrate the
switching/bridging functions into each guest. So even if this doesnt
apply to all domains, it does apply to the dom0.
I like netdevices today (as opposed to queues within netdevices):
- the stack knows them well (I can add IP addresses, i can point routes
to, I can change MAC addresses, i can bring them administratively
down/up, I can add qos rules etc etc).
I can also tie netdevices to a CPU and therefore scale that way. I see
this viable at least from the host/dom0 perspective if a netdevice
represents a guest.

Sorry for the long email - drained some of my morning coffee.
Ok, kill me.

cheers,
jamal

[1] My experience is around qemu/uml/old-openvz - their model is to let
the host do the routing/switching between guests or the outside of the
box. From your description i would add Xen to that behavior.
>From Daves posting, i understand that for many good reasons, any time
you move between any one domain to another you are copying. So if you
use Xen and you want to go from domainX to domainY you go to dom0 which
implies copying domainX->dom0 then dom0->domainY. 
BTW, one curve that threw me off a little is it seems most of the
hardware that provides virtualization also provides point-to-point
connections between different domains; i always thought that they all
provided a point-to-point to the dom0 equivalent and let the dom0 worry
about how things get from domainX to domainY.

[2] Unfortunately that means if i wanted 1024 virtual routers/guest
domains i have at least 1024 netdevices on each guest connected to the
bridge on the guest. I have a freaking problem listing 72 netdevices
today on some device i have.

