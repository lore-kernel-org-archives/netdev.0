From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [patch net-next 0/4] net: allow to change carrier from
 userspace
Date: Thu, 13 Dec 2012 15:54:23 -0200
Message-ID: <20121213155423.07c47307@obelix.rh>
References: <20121212170520.GA3060@minipsycho.orion>
	<20121212092700.7ef2607a@nehalam.linuxnetplumber.net>
	<20121212181017.GB3060@minipsycho.orion>
	<20121212101208.361ccda0@nehalam.linuxnetplumber.net>
	<20121212182556.GC3060@minipsycho.orion>
	<20121212103632.2020efce@nehalam.linuxnetplumber.net>
	<20121212184925.GD3060@minipsycho.orion>
	<20121212105448.490aca5c@nehalam.linuxnetplumber.net>
	<20121212190613.GE3060@minipsycho.orion>
	<20121212113433.21c05614@nehalam.linuxnetplumber.net>
	<20121213161750.GA1914@minipsycho.orion>
	<50CA0D3D.5000503@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, mirqus@gmail.com,
	greearb@candelatech.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38887 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754438Ab2LMRyg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2012 12:54:36 -0500
In-Reply-To: <50CA0D3D.5000503@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 13 Dec 2012 09:15:41 -0800
John Fastabend <john.fastabend@gmail.com> wrote:

> [...]
> 
> >> That is what the operstate mechanism was for. Why did we build that mechanism
> >> if it doesn't work from userspace.
> >>
> >> Maybe the fix is to make setting linkstate also set carrier bits.
> >
> > Hmm. You mean to call netif_carrier_on/off as a reaction to operstate
> > change? How exactly would you like to do that?
> >
> > Thanks
> >
> > Jiri
> 
> This would break existing applications and would not really be in the
> spirit of the operstate mechanism as I read the documentation:
> 
> ./Documentation/networking/operstates.txt
>   63 IF_OPER_DORMANT (5):
>   64  Interface is L1 up, but waiting for an external event, f.e. for a
>   65  protocol to establish. (802.1X)
> 
> The L1 up is netif_carrier_on here.

Agreed. I am also not finding how to change carrier bits from the
current states.


> We use this in user space when we do not want applications to start
> using the link until we have negotiated and configured some link layer
> attributes. To do this we set IFLA_LINKMODE and then use the
> IF_OPER_DORMANT event to trigger the application eventually setting
> IF_OPER_UP when the link layer negotiation is complete. If you take the
> carrier down this breaks. In my case the protocol is LLDP but I think
> there are other examples. This is basically the example Stephen already
> gave.
> 
> I guess I still am missing why teamd doesn't just set IFLA_LINKMODE
> then manage the operstate this way? Sure teamd would have to become a
> bit smarter but it would save adding additional interfaces to the
> kernel. In the LinkAgg case you could just pin the operstate down this
> would also allow protocols to run under the linkagg over the LLC in
> IEEE speak which I think is being discussed in the latest round of
> LLDP/LinkAgg spec updates (I'll check on that later today).

Think about the ARP monitoring as an example. If the teamd (userlevel)
doesn't receive the reply packet, it should set the master interface 
as down in terms of carrier because there isn't a valid L1 from the
master interface perspective.

LACP needs the same action. If the ports can't move to DISTRIBUTING/
COLLECTING state, it should set master's carrier bit to down.

Even the lack of ports should keep the master with carrier down.

I am saying this because people are used to and there are scripts out
there using something like:
# ethtool <iface> | grep 'Link'
to react an interface failure.

Therefore, I am not seeing how setting operstate to down helps with the
current code.  Can ethtool report Link based on a logic between operstate
and netif_carrier_ok()? If operstate is down, it would report down regardless
of netif_carrier_ok() for instance.

Calling netif_carrier_off() also calls dev_deactivate() to stop everything.
So, if team sets operstate to down, the interface remains active sending/
receiving as far as I can see, right? Not sure if this would be a problem.

-- 
fbl
