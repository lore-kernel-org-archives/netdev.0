From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] [PATCH 1/5] net: Introduce sk_tx_queue_mapping
Date: Thu, 15 Oct 2009 12:32:07 +0200
Message-ID: <4AD6FA27.1040804@gmail.com>
References: <20091015055602.30145.65852.sendpatchset@localhost.localdomain> <20091015055632.30145.52459.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:38587 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757225AbZJOKcu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 06:32:50 -0400
In-Reply-To: <20091015055632.30145.52459.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krishna Kumar a =E9crit :
> From: Krishna Kumar <krkumar2@in.ibm.com>
>=20
> Introduce sk_tx_queue_mapping; and functions that set, test and get
> this value. Reset sk_tx_queue_mapping to -1 whenever the dst cache
> is set/reset, and in socket alloc & free (free probably doesn't need
> it).
>=20
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
>  include/net/sock.h |   21 +++++++++++++++++++++
>  net/core/sock.c    |    7 ++++++-
>  2 files changed, 27 insertions(+), 1 deletion(-)
>=20
> diff -ruNp org/include/net/sock.h new/include/net/sock.h
> --- org/include/net/sock.h	2009-10-14 10:36:52.000000000 +0530
> +++ new/include/net/sock.h	2009-10-14 17:59:44.000000000 +0530
> @@ -107,6 +107,7 @@ struct net;
>   *	@skc_node: main hash linkage for various protocol lookup tables
>   *	@skc_nulls_node: main hash linkage for UDP/UDP-Lite protocol
>   *	@skc_refcnt: reference count
> + *	@skc_tx_queue_mapping: tx queue number for this connection
>   *	@skc_hash: hash value used with various protocol lookup tables
>   *	@skc_family: network address family
>   *	@skc_state: Connection state
> @@ -128,6 +129,7 @@ struct sock_common {
>  		struct hlist_nulls_node skc_nulls_node;
>  	};
>  	atomic_t		skc_refcnt;
> +	int			skc_tx_queue_mapping;
> =20

Hmm, two remarks :

1) It adds a 32bits hole on 64bit arches
2) sk_tx_queue_mapping is only read in tx path, but sits close to
skc_refcnt, which is now only read/written in rx path (by socket lookup=
s)

But since sock_common is small, 56 bytes on x86_64,(under a cache line)=
,
there is nothing we can do at this moment.

My plan is to move skc_refcnt at the end of sock_common and I'll need t=
o add
new generic fields into sock_common to make offsetof(skc_refcnt) =3D 64=
=2E

Next to sock_common, will be placed fields used in rx path.

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
