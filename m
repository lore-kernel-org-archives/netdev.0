From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC PATCH v0 1/2] net: bridge: propagate FDB table into
 hardware
Date: Wed, 07 Mar 2012 09:11:40 -0500
Message-ID: <1331129500.2237.72.camel@mojatatu>
References: <1329225526.2806.34.camel@mojatatu> <4F3AAE80.4040609@intel.com>
	 <1329315057.4158.15.camel@mojatatu> <4F3C5B44.7000608@intel.com>
	 <1329488932.2272.19.camel@mojatatu> <4F3E8A01.5000205@intel.com>
	 <1329568900.3027.0.camel@mojatatu> <4F4DAC26.4050108@intel.com>
	 <20120305165339.GS12271@wantstofly.org>
	 <1331041346.2374.108.camel@mojatatu>
	 <20120306140957.GA27559@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	bhutchings@solarflare.com, roprabhu@cisco.com,
	netdev@vger.kernel.org, mst@redhat.com, chrisw@redhat.com,
	davem@davemloft.net, gregory.v.rose@intel.com, kvm@vger.kernel.org,
	sri@us.ibm.com, Chris Healy <chealy@imsco-us.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:40891 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755195Ab2CGOzQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2012 09:55:16 -0500
Received: by vcqp1 with SMTP id p1so5435208vcq.19
        for <netdev@vger.kernel.org>; Wed, 07 Mar 2012 06:55:14 -0800 (PST)
In-Reply-To: <20120306140957.GA27559@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2012-03-06 at 15:09 +0100, Lennert Buytenhek wrote:

> Why so?  (I think the switch chips should just never do learning at
> all..)

I agree that learning in software gives you more flexibility; however,
I am for providing interface flexibility as well - switches have
learning features. I think i should be able to use them when it makes
sense to. 

> > I think it should also be upto the admin to decide whether the learning
> > happens in the kernel or user space.
> 
> I can't see any point in doing it in userspace.  What would be the
> advantage of that?  And based on what would the admin make the decision?
> 

If i wanted to do some funky access control based on some new MAC
address showing up - best place to do it is user space.

> It does, there is an STP state field per port in the switch chip,
> which controls whether learning takes place on this port (in
> Learning and Forwarding states) and whether packets are forwarded
> (in the Forwarding state).

ok, makes sense.

> But e.g. it doesn't automatically flush this port's FDB entries if
> you move a port from Forwarding to Listening -- the STP state field
> only controls direct learning and forwarding for received packets.
>
> And when you receive a BPDU with the topology change notification
> bit set, the switch won't automatically shorten the FDB entry
> timeout for you until the topology change is over, either.

I have to go back and look at some manuals i have - but iirc, the
ones ive played with behaved similarly.  As long as we provide knobs
to set/unset those different attributes, I think the handling of all
that should be from software (likely some daemon in user space);
then it shouldnt matter whether we are working with STP BPDUs or TRILL
or thenewprotocolTM etc. 

> Keep in mind that these chips also do VLAN tagging in hardware, and
> so a scenario like:
> 
> 	# brctl addbr br123
> 	# brctl addif br123 lan1.123
> 	# brctl addif br123 lan2.123
> 
> is also one that can be handled in hardware (which the current
> patchwork patch doesn't handle yet).
> 

We would need to work with offloading VLANs, no? Do the current
VLAN offloads used for NICs suffice for switching chips as well?
i.e typically most chips have a table associated with some port in
which the Vlan is partof or is the lookup key. 

> You can let the switch rate limit the number of packets passed up to
> the CPU.  500 kp/s broadcast traffic seems somewhat excessive in any
> case, and I'm not sure if this deserves handling apart from QoSing
> those streams to manageable levels.

Yes, that would provide a solution.
I havent seen anything where you can rate limit the learning(SA lookup
failure). 

cheers,
jamal
