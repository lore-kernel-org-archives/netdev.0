From: Brian Rak <brak@gameservers.com>
Subject: Re: [net PATCH] fib_trie: leaf_walk_rcu should not compute key if key
 is less than pn->key
Date: Tue, 27 Oct 2015 20:18:36 -0400
Message-ID: <5630145C.3020706@gameservers.com>
References: <20151027220352.1312.18265.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2015.choopa.net ([208.167.225.251]:55297 "EHLO
	mail2015.choopa.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754117AbbJ1ASj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 20:18:39 -0400
In-Reply-To: <20151027220352.1312.18265.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/27/2015 6:06 PM, Alexander Duyck wrote:
> We were computing the child index in cases where the key value we were
> looking for was actually less than the base key of the tnode.  As a result
> we were getting incorrect index values that would cause us to skip over
> some children.
>
> To fix this I have added a test that will force us to use child index 0 if
> the key we are looking for is less than the key of the current tnode.
>
> Fixes: 8be33e955cb9 ("fib_trie: Fib walk rcu should take a tnode and key instead of a trie and a leaf")
> Reported-by: Brian Rak <brak@gameservers.com>
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
> ---
>
> This will need to be queued up for stable as well.  This applies to 4.1 and
> 4.2 kernels as well.
>
>   net/ipv4/fib_trie.c |    2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
> index 6c2af797f2f9..744e5936c10d 100644
> --- a/net/ipv4/fib_trie.c
> +++ b/net/ipv4/fib_trie.c
> @@ -1569,7 +1569,7 @@ static struct key_vector *leaf_walk_rcu(struct key_vector **tn, t_key key)
>   	do {
>   		/* record parent and next child index */
>   		pn = n;
> -		cindex = key ? get_index(key, pn) : 0;
> +		cindex = (key > pn->key) ? get_index(key, pn) : 0;
>   
>   		if (cindex >> pn->bits)
>   			break;
>
Just built 4.2.5 with this patch, and everything works fine.  Thanks for 
your help!
