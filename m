From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: [RFC][PATCH 0/3] bonding support for operation over IPoIB
Date: Tue, 26 Sep 2006 13:16:35 +0300 (IDT)
Message-ID: <Pine.LNX.4.64.0609261309540.24189@zuben>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from taurus.voltaire.com ([193.47.165.240]:59709 "EHLO
	taurus.voltaire.com") by vger.kernel.org with ESMTP
	id S1750792AbWIZKQh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Sep 2006 06:16:37 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series is an RFC for changes to the bonding driver such that it
would be able to support non ARPHRD_ETHER netdevices for its High-Availability
(active-backup) mode.

My motivation was to enable the bonding driver on its HA mode to work with the
IP over Infiniband (IPoIB) driver. With these patches I was able to enslave
IPoIB netdevices and run TCP, UDP, IP (UDP) Multicast and ICMP traffic with
fail-over and fail-back working fine.

More over, as IPoIB is also the IB ARP provider for the RDMA CM driver which
is used by native IB ULPs whose addressing scheme is based on IP (eg iSER, SDP,
Lustre, NFSoRDMA, RDS), bonding support for IPoIB devices **enables** HA for
these ULPs. This holds as when the ULP is informed by the IB HW on the failure
of the currect IB connection, it just need to reconnect, where the bonding
device will now issue the IB ARP over the active IPoIB slave.

The first patch changes some of the bond netdevice attributes and functions
to be that of the active slave for the case of the enslaved device not being
of ARPHRD_ETHER type. Basically it overrides those setting done by ether_setup(),
which are netdevice **type** dependent and hence might be not appropriate for
devices of other types.

IPoIB (see Documentation/infiniband/ipoib.txt) MAC address is made of a 3 bytes
IB QP (Queue Pair) number and 16 bytes IB port GID (Global ID) of the port this
IPoIB device is bounded to. The QP is a resource created by the IB HW and the
GID is an identifier burned into the HCA (i have ommited here some details which
are not important for the bonding RFC).

Basically the IPoIB spec and impl. do not allow for setting the MAC address of
an IPoIB device and my work was made under this assumption.

The second patch allows for enslaving netdevices which do not support the
set_mac_address() function. In that case the bond mac address is the one
of the active slave, where remote peers are notified on the mac address
(neighbour) change by Gratuitous ARP sent by the bonding code when fail-over
occurs (this was already in the bonding code).

The third patch is temporal i hope, and is now required to run IP multicast when
bonding IPoIB devices. The problem is that some multicast groups (eg the all-hosts
224.0.0.1) might be set to the bonding device by the net stack **before** any
enslavement takes place.

Since ether_setup() sets the bonding device type to be ARPHRD_ETHER and address
len to be ETHER_ALEN, the net core code computes a wrong multicast link address.
Now, the current IPoIB impl. attempts to join on this wrong mcast address and
does not process more join requests. As a result IP multicast over other groups
whose link address is computed correct would not work.

Or Gerlitz.
