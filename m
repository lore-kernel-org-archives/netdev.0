From: Toyo Abe <tabe@miraclelinux.com>
Subject: Re: [IPV6] ADDRCONF: Defer dad for global address until dad for linklocal
 is completed.
Date: Fri, 20 Jun 2008 11:17:27 +0900
Message-ID: <485B1337.2000202@miraclelinux.com>
References: <48324792.5070309@miraclelinux.com>	<20080520.173353.128167700.yoshfuji@linux-ipv6.org>	<4832C3CC.5070609@miraclelinux.com> <20080522.015807.02348209.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.miraclelinux.com ([219.118.163.66]:30254 "EHLO
	mail.miraclelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751369AbYFTCR3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 22:17:29 -0400
In-Reply-To: <20080522.015807.02348209.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm wondering why the fix inlined below is not included.
I'd tested this fix w/ TAHI test suite. Then, the failed test cases - v=
6LC.3.1.2 Part B, Part D,
v6LC.3.1.3 Part I, and Part J in IPv6 Stateless Address Autoconfigurati=
on test - were all passed.
If just waiting for verification info, I'm really sorry for the lazy re=
sponse.

I think this can be merged.

Thank you,
-toyo

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> In article <4832C3CC.5070609@miraclelinux.com> (at Tue, 20 May 2008 2=
1:27:56 +0900), Toyo Abe <tabe@miraclelinux.com> says:
>=20
>> I was also thinking so. And I tried it at first.
>> But then, many other test scenarios in TAHI test suite went to FAIL.=
 It
>> was because
>> the tester node send RA with prefix option to the host right after i=
t
>> receives DAD NS
>> from the host, which is obviously in autoconfiguration process for
>> linklocal address.
>=20
> If so, we should complain about the spec / tests.
>=20
>> Since current addrconf code actually accepts RA including prefix opt=
ion=20
>> while DAD for
>> linklocal address is processing, changes of the behaviour looks like=
 a=20
>> degradation for me.
>> Hence, I chose to accept RA at that moment and defer sending DAD NS =
for=20
>> global addresses.
>=20
> Well I don't think so.
> We should choose simpler way - avoid introducing new "unique" state s=
o far.
>=20
> If you really think is worth accepting RA during DAD for link-local
> address, we should cancel all of on-going DADs for global address(es)
> if the RA for link-local address has failed, intead of deferring DAD
> for global address(es).
>=20
> ---
> [RFC PATCH] [IPV6] ADDRCONF: Do not generate "global" address unless =
valid link-local address is available.
>=20
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> ---
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index e591e09..df99c5e 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -1813,8 +1813,14 @@ void addrconf_prefix_rcv(struct net_device *de=
v, u8 *opt, int len)
> =20
>  		if (pinfo->prefix_len =3D=3D 64) {
>  			memcpy(&addr, &pinfo->prefix, 8);
> -			if (ipv6_generate_eui64(addr.s6_addr + 8, dev) &&
> -			    ipv6_inherit_eui64(addr.s6_addr + 8, in6_dev)) {
> +			if (ipv6_inherit_eui64(addr.s6_addr + 8, in6_dev)) {
> +				/*
> +				 * If a valid link-local address is not found,
> +				 * let's ignore autonomous flag.
> +				 */
> +				if (net_ratelimit())
> +					printk(KERN_DEBUG "IPv6 addrconf: valid link-local address not =
found on %s\n",
> +					       in6_dev->dev->name);
>  				in6_dev_put(in6_dev);
>  				return;
>  			}
>=20
> --yoshfuji
>=20

