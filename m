From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: Fix slowness in read /proc/net/tcp
Date: Mon, 07 Jun 2010 09:19:27 +0200
Message-ID: <1275895167.2545.8.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1006062020180.24064@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Yakov Lerner <iler.ml@gmail.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:36239 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755444Ab0FGHTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 03:19:32 -0400
Received: by wyi11 with SMTP id 11so2122693wyi.19
        for <netdev@vger.kernel.org>; Mon, 07 Jun 2010 00:19:31 -0700 (PDT)
In-Reply-To: <alpine.DEB.1.00.1006062020180.24064@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 06 juin 2010 =C3=A0 20:27 -0700, Tom Herbert a =C3=A9crit :
> This patch address a serious performance issue in reading the
> TCP sockets table (/proc/net/tcp).
>=20
> Reading the full table is done by a number of sequential read
> operations.  At each read operation, a seek is done to find the
> last socket that was previously read.  This seek operation requires
> that the sockets in the table need to be counted up to the current
> file position, and to count each of these requires taking a lock for
> each non-empty bucket.  The whole algorithm is O(n^2).
>=20
> The fix is to cache the last bucket value, offset within the bucket,
> and the file position returned by the last read operation.   On the
> next sequential read, the bucket and offset are used to find the
> last read socket immediately without needing ot scan the previous
> buckets  the table.  This algorithm t read the whole table is O(n).
>=20
> The improvement offered by this patch is easily show by performing
> cat'ing /proc/net/tcp on a machine with a lot of connections.  With
> about 182K connections in the table, I see the following:
>=20
> - Without patch
> time cat /proc/net/tcp > /dev/null
>=20
> real	1m56.729s
> user	0m0.214s
> sys	1m56.344s
>=20
> - With patch
> time cat /proc/net/tcp > /dev/null
>=20
> real	0m0.894s
> user	0m0.290s
> sys	0m0.594s
>=20
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---

This problem raises every year,  (last attempt from Yakov Lerner :
http://kerneltrap.org/mailarchive/linux-netdev/2009/9/26/6256119 )

And finally, someone motivated enough to use /proc/net/tcp found the
right answer ;)

Most netdev people tend to push inet_diag (netlink) interface instead o=
f
old /proc/net/tcp, but it seems old interface will still be used in
2030, so :

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

BTW, another problem of /proc/net/tcp is the buffer size used by netsta=
t
utility : 1024 bytes instead of PAGE_SIZE, making O(N^2) behavior even
more palpable.



