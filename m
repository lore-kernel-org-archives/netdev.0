From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 1/2] rps: core implementation
Date: Wed, 11 Nov 2009 08:28:07 -0800
Message-ID: <65634d660911110828j402fbed0m4a0ceb903e3ee638@mail.gmail.com>
References: <65634d660911102253o2b4f7a19kfed5849e5c88bfe1@mail.gmail.com>
	 <4AFA73DA.30308@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:61784 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755652AbZKKQ2I convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 11:28:08 -0500
Received: from zps38.corp.google.com (zps38.corp.google.com [172.25.146.38])
	by smtp-out.google.com with ESMTP id nABGSBD2031637
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2009 16:28:12 GMT
Received: from iwn16 (iwn16.prod.google.com [10.241.68.80])
	by zps38.corp.google.com with ESMTP id nABGR9pt029690
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2009 08:28:09 -0800
Received: by iwn16 with SMTP id 16so1052870iwn.29
        for <netdev@vger.kernel.org>; Wed, 11 Nov 2009 08:28:08 -0800 (PST)
In-Reply-To: <4AFA73DA.30308@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I must say this is really exciting :)
>
Thanks!


>> +/* Maximum size of RPS map (for allocation) */
>> +#define RPS_MAP_SIZE (sizeof(struct rps_map) + \
>> + =A0 =A0(num_possible_cpus() * sizeof(u16)))
>> +
>
> Problem of possible cpus is the number can be very large on some arch=
es,
> but yet few cpus online....
>
> In this kind of situation, get_rps_cpu() will return -1 most of the t=
ime,
> defeating goal of RPS ?
>
I suppose it would make sense to either use num_online_cpus or simply
put a reasonable limit on it (like HW RSS hash tables are 128 entries
I believe).


>> + =A0 =A0 hash =3D jhash_3words(addr1, addr2, ports, simple_hashrnd)=
;
>
> I wonder if you tried to exchange addr1/addr2 =A0port1/port2 so that =
conntracking/routing
> is also speedup ...
>
> ie make sure hash will be the same regardless of the direction of pac=
ket.
>
> union {
> =A0 =A0 =A0 =A0u32 port;
> =A0 =A0 =A0 =A0u16 ports[2];
> } p;
>
> if (addr1 < addr2)
> =A0 =A0 =A0 =A0swap(addr1, addr2);
>
> if (p.ports[0] < p.ports[1]);
> =A0 =A0 =A0 =A0swap(p.ports[0], p.ports[1]);
>
I have not considered that.  How much of a win would this be?

> hash =3D jhash_3words(addr1, addr2, ports, simple_hashrnd);
>
Another possibility we considered was to call inet_hashfn and
inet6_ehashfn directly to get the hash, and store that value in
skb->rxhash and use it later on connection lookup in tcp_v4_rcv to
eliminate to another jhash.  This has some benefit, but it doesn't
help if we get different type of hash from HW (using that is a much
bigger win), and also we needed to pull in more IP header files into
dev.c.

>
> I think I'll try to extend your patches with TX completion recycling =
too.
>
> Ie record in skb the cpu number of original sender, and queue skb to
> remote queue for destruction (sock_wfree() call and expensive schedul=
er calls...)
>
We also have implemented a form of that if you are interested.  In
dev_kfree_skb put the skb on the completion list the origin CPU of the
skb (where it was allocated) and use the remote softirq to schedule
processing.

Tom
