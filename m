From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Question]: reqsk table size limited to 16?
Date: Fri, 02 Oct 2009 08:49:46 +0200
Message-ID: <4AC5A28A.6060104@gmail.com>
References: <20091002061134.GC5646@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:55042 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756883AbZJBGto (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 02:49:44 -0400
In-Reply-To: <20091002061134.GC5646@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gerrit Renker a =E9crit :
> Can someone please have a look, it may be that I am missing something=
?
>=20
> It seems that in the following the maximum number of table entries is=
 set
> to always 16, despite sysctl_max_syn_backlog (tcp_max_syn_backlog),=20
> overriding the 'backlog' parameter to listen(2).

=46alse alarm ;)

>=20
> net/core/request_sock.c
> -----------------------
>=20
> int reqsk_queue_alloc(struct request_sock_queue *queue,
>                       unsigned int nr_table_entries)
> {
>         size_t lopt_size =3D sizeof(struct listen_sock);
>         struct listen_sock *lopt;
>=20
> 	nr_table_entries =3D min_t(u32, nr_table_entries, sysctl_max_syn_bac=
klog);

Here we take the _minimum_ value.
If you have  nr_table_entries=3D4096 and sysctl_max_syn_backlog=3D1024,
result is 1024

>         nr_table_entries =3D max_t(u32, nr_table_entries, 8);

Here we take the _maximum_ value of nr_table_entries and 8

-> 1024

Deal is : We want at least 8 slots, even if users called listen(fd, 1);

(Later, user can change its mind and call listen(fd, 1024).

We dont resize hashtable yet, so we guarantee at least 8 slots fot path=
ological cases.

>         nr_table_entries =3D roundup_pow_of_two(nr_table_entries + 1)=
;
>=20
> 	//...
> 	for (lopt->max_qlen_log =3D 3;
>              (1 << lopt->max_qlen_log) < nr_table_entries;
>              lopt->max_qlen_log++);
>=20
>  	//...
> 	lopt->nr_table_entries =3D nr_table_entries;
> =09
> 	//...
> 	return 0
> }
>=20
> The function is called with an argument 'nr_table_entries', which is =
then clamped as
>=20
>    sysctl_max_syn_backlog <=3D nr_table_entries <=3D 8
>=20
> If nr_table_entries =3D 8, then round_pow_of_two(8 + 1) =3D 16.
>=20
> The sysctl value is set to a much higher value (default 128 or 1024, =
net/ipv4/tcp.c).
>=20
> The reqsk_queue_alloc() gets 'nr_table_entries' passed directly from =
inet_csk_listen_start(),
> which in turn gets its 'nr_table_entries' as the 'backlog' argument t=
o listen(2) via
>  * net/dccp/proto.c   (dccp_listen_start) or
>  * net/ipv4/af_inet.c (inet_listen).

