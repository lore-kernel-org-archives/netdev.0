From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: fix a race in ip4_datagram_release_cb()
Date: Wed, 11 Jun 2014 15:39:54 -0700 (PDT)
Message-ID: <20140611.153954.494439641088532676.davem@davemloft.net>
References: <CA+FTKhs45vD66xSQRgijwFjSuy-Mt8EGr3cRv60oCcEnFPKnaQ@mail.gmail.com>
	<1402407781.3645.426.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: preobr@google.com, dormando@rydia.net,
	steffen.klassert@secunet.com, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, kcc@google.com, dvyukov@google.com,
	larsbull@google.com, edumazet@google.com, brutus@google.com,
	maze@google.com, alexei.starovoitov@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47718 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752184AbaFKWjz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 18:39:55 -0400
In-Reply-To: <1402407781.3645.426.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 10 Jun 2014 06:43:01 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Alexey gave a AddressSanitizer[1] report that finally gave a good hint
> at where was the origin of various problems already reported by Dormando
> in the past [2]
> 
> Problem comes from the fact that UDP can have a lockless TX path, and
> concurrent threads can manipulate sk_dst_cache, while another thread,
> is holding socket lock and calls __sk_dst_set() in
> ip4_datagram_release_cb() (this was added in linux-3.8)
> 
> It seems that all we need to do is to use sk_dst_check() and
> sk_dst_set() so that all the writers hold same spinlock
> (sk->sk_dst_lock) to prevent corruptions.
> 
> TCP stack do not need this protection, as all sk_dst_cache writers hold
> the socket lock.
> 
> [1]
> https://code.google.com/p/address-sanitizer/wiki/AddressSanitizerForKernel
 ...
> Reported-by: Alexey Preobrazhensky <preobr@google.com>
> Reported-by: dormando <dormando@rydia.ne>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: 8141ed9fcedb2 ("ipv4: Add a socket release callback for datagram sockets")

Applied and queued up for -stable.
