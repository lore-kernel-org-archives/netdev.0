From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 2/2 v4] xps: Transmit Packet Steering
Date: Mon, 1 Nov 2010 18:15:46 -0700
Message-ID: <AANLkTik1JumZon9JJcNjQvbTETZPfiBmpsSDdTybLyKb@mail.gmail.com>
References: <alpine.DEB.1.00.1010262033520.2997@pokey.mtv.corp.google.com>
	<1288153966.2652.62.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:20261 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752461Ab0KBBPu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Nov 2010 21:15:50 -0400
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id oA21FnNu014311
	for <netdev@vger.kernel.org>; Mon, 1 Nov 2010 18:15:49 -0700
Received: from pwj2 (pwj2.prod.google.com [10.241.219.66])
	by hpaq12.eem.corp.google.com with ESMTP id oA21FlAA013275
	for <netdev@vger.kernel.org>; Mon, 1 Nov 2010 18:15:47 -0700
Received: by pwj2 with SMTP id 2so1494325pwj.8
        for <netdev@vger.kernel.org>; Mon, 01 Nov 2010 18:15:47 -0700 (PDT)
In-Reply-To: <1288153966.2652.62.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> +struct xps_map {
>> + =A0 =A0 unsigned int len;
>> + =A0 =A0 unsigned int alloc_len;
>> + =A0 =A0 struct rcu_head rcu;
>> + =A0 =A0 u16 queues[0];
>> +};
>
> OK, so its a 'small' structure. And we dont want it to share a cache
> line with an other user in the kernel, or false sharing might happen.
>
> Make sure you allocate big enough ones to fill a full cache line.
>
> alloc_len =3D (L1_CACHE_BYTES - sizeof(struct xps_map)) / sizeof(u16)=
;
>
> I see you allocate ones with alloc_len =3D 1. Thats not good.
>
Okay.

>> +
>> +/*
>> + * This structure holds all XPS maps for device. =A0Maps are indexe=
d by CPU.
>> + */
>> +struct xps_dev_maps {
>> + =A0 =A0 struct rcu_head rcu;
>> + =A0 =A0 struct xps_map *cpu_map[0];
>
> Hmm... per_cpu maybe, instead of an array ?
>
The cpu_map is an array of pointers to the actual maps, and I wouldn't
expect those pointers to be changing so maybe that's okay for the
cache.  We still need the rcu head, and making cpu_map per-cpu (struct
xps_map **) would add another level of indirection.  Is there a
compelling reason to use per-cpu here?

> Also make sure this xps_dev_maps use a full cache line, to avoid fals=
e
> sharing.
>
Okay.



> Really I am not sure we need this array and smp_processor_id().
> Please consider alloc_percpu().
> Then, use __this_cpu_ptr() and avoid the preempt_disable()/enable()
> thing. Its a hint we want to use, because as soon as we leave
> get_xps_queue() we might migrate to another cpu ?

If we don't use per-cpu, how about raw_smp_processor_id() here?


>> + =A0 =A0 if (dev_maps) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D 0; i < num_possible_cpus(); i++=
) {
>
> The use of num_possible_cpus() seems wrong to me.
> Dont you meant nr_cpu_ids ?
>

Okay, thanks for clarifying.

> Some machines have two possible cpus, numbered 0 and 8 :
> num_possible_cpus =3D 2
> nr_cpu_ids =3D 8
>
>
