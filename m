From: Firo Yang <firogm@gmail.com>
Subject: Re: [PATCH] fib_trie: Fix potential null pointer dereference
Date: Sun, 7 Jun 2015 12:46:35 +0800
Message-ID: <20150607044635.GA3515@firo>
References: <1433590553-4672-1-git-send-email-firogm@gmail.com>
 <1433592304.1895.73.camel@edumazet-glaptop2.roam.corp.google.com>
 <5573B7A2.4010607@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33429 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbbFGEqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jun 2015 00:46:33 -0400
Content-Disposition: inline
In-Reply-To: <5573B7A2.4010607@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 06, 2015 at 08:16:50PM -0700, Alexander Duyck wrote:
>On 06/06/2015 05:05 AM, Eric Dumazet wrote:
>>On Sat, 2015-06-06 at 19:35 +0800, Firo Yang wrote:
>>>A smatch warning.
>>>When kmem_cache_alloc() failed to alloc memory, a null pointer
>>>will be returned. Redeference null pointer will generate
>>
>>Dereferencing a null pointer will crash.
>>
>>>an unnecessary oops. So, use it after check.
>>>
>>>Signed-off-by: Firo Yang <firogm@gmail.com>
>>>---
>>>  net/ipv4/fib_trie.c | 3 ++-
>>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>>
>>>diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
>>>index 01bce15..34094c7 100644
>>>--- a/net/ipv4/fib_trie.c
>>>+++ b/net/ipv4/fib_trie.c
>>>@@ -326,12 +326,13 @@ static inline void empty_child_dec(struct key_vector *n)
>>>  static struct key_vector *leaf_new(t_key key, struct fib_alias *fa)
>>>  {
>>>  	struct tnode *kv = kmem_cache_alloc(trie_leaf_kmem, GFP_KERNEL);
>>>-	struct key_vector *l = kv->kv;
>>>+	struct key_vector *l;
>>>  	if (!kv)
>>>  		return NULL;
>>>  	/* initialize key vector */
>>>+	l = kv->kv;
>>>  	l->key = key;
>>>  	l->pos = 0;
>>>  	l->bits = 0;
>>Fixes: dc35dbeda3e0 ("fib_trie: Add tnode struct as a container for fields not needed in key_vector")
>>Acked-by: Eric Dumazet <edumazet@google.com>
>>
>>Thanks.
>
>kv->kv isn't a dereference.  kv is an array contained within the tnode.
>Below is the layout of struct tnode:
>
>|
>struct  tnode{
>	struct  rcu_head rcu;
>	t_key empty_children;		/* KEYLENGTH bits needed */
>	t_key full_children;		/* KEYLENGTH bits needed */
>	struct  key_vector __rcu*parent;
>	struct  key_vector kv[1];
>#define tn_bits kv[0].bits
>};|
>
>
>As such kv->kv doesn't actually dereference anything, it is simply a means
>for getting the offset to the array from the pointer kv.  It should be
>equivalent to &kv->kv[0] which last I knew was how the offsetof macro
>basically worked and it uses a NULL pointer.  The first actual derference
>occurs at "l->key = key" which should be safe since writing to a memory
>location has side effects so the compiler cannot reorder the writes before
>the !kv check.
>
>The patch itself is fine.  However what it is fixing is the smatch false
>positive, not a null pointer deference.  As such you may need to update the
>comments to reflect that.

Thanks Alex for firguring out my false cognition!
I will update the patch with new comments.

Firo

>
>- Alex
>
>

-- 
