From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] socket: add minimum listen queue length sysctl
Date: Mon, 21 Mar 2011 08:36:30 +0100
Message-ID: <1300692990.2831.485.camel@edumazet-laptop>
References: <20110320121414.GC3038@nuttenaction>
	 <1300662282-24741-1-git-send-email-hagen@jauu.net>
	 <1300662282-24741-2-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:34986 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751771Ab1CUHgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 03:36:35 -0400
Received: by fxm17 with SMTP id 17so5217862fxm.19
        for <netdev@vger.kernel.org>; Mon, 21 Mar 2011 00:36:33 -0700 (PDT)
In-Reply-To: <1300662282-24741-2-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 21 mars 2011 =C3=A0 00:04 +0100, Hagen Paul Pfeifer a =C3=A9cr=
it :
> In the case that a server programmer misjudge network characteristic =
the
> backlog parameter for listen(2) may not adequate to utilize hosts
> capabilities and lead to unrequired SYN retransmission - a small back=
log
> value can form an artificial limitation. From Erics server setup, a
> listen queue length of 8 is often a way to small):
>=20
> ss -a | head
> State      Recv-Q Send-Q      Local Address:Port          Peer
> Address:Port
> LISTEN     0      8                       *:imaps                    =
*:*
> LISTEN     0      8                       *:pop3s                    =
*:*
> LISTEN     0      50                      *:mysql                    =
*:*
> LISTEN     0      8                       *:pop3                     =
*:*
> LISTEN     0      8                       *:imap2                    =
*:*
> LISTEN     0      511                     *:www                      =
*:*
>=20
> Until now it is not possible for the system (network) administrator t=
o
> increase this value. A bug report must be filled, the backlog increas=
ed,
> a new version released or even worse: if using closed source software
> you cannot make anything.
>=20
> sysctl_min_syn_backlog provides the ability to increase the minimum
> queue length. The default is 8.
>=20
> Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
>=20
> ---
> I will spin a second documentation patch if Davem accept this patch.
> ---
>  include/net/request_sock.h |    1 +
>  net/core/request_sock.c    |    5 ++++-
>  net/ipv4/sysctl_net_ipv4.c |    7 +++++++
>  3 files changed, 12 insertions(+), 1 deletions(-)
>=20
> diff --git a/include/net/request_sock.h b/include/net/request_sock.h
> index 99e6e19..3e8865f 100644
> --- a/include/net/request_sock.h
> +++ b/include/net/request_sock.h
> @@ -89,6 +89,7 @@ static inline void reqsk_free(struct request_sock *=
req)
>  }
> =20
>  extern int sysctl_max_syn_backlog;
> +extern int sysctl_min_syn_backlog;
> =20
>  /** struct listen_sock - listen state
>   *
> diff --git a/net/core/request_sock.c b/net/core/request_sock.c
> index 182236b..e937e9c 100644
> --- a/net/core/request_sock.c
> +++ b/net/core/request_sock.c
> @@ -35,6 +35,9 @@
>  int sysctl_max_syn_backlog =3D 256;
>  EXPORT_SYMBOL(sysctl_max_syn_backlog);
> =20
> +int sysctl_min_syn_backlog =3D 8;
> +EXPORT_SYMBOL(sysctl_min_syn_backlog);
> +
>  int reqsk_queue_alloc(struct request_sock_queue *queue,
>  		      unsigned int nr_table_entries)
>  {
> @@ -42,7 +45,7 @@ int reqsk_queue_alloc(struct request_sock_queue *qu=
eue,
>  	struct listen_sock *lopt;
> =20
>  	nr_table_entries =3D min_t(u32, nr_table_entries, sysctl_max_syn_ba=
cklog);
> -	nr_table_entries =3D max_t(u32, nr_table_entries, 8);
> +	nr_table_entries =3D max_t(u32, nr_table_entries, sysctl_min_syn_ba=
cklog);
>  	nr_table_entries =3D roundup_pow_of_two(nr_table_entries + 1);
>  	lopt_size +=3D nr_table_entries * sizeof(struct request_sock *);
>  	if (lopt_size > PAGE_SIZE)

I believe you are mistaken.

The code you change is the code sizing the hash table, not
sk->sk_max_ack_backlog

This only matters if one application is able to change its listen
backlog during its lifetime.

Say, it begins with :

listen(fd, 1);

Then, a bit later :

listen(fd, 8192);

This certainly is very unlikely...

With current kernel, it does change the maximum SYN_RECV sockets in
flight, but hash table is not resized and stay with 8 slots, so
performance might be suboptimal, since chains are going to hold 1024
elements.



