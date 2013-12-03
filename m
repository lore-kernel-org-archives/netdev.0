From: Joseph Gasparakis <joseph.gasparakis@intel.com>
Subject: Re: vxlan/veth performance issues on net.git + latest kernels
Date: Tue, 3 Dec 2013 15:13:32 -0800 (PST)
Message-ID: <alpine.LFD.2.03.1312031500020.570@intel.com>
References: <529DF340.70602@mellanox.com> <1386084620.30495.28.camel@edumazet-glaptop2.roam.corp.google.com> <CAJZOPZJ9WM1H9zKNzT5MvQ2UH7RxkTLk2Rhzsk9vdvKz6d2uAw@mail.gmail.com> <alpine.LFD.2.03.1312031310140.23893@intel.com>
 <CAJZOPZL9LxB5HdqS=+gQW-MjvW2NsZOt3NPB7v1iOFoEB7SsMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Gasparakis, Joseph" <joseph.gasparakis@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jerry Chu <hkchu@google.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eric Dumazet <edumazet@google.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:51570 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755415Ab3LCW4H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Dec 2013 17:56:07 -0500
In-Reply-To: <CAJZOPZL9LxB5HdqS=+gQW-MjvW2NsZOt3NPB7v1iOFoEB7SsMQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 3 Dec 2013, Or Gerlitz wrote:

> On Tue, Dec 3, 2013 at 11:11 PM, Joseph Gasparakis
> <joseph.gasparakis@intel.com> wrote:
> 
> >>> lack of GRO : receiver seems to not be able to receive as fast as you want.
> >>>>      TCPOFOQueue: 3167879
> >>> So many packets are received out of order (because of losses)
> 
> >> I see that there's no GRO also for the non-veth tests which involve
> >> vxlan, and over there the receiving side is capable to consume the
> >> packets, do you have rough explaination why adding veth to the chain
> >> is such game changer which makes things to start falling out?
> 
> > I have seen this before. Here are my findings:
> >
> > The gso_type is different if the skb comes from veth or not. From veth,
> > you will see the SKB_GSO_DODGY set. This breaks things as when the
> > skb with DODGY set moves from vxlan to the driver through dev_xmit_hard,
> > the stack drops it silently. I never got the time to find the root cause
> > for this, but I know it causes re-transmissions and big performance
> > degregation.
> >
> > I went as far as just quickly hacking a one liner unsetting the DODGY bit
> > in vxlan.c and that bypassed the issue and recovered the performance
> > problem, but obviously this is not a real fix.
> 
> thanks for the heads up, few quick questions/clafications --
> 
> -- you are talking on drops done @ the sender side, correct? Eric was
> saying we have evidences that the drops happen on the receiver.

I am *guessing* drops on the Rx are due to the drops at the Tx. See my 
answer to your next question for more info.

> 
> -- without the hack you did, still packets are sent/received, so what
> makes the stack to drop only some of them?
> 

What I had seen is GSOs getting dropped on the Tx side. Basically the GSOs 
never made it to the driver, they were broken into non GSO smaller skbs by 
the stack. I think the stack is not handling well the GSO with the DODGY 
bit set, and that causes it to maybe partially the packet to be emitted,
causing the re-transmits (and maybe the drops on your Rx end)? Of course 
all this is speculation, the fact that I know is that as soon as I was
forcing the gso type I saw offloaded VXLAN encapsulated traffic at decent speeds.

> -- why packets coming from veth would have the SKB_GSO_DODGY bit set?

That is something I would love to know too. I am guessing this is a way 
for the VM to say it is a non-trusted packet? And maybe all this can be 
fixed by maybe setting something on the VM through a userspace tool that 
will stop the veth to set the DODGY bit?

> 
> -- so where is now (say net.git or 3.12.x) this one line you commented
> out? I don't see in vxlan.c or in ip_tunnel_core.c / ip_tunnel.c
> explicit setting of SKB_GSO_DODGY

I did not commit it, as this was just a workaround to prove to myself that 
the problem I was seing was due to the gso_type, and it would actually 
just hide the problem and not give a proper solution to it.

> 
> Also, I am pretty sure the problem exists also when sending/receiving
> guest traffic through tap/macvtap <--> vhost/virtio-net and friends, I
> just sticked to the veth flavour b/c its one (== the hypervisor)
> network stack to debug and not two (+ the guest one).
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
