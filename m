From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] igmp: RCU conversion of in_dev->mc_list
Date: Fri, 12 Nov 2010 15:26:14 +0100
Message-ID: <1289571974.3185.254.camel@edumazet-laptop>
References: <AANLkTikvT=x9eBovn2-m6HLqk7wyXSAR3sc9jCQ0C6mL@mail.gmail.com>
	 <1289489007.17691.1310.camel@edumazet-laptop>
	 <AANLkTik93QUQxSDmwd4Qj-gXQiWWPzd68JPAYAHBAsHR@mail.gmail.com>
	 <20101112071323.GB5660@cr0.nay.redhat.com>
	 <1289546874.17691.1774.camel@edumazet-laptop>
	 <20101112081945.GA5949@cr0.nay.redhat.com>
	 <1289553759.3185.1.camel@edumazet-laptop>
	 <1289568858.3185.252.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cypher Wu <cypher.w@gmail.com>, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: =?ISO-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:33105 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752464Ab0KLO0Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 09:26:25 -0500
In-Reply-To: <1289568858.3185.252.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 12 novembre 2010 =C3=A0 14:34 +0100, Eric Dumazet a =C3=A9c=
rit :
> Le vendredi 12 novembre 2010 =C3=A0 10:22 +0100, Eric Dumazet a =C3=A9=
crit :
> > Le vendredi 12 novembre 2010 =C3=A0 16:19 +0800, Am=C3=A9rico Wang =
a =C3=A9crit :
> > > On Fri, Nov 12, 2010 at 08:27:54AM +0100, Eric Dumazet wrote:
> >=20
> > > >A RCU conversion is far more complex.
> > > >
> > >=20
> > > Yup.
> >=20
> >=20
> > Well, actually this is easy in this case.
> >=20
> > I'll post a patch to do this RCU conversion.
> >=20
> >=20
>=20
> Note : compile tested only, I'll appreciate if someone can test it ;)
>=20
> Note: one patch from net-2.6 is not yet included in net-next-2.6, so
> please make sure you have it before testing ;)
>=20
> ( http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-2.6.git;a=3Dc=
ommitdiff;h=3D18943d292facbc70e6a36fc62399ae833f64671b )
>=20
>=20
> Thanks
>=20
> [PATCH net-next-2.6] igmp: RCU conversion of in_dev->mc_list
>=20
> in_dev->mc_list is protected by one rwlock (in_dev->mc_list_lock).
>=20
> This can easily be converted to a RCU protection.
>=20
> Writers hold RTNL, so mc_list_lock is removed, not replaced by a
> spinlock.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Cypher Wu <cypher.w@gmail.com>
> Cc: Am=C3=A9rico Wang <xiyou.wangcong@gmail.com>
> ---

=2E..

>  void ip_mc_up(struct in_device *in_dev)
>  {
> -	struct ip_mc_list *i;
> +	struct ip_mc_list *pmc;
> =20
>  	ASSERT_RTNL();
> =20
>  	ip_mc_inc_group(in_dev, IGMP_ALL_HOSTS);
> =20
> -	for (i=3Din_dev->mc_list; i; i=3Di->next)
> -		igmp_group_added(i);
> +	for_each_pmc_rtnl(in_dev, pmc);
> +		igmp_group_added(pmc);
>  }


Oops there is an extra ; after the for_each_pmc_rtnl(in_dev, pmc)

should be

	for_each_pmc_rtnl(in_dev, pmc)
		igmp_group_added(pmc);



