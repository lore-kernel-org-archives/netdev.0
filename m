From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 7/8] net: Add calaulation of non folded IPV6
 pseudo header checksum
Date: Thu, 30 Oct 2014 17:09:31 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1C9E258D@AcuExch.aculab.com>
References: <1414685216-28907-1-git-send-email-ogerlitz@mellanox.com>
 <1414685216-28907-8-git-send-email-ogerlitz@mellanox.com>
 <063D6719AE5E284EB5DD2968C1650D6D1C9E2415@AcuExch.aculab.com>
 <5452682B.2030802@mellanox.com>
 <063D6719AE5E284EB5DD2968C1650D6D1C9E2497@AcuExch.aculab.com>
 <54526D3C.2040604@mellanox.com>
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
Received: from mx0.aculab.com ([213.249.233.131]:44587 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1758433AbaJ3RMB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 13:12:01 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 15401-02 for <netdev@vger.kernel.org>;
 Thu, 30 Oct 2014 17:11:51 +0000 (GMT)
In-Reply-To: <54526D3C.2040604@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> OK, talking to Matan, hecame up with this super-quick (compile tested
> only) alternative, is
> this what you were advocating for?
>   {
> +       sum = csum_partial(saddr, sizeof(saddr->in6_u.u6_addr32), sum);
> +       sum = csum_partial(saddr, sizeof(daddr->in6_u.u6_addr32), sum);

I'm pretty sure your 'saddr' and 'daddr' are adjacent.
Whether you can prove that is another matter.

> +       sum = csum_add(sum, (__force __wsum)htonl(len));
> +       sum = csum_add(sum, (__force __wsum)htons(proto));
> +
> +       return sum;
> +}

On 64 bit systems you probably want to end up with something akin to:
	__u64 a, b, c, d;

	a = saddr[0] + saddr[1];
	b = saddr[2] + saddr[3];
	c = daddr[0] + daddr[1];
	d = daddr[2] + daddr[3];
	a += b;
	c += d;
	a += c;
and then collapse down the 64bit value.
However if you write the above in proper C, gcc will probably
convert it to long dependence chain.

An architecture specific csum_partial() probably manages to DTRT.

	David
