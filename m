From: Arvid Brodin <arvid.brodin@enea.com>
Subject: Re: bridge: HSR support
Date: Wed, 7 Dec 2011 19:30:21 +0100
Message-ID: <4EDFB0BD.60701@enea.com>
References: <4E948A04.8060400@enea.com>	<20111011112821.28cd3e51@nehalam.linuxnetplumber.net>	<4E94D67A.9060207@enea.com>	<4EA5738B.8080008@enea.com>	<4EAACB7A.4090207@enea.com>	<20111028175421.339b7c49@s6510.linuxnetplumber.net>	<4EDEA3E9.3070004@enea.com> <20111206152745.7dd6bc1c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sestofw01.enea.se ([192.36.1.252]:12636 "HELO mx-3.enea.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1756504Ab1LGSad (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Dec 2011 13:30:33 -0500
In-Reply-To: <20111206152745.7dd6bc1c@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Wed, 7 Dec 2011 00:23:21 +0100
> Arvid Brodin <arvid.brodin@enea.com> wrote:
> 
>> Stephen Hemminger wrote:
>>> On Fri, 28 Oct 2011 17:34:18 +0200
>>> Arvid Brodin <arvid.brodin@enea.com> wrote:
>>>
>>>> Ok, so after a lot of reading and looking through code I have this idea of a
>>>> standalone solution:
>>>>
>>>> 1) Add ioctls to create (and remove) "hsr" netdevs which encapsulates two
>>>>    physical Ethernet interfaces each (somewhat like the bridge code does, but
>>>>    with precisely 2 interfaces slaved).
>>> Please use the newer netlink interface and the master attribute for this
>>> rather than inventing yet another ioctl.
>>
>> Is the rtnl interface documented anywhere (the usage of the different IFLA_
>> flags etc.)? Specifically: how do I use the IFLA_MASTER flag (what's the
>> meaning of the 32-bit data it wants, and how is it used by the kernel)? I 
>> haven't been very successful figuring this out by looking at the kernel code.
> 
> 
> Look at bridging or bonding.

Believe me, I have! :) Turns out IFLA_MASTER is actually handled in net/core/rtnetlink.c.
Although the message is sent to the slave device, the functions called are the
master device's ndo_{add,del}_slave(). Looking at the bridging and bonding
implementations br_add_slave() and bond_enslave() and the functions they call,
it all boils down mostly to 

* netdev_set_master() which assigns slave_dev->master = master_dev.
* bonding also set IFF_SLAVE on the slave.
* netdev_rx_handler_register(slave_dev, ). "This handler will then be called
  from __netif_receive_skb."

So far so good, but:

* I don't know the meaning of the IFF_SLAVE flag. It's referenced all over the place
  (core, vlan, bonding, ipv6, eql). Do I need to/want to set this?

* I don't know the effects of setting dev->master. Do I need/want this?

* I don't want to forward all ingress frames on the slave devices to my master
  device; I only want the ones with protocol 0x88FB to be forwarded (other
  frames should be received by the slaves as normal). I think I already have this
  covered by registering a protocol handler (using dev_add_pack(packet_type)).
  So perhaps calling netdev_rx_handler_register() is not necessary in my case?

* As far as I can see, neither bridging nor bonding is handled by the ip program
  (iproute2 suite)? I.e. no examples of binding more than one interface to a
  virtual interface when it comes to which messages to send, etc. VLAN uses
  IFLA_IFNAME (name of the vlan link), IFLA_LINK (physical link behind the vlan
  link), and some IFLA_VLAN-specific messages.

  What I want to do is to atomically (from a user space perspective) create the
  HSR bonding, i.e.:

  	# ip link add name hsr0 type hsr slave1 slave2

  I have written a hsr "plugin" to iproute2 that accepts these parameters, I'm
  just not sure how to tell the kernel about them. Perhaps then I should define
  my own IFLA_HSR_UNSPEC, IFLA_HSR_SLAVE1, IFLA_HSR_SLAVE2 messages?


>> Also, how do I best tell the kernel which my slave devices are when creating
>> the hsr device? Should I create my own IFLA_HSR_UNSPEC, etc, or can I use some
>> of the generic flags?
> 
> Look at macvlan, vlan, or bridging. There this is done by processing a newlink
> message.

macvlan and vlan both use IFLA_LINK to tell the kernel about their single
underlying "real" device. None of these use more than one underlying device.
Bridging does not implement newlink at all (uses ioctls, I think).


>> Oh, and the kernel (struct rtnl_link_ops).newlink method has two (struct
>> nlattr *[]) params: tb and data. What are their roles?
>>
 
Heh, I just realised that the difference is that "tb" contains generic (IFLA_)
message data and "data" contains specific (e.g. IFLA_VLAN_) message data. 


-- 
Arvid Brodin
Enea Services Stockholm AB
