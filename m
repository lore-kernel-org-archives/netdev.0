From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] Question about potential problem in net/ipv4/route.c
Date: Thu, 12 Oct 2006 07:31:12 +0200
Message-ID: <452DD320.7060408@trash.net>
References: <20061011090504.GC2938@mellanox.co.il>	<20061011.022015.63051509.davem@davemloft.net>	<200610111511.19028.dada1@cosmosbay.com> <20061011.220506.76273501.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030200080306010403070902"
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:5596 "EHLO stinky.trash.net")
	by vger.kernel.org with ESMTP id S965281AbWJLF3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2006 01:29:46 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061011.220506.76273501.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030200080306010403070902
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

David Miller wrote:
> We always explicitly initialize the flows, and even for local stack
> assignment based initialization, gcc zeros out the padding bytes
> always.

I thought so too until I added the iptables compat functions recently
and noticed uninitialized padding of on-stack structures, which
confused iptables since it also uses memcmp.

This program demonstrates the effect, it doesn't output the expected
"1 2" but "1 4294967042" on my x86_64 (gcc-Version 4.1.2 20060901
(prerelease) (Debian 4.1.1-13)). The initialization doesn't touch
the padding bytes:

0x0000000000400494 <test+8>:    movl   $0x1,0xfffffffffffffff0(%rbp)
0x000000000040049b <test+15>:   movb   $0x2,0xfffffffffffffff4(%rbp)


--------------030200080306010403070902
Content-Type: text/x-csrc;
 name="x.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x.c"

#include <stdio.h>

struct x1 {
	unsigned int	x;
	char		y;
};

struct x2 {
	unsigned int	x;
	unsigned int	y;
};

void pollute(void)
{
	struct x2 x = {
		.x	= ~0,
		.y	= ~0,
	};
}

void test(void)
{
	struct x1 x1 = {
		.x	= 1,
		.y	= 2,
	};
	struct x2 *x2 = (struct x2 *)&x1;

	printf("%u %u\n", x2->x, x2->y);
}

int main(int argc, char **argv)
{
	pollute();
	test();
	return 0;
}

--------------030200080306010403070902--
