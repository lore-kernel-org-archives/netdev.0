From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: xfrm hash to use Jenkins' hash
Date: Wed, 05 Aug 2009 12:08:31 -0700 (PDT)
Message-ID: <20090805.120831.66033097.davem@davemloft.net>
References: <ce10d01f0908050041p43c308fav72ac640f665e161f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: joamaki@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59242
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750964AbZHETIW convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Aug 2009 15:08:22 -0400
In-Reply-To: <ce10d01f0908050041p43c308fav72ac640f665e161f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jussi M=E4ki <joamaki@gmail.com>
Date: Wed, 5 Aug 2009 10:41:42 +0300

> Hi,
>=20
> The current xfrm hash functions perform very poorly when a number of
> policies have the same
> last byte in source and destination addresses.
>=20
> For example with __xfrm_dst_hash, hmask of 0xfff:
>=20
> 192.168.0.1-172.16.0.1 hashes to 3258
> 192.168.0.2-172.16.0.2 hashes to 3258
> ... and so on.
>=20
> This patch addresses the issue by rewriting the xfrm
> hash functions to use the Jenkins' hash function.
>=20
> Signed-off-by: Jussi Maki <joamaki@gmail.com>

jhash expands to a lot of code, and given your description of the
problem, you could have fixed it by adding 2 instructions (see below)
instead of 20 or 30 (jhash instruction count) at every hash
calculation site.

Simply change every instance of:

	(h >> 16)

with

	((h >> 16) ^ (h >> 24))

As much as I love jhash, it's overkill for fixing this problem.

And if we do end up using jhash, it should get inlined into a
seperate non-inline function instead of expanding that monster
4 or 5 times throughout the XFRM code.

I'm not applying this, either make the simple one-liner fix I
suggested above work or move the jhash into a non-inline expansion.
