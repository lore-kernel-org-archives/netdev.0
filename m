From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] dcache: better name hash function
Date: Tue, 27 Oct 2009 07:07:31 +0100
Message-ID: <4AE68E23.20205@gmail.com>
References: <19864844.24581256620784317.JavaMail.root@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Al Viro <viro@zeniv.linux.org.uk>
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:60914 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755451AbZJ0GIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 02:08:05 -0400
In-Reply-To: <19864844.24581256620784317.JavaMail.root@tahiti.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =C3=A9crit :
> One of the root causes of slowness in network usage
> was my original choice of power of 2 for hash size, to avoid
> a mod operation. It turns out if size is not a power of 2
> the original algorithm works fairly well.

Interesting, but I suspect all users have power of 2 tables :(

>=20
> On slow cpu; with 10million entries and 211 hash size
>=20
>
>=20
> How important is saving the one division, versus getting better
> distribution.


unsigned int fold1(unsigned hash)
{
	return hash % 211;
}

Compiler uses a reciprocal divide because of 211 being a constant.

And you also could try following that contains one multiply only,
and check if hash distribution properties are still OK

unsigned int fold2(unsigned hash)
{
	return ((unsigned long long)hash * 211) >> 32;
}

fold1:
        movl    4(%esp), %ecx
        movl    $-1689489505, %edx
        movl    %ecx, %eax
        mull    %edx
        shrl    $7, %edx
        imull   $211, %edx, %edx
        subl    %edx, %ecx
        movl    %ecx, %eax
        ret

fold2:
        movl    $211, %eax
        mull    4(%esp)
        movl    %edx, %eax
        ret


