From: Tom Herbert <therbert@google.com>
Subject: Re: [RFC PATCH] udp4: Don't take socket reference in receive path
Date: Thu, 6 Feb 2014 14:40:17 -0800
Message-ID: <CA+mtBx9Zovogvnc0_J2Xrf-B+yjxV4Of-24SDLNTt5WGsL5Qhw@mail.gmail.com>
References: <alpine.DEB.2.02.1402061154580.17707@tomh.mtv.corp.google.com>
	<1391720338.10160.12.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f47.google.com ([209.85.212.47]:63190 "EHLO
	mail-vb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757038AbaBFWkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 17:40:18 -0500
Received: by mail-vb0-f47.google.com with SMTP id p6so1956027vbe.20
        for <netdev@vger.kernel.org>; Thu, 06 Feb 2014 14:40:18 -0800 (PST)
In-Reply-To: <1391720338.10160.12.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 6, 2014 at 12:58 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2014-02-06 at 11:58 -0800, Tom Herbert wrote:
>> The reference counting in the UDP receive path is quite expensive for
>> a socket that is share amoungst CPUs. This is probably true for normal
>> sockets, but really is painful when just using the socket for
>> receive encapsulation.
>>
>> udp4_lib_lookup always takes a socket reference, and we also put back
>> the reference after calling udp_queue_rcv_skb in the normal receive
>> path, so the need for taking the reference seems to be to hold the
>> socket after doing rcu_read_unlock. This patch modifies udp_lib_lookup
>> to optionally take a reference and is always called with rcu_read_lock.
>> In udp4_lib_rcv we call lib_lookup and udp_queue_rcv under the
>> rcu_read_lock but without having taken the reference.
>>
>> Requesting comments because I suspect there are nuances to this!
>>
>> Signed-off-by: Tom Herbert <therbert@google.com>
>> ---
>
> Unfortunately this cant work.
>
> When I did the RCU implementation for TCP/UDP, we chose to use
> SLAB_DESTROY_BY_RCU.
>
> This meant we have to take a reference, then check again the keys for
> the lookup.
>
> If we remove SLAB_DESTROY_BY_RCU, we kill performance for short lived
> sessions, because of call_rcu() added latencies.
>
Thanks for the explanation.

> (One UDP socket is about 1024 bytes in memory, call_rcu() grace period
> is throwing away 1024 bytes from cpu caches)
>
> Sure, in your case you know your udp sessions are not short lived,
> but many applications used UDP for DNS lookups, using few packets per
> socket.
>
The rationale for SLAB_DESTROY_BY_RCU might be different for UDP than
TCP. For instance, in the DNS example small connected UDP flows are
more an issue on the client, the server (which is likely to have much
greater load) should be using unconnected sockets.

In any case, I am still looking for a way to address this. Like I said
in the commit log, this per packet cost for UDP processing is far too
high at least in encapsulation path. I thought about extending
SO__REUSEPORT to provide CPU affinity but that seems like overkill
with its own performance implications. Alternatively, we could have
fast path for the encapsulation using UDP offload model which bypass
sockets completely which seems unpleasant.

>
>
