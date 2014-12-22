From: Wengang <wen.gang.wang@oracle.com>
Subject: Re: [PATCH] bonding: move ipoib_header_ops to vmlinux
Date: Mon, 22 Dec 2014 09:14:21 +0800
Message-ID: <5497706D.8000305@oracle.com>
References: <20141125.010741.450666241983239119.davem@davemloft.net>	<54742D6E.9030605@mellanox.com>	<19740.1416940877@famine> <20141125.134450.1265438298771389292.davem@davemloft.net> <54752D4C.7000603@oracle.com> <547E6C70.7040809@oracle.com> <548E3595.60206@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ogerlitz@mellanox.com, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org
To: David Miller <davem@davemloft.net>, jay.vosburgh@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:39285 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753545AbaLVBMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Dec 2014 20:12:53 -0500
In-Reply-To: <548E3595.60206@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Anyone please review this patch? David? Jay? please.

thanks,
wengang

=E4=BA=8E 2014=E5=B9=B412=E6=9C=8815=E6=97=A5 09:12, Wengang =E5=86=99=E9=
=81=93:
> Anyone please respond to this?
>
> thanks,
> wengang
>
> =E4=BA=8E 2014=E5=B9=B412=E6=9C=8803=E6=97=A5 09:50, Wengang Wang =E5=
=86=99=E9=81=93:
>> Hi David and Jay,
>>
>> Then about about the change in this patch?
>>
>> thanks,
>> wengang
>>
>> =E5=9C=A8 2014=E5=B9=B411=E6=9C=8826=E6=97=A5 09:30, Wengang =E5=86=99=
=E9=81=93:
>>> =E4=BA=8E 2014=E5=B9=B411=E6=9C=8826=E6=97=A5 02:44, David Miller =E5=
=86=99=E9=81=93:
>>>> From: Jay Vosburgh <jay.vosburgh@canonical.com>
>>>> Date: Tue, 25 Nov 2014 10:41:17 -0800
>>>>
>>>>> Or Gerlitz <ogerlitz@mellanox.com> wrote:
>>>>>
>>>>>> On 11/25/2014 8:07 AM, David Miller wrote:
>>>>>>> IPOIB should not work over bonding as it requires that the devi=
ce
>>>>>>> use ARPHRD_ETHER.
>>>>>> Hi Dave,
>>>>>>
>>>>>> IPoIB devices can be enslaved to both bonding and teaming in=20
>>>>>> their HA mode,
>>>>>> the bond device type becomes ARPHRD_INFINIBAND when this happens=
=2E
>>>>>     The point was that pktgen disallows ARPHRD_INFINIBAND, not th=
at
>>>>> bonding does.
>>>>>
>>>>>     Pktgen specifically checks for type !=3D ARPHRD_ETHER, so the
>>>>> IPoIB bond should not be able to be used with pkgten.  My=20
>>>>> suspicion is
>>>>> that pktgen is being configured on the bond first, then an IPoIB=20
>>>>> slave
>>>>> is added to the bond; this would change its type in a way that pk=
tgen
>>>>> wouldn't notice.
>>>> +1
>>>
>>> I think it go this way:
>>>
>>> 1) bond_master is ready
>>> 2) bond_enslave enslave a IPOIB interface calling bond_setup_by_sla=
ve
>>> 3) then bond_setup_by_slave set change master type to=20
>>> ARPHRD_INFINIBAND.
>>>
>>> code is like this:
>>>
>>> 1 /* enslave device <slave> to bond device <master> */
>>> 2 int bond_enslave(struct net_device *bond_dev, struct net_device=20
>>> *slave_dev)
>>> 3 {
>>> 4 <snip>...
>>> 5 /* set bonding device ether type by slave - bonding netdevices ar=
e
>>> 6 * created with ether_setup, so when the slave type is not=20
>>> ARPHRD_ETHER
>>> 7 * there is a need to override some of the type dependent=20
>>> attribs/funcs.
>>> 8 *
>>> 9 * bond ether type mutual exclusion - don't allow slaves of dissim=
ilar
>>> 10 * ether type (eg ARPHRD_ETHER and ARPHRD_INFINIBAND) share the=20
>>> same bond
>>> 11 */
>>> 12 if (!bond_has_slaves(bond)) {
>>> 13 if (bond_dev->type !=3D slave_dev->type) {
>>> 14 <snip>...
>>> 15 if (slave_dev->type !=3D ARPHRD_ETHER)
>>> 16 bond_setup_by_slave(bond_dev, slave_dev);
>>> 17 else {
>>> 18 ether_setup(bond_dev);
>>> 19 bond_dev->priv_flags &=3D ~IFF_TX_SKB_SHARING;
>>> 20 }
>>> 21
>>> 22 call_netdevice_notifiers(NETDEV_POST_TYPE_CHANGE,
>>> 23 bond_dev);
>>> 24 }
>>> 25 <snip>...
>>> 26 }
>>> 27
>>> 28 static void bond_setup_by_slave(struct net_device *bond_dev,
>>> 29 struct net_device *slave_dev)
>>> 30 {
>>> 31 bond_dev->header_ops =3D slave_dev->header_ops;
>>> 32
>>> 33 bond_dev->type =3D slave_dev->type;
>>> 34 bond_dev->hard_header_len =3D slave_dev->hard_header_len;
>>> 35 bond_dev->addr_len =3D slave_dev->addr_len;
>>> 36
>>> 37 memcpy(bond_dev->broadcast, slave_dev->broadcast,
>>> 38 slave_dev->addr_len);
>>> 39 }
>>> 40
>>>
>>> thanks
>>> wengang
>>> --=20
>
