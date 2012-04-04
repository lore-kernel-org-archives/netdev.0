From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [RFC PATCH 2/2] PID-based packet filtering support
Date: Wed, 4 Apr 2012 13:01:50 -0400
Message-ID: <CAAsGZS4Ndue7pVOohEHyWimffZECbjVLF40wiGkGXTswJimPCA@mail.gmail.com>
References: <cover.1333466900.git.nuno.martins@caixamagica.pt>
	<19b9f7a0f38c1bab367da6f6cf622c8c2b3a4920.1333466900.git.nuno.martins@caixamagica.pt>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Alfredo Matos <alfredo.matos@caixamagica.pt>,
	Paulo Trezentos <paulo.trezentos@caixamagica.pt>
To: Nuno Martins <nuno.martins@caixamagica.pt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f52.google.com ([209.85.210.52]:53136 "EHLO
	mail-pz0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756854Ab2DDRBv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 13:01:51 -0400
Received: by dake40 with SMTP id e40so496541dak.11
        for <netdev@vger.kernel.org>; Wed, 04 Apr 2012 10:01:50 -0700 (PDT)
In-Reply-To: <19b9f7a0f38c1bab367da6f6cf622c8c2b3a4920.1333466900.git.nuno.martins@caixamagica.pt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 4, 2012 at 5:16 AM, Nuno Martins
<nuno.martins@caixamagica.pt> wrote:

> =C2=A0net/pidmonitor/Makefile =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=
=A0 =C2=A03 +

might make sense to prefix files with 'net' tag. Like: net_pidmonitor,
net_proc_monitor.c etc. Because proc_monitor is too generic.


> +static int is_equal_packet_info(struct packetInfo *pi,

It should be 'packet_info' and not 'packetInfo'. Init-char convention
is not used in linux. same goes for portInfo and other structs(if
any).


> +static int insert_address(struct packetInfo *lpi, struct portInfo *p=
ort_info)
> +{
> +
> + =C2=A0 =C2=A0 =C2=A0 switch (lpi->protocol) {
> + =C2=A0 =C2=A0 =C2=A0 case IPPROTO_TCP:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!(port_info->t=
cp)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 port_info->tcp =3D kmalloc(sizeof(struct local_addresses_list),=
 GFP_KERNEL);

Do you think it might make sense to pre-alloc a list? or
managing/growing that list would add more pain/code than it's worth?
I'm just thinking in terms of search scalability when memory is
fragmented and we have lots of nodes in the tree.But I'm sure you
must've done some light tests.


> +static struct portInfo *create_packet_info(struct packetInfo *lpi)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct portInfo *pi =3D NULL;
> + =C2=A0 =C2=A0 =C2=A0 pi =3D kmalloc(sizeof(*pi), GFP_KERNEL);
> +
> + =C2=A0 =C2=A0 =C2=A0 if (!pi)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return NULL;
> +
> + =C2=A0 =C2=A0 =C2=A0 pi->port =3D lpi->port;
> + =C2=A0 =C2=A0 =C2=A0 pi->tcp =3D NULL;
> + =C2=A0 =C2=A0 =C2=A0 pi->tcp_list_counter =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 pi->udp =3D NULL;
> + =C2=A0 =C2=A0 =C2=A0 pi->udp_list_counter =3D 0;
> +
> + =C2=A0 =C2=A0 =C2=A0 insert_address(lpi, pi);
> +
> + =C2=A0 =C2=A0 =C2=A0 return pi;
> +}
> +

Just thinking out loud - what if packet_info and pid were introduced
as part of struct sock or something? The no need to kmalloc.
And at the end of the bind/accept/other-calls-you-intercept-via-probes
you can populate the structs. Then the kprobes could go away too. But
I know nothing about BPF so I can't really comment for sure.


Chetan
