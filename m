From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 6/8] bonding: add arp_ip_target netlink support
Date: Thu, 7 Nov 2013 13:56:47 +0100
Message-ID: <20131107125647.GB2463@minipsycho.orion>
References: <20131107094330.15846.84353.stgit@monster-03.cumulusnetworks.com>
 <20131107101640.GA2463@minipsycho.orion>
 <C580A3C6-BF26-4316-A6F5-6DB02319B100@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net,
	netdev@vger.kernel.org, shm <shm@cumulusnetworks.com>
To: Scott Feldman <sfeldma@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f172.google.com ([209.85.215.172]:63336 "EHLO
	mail-ea0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750996Ab3KGM4x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 07:56:53 -0500
Received: by mail-ea0-f172.google.com with SMTP id r16so302852ead.17
        for <netdev@vger.kernel.org>; Thu, 07 Nov 2013 04:56:52 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <C580A3C6-BF26-4316-A6F5-6DB02319B100@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Nov 07, 2013 at 11:56:35AM CET, sfeldma@cumulusnetworks.com wrote:
>
>On Nov 7, 2013, at 12:16 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>
>> Thu, Nov 07, 2013 at 10:43:30AM CET, sfeldma@cumulusnetworks.com wro=
te:
>>> Add IFLA_BOND_ARP_IP_TARGET to allow get/set of bonding parameter
>>> arp_ip_target via netlink.
>>>=20
>>> Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
>>> ---
>>> drivers/net/bonding/bond_netlink.c |   43 ++++++++++++++-
>>> drivers/net/bonding/bond_options.c |  102 +++++++++++++++++++++++++=
+++++++++++
>>> drivers/net/bonding/bond_sysfs.c   |   77 +++----------------------=
--
>>> drivers/net/bonding/bonding.h      |    3 +
>>> include/uapi/linux/if_link.h       |    1=20
>>> 5 files changed, 155 insertions(+), 71 deletions(-)
>>>=20
>>> diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bondi=
ng/bond_netlink.c
>>> index 9c50165..e4673ba 100644
>>> --- a/drivers/net/bonding/bond_netlink.c
>>> +++ b/drivers/net/bonding/bond_netlink.c
>>> @@ -29,6 +29,7 @@ static const struct nla_policy bond_policy[IFLA_B=
OND_MAX + 1] =3D {
>>> 	[IFLA_BOND_DOWNDELAY]		=3D { .type =3D NLA_U32 },
>>> 	[IFLA_BOND_USE_CARRIER]		=3D { .type =3D NLA_U8 },
>>> 	[IFLA_BOND_ARP_INTERVAL]	=3D { .type =3D NLA_U32 },
>>> +	[IFLA_BOND_ARP_IP_TARGET]	=3D { .type =3D NLA_NESTED },
>>> };
>>>=20
>>> static int bond_validate(struct nlattr *tb[], struct nlattr *data[]=
)
>>> @@ -109,6 +110,21 @@ static int bond_changelink(struct net_device *=
bond_dev,
>>> 		if (err)
>>> 			return err;
>>> 	}
>>> +	if (data[IFLA_BOND_ARP_IP_TARGET]) {
>>> +		struct nlattr *attr;
>>> +		int rem;
>>> +
>>> +		err =3D bond_option_arp_ip_target_clear_all(bond);
>>> +		if (err)
>>> +			return err;
>>> +
>>=20
>> Hmm. I think this is not correct. I think you should not clear all. =
They
>> might be needed to be used but for a brief moment, they disappear.
>>=20
>> Just set or unset them one by one.
>
>That=E2=80=99s a good catch.  I should compare existing set with new s=
et and retain entries entries common to both sets (and add/remove uncom=
mon ones).
>
>Just to be clear, for netlink, the idea is to push a set of ip targets=
 addrs as a nested attribute and process as a set.  This is consistent =
with arp_ip_target documentation in Documentation/networking/bonding.tx=
t where arp_ip_target is passed as a comma-separated list of addrs.  Ho=
wever, it=E2=80=99s not consistent with the sysfs interface where addrs=
 are added/removed one at a time using =E2=80=9C+=E2=80=9D or =E2=80=9C=
-=E2=80=9C prefix.

I believe that the behaviour you described is ok.

>
>e.g.:
>
>ip link add bond7 type bond mode 1
>ip link set dev bond7 type bond arp_ip_target 10.0.0.1,10.0.0.5
>ip link set dev bond7 type bond arp_ip_target 10.0.0.1
>
>
>>> @@ -141,6 +159,8 @@ static int bond_fill_info(struct sk_buff *skb,
>>> {
>>> 	struct bonding *bond =3D netdev_priv(bond_dev);
>>> 	struct net_device *slave_dev =3D bond_option_active_slave_get(bond=
);
>>> +	struct nlattr *targets;
>>> +	int i, targets_added;
>>>=20
>>> 	if (nla_put_u8(skb, IFLA_BOND_MODE, bond->params.mode))
>>> 		goto nla_put_failure;
>>> @@ -152,10 +172,12 @@ static int bond_fill_info(struct sk_buff *skb=
,
>>> 	if (nla_put_u32(skb, IFLA_BOND_MIIMON, bond->params.miimon))
>>> 		goto nla_put_failure;
>>>=20
>>> -	if (nla_put_u32(skb, IFLA_BOND_UPDELAY, bond->params.updelay))
>>> +	if (nla_put_u32(skb, IFLA_BOND_UPDELAY,
>>> +		bond->params.updelay * bond->params.miimon))
>>> 		goto nla_put_failure;
>>=20
>> 	This bit should probably no be here :)
>
>Drats, that change goes with earlier patch.  I=E2=80=99ll fix on patch=
 set resend for issue above.
>
>-scott
