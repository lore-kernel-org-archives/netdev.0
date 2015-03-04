From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: Switchdev Application to SR-IOV NICs
Date: Wed, 4 Mar 2015 08:25:37 +0100
Message-ID: <20150304072537.GA2029@nanopsycho.orion>
References: <3A5015FE9E557D448AF7238AF0ACE20A2D8ACC6F@IRVEXCHMB11.corp.ad.broadcom.com>
 <54F6846F.70203@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Christensen <davidch@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:45835 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933448AbbCDHZo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 02:25:44 -0500
Received: by wivz2 with SMTP id z2so8853629wiv.4
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2015 23:25:43 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <54F6846F.70203@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Mar 04, 2015 at 05:05:03AM CET, john.fastabend@gmail.com wrote:
>On 03/03/2015 04:26 PM, David Christensen wrote:
>>I'm struggling with the concept of implementing switchdev on an SR-IOV NIC.
>>Most slides presented at Netdev 0.1 agreed that switchdev should be applicable
>>to SR-IOV NICs as well as switch ASICs, but I'm having difficulty figuring
>>out exactly how things should operate.  Here's how things look today with
>>netdev and SR-IOV VFs passed-through to a virtual machine.
>>
>>       +-----+-----+-----+
>>       | vm0 | vm1 | vm2 | Virtual
>>       | eth0| eth0| eth0| Machines
>>+-----+--|--+--|--+--|--+----------
>>|eth0 |  |     |     |    Kernel
>>+--|--+--|-----|-----|--+----------
>>| pf0   vf0   vf1   vf2 | PCIe
>>+--|-----|-----|-----|--+----------
>>| ++-----+-----+-----++ | SR-IOV NIC
>>| | VEB               | |
>>| +------------+------+ |
>>+--------------|--------+
>>                |
>>               PHY
>>
>>Connectivity between VMs and the host is handled by the VEB operating in the
>>NIC, other traffic is forwarded normally by the VEB from the external network
>>to the host/VM based on destination MAC and VLAN with special handling
>>required for broadcast/multicast.
>>
>>Based on some separate conversations I've had with Jiri, I'm lead to believe
>>switchdev would look something like this.
>>
>>       +-----+-----+-----+
>>       | vm0 | vm1 | vm2 | Virtual
>>       | eth0| eth0| eth0| Machines
>>+-----+--|--+--|--+--|--+----------
>>|sw0p0 sw0p1 sw0p2 sw0p3| Kernel
>>+--|-----|-----|-----|--+----------
>>| pf0   vf0   vf1   vf2 | PCIe
>>+--|-----|-----|-----|--+----------
>>| ++-----+-----+-----++ | SR-IOV NIC
>>| | VEB               | |
>>| +------------+------+ |
>>| SR-IOV NIC   |        |
>>+--------------|--------+
>>                |
>>               PHY
>
>That looks good to me I might add one more netdev to represent the
>egress port though. This could be used to submit control traffic
>that should not by spec be sent through a VEB. For example STP,
>LLDP, etc. At the moment we send this traffic on sw0p0 which is
>exactly correct.

Indeed. Looks like we may need 2 more netdevices on top of that. One to
represent actual phy (sw0pX) and one to represent the associated port in
embedded switch (ethX). I thought that this could be handled by PF netdevs
but that does not look correct now. For example packet going from vm1 for pf
should go through sw0p0 finishing in PF netdev. On the other hand,
packet going from vm1 outside should go through sw0pX ethX.

      +-----+-----+-----+
      | vm0 | vm1 | vm2 | Virtual
      | eth0| eth0| eth0| Machines
+-----+--|--+--|--+--|--+----------
| host|  |  |  |  |  |  |
| eth0|  |  |  |  |  |  | kernel
+--|--+--|--+--|--+--|--+
|sw0p0 sw0p1 sw0p2 sw0p3|
+--|-----|-----|-----|--+----------
| pf0   vf0   vf1   vf2 | PCIe
+--|-----|-----|-----|--+----------
| ++-----+-----+-----++ | SR-IOV NIC
| | VEB               | |
| +------------+------+ |
| SR-IOV NIC   |        |
+--------------|--------+
               |
	     sw0pX
	       |
	      ethX
              PHY

>From the higher perspective, this somehow downgrades PF functionality
to be on of the VFs.

The best would be to use PF for the PHY port. In that case, PF netdev
would be just a representor, without possibility to actually use it in
host for actual host targeted traffic. But not sure that could be doable
since it would break the current model we have in kernel.


>
>I had some prototype code @ one point that did this I can dig it
>up if folks think its useful.
>
>Also it might be worth noting the "Kernel" net_devices are not
>actually bound to the virtual function but multiplexed/demux'd
>over the physical function pf0 in the diagram. The diagram might
>be read to imply some PCIe relationship between sw0p3 and vf2.

Exactly. This is just how to represent things in kernel.


>
>>
>>The use of switchdev would show that all sw0* devices are associated with the
>>same switch, and the instantiation of the sw0* devices in the kernel would
>>provide higher level applications like OVS/Linux bridge/etc. to control traffic
>>in a way not possible in the earlier example.  So far so good?
>>
>>Now the question becomes how to plumb SR-IOV NIC to create this representation.
>>Looking at one specific path:
>>
>>   +-----+
>>   | vm0 |
>>   | eth0|
>>   +--|--+
>>   |sw0p1|
>>   +--|--+
>>   | vf0 |
>>+----|----+
>>| +--+--+ |
>>| | VEB | |
>>| +-----+ |
>>+---------+
>>
>>It's unclear to me when traffic egressing the VEB should terminate at sw0p1 vs.
>>vm0's eth0.  They both represent the same MAC/VLAN.  Similarly, for traffic
>>egressing vm0's eth0, when should it terminate at sw0p1 vs. the VEB.
>>
>>Can anyone offer an alternate diagram for switchdev on an SR-IOV NIC?
>>
>
>One approach would be to treat it like the switch case where instead
>of a physical port you have a VF. In this case if you xmit a packet on
>sw0p1 it is sent to eth0. Then if vm0 (eth0) xmits a packet it enters
>the VEB. The only way to get packets onto sw0p1 is to use a rule to
>either "trap" or "mirror" packets to the "CPU sw0p1 port". Maybe a
>better name would be "hypervisor sw0p1 port". This would be analagous
>to the switch case, I have experimented with adding this support to
>the Flow API I'm working on but have not implemented it on rocker yet.
>
>
> +-----+      +-----+
> |hyper|      | vm1 |
> |visor|      | eth0|
> +-----+      +-----+
>    |            |
> +--|--+      +--|--+
> |sw0p0|      |sw0p2|
> +-----+      +-----+
>    |           |
> +--|-----|-----|-----|--+
> | ++-----+-----+-----++ |
> | | VEB               | |
> | +------------+------+ |
> | SR-IOV NIC   |        |
> +--------------|--------+
>                 |
>                PHY
>
>here the link between sw0p2 and vm1 is a virtual function instead of a
>physical wire. And sw0p0 is the "CPU port" directly to the hypervisor.
>
>Is that at all clear? Let me know I can try to do a better write up
>in the AM.
>
>.John
>
>>Dave
>>--
>>To unsubscribe from this list: send the line "unsubscribe netdev" in
>>the body of a message to majordomo@vger.kernel.org
>>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>
>
>-- 
>John Fastabend         Intel Corporation
