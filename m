From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: network device reference leak with net-next
Date: Mon, 15 Nov 2010 15:18:38 -0800
Message-ID: <4CE1BFCE.70105@intel.com>
References: <20101115105646.0cc823ce@nehalam>	<1289847840.2607.120.camel@edumazet-laptop> <20101115111024.3b3377be@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	brian.haley@hp.com, maze@google.com
To: Stephen Hemminger <shemminger@vyatta.com>, lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:18640 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751556Ab0KOXSj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Nov 2010 18:18:39 -0500
In-Reply-To: <20101115111024.3b3377be@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/15/2010 11:10 AM, Stephen Hemminger wrote:
> On Mon, 15 Nov 2010 20:04:00 +0100
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
>> Le lundi 15 novembre 2010 =E0 10:56 -0800, Stephen Hemminger a =E9cr=
it :
>>> This is a new regression (doesn't exist with 2.6.36)
>>>
>>> If I shutdown KVM instance with Virt manager, the virtual
>>> interfaces in the bridge aren't getting cleaned up because
>>> of leftover reference count.
>>>
>>>
>>> [ 9781.050474] unregister_netdevice: waiting for vnet1 to become fr=
ee. Usage count =3D 1
>>> [ 9785.143400] virbr4: port 3(vnet6) entering forwarding state
>>> [ 9785.177194] virbr4: port 3(vnet6) entering disabled state
>>> [ 9785.201129] device vnet6 left promiscuous mode
>>> [ 9785.201135] virbr4: port 3(vnet6) entering disabled state
>>> [ 9791.286950] unregister_netdevice: waiting for vnet1 to become fr=
ee. Usage count =3D 1
>>> [ 9795.461526] unregister_netdevice: waiting for vnet6 to become fr=
ee. Usage count =3D 1
>>> [ 9801.523398] unregister_netdevice: waiting for vnet1 to become fr=
ee. Usage count =3D 1
>>> --
>>
>> Is the refcount stay forever to 1, or eventually reaches 0 ?
>>
>>
>>
>=20
> Stays 1 for as long as I waited about 10 minutes
>=20

Similar refcount error with ixgbe bisected to this patch,

commit 2de795707294972f6c34bae9de713e502c431296
Author: Lorenzo Colitti <lorenzo@google.com>
Date:   Wed Oct 27 18:16:49 2010 +0000

    ipv6: addrconf: don't remove address state on ifdown if the address=
 is being kept

    Currently, addrconf_ifdown does not delete statically configured IP=
v6
    addresses when the interface is brought down. The intent is that wh=
en
    the interface comes back up the address will be usable again. Howev=
er,
    this doesn't actually work, because the system stops listening on t=
he
    corresponding solicited-node multicast address, so the address cann=
ot
    respond to neighbor solicitations and thus receive traffic. Also, t=
he
    code notifies the rest of the system that the address is being dele=
ted
    (e.g, RTM_DELADDR), even though it is not. Fix it so that none of t=
his
    state is updated if the address is being kept on the interface.

    Tested: Added a statically configured IPv6 address to an interface,
    started ping, brought link down, brought link up again. When link c=
ame
    up ping kept on going and "ip -6 maddr" showed that the host was st=
ill
    subscribed to there

    Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>


Quick glance looks like an in6_ifa_put is missed?

--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2754,13 +2754,13 @@ Hunk #1, a/net/ipv6/addrconf.c static int addrc=
onf_ifdown(struct net_device *dev, int how)
                        ifa->state =3D INET6_IFADDR_STATE_DEAD;
                        spin_unlock_bh(&ifa->state_lock);

-                       if (state =3D=3D INET6_IFADDR_STATE_DEAD) {
-                               in6_ifa_put(ifa);
-                       } else {
+                       if (state !=3D INET6_IFADDR_STATE_DEAD) {
                                __ipv6_ifa_notify(RTM_DELADDR, ifa);
                                atomic_notifier_call_chain(&inet6addr_c=
hain,
                                                           NETDEV_DOWN,=
 ifa);
                        }
+
+                       in6_ifa_put(ifa);
                        write_lock_bh(&idev->lock);
                }
        }

With a quick hack the above seems to resolve the issue but I'll need to=
 review the ipv6 stuff to be sure this is sane.

Thanks,
John.
