From: Matt Domsch <Matt_Domsch@dell.com>
Subject: Re: [PATCH net-next] bnx2x: Add Nic partitioning mode (57712 devices)
Date: Sat, 18 Dec 2010 23:49:53 -0600
Message-ID: <20101219054953.GC5854@auslistsprd01.us.dell.com>
References: <1290982177.6066.3.camel@lb-tlvb-dmitry> <20101129060114.GC29904@auslistsprd01.us.dell.com> <1291023192.9770.0.camel@lb-tlvb-eilong.il.broadcom.com> <20101206173534.GC13628@auslistsprd01.us.dell.com> <4CFD29BE.2060201@chelsio.com> <1291906166.21210.10.camel@lb-tlvb-eilong.il.broadcom.com> <20101217024509.GA5854@auslistsprd01.us.dell.com> <4D0BEE9A.5070505@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eilon Greenstein <eilong@broadcom.com>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"narendra_k@dell.com" <narendra_k@dell.com>,
	"jordan_hargrave@dell.com" <jordan_hargrave@dell.com>
To: Dimitris Michailidis <dm@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60ps301.us.dell.com ([143.166.148.206]:5295 "EHLO
	ausc60ps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816Ab0LSFtz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Dec 2010 00:49:55 -0500
Content-Disposition: inline
In-Reply-To: <4D0BEE9A.5070505@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 17, 2010 at 03:13:30PM -0800, Dimitris Michailidis wrote:
> Matt Domsch wrote:
> >On Thu, Dec 09, 2010 at 04:49:25PM +0200, Eilon Greenstein wrote:
> >>On Mon, 2010-12-06 at 10:21 -0800, Dimitris Michailidis wrote:
> >>>Matt Domsch wrote:
> >>...
> >>>/sys/class/net/<ifname>/dev_id indicates the physical port <ifname> is 
> >>>associated with.  At least a few drivers set up dev_id this way.
> >>>
> >>>
> >>So we are on agreement? This can satisf all needs? If so, we will add
> >>this scheme to the bnx2x as well.
> >
> >I don't think that's enough.  Necessary, but not sufficient.
> >
> >If dev_id is a field that starts over with each PCI device (e.g. is
> >used to distinguish multiple ports that share the same PCI
> >device), that's enough to handle the Chelsio case, but not the NPAR &
> >SR-IOV case.
> 
> My understanding is that dev_id indicates the physical port of the card 
> associated with an interface.  It does not reset when you move to a new 
> function of the device.
> 
> >
> >If the above is true, then a value of dev_id=0 for all 1:1 PCI Device
> >: Port relations is fine, leaving the three drivers that set dev_id
> >non-zero are all multi-port, single PCI device controllers.
> >
> >cxgb4/t4_hw.c:          adap->port[i]->dev_id = j;
> 
> The HW cxgb4 deals with is multi-function (actually the driver uses 
> primarily function 4 nowadays) but it's virtualizable and the association 
> between functions and ports very flexible.  For example, you may have a 
> 2-port card but maybe the driver will be given just (a slice of) port 1.  
> So the driver will create one netdev with dev_id==1 and there won't be 
> anything with dev_id 0.  You cannot determine this by looking at anything 
> PCI-related or any static table.
>
> For this driver you can get two pieces of information for an interface:
> - /sys/class/net/<interface>/device points to the PCI function handling the 
> interface
> - /sys/class/net/<interface>/dev_id indicates the physical port of the 
> interface
>
> You can have several interfaces with same device link and different dev_id. 
>  While the current driver doesn't do it you could also have several 
> interfaces with different device links but same dev_id (NPAR situation, 
> notice again that dev_ids are not per PCI function), or interfaces with 
> different device and dev_id, or even interfaces with same device and dev_id.

What is the scope of dev_id then?  It's not per PCI device like I
thought.  It sounds like it's per card, but how can I know the card
boundary?

If I have 2 cards driven by cxgb4 in the system, each with say 4
ports.  I could see a minimum of 8 PCI devices (fine), but the dev_id
values would be?  0,1,2,3; 0,1,2,3 ?  How can I tell that these are
two different cards, with two different sets of dev_id values, rather
than one card with 4 ports, 8 (NPAR or SR-IOV) interfaces, with each 2
interfaces mapping to the same port?

dev_id is not system-wide unique.  It's not even slot unique best as I
can tell.  If I had a PCI slot extender, with 2 PCI slots, and I put
two of the above cards in, I would see 0,1,2,3; 0,1,2,3.  To be fair,
my naming scheme doesn't really account for such an extender, though
currently it would go pci<slot>#<12345678>.

 
> dev_ids can handle NPAR but I do understand that dev_id 0 is ambiguous.  
> Two functions with dev_id 0 mean one thing for a driver that sets dev_id 
> and a very different thing for one that doesn't.

yeah, that sucks.

> >What if we did something like this?
> >
> >/sys/devices/net_ports/port0/
> >/sys/devices/pci0000:00/0000:00:1c.0/0000:0b:00.0/net/eth0/port -> 
> >    /../../../../../net_ports/port0
> >/sys/devices/pci0000:00/0000:00:1c.0/0000:0b:00.1/net/eth1/port -> 
> >    /../../../../../net_ports/port0
> >
> >
> >In this case, the port0 "name" is simply a way to group interfaces
> >into ports, it's not how ports are labeled on the chassis.
> 
> If I understand you right a "port" is a group of interfaces sharing one 
> physical port without saying which one.  I think dev_id does the same and 
> specifies which physical port.

And I don't think it does, or at least, not in an unambiguous way, the
dev_id=0 case and even != 0. Understanding the boundary of dev_id
domains is the key, and I clearly don't.

Please advise.

Thanks,
Matt

-- 
Matt Domsch
Technology Strategist
Dell | Office of the CTO
