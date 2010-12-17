From: Matt Domsch <Matt_Domsch@dell.com>
Subject: Re: [PATCH net-next] bnx2x: Add Nic partitioning mode (57712 devices)
Date: Thu, 16 Dec 2010 20:45:09 -0600
Message-ID: <20101217024509.GA5854@auslistsprd01.us.dell.com>
References: <1290982177.6066.3.camel@lb-tlvb-dmitry> <20101129060114.GC29904@auslistsprd01.us.dell.com> <1291023192.9770.0.camel@lb-tlvb-eilong.il.broadcom.com> <20101206173534.GC13628@auslistsprd01.us.dell.com> <4CFD29BE.2060201@chelsio.com> <1291906166.21210.10.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dimitris Michailidis <dm@chelsio.com>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"narendra_k@dell.com" <narendra_k@dell.com>,
	"jordan_hargrave@dell.com" <jordan_hargrave@dell.com>
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausxippc101.us.dell.com ([143.166.85.207]:26893 "EHLO
	ausxippc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751114Ab0LQCpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 21:45:13 -0500
Content-Disposition: inline
In-Reply-To: <1291906166.21210.10.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 09, 2010 at 04:49:25PM +0200, Eilon Greenstein wrote:
> On Mon, 2010-12-06 at 10:21 -0800, Dimitris Michailidis wrote:
> > Matt Domsch wrote:
> ...
> > /sys/class/net/<ifname>/dev_id indicates the physical port <ifname> is 
> > associated with.  At least a few drivers set up dev_id this way.
> > 
> > 
> 
> So we are on agreement? This can satisf all needs? If so, we will add
> this scheme to the bnx2x as well.

I don't think that's enough.  Necessary, but not sufficient.

If dev_id is a field that starts over with each PCI device (e.g. is
used to distinguish multiple ports that share the same PCI
device), that's enough to handle the Chelsio case, but not the NPAR &
SR-IOV case.

If the above is true, then a value of dev_id=0 for all 1:1 PCI Device
: Port relations is fine, leaving the three drivers that set dev_id
non-zero are all multi-port, single PCI device controllers.

cxgb4/t4_hw.c:          adap->port[i]->dev_id = j;
mlx4/en_netdev.c:       dev->dev_id =  port - 1;
sfc/siena.c:    efx->net_dev->dev_id = EFX_OWORD_FIELD(reg, FRF_CZ_CS_PORT_NUM) - 1;

Is that truly how these three controllers work: they set dev_id when
there are multiple physical ports that a single PCI d/b/d/f drives?

My naming convention of:
  pci<slot>#<port>
wants to express this relationship.  If I have a card with 2 PCI
devices, and 2 physical ports on each device, I have 4 ports to
describe.  The dev_ids would look like: 0,1 0,1 , so I can't use that
value directly.  I can make a list of PCI devices on the same card,
look at the dev_id field of each, and run a counter:

for each slot:
  int port=1;
  for each pci device:
     for each in net/<interface>/dev_id:
        use name pci<slot>#<port>
	port++

OK?  Can someone with such a card send me tree /sys, so I can see the
tree does really look like I expect:

/sys/devices/pci0000:00/0000:00:1c.0/0000:0b:00.0/net/eth0/dev_id = 0
/sys/devices/pci0000:00/0000:00:1c.0/0000:0b:00.0/net/eth1/dev_id = 1

simply finding a net/ subdir under a PCI device, each of the
directories in net/ are interface names, with different dev_id values.



Now for the partitioned devices (NPAR or SR-IOV).  Here, we have
multiple PCI devices mapped to the same port.

My naming convention of:
  pci<slot>#<port>_<partition>
wants to express this relationship. 

I need a way to express which port a given partition maps to.  I'm
also presuming this is a static mapping right now, that it won't
change around during runtime (ala Xsigo, which I have no solution here
for; if the mapping isn't static, this is going to get trickier).

As dev_ids are only unique per PCI device, we would need a pointer to
the "base" device.  However, in the Broadcom 57712 case, there is no
such "base" device. :-( So, using dev_id here doesn't seem like the
right approach for these devices.

What if we did something like this?

/sys/devices/net_ports/port0/
/sys/devices/pci0000:00/0000:00:1c.0/0000:0b:00.0/net/eth0/port -> 
    /../../../../../net_ports/port0
/sys/devices/pci0000:00/0000:00:1c.0/0000:0b:00.1/net/eth1/port -> 
    /../../../../../net_ports/port0


In this case, the port0 "name" is simply a way to group interfaces
into ports, it's not how ports are labeled on the chassis.

Do network drivers know how many ports they have?
What are the characteristics of network ports? Ideally, physical
location (PCI slot), and index within that physical location.  These
right now I'm deriving from SMBIOS and PCI, and if not explicitly
exposed, counting devices on the same slot and assigning port numbers
that way, but I would love to have explicit information from the
drivers.

Thoughts?

Thanks,
Matt

-- 
Matt Domsch
Technology Strategist
Dell | Office of the CTO
