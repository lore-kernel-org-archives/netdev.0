From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] udp4: Don't take socket reference in receive path
Date: Thu, 06 Feb 2014 12:58:58 -0800
Message-ID: <1391720338.10160.12.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1402061154580.17707@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, edumazet@google.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:37149 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751297AbaBFU7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 15:59:00 -0500
Received: by mail-pd0-f169.google.com with SMTP id v10so2203028pde.0
        for <netdev@vger.kernel.org>; Thu, 06 Feb 2014 12:59:00 -0800 (PST)
In-Reply-To: <alpine.DEB.2.02.1402061154580.17707@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-02-06 at 11:58 -0800, Tom Herbert wrote:
> The reference counting in the UDP receive path is quite expensive for
> a socket that is share amoungst CPUs. This is probably true for normal
> sockets, but really is painful when just using the socket for
> receive encapsulation.
> 
> udp4_lib_lookup always takes a socket reference, and we also put back
> the reference after calling udp_queue_rcv_skb in the normal receive
> path, so the need for taking the reference seems to be to hold the
> socket after doing rcu_read_unlock. This patch modifies udp_lib_lookup
> to optionally take a reference and is always called with rcu_read_lock.
> In udp4_lib_rcv we call lib_lookup and udp_queue_rcv under the
> rcu_read_lock but without having taken the reference.
> 
> Requesting comments because I suspect there are nuances to this!
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---

Unfortunately this cant work.

When I did the RCU implementation for TCP/UDP, we chose to use
SLAB_DESTROY_BY_RCU.

This meant we have to take a reference, then check again the keys for
the lookup.

If we remove SLAB_DESTROY_BY_RCU, we kill performance for short lived
sessions, because of call_rcu() added latencies.

(One UDP socket is about 1024 bytes in memory, call_rcu() grace period
is throwing away 1024 bytes from cpu caches)

Sure, in your case you know your udp sessions are not short lived,
but many applications used UDP for DNS lookups, using few packets per
socket.
