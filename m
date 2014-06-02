From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 net-next] inetpeer: get rid of ip_id_count
Date: Sun, 01 Jun 2014 19:01:47 -0700 (PDT)
Message-ID: <20140601.190147.889157989845313443.davem@davemloft.net>
References: <1401668284.3645.165.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55293 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752694AbaFBCBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2014 22:01:48 -0400
In-Reply-To: <1401668284.3645.165.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 01 Jun 2014 17:18:04 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Ideally, we would need to generate IP ID using a per destination IP
> generator.
> 
> linux kernels used inet_peer cache for this purpose, but this had a huge
> cost on servers disabling MTU discovery.
> 
> 1) each inet_peer struct consumes 192 bytes
> 
> 2) inetpeer cache uses a binary tree of inet_peer structs,
>    with a nominal size of ~66000 elements under load.
> 
> 3) lookups in this tree are hitting a lot of cache lines, as tree depth
>    is about 20.
> 
> 4) If server deals with many tcp flows, we have a high probability of
>    not finding the inet_peer, allocating a fresh one, inserting it in
>    the tree with same initial ip_id_count, (cf secure_ip_id())
> 
> 5) We garbage collect inet_peer aggressively.
> 
> IP ID generation do not have to be 'perfect'
> 
> Goal is trying to avoid duplicates in a short period of time,
> so that reassembly units have a chance to complete reassembly of
> fragments belonging to one message before receiving other fragments
> with a recycled ID.
> 
> We simply use an array of generators, and a Jenkin hash using the dst IP
> as a key.
> 
> ipv6_select_ident() is put back into net/ipv6/ip6_output.c where it
> belongs (it is only used from this file)
> 
> secure_ip_id() and secure_ipv6_id() no longer are needed.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
> Note: Based on current net-next, but needs a respin or merge resolution
> after other patch [1] is merged.

I like it.

I think we should get rid of the 'dst' argument from __ip_select_ident() (and thus
ip_select_ident() and ip_select_ident_mode()), it is completely unused.

It might even help to do so for ipv6_select_ident(), having it just pass the
dest addr pointer in instead.
