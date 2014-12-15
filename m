From: Wengang <wen.gang.wang-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] bonding: move ipoib_header_ops to vmlinux
Date: Mon, 15 Dec 2014 09:12:53 +0800
Message-ID: <548E3595.60206@oracle.com>
References: <20141125.010741.450666241983239119.davem@davemloft.net>	<54742D6E.9030605@mellanox.com>	<19740.1416940877@famine> <20141125.134450.1265438298771389292.davem@davemloft.net> <54752D4C.7000603@oracle.com> <547E6C70.7040809@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, jay.vosburgh-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <547E6C70.7040809-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Anyone please respond to this?

thanks,
wengang

=E4=BA=8E 2014=E5=B9=B412=E6=9C=8803=E6=97=A5 09:50, Wengang Wang =E5=86=
=99=E9=81=93:
> Hi David and Jay,
>
> Then about about the change in this patch?
>
> thanks,
> wengang
>
> =E5=9C=A8 2014=E5=B9=B411=E6=9C=8826=E6=97=A5 09:30, Wengang =E5=86=99=
=E9=81=93:
>> =E4=BA=8E 2014=E5=B9=B411=E6=9C=8826=E6=97=A5 02:44, David Miller =E5=
=86=99=E9=81=93:
>>> From: Jay Vosburgh <jay.vosburgh-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
>>> Date: Tue, 25 Nov 2014 10:41:17 -0800
>>>
>>>> Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org> wrote:
>>>>
>>>>> On 11/25/2014 8:07 AM, David Miller wrote:
>>>>>> IPOIB should not work over bonding as it requires that the devic=
e
>>>>>> use ARPHRD_ETHER.
>>>>> Hi Dave,
>>>>>
>>>>> IPoIB devices can be enslaved to both bonding and teaming in thei=
r=20
>>>>> HA mode,
>>>>> the bond device type becomes ARPHRD_INFINIBAND when this happens.
>>>>     The point was that pktgen disallows ARPHRD_INFINIBAND, not tha=
t
>>>> bonding does.
>>>>
>>>>     Pktgen specifically checks for type !=3D ARPHRD_ETHER, so the
>>>> IPoIB bond should not be able to be used with pkgten.  My suspicio=
n is
>>>> that pktgen is being configured on the bond first, then an IPoIB s=
lave
>>>> is added to the bond; this would change its type in a way that pkt=
gen
>>>> wouldn't notice.
>>> +1
>>
>> I think it go this way:
>>
>> 1) bond_master is ready
>> 2) bond_enslave enslave a IPOIB interface calling bond_setup_by_slav=
e
>> 3) then bond_setup_by_slave set change master type to ARPHRD_INFINIB=
AND.
>>
>> code is like this:
>>
>> 1 /* enslave device <slave> to bond device <master> */
>> 2 int bond_enslave(struct net_device *bond_dev, struct net_device=20
>> *slave_dev)
>> 3 {
>> 4 <snip>...
>> 5 /* set bonding device ether type by slave - bonding netdevices are
>> 6 * created with ether_setup, so when the slave type is not ARPHRD_E=
THER
>> 7 * there is a need to override some of the type dependent=20
>> attribs/funcs.
>> 8 *
>> 9 * bond ether type mutual exclusion - don't allow slaves of dissimi=
lar
>> 10 * ether type (eg ARPHRD_ETHER and ARPHRD_INFINIBAND) share the=20
>> same bond
>> 11 */
>> 12 if (!bond_has_slaves(bond)) {
>> 13 if (bond_dev->type !=3D slave_dev->type) {
>> 14 <snip>...
>> 15 if (slave_dev->type !=3D ARPHRD_ETHER)
>> 16 bond_setup_by_slave(bond_dev, slave_dev);
>> 17 else {
>> 18 ether_setup(bond_dev);
>> 19 bond_dev->priv_flags &=3D ~IFF_TX_SKB_SHARING;
>> 20 }
>> 21
>> 22 call_netdevice_notifiers(NETDEV_POST_TYPE_CHANGE,
>> 23 bond_dev);
>> 24 }
>> 25 <snip>...
>> 26 }
>> 27
>> 28 static void bond_setup_by_slave(struct net_device *bond_dev,
>> 29 struct net_device *slave_dev)
>> 30 {
>> 31 bond_dev->header_ops =3D slave_dev->header_ops;
>> 32
>> 33 bond_dev->type =3D slave_dev->type;
>> 34 bond_dev->hard_header_len =3D slave_dev->hard_header_len;
>> 35 bond_dev->addr_len =3D slave_dev->addr_len;
>> 36
>> 37 memcpy(bond_dev->broadcast, slave_dev->broadcast,
>> 38 slave_dev->addr_len);
>> 39 }
>> 40
>>
>> thanks
>> wengang
>> --=20
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> More majordomo info at http://vger.kernel.org/majordomo-info.html
>
> --=20
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
