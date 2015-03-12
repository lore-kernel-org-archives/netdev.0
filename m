From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: add real socket cookies
Date: Wed, 11 Mar 2015 18:31:42 -0700
Message-ID: <1426123902.11398.120.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1426027533.11398.18.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150311.175345.836846566788322568.davem@davemloft.net>
	 <1426113035.11398.90.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150311.212112.908171202958424986.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, salo@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:36211 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181AbbCLBbp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 21:31:45 -0400
Received: by iegc3 with SMTP id c3so8374721ieg.3
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 18:31:45 -0700 (PDT)
In-Reply-To: <20150311.212112.908171202958424986.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-03-11 at 21:21 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 11 Mar 2015 15:30:35 -0700
> 
> > Note that sk_clone_lock() really does the clear for us :
> > 
> > net/core/sock.c:1541:		atomic64_set(&newsk->sk_cookie, 0);
> > 
> > atomic_cmpxchg() is needed here in case a concurrent dumper already
> > caught the new socket.
> 
> How is newsk visible at this moment?
> 
> It is freshly allocated, and not present in any tables.  Nothing even
> indirectly links to it at this point.
> 
> Visibility only happens after we return from this function, in
> routines such as tcp_v4_syn_recv_sock() which do the hash table
> insertion.

Yes, but remember we use RCU with SLAB_DESTROY_BY_RCU thing,
and inet_diag_dump_one_icsk() uses RCU as well.

I wanted to be extra careful here. Note that with v2, this
atomic_cmpxchg() wont happen unless one dump operation previously
revealed the SYN_RECV to the world.

I have no strong opinion and definitely it is currently safe to use
atomic64_set() here.
