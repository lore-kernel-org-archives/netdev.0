From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: bridge: HSR support
Date: Wed, 07 Dec 2011 11:59:49 -0800
Message-ID: <14653.1323287989@death>
References: <4E948A04.8060400@enea.com> <20111011112821.28cd3e51@nehalam.linuxnetplumber.net> <4E94D67A.9060207@enea.com> <4EA5738B.8080008@enea.com> <4EAACB7A.4090207@enea.com> <20111028175421.339b7c49@s6510.linuxnetplumber.net> <4EDEA3E9.3070004@enea.com> <20111206152745.7dd6bc1c@nehalam.linuxnetplumber.net> <4EDFB0BD.60701@enea.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Arvid Brodin <arvid.brodin@enea.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:35728 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757528Ab1LGUAI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Dec 2011 15:00:08 -0500
Received: from /spool/local
	by e1.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Wed, 7 Dec 2011 15:00:01 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pB7JxsKa231744
	for <netdev@vger.kernel.org>; Wed, 7 Dec 2011 14:59:54 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pB7Jxs4g006004
	for <netdev@vger.kernel.org>; Wed, 7 Dec 2011 17:59:54 -0200
In-reply-to: <4EDFB0BD.60701@enea.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arvid Brodin <arvid.brodin@enea.com> wrote:

>Stephen Hemminger wrote:
>> On Wed, 7 Dec 2011 00:23:21 +0100
>> Arvid Brodin <arvid.brodin@enea.com> wrote:
>> 
>>> Stephen Hemminger wrote:
>>>> On Fri, 28 Oct 2011 17:34:18 +0200
>>>> Arvid Brodin <arvid.brodin@enea.com> wrote:
>>>>
>>>>> Ok, so after a lot of reading and looking through code I have this idea of a
>>>>> standalone solution:
>>>>>
>>>>> 1) Add ioctls to create (and remove) "hsr" netdevs which encapsulates two
>>>>>    physical Ethernet interfaces each (somewhat like the bridge code does, but
>>>>>    with precisely 2 interfaces slaved).
>>>> Please use the newer netlink interface and the master attribute for this
>>>> rather than inventing yet another ioctl.
>>>
>>> Is the rtnl interface documented anywhere (the usage of the different IFLA_
>>> flags etc.)? Specifically: how do I use the IFLA_MASTER flag (what's the
>>> meaning of the 32-bit data it wants, and how is it used by the kernel)? I 
>>> haven't been very successful figuring this out by looking at the kernel code.
>> 
>> 
>> Look at bridging or bonding.
>
>Believe me, I have! :) Turns out IFLA_MASTER is actually handled in net/core/rtnetlink.c.
>Although the message is sent to the slave device, the functions called are the
>master device's ndo_{add,del}_slave(). Looking at the bridging and bonding
>implementations br_add_slave() and bond_enslave() and the functions they call,
>it all boils down mostly to 
>
>* netdev_set_master() which assigns slave_dev->master = master_dev.
>* bonding also set IFF_SLAVE on the slave.
>* netdev_rx_handler_register(slave_dev, ). "This handler will then be called
>  from __netif_receive_skb."
>
>So far so good, but:
>
>* I don't know the meaning of the IFF_SLAVE flag. It's referenced all over the place
>  (core, vlan, bonding, ipv6, eql). Do I need to/want to set this?

	Only if you actually need to for some reason.  There are a few
tests that make actual use of IFF_SLAVE, e.g., IPv6 won't run addrconf
on an interface with IFF_SLAVE set (which prevents bonding slaves from
having an IPv6 address distinct from the master).  Netpoll also treats
interfaces with IFF_SLAVE in a special way.  Bonding uses it internally
for various tests.

>* I don't know the effects of setting dev->master. Do I need/want this?

	Maybe.  One effect of netdev_set_master is that a reference is
acquired on the master, on behalf of the slave, so the master cannot
simply vanish until the slave releases that reference.  This predates
the notifier facility, and careful use of notifiers (handling
NETDEV_UNREGISTER) can get around the need for dev->master, but, e.g.,
vlan still acquires a reference to the real_dev without using
dev->master.

	It used to be that dev->master was used in netif_receive_skb for
packet handling purposes (for bonding, mostly; bridge and I think
macvlan had separate hooks).  That special sauce is now done by the
rx_handler, so there's really no requirement to use dev->master if you
have no need.

>* I don't want to forward all ingress frames on the slave devices to my master
>  device; I only want the ones with protocol 0x88FB to be forwarded (other
>  frames should be received by the slaves as normal). I think I already have this
>  covered by registering a protocol handler (using dev_add_pack(packet_type)).
>  So perhaps calling netdev_rx_handler_register() is not necessary in my case?

	You may want to use the rx_handler, and have it set skb->dev
appropriately for the frames that should forward to the master, and
leave skb->dev alone for the ones that should stick with the slave.
Both of those need the appropriate return from the rx_handler, which is
documented in netdevice.h.

	I'm not sure that you need a dev_add_pack at all; bonding
doesn't use one anymore, since everything it needs can now be done via
rx_handler.  The dev_add_pack approach may work, but rx_handler is
probably more efficient.

>* As far as I can see, neither bridging nor bonding is handled by the ip program
>  (iproute2 suite)? I.e. no examples of binding more than one interface to a
>  virtual interface when it comes to which messages to send, etc. VLAN uses
>  IFLA_IFNAME (name of the vlan link), IFLA_LINK (physical link behind the vlan
>  link), and some IFLA_VLAN-specific messages.

	In current versions of iproute, something like "ip link set
device eth0 master bond0" would add a slave to a bond.  You are correct,
though, that ip does not permit changing the bonding options, and I
don't believe it will create new master devices, either, so the bonding
support is limited.

	-J

>  What I want to do is to atomically (from a user space perspective) create the
>  HSR bonding, i.e.:
>
>  	# ip link add name hsr0 type hsr slave1 slave2
>
>  I have written a hsr "plugin" to iproute2 that accepts these parameters, I'm
>  just not sure how to tell the kernel about them. Perhaps then I should define
>  my own IFLA_HSR_UNSPEC, IFLA_HSR_SLAVE1, IFLA_HSR_SLAVE2 messages?
>
>>> Also, how do I best tell the kernel which my slave devices are when creating
>>> the hsr device? Should I create my own IFLA_HSR_UNSPEC, etc, or can I use some
>>> of the generic flags?
>> 
>> Look at macvlan, vlan, or bridging. There this is done by processing a newlink
>> message.
>
>macvlan and vlan both use IFLA_LINK to tell the kernel about their single
>underlying "real" device. None of these use more than one underlying device.
>Bridging does not implement newlink at all (uses ioctls, I think).
>
>
>>> Oh, and the kernel (struct rtnl_link_ops).newlink method has two (struct
>>> nlattr *[]) params: tb and data. What are their roles?
>>>
>
>Heh, I just realised that the difference is that "tb" contains generic (IFLA_)
>message data and "data" contains specific (e.g. IFLA_VLAN_) message data. 

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
