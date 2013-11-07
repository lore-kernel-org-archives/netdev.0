From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: Re: [PATCH net-next 6/8] bonding: add arp_ip_target netlink support
Date: Thu, 7 Nov 2013 00:56:35 -1000
Message-ID: <C580A3C6-BF26-4316-A6F5-6DB02319B100@cumulusnetworks.com>
References: <20131107094330.15846.84353.stgit@monster-03.cumulusnetworks.com> <20131107101640.GA2463@minipsycho.orion>
Mime-Version: 1.0 (Mac OS X Mail 7.0 \(1816\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net,
	netdev@vger.kernel.org, shm <shm@cumulusnetworks.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:39316 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752319Ab3KGK4n convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 05:56:43 -0500
In-Reply-To: <20131107101640.GA2463@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Nov 7, 2013, at 12:16 AM, Jiri Pirko <jiri@resnulli.us> wrote:

> Thu, Nov 07, 2013 at 10:43:30AM CET, sfeldma@cumulusnetworks.com wrot=
e:
>> Add IFLA_BOND_ARP_IP_TARGET to allow get/set of bonding parameter
>> arp_ip_target via netlink.
>>=20
>> Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
>> ---
>> drivers/net/bonding/bond_netlink.c |   43 ++++++++++++++-
>> drivers/net/bonding/bond_options.c |  102 ++++++++++++++++++++++++++=
++++++++++
>> drivers/net/bonding/bond_sysfs.c   |   77 +++-----------------------=
-
>> drivers/net/bonding/bonding.h      |    3 +
>> include/uapi/linux/if_link.h       |    1=20
>> 5 files changed, 155 insertions(+), 71 deletions(-)
>>=20
>> diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bondin=
g/bond_netlink.c
>> index 9c50165..e4673ba 100644
>> --- a/drivers/net/bonding/bond_netlink.c
>> +++ b/drivers/net/bonding/bond_netlink.c
>> @@ -29,6 +29,7 @@ static const struct nla_policy bond_policy[IFLA_BO=
ND_MAX + 1] =3D {
>> 	[IFLA_BOND_DOWNDELAY]		=3D { .type =3D NLA_U32 },
>> 	[IFLA_BOND_USE_CARRIER]		=3D { .type =3D NLA_U8 },
>> 	[IFLA_BOND_ARP_INTERVAL]	=3D { .type =3D NLA_U32 },
>> +	[IFLA_BOND_ARP_IP_TARGET]	=3D { .type =3D NLA_NESTED },
>> };
>>=20
>> static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
>> @@ -109,6 +110,21 @@ static int bond_changelink(struct net_device *b=
ond_dev,
>> 		if (err)
>> 			return err;
>> 	}
>> +	if (data[IFLA_BOND_ARP_IP_TARGET]) {
>> +		struct nlattr *attr;
>> +		int rem;
>> +
>> +		err =3D bond_option_arp_ip_target_clear_all(bond);
>> +		if (err)
>> +			return err;
>> +
>=20
> Hmm. I think this is not correct. I think you should not clear all. T=
hey
> might be needed to be used but for a brief moment, they disappear.
>=20
> Just set or unset them one by one.

That=92s a good catch.  I should compare existing set with new set and =
retain entries entries common to both sets (and add/remove uncommon one=
s).

Just to be clear, for netlink, the idea is to push a set of ip targets =
addrs as a nested attribute and process as a set.  This is consistent w=
ith arp_ip_target documentation in Documentation/networking/bonding.txt=
 where arp_ip_target is passed as a comma-separated list of addrs.  How=
ever, it=92s not consistent with the sysfs interface where addrs are ad=
ded/removed one at a time using =93+=94 or =93-=93 prefix.

e.g.:

ip link add bond7 type bond mode 1
ip link set dev bond7 type bond arp_ip_target 10.0.0.1,10.0.0.5
ip link set dev bond7 type bond arp_ip_target 10.0.0.1


>> @@ -141,6 +159,8 @@ static int bond_fill_info(struct sk_buff *skb,
>> {
>> 	struct bonding *bond =3D netdev_priv(bond_dev);
>> 	struct net_device *slave_dev =3D bond_option_active_slave_get(bond)=
;
>> +	struct nlattr *targets;
>> +	int i, targets_added;
>>=20
>> 	if (nla_put_u8(skb, IFLA_BOND_MODE, bond->params.mode))
>> 		goto nla_put_failure;
>> @@ -152,10 +172,12 @@ static int bond_fill_info(struct sk_buff *skb,
>> 	if (nla_put_u32(skb, IFLA_BOND_MIIMON, bond->params.miimon))
>> 		goto nla_put_failure;
>>=20
>> -	if (nla_put_u32(skb, IFLA_BOND_UPDELAY, bond->params.updelay))
>> +	if (nla_put_u32(skb, IFLA_BOND_UPDELAY,
>> +		bond->params.updelay * bond->params.miimon))
>> 		goto nla_put_failure;
>=20
> 	This bit should probably no be here :)

Drats, that change goes with earlier patch.  I=92ll fix on patch set re=
send for issue above.

-scott