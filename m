From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: questions on NAPI processing latency and dropped network packets
Date: Mon, 14 Jan 2008 20:33:24 +0100
Message-ID: <478BB904.3060903@cosmosbay.com>
References: <478654C3.60806@nortel.com> <2c0942db0801112137k3f3f885ek212d5cbaecb7fea0@mail.gmail.com> <478B8473.6080506@nortel.com> <478B943C.7080009@cosmosbay.com> <478BB722.1020004@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ray Lee <ray-lk@madrabbit.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2a.orange.fr ([80.12.242.139]:31174 "EHLO smtp2a.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750801AbYANTde convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 14:33:34 -0500
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf2a06.orange.fr (SMTP Server) with ESMTP id 8122E700008B
	for <netdev@vger.kernel.org>; Mon, 14 Jan 2008 20:33:33 +0100 (CET)
In-Reply-To: <478BB722.1020004@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Friesen a =C3=A9crit :
> Eric Dumazet wrote:
>> Chris Friesen a =C3=A9crit :
>
>>> Based on profiling and instrumentation it seems like the cost of=20
>>> sctp_endpoint_lookup_assoc() more than triples, which means that th=
e=20
>>> amount of time that bottom halves are disabled in that function als=
o=20
>>> triples.
>>
>> Any idea of the size of sctp hash size you have ?
>> (your dmesg probably includes a message starting with SCTP: Hash=20
>> tables configured...
>> How many concurrent sctp sockets are handled ?
>
> Our lab is currently rebooting, but I'll try and get this once it's=20
> back up.
>
>> Maybe sctp_assoc_hashfn() is too weak for your use, and some chains=20
>> are *really* long.
>
> Based on the profiling information we're spending time in=20
> sctp_endpoint_lookup_assoc() which doesn't actually use hashes, so I=20
> can't see how the hash would be related.  I'm pretty new to SCTP=20
> though, so I may be missing something.
Well, it does use hashes :)

        hash =3D sctp_assoc_hashfn(ep->base.bind_addr.port, rport);
        head =3D &sctp_assoc_hashtable[hash];
        read_lock(&head->lock);
        sctp_for_each_hentry(epb, node, &head->chain) {
            /* maybe your machine is traversing here a *really* long=20
chain */
            }

>
> Here's the top results from readprofile, unfortunately these are=20
> aggregated across both cpus so they don't really show what's going on=
=2E=20
> The key thing is that sctp_endpoint_lookup_assoc() is the most=20
> expensive kernel routine on this entire system.
>
>   3147 .power4_idle                              22.4786
>   1712 .native_idle                              20.3810
>   1234 .sctp_endpoint_lookup_assoc                2.1725

>   1212 ._spin_unlock_irqrestore                   6.4468
>    778 .do_futex                                  0.3791
>    447 ._spin_unlock_irq                          4.2981
>    313 .fget                                      1.7784
>    277 .fput                                      3.8472
>    275 .kfree                                     0.7473
>    234 .__kmalloc                                 0.5571
>    131 SystemCall_common                          0.3411
>    130 .sctp_assoc_is_match                       0.6373
>    123 .lock_sock                                 0.4155
>    119 .find_vma                                  0.6919
>    116 .kmem_cache_alloc                          0.3580
>    111 .kmem_cache_free                           0.3343
>    106 .skb_release_data                          0.4907
>    102 .__copy_tofrom_user                        0.0724
>    100 .exit_elf_binfmt                           1.9231
>    100 .do_select                                 0.0820
>
>
> Chris
> --=20
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>




