From: Dimitris Michailidis <dm@chelsio.com>
Subject: Re: [PATCH net-next] bnx2x: Add Nic partitioning mode (57712 devices)
Date: Fri, 17 Dec 2010 15:13:30 -0800
Message-ID: <4D0BEE9A.5070505@chelsio.com>
References: <1290982177.6066.3.camel@lb-tlvb-dmitry> <20101129060114.GC29904@auslistsprd01.us.dell.com> <1291023192.9770.0.camel@lb-tlvb-eilong.il.broadcom.com> <20101206173534.GC13628@auslistsprd01.us.dell.com> <4CFD29BE.2060201@chelsio.com> <1291906166.21210.10.camel@lb-tlvb-eilong.il.broadcom.com> <20101217024509.GA5854@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eilon Greenstein <eilong@broadcom.com>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"narendra_k@dell.com" <narendra_k@dell.com>,
	"jordan_hargrave@dell.com" <jordan_hargrave@dell.com>
To: Matt Domsch <Matt_Domsch@dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:7178 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754433Ab0LQXNl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 18:13:41 -0500
In-Reply-To: <20101217024509.GA5854@auslistsprd01.us.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matt Domsch wrote:
> On Thu, Dec 09, 2010 at 04:49:25PM +0200, Eilon Greenstein wrote:
>> On Mon, 2010-12-06 at 10:21 -0800, Dimitris Michailidis wrote:
>>> Matt Domsch wrote:
>> ...
>>> /sys/class/net/<ifname>/dev_id indicates the physical port <ifname> is 
>>> associated with.  At least a few drivers set up dev_id this way.
>>>
>>>
>> So we are on agreement? This can satisf all needs? If so, we will add
>> this scheme to the bnx2x as well.
> 
> I don't think that's enough.  Necessary, but not sufficient.
> 
> If dev_id is a field that starts over with each PCI device (e.g. is
> used to distinguish multiple ports that share the same PCI
> device), that's enough to handle the Chelsio case, but not the NPAR &
> SR-IOV case.

My understanding is that dev_id indicates the physical port of the card 
associated with an interface.  It does not reset when you move to a new 
function of the device.

> 
> If the above is true, then a value of dev_id=0 for all 1:1 PCI Device
> : Port relations is fine, leaving the three drivers that set dev_id
> non-zero are all multi-port, single PCI device controllers.
> 
> cxgb4/t4_hw.c:          adap->port[i]->dev_id = j;

The HW cxgb4 deals with is multi-function (actually the driver uses 
primarily function 4 nowadays) but it's virtualizable and the association 
between functions and ports very flexible.  For example, you may have a 
2-port card but maybe the driver will be given just (a slice of) port 1.  So 
the driver will create one netdev with dev_id==1 and there won't be anything 
with dev_id 0.  You cannot determine this by looking at anything PCI-related 
or any static table.

For this driver you can get two pieces of information for an interface:
- /sys/class/net/<interface>/device points to the PCI function handling the 
interface
- /sys/class/net/<interface>/dev_id indicates the physical port of the interface

You can have several interfaces with same device link and different dev_id. 
  While the current driver doesn't do it you could also have several 
interfaces with different device links but same dev_id (NPAR situation, 
notice again that dev_ids are not per PCI function), or interfaces with 
different device and dev_id, or even interfaces with same device and dev_id.

> mlx4/en_netdev.c:       dev->dev_id =  port - 1;
> sfc/siena.c:    efx->net_dev->dev_id = EFX_OWORD_FIELD(reg, FRF_CZ_CS_PORT_NUM) - 1;
> 
> Is that truly how these three controllers work: they set dev_id when
> there are multiple physical ports that a single PCI d/b/d/f drives?
> 
> My naming convention of:
>   pci<slot>#<port>
> wants to express this relationship.  If I have a card with 2 PCI
> devices, and 2 physical ports on each device, I have 4 ports to
> describe.  The dev_ids would look like: 0,1 0,1 , so I can't use that
> value directly.

I think they'd be 0,1,2,3 for drivers that set dev_id and 0,0,0,0 otherwise.

   I can make a list of PCI devices on the same card,
> look at the dev_id field of each, and run a counter:
> 
> for each slot:
>   int port=1;
>   for each pci device:
>      for each in net/<interface>/dev_id:
>         use name pci<slot>#<port>
> 	port++
> 
> OK?  Can someone with such a card send me tree /sys, so I can see the
> tree does really look like I expect:
> 
> /sys/devices/pci0000:00/0000:00:1c.0/0000:0b:00.0/net/eth0/dev_id = 0
> /sys/devices/pci0000:00/0000:00:1c.0/0000:0b:00.0/net/eth1/dev_id = 1
> 
> simply finding a net/ subdir under a PCI device, each of the
> directories in net/ are interface names, with different dev_id values.

This would be the common case but in general the dev_ids don't need to be 
consecutive or start at 0, nor does a particular dev_id need to appear just 
once.

> Now for the partitioned devices (NPAR or SR-IOV).  Here, we have
> multiple PCI devices mapped to the same port.
> 
> My naming convention of:
>   pci<slot>#<port>_<partition>
> wants to express this relationship. 
> 
> I need a way to express which port a given partition maps to.  I'm
> also presuming this is a static mapping right now, that it won't
> change around during runtime (ala Xsigo, which I have no solution here
> for; if the mapping isn't static, this is going to get trickier).
> 
> As dev_ids are only unique per PCI device, we would need a pointer to
> the "base" device.  However, in the Broadcom 57712 case, there is no
> such "base" device. :-( So, using dev_id here doesn't seem like the
> right approach for these devices.

dev_ids can handle NPAR but I do understand that dev_id 0 is ambiguous.  Two 
functions with dev_id 0 mean one thing for a driver that sets dev_id and a 
very different thing for one that doesn't.

> What if we did something like this?
> 
> /sys/devices/net_ports/port0/
> /sys/devices/pci0000:00/0000:00:1c.0/0000:0b:00.0/net/eth0/port -> 
>     /../../../../../net_ports/port0
> /sys/devices/pci0000:00/0000:00:1c.0/0000:0b:00.1/net/eth1/port -> 
>     /../../../../../net_ports/port0
> 
> 
> In this case, the port0 "name" is simply a way to group interfaces
> into ports, it's not how ports are labeled on the chassis.

If I understand you right a "port" is a group of interfaces sharing one 
physical port without saying which one.  I think dev_id does the same and 
specifies which physical port.

> 
> Do network drivers know how many ports they have?
> What are the characteristics of network ports? Ideally, physical
> location (PCI slot), and index within that physical location.

This index is the dev_id for drivers that set it.

> These
> right now I'm deriving from SMBIOS and PCI, and if not explicitly
> exposed, counting devices on the same slot and assigning port numbers
> that way, but I would love to have explicit information from the
> drivers.
> 
> Thoughts?
> 
> Thanks,
> Matt
> 

