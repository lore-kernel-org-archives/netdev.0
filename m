From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Bonding on bond
Date: Thu, 20 Jan 2011 11:53:13 -0800
Message-ID: <4202.1295553193@death>
References: <4D374A8F.2020303@gmail.com> <20110120153110.GA3931@midget.suse.cz> <4D385F0B.1010000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Bohac <jbohac@suse.cz>,
	"bonding-devel@lists.sourceforge.net"
	<bonding-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?us-ascii?Q?=3D=3FISO-8859-1=3FQ=3FNicolas=5Fde=5FPeslo=3DFCan=3F=3D?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:35824 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754027Ab1ATTxR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 14:53:17 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p0KJomMi020348
	for <netdev@vger.kernel.org>; Thu, 20 Jan 2011 12:50:48 -0700
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0KJrFfK091592
	for <netdev@vger.kernel.org>; Thu, 20 Jan 2011 12:53:16 -0700
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0KJrF9f017805
	for <netdev@vger.kernel.org>; Thu, 20 Jan 2011 12:53:15 -0700
In-reply-to: <4D385F0B.1010000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas de Peslo=C3=BCan 	<nicolas.2p.debian@gmail.com> wrote:

>Le 20/01/2011 16:31, Jiri Bohac a =C3=A9crit :
>> On Wed, Jan 19, 2011 at 09:33:19PM +0100, Nicolas de Peslo=C3=BCan w=
rote:
>>> Even if it is possible to test for slave and for master with a
>>> single condition (IFF_BONDING), I suggest to split the tests and th=
e
>>> error messages, to give end user the best possible diagnostic.
>>
>> OK, why not. The below patch still uses IFF_BONDING to detect a
>> master is being enslaved, because IFF_MASTER is also used by the
>> eql driver. No idea if it works / someone ever uses it with
>> bonding, but it might collide.
>
>Thanks Jiri.
>
>> bonding: prohibit enslaving of bonding masters
>>
>> Nested bonding is not supported and will result in strange problems,=
 e.g.:
>> - netif_receive_skb() will not properly change skb->dev to point to =
the
>>    uppoer-most bonding master
>> - arp monitor will not work (dev->last_rx is only updated by hardwar=
e drivers)
>> - accidentally enslaving a bonding master to itself will cause an in=
finite
>>    recursion in the TX path

	Did you test these?  I'm curious about the ARP monitor
assertion, because last_rx is updated by bonding itself now (in
skb_bond_should_drop), not in the device drivers.

	I'm in agreement that, by and large, nesting of bonds is
pointless.  However, I suspect that there are users out in the world wh=
o
are happily doing so, and this patch may shut them down.

	I've not tested with nesting in a while; I know it used to work
(at least for limited cases, typically an active-backup bond with a pai=
r
of balance-xor or balance-rr or sometimes 802.3ad enslaved to it), but
has never really been a deliberate feature.  Is nesting now utterly
broken, as suggested by the list of problems above?

>> This patch prevents this by prohibiting a bonding master from being =
further enslaved.
>>
>> Signed-off-by: Jiri Bohac<jbohac@suse.cz>
>
>Reviewed-by: Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr>

	If nesting really doesn't work and is going to be disabled, then
at a minimum it should also have an update to the documentation
explaining this.

	-J

>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/b=
ond_main.c
>> index b1025b8..b117dd8 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -1453,6 +1453,12 @@ int bond_enslave(struct net_device *bond_dev,=
 struct net_device *slave_dev)
>>   		return -EBUSY;
>>   	}
>>
>> +	/* cannot enslave a master */
>> +	if (slave_dev->priv_flags&  IFF_BONDING) {
>> +		pr_debug("Error, cannot enslave a bonding master\n");
>> +		return -EBUSY;
>> +	}
>> +
>>   	/* vlan challenged mutual exclusion */
>>   	/* no need to lock since we're protected by rtnl_lock */
>>   	if (slave_dev->features&  NETIF_F_VLAN_CHALLENGED) {
>>

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
