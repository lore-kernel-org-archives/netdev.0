From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address
 Detection
Date: Fri, 26 Jan 2007 09:20:12 -0500
Message-ID: <45BA0E1C.80408@hp.com>
References: <20070125133340.GA8891@hmsreliant.homelinux.net>	<45B8E60B.7080809@hp.com>	<20070125194500.GB8891@hmsreliant.homelinux.net> <20070126.091331.22638713.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nhorman@tuxdriver.com, sri@us.ibm.com, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@coreworks.de, netdev@vger.kernel.org
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:36429 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965690AbXAZOUR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jan 2007 09:20:17 -0500
In-Reply-To: <20070126.091331.22638713.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> In article <20070125194500.GB8891@hmsreliant.homelinux.net> (at Thu, =
25 Jan 2007 14:45:00 -0500), Neil Horman <nhorman@tuxdriver.com> says:
>=20
>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>> index 2a7e461..46f91ee 100644
>> --- a/net/ipv6/addrconf.c
>> +++ b/net/ipv6/addrconf.c
>> @@ -830,7 +830,8 @@ retry:
>>  	ift =3D !max_addresses ||
>>  	      ipv6_count_addresses(idev) < max_addresses ?=20
>>  		ipv6_add_addr(idev, &addr, tmp_plen,
>> -			      ipv6_addr_type(&addr)&IPV6_ADDR_SCOPE_MASK, IFA_F_TEMPORAR=
Y) : NULL;
>> +			      ipv6_addr_type(&addr)&IPV6_ADDR_SCOPE_MASK,=20
>> +			      IFA_F_TEMPORARY|IFA_F_OPTIMISTIC) : NULL;
>>  	if (!ift || IS_ERR(ift)) {
>>  		in6_ifa_put(ifp);
>>  		in6_dev_put(idev);
>=20
> If optimistic_dad is disabled, flags should be IFA_F_TEMPORARY,
> not IFA_F_TEMPORARY|IFA_F_OPTIMISTIC.
>=20
> Another idea is to use IFA_F_OPTIMISTIC not
> IFA_F_OPTIMISTIC|IFA_F_TENTATIVE until the DAD has been finished.
>=20
>> @@ -1027,15 +1029,17 @@ int ipv6_dev_get_saddr(struct net_device *da=
ddr_dev,
> :
>> +			/* Rule 3: Avoid deprecated and optimistic address */
>>  			if (hiscore.rule < 3) {
>>  				if (ipv6_saddr_preferred(hiscore.addr_type) ||
>> -				    !(ifa_result->flags & IFA_F_DEPRECATED))
>> +				    ((!(ifa_result->flags & IFA_F_DEPRECATED)) &&=20
>> +				    (!(ifa_result->flags & IFA_F_OPTIMISTIC))))
>>  					hiscore.attrs |=3D IPV6_SADDR_SCORE_PREFERRED;
>>  				hiscore.rule++;
>=20
>                                     ((ifa_result->flags & (IFA_F_DEPR=
ECATED|IFA_F_OPTIMISTIC)) =3D=3D 0)
>=20
>>  			}
>>  			if (ipv6_saddr_preferred(score.addr_type) ||
>> -			    !(ifa->flags & IFA_F_DEPRECATED)) {
>> +			    ((!(ifa->flags & IFA_F_DEPRECATED)) &&
>> +			    (!(ifa_result->flags & IFA_F_OPTIMISTIC)))) {
>>  				score.attrs |=3D IPV6_SADDR_SCORE_PREFERRED;
>>  				if (!(hiscore.attrs & IPV6_SADDR_SCORE_PREFERRED)) {
>>  					score.rule =3D 3;
>=20
> ditto.
>=20
>> @@ -2123,7 +2133,8 @@ static void addrconf_add_linklocal(struct inet=
6_dev *idev, struct in6_addr *addr
>>  {
>>  	struct inet6_ifaddr * ifp;
>> =20
>> -	ifp =3D ipv6_add_addr(idev, addr, 64, IFA_LINK, IFA_F_PERMANENT);
>> +	ifp =3D ipv6_add_addr(idev, addr, 64, IFA_LINK,=20
>> +		            IFA_F_PERMANENT|IFA_F_OPTIMISTIC);
>>  	if (!IS_ERR(ifp)) {
>>  		addrconf_dad_start(ifp, 0);
>>  		in6_ifa_put(ifp);
>=20
> Please do not always put IFA_F_OPTIMISTIC.
>=20
>> =20
>> +	/*
>> +	 * Optimistic nodes need to joing the anycast address
>> +	 * right away
>> +	 */
>> +	if (ifp->flags & IFA_F_OPTIMISTIC)
>> +		addrconf_join_anycast(ifp);
>> +
>>  	if (ifp->prefix_len !=3D 128 && (ifp->flags&IFA_F_PERMANENT))
>>  		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, dev, 0,
>>  					flags);
>=20
> Should we join anycast even if the node is a host (not a router)?!

"A router SHOULD NOT configure an Optimistic Address. "
Section 3.3

I think this check is missing from the implementation.


>> @@ -622,9 +637,20 @@ void ndisc_send_rs(struct net_device *dev, stru=
ct in6_addr *saddr,
>> +	/*
>> +	 * Check the source address.  If its OPTIMISTIC
>> +	 * and addr_len is non-zero (implying the sllao option)
>> +	 * then don't send the RS (RFC 4429, section 2.2)
>> +	 */
>> +	ifp =3D ipv6_get_ifaddr(saddr, dev, 1);
>> +
>> +	if ((!ifp) || ((ifp->flags & IFA_F_OPTIMISTIC) && dev->addr_len))
>> +		return;
>> +
>>  	ndisc_flow_init(&fl, NDISC_ROUTER_SOLICITATION, saddr, daddr,
>>  			dev->ifindex);
>> =20
>=20
> I disagree. Please send RS in other way.
> Choose another address, or send it without SLLAO.
>=20

Agree.  Sending without SLLAO is a "MAY" option in the draft and would
yield better operation.

-vlad
