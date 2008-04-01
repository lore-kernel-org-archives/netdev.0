From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Fix for the fundamental network/block layer race in sendfile().
Date: Tue, 01 Apr 2008 21:21:19 +0200
Message-ID: <47F28B2F.2070609@cosmosbay.com>
References: <20080328092036.GA11924@2ka.mipt.ru> <20080328.134053.122172549.davem@davemloft.net> <20080328205613.GA24812@2ka.mipt.ru> <20080328.140736.92315090.davem@davemloft.net> <20080328215131.GB24812@2ka.mipt.ru> <20080401164904.GA2382@2ka.mipt.ru> <47F26EAB.7040900@cosmosbay.com> <20080401174759.GB28217@2ka.mipt.ru> <20080401180751.GA3263@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, axboe@kernel.dk,
	netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from neuf-infra-smtp-out-sp604007av.neufgp.fr ([84.96.92.120]:54104
	"EHLO neuf-infra-smtp-out-sp604007av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753678AbYDATV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 15:21:29 -0400
In-Reply-To: <20080401180751.GA3263@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Evgeniy Polyakov a =E9crit :
> On Tue, Apr 01, 2008 at 09:47:59PM +0400, Evgeniy Polyakov (johnpol@2=
ka.mipt.ru) wrote:
>>> 1) Is out_file garanted to be a socket ?
>>> 2) SO_PRIVATE_CALLBACK is defined to be 37 later on your patch. Is =
ORing 37=20
>>> to sk_flags really working ???
>>> 3) So, once a socket has been used for a sendfile(), all subsequent=
=20
>>> sendmsg() will call skb_splice_destructor ? (I see no clearing of=20
>>> SO_PRIVATE_CALLBACK)
>>>  This will probably crash.
>>> 4) god_blessed_us name ... Oh I got it, its April the first !!!!
>=20
> Addressed all above (2 and 3 actually).
> The formed by using correct socket flag (set_bit/clear_bit, like in a
> real life), the latter by clearing bit on sendfile() exit and to fix
> exit/clear race each spliced page also setups lru.prev to itself, whi=
ch
> is checked in destructor.
> Name was not changed, does it matter?
>=20
> Patch still works ok :)
>=20
> Thanks Eric for pointing that bugs.
>=20
> Signed-off-as-usual.
>=20
> diff --git a/fs/read_write.c b/fs/read_write.c
> index 49a9871..fda55f6 100644
> --- a/fs/read_write.c
> +++ b/fs/read_write.c
> @@ -16,6 +16,7 @@
>  #include <linux/syscalls.h>
>  #include <linux/pagemap.h>
>  #include <linux/splice.h>
> +#include <net/sock.h>
>  #include "read_write.h"
> =20
>  #include <asm/uaccess.h>
> @@ -703,6 +704,8 @@ static ssize_t do_sendfile(int out_fd, int in_fd,=
 loff_t *ppos,
>  	loff_t pos;
>  	ssize_t retval;
>  	int fput_needed_in, fput_needed_out, fl;
> +	struct sock *sk;
> +	struct socket *sock;
> =20
>  	/*
>  	 * Get input file, and verify that it is ok..
> @@ -762,6 +765,12 @@ static ssize_t do_sendfile(int out_fd, int in_fd=
, loff_t *ppos,
>  		count =3D max - pos;
>  	}
> =20
> +	sock =3D out_file->private_data;
> +	sk =3D sock->sk;
> +
> +	sk->sk_user_data =3D &skb_splice_destructor;
> +	set_bit(SOCK_PRIVATE_CALLBACK, &sock->flags);
> +
>  	fl =3D 0;
>  #if 0
>  	/*
> @@ -775,6 +784,8 @@ static ssize_t do_sendfile(int out_fd, int in_fd,=
 loff_t *ppos,
>  #endif
>  	retval =3D do_splice_direct(in_file, ppos, out_file, count, fl);
> =20
> +	clear_bit(SOCK_PRIVATE_CALLBACK, &sock->flags);


I see no socket locking, so multiple threads could use sendfile() & sen=
dmsg()=20
on same socket, and crash kernel...


