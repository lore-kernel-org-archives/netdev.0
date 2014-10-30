From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 7/8] net: Add calaulation of non folded IPV6
 pseudo header checksum
Date: Thu, 30 Oct 2014 16:39:33 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1C9E2497@AcuExch.aculab.com>
References: <1414685216-28907-1-git-send-email-ogerlitz@mellanox.com>
 <1414685216-28907-8-git-send-email-ogerlitz@mellanox.com>
 <063D6719AE5E284EB5DD2968C1650D6D1C9E2415@AcuExch.aculab.com>
 <5452682B.2030802@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>
To: 'Or Gerlitz' <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:43772 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1758989AbaJ3QmC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 12:42:02 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 13027-06 for <netdev@vger.kernel.org>;
 Thu, 30 Oct 2014 16:41:52 +0000 (GMT)
In-Reply-To: <5452682B.2030802@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz [mailto:ogerlitz@mellanox.com]
> On 10/30/2014 6:25 PM, David Laight wrote:
> >> >+static inline __wsum csum_ipv6_magic_nofold(const struct in6_addr *saddr,
> >> >+					    const struct in6_addr *daddr,
> >> >+					    __u32 len, unsigned short proto,
> >> >+					    __wsum sum)
> >> >+{
> >> >+	__wsum res = sum;
> >> >+
> >> >+	res = csum_add(res, (__force __wsum)saddr->in6_u.u6_addr32[0]);
> >> >+	res = csum_add(res, (__force __wsum)saddr->in6_u.u6_addr32[1]);
> >> >+	res = csum_add(res, (__force __wsum)saddr->in6_u.u6_addr32[2]);
> >> >+	res = csum_add(res, (__force __wsum)saddr->in6_u.u6_addr32[3]);
> >> >+	res = csum_add(res, (__force __wsum)daddr->in6_u.u6_addr32[0]);
> >> >+	res = csum_add(res, (__force __wsum)daddr->in6_u.u6_addr32[1]);
> >> >+	res = csum_add(res, (__force __wsum)daddr->in6_u.u6_addr32[2]);
> >> >+	res = csum_add(res, (__force __wsum)daddr->in6_u.u6_addr32[3]);
>
> > That probably generates a very long dependency chain.
> >
> 
> Could you clarify this comment a bit?

csum_add() probably generates a 32bit 'add with carry' instruction.
So the above generates 8 instructions that have to be executed in series
(dependencies on the register and the carry flag).

On a 64bit cpu there are other options, eg adding 32bit values into
several 64bit registers, then adding those together and finally
collapsing the value to 32 then 16 bits.

Maybe __wsum does end up being 64bit (not looked), but gcc won't
generate a 'tree' of additions, it will still generate a dependency chain.

Hopefully the software 'checksum a buffer' function is written to
avoid these problems.

	David
