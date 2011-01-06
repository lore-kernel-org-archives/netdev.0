From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next-2.6 PATCH v5 1/2] net: implement mechanism for HW based
 QOS
Date: Thu, 06 Jan 2011 10:45:22 -0800
Message-ID: <4D260DC2.6050601@intel.com>
References: <20110104185600.13692.47967.stgit@jf-dev1-dcblab>	 <1294338015.11825.26.camel@bwh-desktop> <1294338690.3074.91.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"jarkao2@gmail.com" <jarkao2@gmail.com>,
	"hadi@cyberus.ca" <hadi@cyberus.ca>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:29950 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752927Ab1AFSqE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jan 2011 13:46:04 -0500
In-Reply-To: <1294338690.3074.91.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/6/2011 10:31 AM, Eric Dumazet wrote:
> Le jeudi 06 janvier 2011 =C3=A0 18:20 +0000, Ben Hutchings a =C3=A9cr=
it :
>> On Tue, 2011-01-04 at 10:56 -0800, John Fastabend wrote:
>> [...]
>>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>>> index 0f6b1c9..ae51323 100644
>>> --- a/include/linux/netdevice.h
>>> +++ b/include/linux/netdevice.h
>>> @@ -646,6 +646,14 @@ struct xps_dev_maps {
>>>      (nr_cpu_ids * sizeof(struct xps_map *)))
>>>  #endif /* CONFIG_XPS */
>>> =20
>>> +#define TC_MAX_QUEUE	16
>>> +#define TC_BITMASK	15
>>> +/* HW offloaded queuing disciplines txq count and offset maps */
>>> +struct netdev_tc_txq {
>>> +	u16 count;
>>> +	u16 offset;
>>> +};
>>> +
>>>  /*
>>>   * This structure defines the management hooks for network devices=
=2E
>>>   * The following hooks can be defined; unless noted otherwise, the=
y are
>>> @@ -1146,6 +1154,9 @@ struct net_device {
>>>  	/* Data Center Bridging netlink ops */
>>>  	const struct dcbnl_rtnl_ops *dcbnl_ops;
>>>  #endif
>>> +	u8 num_tc;
>>> +	struct netdev_tc_txq tc_to_txq[TC_MAX_QUEUE];
>>> +	u8 prio_tc_map[TC_BITMASK+1];
>> [...]
>>
>> I'm still concerned by the addition of all this state to every
>> net_device.  From previous discussion, Eric wanted this, citing 'fal=
se
>> sharing' while Stephen thought it should be accessed indirectly.
>>
>> Eric, when you refer to 'false sharing' do you mean that the TC stat=
e
>> might end up sharing a cache line with some other data?  That seems
>> quite unlikely as the allocation size will be 128 bytes, and it coul=
d be
>> padded to fill a cache line if that's still a concern.
>=20
> At the time I made a comment, the allocated data was less than 64 byt=
es
>=20
> Problem is adding so many indirections here and here reduce latencies=
 on
> workloads handling a few packets per second.
>=20
> sizeof(struct net_device)=3D0x600
>=20
> We currently have 512 unused bytes (because of kmalloc() power of two=
)
>=20
> (Most virtual devices have small private part added to net_device.
> The real devices are probably crossing the 0x800 limit (or even 0x100=
0))
>=20
>=20
>=20

It should still be 64 bytes.

struct netdev_tc_txq {
        u16 count;
        u16 offset;
};

struct netdev_tc_txq (4 octets) and TC_MAX_QUEUE =3D 16, so 4*16 =3D 64

+	struct netdev_tc_txq tc_to_txq[TC_MAX_QUEUE];   =3D> 64 octets
+	u8 prio_tc_map[TC_BITMASK+1];			=3D> 16 octets

All together 80 bytes this is certainly in the 512 unused bytes.
