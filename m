From: "Carl Yang \(caryang\)" <caryang@cisco.com>
Subject: RE: [openib-general] [RFC] [PATCH V2 0/3] bonding support foroperation over IPoIB
Date: Thu, 7 Dec 2006 14:27:31 -0800
Message-ID: <A3C7F222C349444DA8B01D881740A0030109116F@xmb-sjc-226.amer.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Roland Dreier \(rdreier\)" <rdreier@cisco.com>,
	"Jay Vosburgh" <fubar@us.ibm.com>, <openib-general@openib.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:35162 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1163523AbWLGW1j convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 17:27:39 -0500
Content-class: urn:content-classes:message
To: "Or Gerlitz" <ogerlitz@voltaire.com>, <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Or,

Can you please forward me (or to the email alias) "an example bonding
sysfs script which can be used to set bonding to work with patches 1-3?"

Thanks,
Carl


-----Original Message-----
From: openib-general-bounces@openib.org
[mailto:openib-general-bounces@openib.org] On Behalf Of Or Gerlitz
Sent: Thursday, November 30, 2006 2:57 AM
To: netdev@vger.kernel.org
Cc: Roland Dreier (rdreier); Jay Vosburgh; openib-general@openib.org
Subject: [openib-general] [RFC] [PATCH V2 0/3] bonding support
foroperation over IPoIB

This patch series is a second version (see below link to V1) of the
suggested changes to the bonding driver such that it would be able to
support non ARPHRD_ETHER netdevices for its High-Availability
(active-backup) mode.

The motivation is to enable the bonding driver on its HA mode to work
with the IP over Infiniband (IPoIB) driver. With these patches I was
able to enslave IPoIB netdevices and run TCP, UDP, IP (UDP) Multicast
and ICMP traffic with fail-over and fail-back working fine. My working
env was the net-2.6.20 git.

More over, as IPoIB is also the IB ARP provider for the RDMA CM driver
which is used by native IB ULPs whose addressing scheme is based on IP
(eg iSER, SDP, Lustre, NFSoRDMA, RDS), bonding support for IPoIB devices
**enables** HA for these ULPs. This holds as when the ULP is informed by
the IB HW on the failure of the current IB connection, it just need to
reconnect, where the bonding device will now issue the IB ARP over the
active IPoIB slave.

The first patch changes some of the bond netdevice attributes and
functions to be that of the active slave for the case of the enslaved
device not being of ARPHRD_ETHER type. Basically it overrides those
setting done by ether_setup(), which are netdevice **type** dependent
and hence might be not appropriate for devices of other types. It also
enforces mutual exclusion on bonding slaves from dissimilar ether types,
as was concluded over the v1 discussion.

IPoIB (see Documentation/infiniband/ipoib.txt) MAC address is made of a
3 bytes IB QP (Queue Pair) number and 16 bytes IB port GID (Global ID)
of the port this IPoIB device is bounded to. The QP is a resource
created by the IB HW and the GID is an identifier burned into the HCA (i
have omitted here some details which are not important for the bonding
RFC).

Basically the IPoIB spec and impl. do not allow for setting the MAC
address of an IPoIB device and this work was made under this assumption.

Hence, the second patch allows for enslaving netdevices which do not
support the set_mac_address() function. In that case the bond mac
address is the one of the active slave, where remote peers are notified
on the mac address
(neighbour) change by Gratuitous ARP sent by bonding when fail-over
occurs (this is already done by the bonding code).

Normally, the bonding driver is UP before any enslavement takes place.
Once a netdevice is UP, the network stack acts to have it join some
multicast groups (eg the all-hosts 224.0.0.1). Now, since ether_setup()
have set the bonding device type to be ARPHRD_ETHER and address len to
be ETHER_ALEN, the net core code computes a wrong multicast link
address. This is b/c ip_eth_mc_map() is called where for mcast joins
taking place **after** the enslavement another ip_xxx_mc_map() is called
(eg ip_ib_mc_map() when the bond type is ARPHRD_INFINIBAND)

The third patch handles this problem by allowing to enslave devices when
the bonding device is not up. Over the discussion held at the previous
post this seemed to be the most clean way to go, where it is not
expected to cause instabilities.

These patches are not enough for configuration of IPoIB bonding through
tools (eg /sbin/ifenslave and /sbin/ifup) provided by packages such as
sysconfig and initscripts, specifically since these tools sets the
bonding device to be UP before enslaving anything. Once this patchset
gets positive/feedback the next step would be to look how to enhance the
tools/packages so it would be possible to bond/enslave with the modified
code. As suggested by the bonding maintainer, this step can potentially
involve converting ifenslave to be a script based on the bonding sysfs
infrastructure rather on the somehow obsoleted
Documentation/networking/ifenslave.c

For the ease of potential testers, I will post an example bonding sysfs
script which can be used to set bonding to work with patches 1-3 (let me
know!)

Or.

changes from V1 (the links point to V1 0-3/3)

http://marc.theaimsgroup.com/?l=linux-netdev&m=115926582209736&w=2
http://marc.theaimsgroup.com/?l=linux-netdev&m=115926599515568&w=2
http://marc.theaimsgroup.com/?l=linux-netdev&m=115926599430055&w=2
http://marc.theaimsgroup.com/?l=linux-netdev&m=115926599415729&w=2

+ enforce mutual exclusion on the slaves ether types don't attempt to 
+ set the bond mtu when enslaving a non ARPHRD_ETHER device rather than 
+ hack the bond device ether type through mod params allow enslavement
  when the bond device is not up

_______________________________________________
openib-general mailing list
openib-general@openib.org
http://openib.org/mailman/listinfo/openib-general

To unsubscribe, please visit
http://openib.org/mailman/listinfo/openib-general
