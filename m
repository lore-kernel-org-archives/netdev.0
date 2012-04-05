From: Nuno Martins <nuno.martins@caixamagica.pt>
Subject: Re: [RFC PATCH 2/2] PID-based packet filtering support
Date: Thu, 5 Apr 2012 10:41:35 +0100
Message-ID: <CALKxAXVK9EhJiNOuq0JYqWiw75q3TYCScp+bGf-qqF_irKYtbA@mail.gmail.com>
References: <cover.1333466900.git.nuno.martins@caixamagica.pt>
	<19b9f7a0f38c1bab367da6f6cf622c8c2b3a4920.1333466900.git.nuno.martins@caixamagica.pt>
	<CAAsGZS4Ndue7pVOohEHyWimffZECbjVLF40wiGkGXTswJimPCA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Alfredo Matos <alfredo.matos@caixamagica.pt>,
	Paulo Trezentos <paulo.trezentos@caixamagica.pt>
To: chetan loke <loke.chetan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:50817 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753913Ab2DEJlh convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Apr 2012 05:41:37 -0400
Received: by lahj13 with SMTP id j13so1293167lah.19
        for <netdev@vger.kernel.org>; Thu, 05 Apr 2012 02:41:35 -0700 (PDT)
In-Reply-To: <CAAsGZS4Ndue7pVOohEHyWimffZECbjVLF40wiGkGXTswJimPCA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4 April 2012 18:01, chetan loke <loke.chetan@gmail.com> wrote:
> On Wed, Apr 4, 2012 at 5:16 AM, Nuno Martins
> <nuno.martins@caixamagica.pt> wrote:
>
>> =A0net/pidmonitor/Makefile =A0 =A0 =A0 =A0 =A0 | =A0 =A03 +
>
> might make sense to prefix files with 'net' tag. Like: net_pidmonitor=
,
> net_proc_monitor.c etc. Because proc_monitor is too generic.
>

Good point, will refactor it.

>
>> +static int is_equal_packet_info(struct packetInfo *pi,
>
> It should be 'packet_info' and not 'packetInfo'. Init-char convention
> is not used in linux. same goes for portInfo and other structs(if
> any).
>
>

Thanks for spotting that. Will be fixed in our tree.


>> +static int insert_address(struct packetInfo *lpi, struct portInfo *=
port_info)
>> +{
>> +
>> + =A0 =A0 =A0 switch (lpi->protocol) {
>> + =A0 =A0 =A0 case IPPROTO_TCP:
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!(port_info->tcp)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 port_info->tcp =3D kma=
lloc(sizeof(struct local_addresses_list), GFP_KERNEL);
>
> Do you think it might make sense to pre-alloc a list? or
> managing/growing that list would add more pain/code than it's worth?
> I'm just thinking in terms of search scalability when memory is
> fragmented and we have lots of nodes in the tree.But I'm sure you
> must've done some light tests.
>
>
>> +static struct portInfo *create_packet_info(struct packetInfo *lpi)
>> +{
>> + =A0 =A0 =A0 struct portInfo *pi =3D NULL;
>> + =A0 =A0 =A0 pi =3D kmalloc(sizeof(*pi), GFP_KERNEL);
>> +
>> + =A0 =A0 =A0 if (!pi)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
>> +
>> + =A0 =A0 =A0 pi->port =3D lpi->port;
>> + =A0 =A0 =A0 pi->tcp =3D NULL;
>> + =A0 =A0 =A0 pi->tcp_list_counter =3D 0;
>> + =A0 =A0 =A0 pi->udp =3D NULL;
>> + =A0 =A0 =A0 pi->udp_list_counter =3D 0;
>> +
>> + =A0 =A0 =A0 insert_address(lpi, pi);
>> +
>> + =A0 =A0 =A0 return pi;
>> +}
>> +


Our tests with 1024 node tree gives us something like 1.3 us on
average. Your suggestion makes a lot of sense, and we will definitely
look into.
This doesn't seem hard to do as we are considering introducing a pid
based hash table, with a tree in each entry, which can and possibly
should be pre-allocated.


>
> Just thinking out loud - what if packet_info and pid were introduced
> as part of struct sock or something? The no need to kmalloc.
> And at the end of the bind/accept/other-calls-you-intercept-via-probe=
s
> you can populate the structs. Then the kprobes could go away too. But
> I know nothing about BPF so I can't really comment for sure.

That's also a good approach. We will look into it.

>
>
> Chetan

Thank you very much for your feedback

Nuno Martins
