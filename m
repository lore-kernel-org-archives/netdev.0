From: =?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: [PATCH net-2.6] Re: rib_trie / Fix inflate_threshold_root.	Now=15
 size=11 bits
Date: Mon, 29 Jun 2009 18:24:47 +0200
Message-ID: <4A48EACF.30903@itcare.pl>
References: <20090629083315.GA4712@ff.dom.local> <4A488EB8.4070602@itcare.pl> <20090629104703.GC4712@ff.dom.local>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040102070201090706050302"
Cc: David Miller <davem@davemloft.net>,
	Robert Olsson <robert@robur.slu.se>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	"Jorge Boncompte [DTI2]" <jorge@dti2.net>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Robert Olsson <robert.olsson@its.uu.se>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:49489 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751486AbZF2QYr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jun 2009 12:24:47 -0400
In-Reply-To: <20090629104703.GC4712@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040102070201090706050302
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 8bit

Jarek Poplawski pisze:
> On Mon, Jun 29, 2009 at 11:51:52AM +0200, Pawe³ Staszewski wrote:
>   
>> I apply this patch
>>
>> fib_triestats in attached file :)
>>     
>
> Great! But it would be nice to check if this (accidentally ;-) might
> fix the previous problem, so I attach below the patch with "manual
> RCU", which btw. (or even more important) should verify RCU use here.
>
>   
After this patches all is OK now i don't see Fix inflate_threshold_root.
Even if i make "clear ip bgp * "

Before this patches when i make clear ip bgp there was always info in 
dmesg about "Fix inflate_threshold_root"


> It should be applied on top of this last "Fix..., part3". And
> again: it's quite probable it can fail, so with caution, no hurry
> (it can wait for quiet time)...
>
>   
After apply this last patch - traffic is not forwarded again :)
i was fast and have only some fib_triestats in attached file before 
failover switch routers.

This stats are from machine with this last patch that makes kernel to 
stop forwarding


> Many thanks,
> Jarek P.
> --------------------> (synchronize_rcu take 4)
>
> diff -Nurp a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
> --- a/net/ipv4/fib_trie.c	2009-06-29 10:00:14.000000000 +0000
> +++ b/net/ipv4/fib_trie.c	2009-06-29 10:04:22.000000000 +0000
> @@ -366,6 +366,17 @@ static void __tnode_vfree(struct work_st
>  	vfree(tn);
>  }
>  
> +static void __tnode_free(struct tnode *tn)
> +{
> +	size_t size = sizeof(struct tnode) +
> +		      (sizeof(struct node *) << tn->bits);
> +
> +	if (size <= PAGE_SIZE)
> +		kfree(tn);
> +	else
> +		vfree(tn);
> +}
> +
>  static void __tnode_free_rcu(struct rcu_head *head)
>  {
>  	struct tnode *tn = container_of(head, struct tnode, rcu);
> @@ -402,7 +413,7 @@ static void tnode_free_flush(void)
>  	while ((tn = tnode_free_head)) {
>  		tnode_free_head = tn->tnode_free;
>  		tn->tnode_free = NULL;
> -		tnode_free(tn);
> +		__tnode_free(tn);
>  	}
>  }
>  
> @@ -1021,21 +1032,27 @@ static void trie_rebalance(struct trie *
>  				      (struct node *)tn, wasfull);
>  
>  		tp = node_parent((struct node *) tn);
> -		if (!tp)
> +		if (!tp) {
>  			rcu_assign_pointer(t->trie, (struct node *)tn);
> -
> -		tnode_free_flush();
> -		if (!tp)
>  			break;
> +		}
>  		tn = tp;
>  	}
>  
> +	if (tnode_free_head) {
> +		synchronize_rcu();
> +		tnode_free_flush();
> +	}
> +
>  	/* Handle last (top) tnode */
> -	if (IS_TNODE(tn))
> +	if (IS_TNODE(tn)) {
>  		tn = (struct tnode *)resize(t, (struct tnode *)tn);
> -
> -	rcu_assign_pointer(t->trie, (struct node *)tn);
> -	tnode_free_flush();
> +		rcu_assign_pointer(t->trie, (struct node *)tn);
> +		synchronize_rcu();
> +		tnode_free_flush();
> +	} else {
> +		rcu_assign_pointer(t->trie, (struct node *)tn);
> +	}
>  
>  	return;
>  }
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>   


--------------040102070201090706050302
Content-Type: text/plain;
 name="fib_triestats.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="fib_triestats.txt"

cat /proc/net/fib_triestat
Basic info: size of leaf: 20 bytes, size of tnode: 36 bytes.
Main:
        Aver depth:     3.51
        Max depth:      8
        Leaves:         3089
        Prefixes:       3156
        Internal nodes: 1167
          1: 737  2: 202  3: 150  4: 40  5: 28  6: 8  7: 1  10: 1
        Pointers: 6682
Null ptrs: 2427
Total size: 214  kB

Counters:
---------
gets = 1554240
backtracks = 916511
semantic match passed = 1127691
semantic match miss = 27
null node hit= 1439140
skipped node resize = 0

Local:
        Aver depth:     3.75
        Max depth:      5
        Leaves:         12
        Prefixes:       13
        Internal nodes: 10
          1: 9  2: 1
        Pointers: 22
Null ptrs: 1
Total size: 2  kB

Counters:
---------
gets = 1554767
backtracks = 572694
semantic match passed = 534
semantic match miss = 0
null node hit= 288
skipped node resize = 0


--------------040102070201090706050302--
