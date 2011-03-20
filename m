From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] socket: increase default maximum listen queue length
Date: Sun, 20 Mar 2011 09:30:17 +0100
Message-ID: <1300609817.2831.56.camel@edumazet-laptop>
References: <1300585811-21566-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:53589 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750903Ab1CTIaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Mar 2011 04:30:22 -0400
Received: by wwa36 with SMTP id 36so6333623wwa.1
        for <netdev@vger.kernel.org>; Sun, 20 Mar 2011 01:30:20 -0700 (PDT)
In-Reply-To: <1300585811-21566-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 20 mars 2011 =C3=A0 02:50 +0100, Hagen Paul Pfeifer a =C3=A9=
crit :
> sysctl_somaxconn (SOMAXCONN: 128) specifies the maximum number of
> sockets in state SYN_RECV per listen socket queue. At listen(2) time =
the
> backlog is adjusted to this limit if bigger then that.
>=20
> Afterwards in reqsk_queue_alloc() the backlog value is checked again
> (nr_table_entries =3D=3D backlog):
>=20
>     nr_table_entries =3D min_t(u32, nr_table_entries, sysctl_max_syn_=
backlog);
>     nr_table_entries =3D max_t(u32, nr_table_entries, 8);
>     nr_table_entries =3D roundup_pow_of_two(nr_table_entries + 1);
>=20
> sysctl_max_syn_backlog on the other hand is dynamically adjusted,
> depending on the memory characteristic of the system. Default is 256,
> 128 for small systems and up to 1024 for bigger systems.
>=20
> For real server work the defacto sysctl_somaxconn limit seems inadequ=
ate:
>=20
>     Experiments with real servers show, that it is absolutely not eno=
ugh
>     even at 100conn/sec. 256 cures most of problems.
>=20
> Increase default sysctl_somaxconn from 128 to 256 to meet todays cond=
ition by
> simultaneously limit nr_table_entries by sysctl_max_syn_backlog which=
 is
> based on memory condition (max(128, (tcp_hashinfo.ehash_mask + 1 / 25=
6)).
>=20
> Signed_off-by: Hagen Paul Pfeifer <hagen@jauu.net>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  include/linux/socket.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/include/linux/socket.h b/include/linux/socket.h
> index edbb1d0..bf35ce2 100644
> --- a/include/linux/socket.h
> +++ b/include/linux/socket.h
> @@ -237,7 +237,7 @@ struct ucred {
>  #define PF_MAX		AF_MAX
> =20
>  /* Maximum queue length specifiable by listen.  */
> -#define SOMAXCONN	128
> +#define SOMAXCONN	256
> =20
>  /* Flags we can use with send/ and recv.=20
>     Added those for 1003.1g not all are supported yet


Hmm, real problem is not the 'maximum queue value', but the minimum one=
=2E

If application says : listen(fd, 10), you are stuck.

128 or 256 is way too small on some servers, where admin can tune
in /etc/sysctl.conf :

net.core.somaxconn =3D 8192
net.ipv4.tcp_max_syn_backlog =3D 8192

But application also needs to use : listen(fd, 8192)



