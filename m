From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] socket, bpf: fix sk_filter use after free in
 sk_clone_lock
Date: Wed, 22 Mar 2017 15:37:35 -0700 (PDT)
Message-ID: <20170322.153735.1284654162173125944.davem@davemloft.net>
References: <3016fb20a3666f0db138b85049f9000ecd33a1f6.1490184193.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45370 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751355AbdCVWhh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 18:37:37 -0400
In-Reply-To: <3016fb20a3666f0db138b85049f9000ecd33a1f6.1490184193.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed, 22 Mar 2017 13:08:08 +0100

> In sk_clone_lock(), we create a new socket and inherit most of the
> parent's members via sock_copy() which memcpy()'s various sections.
> Now, in case the parent socket had a BPF socket filter attached,
> then newsk->sk_filter points to the same instance as the original
> sk->sk_filter.
> 
> sk_filter_charge() is then called on the newsk->sk_filter to take a
> reference and should that fail due to hitting max optmem, we bail
> out and release the newsk instance.
> 
> The issue is that commit 278571baca2a ("net: filter: simplify socket
> charging") wrongly combined the dismantle path with the failure path
> of xfrm_sk_clone_policy(). This means, even when charging failed, we
> call sk_free_unlock_clone() on the newsk, which then still points to
> the same sk_filter as the original sk.
> 
> Thus, sk_free_unlock_clone() calls into __sk_destruct() eventually
> where it tests for present sk_filter and calls sk_filter_uncharge()
> on it, which potentially lets sk_omem_alloc wrap around and releases
> the eBPF prog and sk_filter structure from the (still intact) parent.
> 
> Fix it by making sure that when sk_filter_charge() failed, we reset
> newsk->sk_filter back to NULL before passing to sk_free_unlock_clone(),
> so that we don't mess with the parents sk_filter.
> 
> Only if xfrm_sk_clone_policy() fails, we did reach the point where
> either the parent's filter was NULL and as a result newsk's as well
> or where we previously had a successful sk_filter_charge(), thus for
> that case, we do need sk_filter_uncharge() to release the prior taken
> reference on sk_filter.
> 
> Fixes: 278571baca2a ("net: filter: simplify socket charging")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Applied and queued up for -stable, thanks Daniel.
