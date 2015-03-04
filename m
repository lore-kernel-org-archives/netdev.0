From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: Switchdev Application to SR-IOV NICs
Date: Tue, 03 Mar 2015 20:05:03 -0800
Message-ID: <54F6846F.70203@gmail.com>
References: <3A5015FE9E557D448AF7238AF0ACE20A2D8ACC6F@IRVEXCHMB11.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	=?UTF-8?B?IkppxZnDrQ==?=
	 =?UTF-8?B?IFDDrXJrbyAoamlyaUByZXNudWxsaS51cyki?=
	<jiri@resnulli.us>
To: David Christensen <davidch@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:34673 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758151AbbCDEFN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 23:05:13 -0500
Received: by oigh136 with SMTP id h136so3526338oig.1
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2015 20:05:12 -0800 (PST)
In-Reply-To: <3A5015FE9E557D448AF7238AF0ACE20A2D8ACC6F@IRVEXCHMB11.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/03/2015 04:26 PM, David Christensen wrote:
> I'm struggling with the concept of implementing switchdev on an SR-IOV NIC.
> Most slides presented at Netdev 0.1 agreed that switchdev should be applicable
> to SR-IOV NICs as well as switch ASICs, but I'm having difficulty figuring
> out exactly how things should operate.  Here's how things look today with
> netdev and SR-IOV VFs passed-through to a virtual machine.
>
>        +-----+-----+-----+
>        | vm0 | vm1 | vm2 | Virtual
>        | eth0| eth0| eth0| Machines
> +-----+--|--+--|--+--|--+----------
> |eth0 |  |     |     |    Kernel
> +--|--+--|-----|-----|--+----------
> | pf0   vf0   vf1   vf2 | PCIe
> +--|-----|-----|-----|--+----------
> | ++-----+-----+-----++ | SR-IOV NIC
> | | VEB               | |
> | +------------+------+ |
> +--------------|--------+
>                 |
>                PHY
>
> Connectivity between VMs and the host is handled by the VEB operating in the
> NIC, other traffic is forwarded normally by the VEB from the external network
> to the host/VM based on destination MAC and VLAN with special handling
> required for broadcast/multicast.
>
> Based on some separate conversations I've had with Jiri, I'm lead to believe
> switchdev would look something like this.
>
>        +-----+-----+-----+
>        | vm0 | vm1 | vm2 | Virtual
>        | eth0| eth0| eth0| Machines
> +-----+--|--+--|--+--|--+----------
> |sw0p0 sw0p1 sw0p2 sw0p3| Kernel
> +--|-----|-----|-----|--+----------
> | pf0   vf0   vf1   vf2 | PCIe
> +--|-----|-----|-----|--+----------
> | ++-----+-----+-----++ | SR-IOV NIC
> | | VEB               | |
> | +------------+------+ |
> | SR-IOV NIC   |        |
> +--------------|--------+
>                 |
>                PHY

That looks good to me I might add one more netdev to represent the
egress port though. This could be used to submit control traffic
that should not by spec be sent through a VEB. For example STP,
LLDP, etc. At the moment we send this traffic on sw0p0 which is
exactly correct.

I had some prototype code @ one point that did this I can dig it
up if folks think its useful.

Also it might be worth noting the "Kernel" net_devices are not
actually bound to the virtual function but multiplexed/demux'd
over the physical function pf0 in the diagram. The diagram might
be read to imply some PCIe relationship between sw0p3 and vf2.

>
> The use of switchdev would show that all sw0* devices are associated with the
> same switch, and the instantiation of the sw0* devices in the kernel would
> provide higher level applications like OVS/Linux bridge/etc. to control traffic
> in a way not possible in the earlier example.  So far so good?
>
> Now the question becomes how to plumb SR-IOV NIC to create this representation.
> Looking at one specific path:
>
>    +-----+
>    | vm0 |
>    | eth0|
>    +--|--+
>    |sw0p1|
>    +--|--+
>    | vf0 |
> +----|----+
> | +--+--+ |
> | | VEB | |
> | +-----+ |
> +---------+
>
> It's unclear to me when traffic egressing the VEB should terminate at sw0p1 vs.
> vm0's eth0.  They both represent the same MAC/VLAN.  Similarly, for traffic
> egressing vm0's eth0, when should it terminate at sw0p1 vs. the VEB.
>
> Can anyone offer an alternate diagram for switchdev on an SR-IOV NIC?
>

One approach would be to treat it like the switch case where instead
of a physical port you have a VF. In this case if you xmit a packet on
sw0p1 it is sent to eth0. Then if vm0 (eth0) xmits a packet it enters
the VEB. The only way to get packets onto sw0p1 is to use a rule to
either "trap" or "mirror" packets to the "CPU sw0p1 port". Maybe a
better name would be "hypervisor sw0p1 port". This would be analagous
to the switch case, I have experimented with adding this support to
the Flow API I'm working on but have not implemented it on rocker yet.


  +-----+      +-----+
  |hyper|      | vm1 |
  |visor|      | eth0|
  +-----+      +-----+
     |            |
  +--|--+      +--|--+
  |sw0p0|      |sw0p2|
  +-----+      +-----+
     |           |
  +--|-----|-----|-----|--+
  | ++-----+-----+-----++ |
  | | VEB               | |
  | +------------+------+ |
  | SR-IOV NIC   |        |
  +--------------|--------+
                  |
                 PHY

here the link between sw0p2 and vm1 is a virtual function instead of a
physical wire. And sw0p0 is the "CPU port" directly to the hypervisor.

Is that at all clear? Let me know I can try to do a better write up
in the AM.

.John

> Dave
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
John Fastabend         Intel Corporation
