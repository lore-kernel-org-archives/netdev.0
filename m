From: Arvid Brodin <arvid.brodin@enea.com>
Subject: Re: bridge: HSR support
Date: Thu, 8 Dec 2011 15:45:37 +0100
Message-ID: <4EE0CD91.2070804@enea.com>
References: <4E948A04.8060400@enea.com> <20111011112821.28cd3e51@nehalam.linuxnetplumber.net> <4E94D67A.9060207@enea.com> <4EA5738B.8080008@enea.com> <4EAACB7A.4090207@enea.com> <20111028175421.339b7c49@s6510.linuxnetplumber.net> <4EDEA3E9.3070004@enea.com> <20111206152745.7dd6bc1c@nehalam.linuxnetplumber.net> <4EDFB0BD.60701@enea.com> <14653.1323287989@death>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sestofw01.enea.se ([192.36.1.252]:13144 "HELO mx-3.enea.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751551Ab1LHOpr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Dec 2011 09:45:47 -0500
In-Reply-To: <14653.1323287989@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh wrote:
> Arvid Brodin <arvid.brodin@enea.com> wrote:
>> * I don't know the meaning of the IFF_SLAVE flag. It's referenced all over the place
>>  (core, vlan, bonding, ipv6, eql). Do I need to/want to set this?
> 
> 	Only if you actually need to for some reason.  There are a few
> tests that make actual use of IFF_SLAVE, e.g., IPv6 won't run addrconf
> on an interface with IFF_SLAVE set (which prevents bonding slaves from
> having an IPv6 address distinct from the master).  Netpoll also treats
> interfaces with IFF_SLAVE in a special way.  Bonding uses it internally
> for various tests.
> 
>> * I don't know the effects of setting dev->master. Do I need/want this?
> 
> 	Maybe.  One effect of netdev_set_master is that a reference is
> acquired on the master, on behalf of the slave, so the master cannot
> simply vanish until the slave releases that reference.  This predates
> the notifier facility, and careful use of notifiers (handling
> NETDEV_UNREGISTER) can get around the need for dev->master, but, e.g.,
> vlan still acquires a reference to the real_dev without using
> dev->master.
> 
> 	It used to be that dev->master was used in netif_receive_skb for
> packet handling purposes (for bonding, mostly; bridge and I think
> macvlan had separate hooks).  That special sauce is now done by the
> rx_handler, so there's really no requirement to use dev->master if you
> have no need.
> 
>> * I don't want to forward all ingress frames on the slave devices to my master
>>  device; I only want the ones with protocol 0x88FB to be forwarded (other
>>  frames should be received by the slaves as normal). I think I already have this
>>  covered by registering a protocol handler (using dev_add_pack(packet_type)).
>>  So perhaps calling netdev_rx_handler_register() is not necessary in my case?
> 
> 	You may want to use the rx_handler, and have it set skb->dev
> appropriately for the frames that should forward to the master, and
> leave skb->dev alone for the ones that should stick with the slave.
> Both of those need the appropriate return from the rx_handler, which is
> documented in netdevice.h.
> 
> 	I'm not sure that you need a dev_add_pack at all; bonding
> doesn't use one anymore, since everything it needs can now be done via
> rx_handler.  The dev_add_pack approach may work, but rx_handler is
> probably more efficient.
> 
>> * As far as I can see, neither bridging nor bonding is handled by the ip program
>>  (iproute2 suite)? I.e. no examples of binding more than one interface to a
>>  virtual interface when it comes to which messages to send, etc. VLAN uses
>>  IFLA_IFNAME (name of the vlan link), IFLA_LINK (physical link behind the vlan
>>  link), and some IFLA_VLAN-specific messages.
> 
> 	In current versions of iproute, something like "ip link set
> device eth0 master bond0" would add a slave to a bond.  You are correct,
> though, that ip does not permit changing the bonding options, and I
> don't believe it will create new master devices, either, so the bonding
> support is limited.
> 
> 	-J
> 
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
> 

Lots of great info there, many thanks!

-- 
Arvid Brodin
Enea Services Stockholm AB
