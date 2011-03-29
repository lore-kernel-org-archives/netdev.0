From: =?UTF-8?B?VGltbyBUZXLDpHM=?= <timo.teras@iki.fi>
Subject: Re: [PATCH] net: gre: provide multicast mappings for ipv4 and ipv6
Date: Tue, 29 Mar 2011 13:00:32 +0300
Message-ID: <4D91ADC0.9090400@iki.fi>
References: <4D8F6313.60408@iki.fi>	 <1301388053-6083-1-git-send-email-timo.teras@iki.fi> <1301389905.3161.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Doug Kehn <rdkehn@yahoo.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:59111 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751251Ab1C2KAf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2011 06:00:35 -0400
Received: by eyx24 with SMTP id 24so1417325eyx.19
        for <netdev@vger.kernel.org>; Tue, 29 Mar 2011 03:00:34 -0700 (PDT)
In-Reply-To: <1301389905.3161.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/29/2011 12:11 PM, Eric Dumazet wrote:
> Le mardi 29 mars 2011 =C3=A0 11:40 +0300, Timo Ter=C3=A4s a =C3=A9cri=
t :
>> My commit 6d55cb91a0020ac0 (gre: fix hard header destination
>> address checking) broke multicast.
>>
>> The reason is that ip_gre used to get ipgre_header() calls with
>> zero destination if we have NOARP or multicast destination. Instead
>> the actual target was decided at ipgre_tunnel_xmit() time based on
>> per-protocol dissection.
>>
>> Instead of allowing the "abuse" of ->header() calls with invalid
>> destination, this creates multicast mappings for ip_gre. This also
>> fixes "ip neigh show nud noarp" to display the proper multicast
>> mappings used by the gre device.
>>
>> Reported-by: Doug Kehn <rdkehn@yahoo.com>
>> Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
>> ---
>> Compile tested only. Doug tested IPv4 side with the earlier patch.
>=20
>=20
>> +static inline int ipv6_ipgre_mc_map(const struct in6_addr *addr,
>> +				    const unsigned char *broadcast, char *buf)
>> +{
>> +	if ((broadcast[0] | broadcast[1] | broadcast[2] | broadcast[3]) !=3D=
 0) {
>> +		memcpy(buf, broadcast, 4);
>> +	} else {
>> +		/* v4mapped? */
>> +		if ((addr->s6_addr32[0] | addr->s6_addr32[1] |
>> +		     (addr->s6_addr32[2] ^ htonl(0x0000ffff))) !=3D 0)
>> +			return -EINVAL;
>=20
> 		if (ipv6_addr_v4mapped(addr))
>=20
>=20
>> +		memcpy(buf, &addr->s6_addr32[3], 4);
>> +	}
>> +	return 0;
>> +}

I wanted to put the function same header as all other similar ones:
net/if_inet6.h. However, ipv6_addr_v4mapped() is defined in net/ipv6.h
which includes net/if_inet6.h. So I can't really use that function ther=
e.

