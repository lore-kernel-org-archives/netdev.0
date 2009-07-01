From: =?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: [PATCH net-2.6] Re: rib_trie / Fix inflate_threshold_root.	Now=15
 size=11 bits
Date: Wed, 01 Jul 2009 11:50:09 +0200
Message-ID: <4A4B3151.5050909@itcare.pl>
References: <20090629083315.GA4712@ff.dom.local> <4A488EB8.4070602@itcare.pl> <20090629104703.GC4712@ff.dom.local> <20090630070929.GB5589@ff.dom.local> <4A4A72B9.3030400@itcare.pl> <20090630204141.GB3026@ami.dom.local> <4A4AA03D.5090808@itcare.pl> <20090701063651.GA4876@ff.dom.local> <20090701072409.GA12592@ff.dom.local> <4A4B2FA8.3040007@itcare.pl>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030500080501090106040509"
Cc: Linux Network Development list <netdev@vger.kernel.org>,
	Robert Olsson <robert@robur.slu.se>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:44879 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753285AbZGAJuJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jul 2009 05:50:09 -0400
In-Reply-To: <4A4B2FA8.3040007@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030500080501090106040509
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 8bit

Pawe³ Staszewski pisze:
> Jarek Poplawski pisze:
>> On Wed, Jul 01, 2009 at 06:36:51AM +0000, Jarek Poplawski wrote:
>>  
>>> On Wed, Jul 01, 2009 at 01:31:09AM +0200, Pawe³ Staszewski wrote:
>>> ...
>>>     
>>
>> It looks like Cc was shortened BTW, but I guess at least Robert is
>> interested in this testing, so I add him back.
>>
>> Cheers,
>> Jarek P.
>>
>>  
>>>> Yes i can make tests like this.
>>>> My network is splited to test clients and other normal clients
>>>> so it's really no problem to make testing. - if testing clients 
>>>> working  then traffic from normal clients is also switched to this 
>>>> router (but if  traffic is not forwarded "like in this case" for 
>>>> testing clients then  failover switching them to working router )
>>>>
>>>> and other point to make this tests - is that - it is good to have 
>>>> all in  linux kernel networking working well :)
>>>>       
>>> It's extremely nice of you! On the other hand, this type of change
>>> was planned to the net-next to fix possible memory problems, which
>>> might have happened to you as well. So you'd probably experience this
>>> problem in the future (2.6.32) anyway.
>>>
>>> So here is the first of 2 patches (the second in a separate message),
>>> which should be tested separately, each one applied on top of the
>>> 2.6.29.x (vanilla - at least fib_trie.c), after reverting the previous
>>> one. So, they are again all-in-one, to eclude any misunderstanding.
>>>
>>> Btw., I assume there were no oopses, warnings or lockups after those
>>> previous non-working patches - only no routing/forwarding.
>>>
>>>     
> Yes on on previous patches there was / no warnings / no oopses or lockups
>
> But now i apply this patch and i make more testing.
> First boot with start of bgpd and - traffic is not forwarded
> So i start to search and make only some routes (static without bgpd) 
> thru this host
> And all is working for this host when i make all by static routes.
>
> So i change a little my bgp configuration and make default route to 
> only one of my iBGP peers and start bgpd process
> All is working and what is weird is number of routes in kernel table.
> Kernel is learning routes from bgpd but very slowly - really very slowly.
>
> In attached file there are some fib_triestats after 5min of traffic.
>
> Without this patch (normally)
> total size: reported by fib_triestats in less that 1sec is:  "Total 
> size: 35769  kB"
>
> But with this patch
> Total size is growing up and in 5 min of traffic it grow to only:  
> "Total size: 1005  kB"
>
Sorry no attached file.

> Regards
> Pawe³ Staszewski
>
>>> Thanks,
>>> Jarek P.
>>> ----------> (synchronize take 6 all-in-one for 2.6.29x, .28, or .27)
>>>
>>> diff -Nurp a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
>>> --- a/net/ipv4/fib_trie.c    2009-06-29 05:30:50.000000000 +0000
>>> +++ b/net/ipv4/fib_trie.c    2009-07-01 05:15:37.000000000 +0000
>>> @@ -123,6 +123,7 @@ struct tnode {
>>>      union {
>>>          struct rcu_head rcu;
>>>          struct work_struct work;
>>> +        struct tnode *tnode_free;
>>>      };
>>>      struct node *child[0];
>>>  };
>>> @@ -161,6 +162,8 @@ static void tnode_put_child_reorg(struct
>>>  static struct node *resize(struct trie *t, struct tnode *tn);
>>>  static struct tnode *inflate(struct trie *t, struct tnode *tn);
>>>  static struct tnode *halve(struct trie *t, struct tnode *tn);
>>> +/* tnodes to free after resize(); protected by RTNL */
>>> +static struct tnode *tnode_free_head;
>>>  
>>>  static struct kmem_cache *fn_alias_kmem __read_mostly;
>>>  static struct kmem_cache *trie_leaf_kmem __read_mostly;
>>> @@ -385,6 +388,24 @@ static inline void tnode_free(struct tno
>>>          call_rcu(&tn->rcu, __tnode_free_rcu);
>>>  }
>>>  
>>> +static void tnode_free_safe(struct tnode *tn)
>>> +{
>>> +    BUG_ON(IS_LEAF(tn));
>>> +    tn->tnode_free = tnode_free_head;
>>> +    tnode_free_head = tn;
>>> +}
>>> +
>>> +static void tnode_free_flush(void)
>>> +{
>>> +    struct tnode *tn;
>>> +
>>> +    while ((tn = tnode_free_head)) {
>>> +        tnode_free_head = tn->tnode_free;
>>> +        tn->tnode_free = NULL;
>>> +        tnode_free(tn);
>>> +    }
>>> +}
>>> +
>>>  static struct leaf *leaf_new(void)
>>>  {
>>>      struct leaf *l = kmem_cache_alloc(trie_leaf_kmem, GFP_KERNEL);
>>> @@ -495,7 +516,7 @@ static struct node *resize(struct trie *
>>>  
>>>      /* No children */
>>>      if (tn->empty_children == tnode_child_length(tn)) {
>>> -        tnode_free(tn);
>>> +        tnode_free_safe(tn);
>>>          return NULL;
>>>      }
>>>      /* One child */
>>> @@ -509,7 +530,7 @@ static struct node *resize(struct trie *
>>>  
>>>              /* compress one level */
>>>              node_set_parent(n, NULL);
>>> -            tnode_free(tn);
>>> +            tnode_free_safe(tn);
>>>              return n;
>>>          }
>>>      /*
>>> @@ -670,7 +691,7 @@ static struct node *resize(struct trie *
>>>              /* compress one level */
>>>  
>>>              node_set_parent(n, NULL);
>>> -            tnode_free(tn);
>>> +            tnode_free_safe(tn);
>>>              return n;
>>>          }
>>>  
>>> @@ -756,7 +777,7 @@ static struct tnode *inflate(struct trie
>>>              put_child(t, tn, 2*i, inode->child[0]);
>>>              put_child(t, tn, 2*i+1, inode->child[1]);
>>>  
>>> -            tnode_free(inode);
>>> +            tnode_free_safe(inode);
>>>              continue;
>>>          }
>>>  
>>> @@ -801,9 +822,9 @@ static struct tnode *inflate(struct trie
>>>          put_child(t, tn, 2*i, resize(t, left));
>>>          put_child(t, tn, 2*i+1, resize(t, right));
>>>  
>>> -        tnode_free(inode);
>>> +        tnode_free_safe(inode);
>>>      }
>>> -    tnode_free(oldtnode);
>>> +    tnode_free_safe(oldtnode);
>>>      return tn;
>>>  nomem:
>>>      {
>>> @@ -885,7 +906,7 @@ static struct tnode *halve(struct trie *
>>>          put_child(t, newBinNode, 1, right);
>>>          put_child(t, tn, i/2, resize(t, newBinNode));
>>>      }
>>> -    tnode_free(oldtnode);
>>> +    tnode_free_safe(oldtnode);
>>>      return tn;
>>>  nomem:
>>>      {
>>> @@ -983,12 +1004,14 @@ fib_find_node(struct trie *t, u32 key)
>>>      return NULL;
>>>  }
>>>  
>>> -static struct node *trie_rebalance(struct trie *t, struct tnode *tn)
>>> +static void trie_rebalance(struct trie *t, struct tnode *tn, bool 
>>> sync)
>>>  {
>>>      int wasfull;
>>> -    t_key cindex, key = tn->key;
>>> +    t_key cindex, key;
>>>      struct tnode *tp;
>>>  
>>> +    key = tn->key;
>>> +
>>>      while (tn != NULL && (tp = node_parent((struct node *)tn)) != 
>>> NULL) {
>>>          cindex = tkey_extract_bits(key, tp->pos, tp->bits);
>>>          wasfull = tnode_full(tp, tnode_get_child(tp, cindex));
>>> @@ -999,6 +1022,10 @@ static struct node *trie_rebalance(struc
>>>  
>>>          tp = node_parent((struct node *) tn);
>>>          if (!tp)
>>> +            rcu_assign_pointer(t->trie, (struct node *)tn);
>>> +
>>> +        //tnode_free_flush();
>>> +        if (!tp)
>>>              break;
>>>          tn = tp;
>>>      }
>>> @@ -1007,7 +1034,12 @@ static struct node *trie_rebalance(struc
>>>      if (IS_TNODE(tn))
>>>          tn = (struct tnode *)resize(t, (struct tnode *)tn);
>>>  
>>> -    return (struct node *)tn;
>>> +    rcu_assign_pointer(t->trie, (struct node *)tn);
>>> +    if (sync)
>>> +        synchronize_rcu();
>>> +    tnode_free_flush();
>>> +
>>> +    return;
>>>  }
>>>  
>>>  /* only used from updater-side */
>>> @@ -1155,7 +1187,7 @@ static struct list_head *fib_insert_node
>>>  
>>>      /* Rebalance the trie */
>>>  
>>> -    rcu_assign_pointer(t->trie, trie_rebalance(t, tp));
>>> +    trie_rebalance(t, tp, true);
>>>  done:
>>>      return fa_head;
>>>  }
>>> @@ -1575,7 +1607,7 @@ static void trie_leaf_remove(struct trie
>>>      if (tp) {
>>>          t_key cindex = tkey_extract_bits(l->key, tp->pos, tp->bits);
>>>          put_child(t, (struct tnode *)tp, cindex, NULL);
>>> -        rcu_assign_pointer(t->trie, trie_rebalance(t, tp));
>>> +        trie_rebalance(t, tp, false);
>>>      } else
>>>          rcu_assign_pointer(t->trie, NULL);
>>>  
>>>     
>> -- 
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>
>>   
>
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>


--------------030500080501090106040509
Content-Type: text/plain;
 name="fib_triestats.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="fib_triestats.txt"

cat /proc/net/fib_triestat
Basic info: size of leaf: 20 bytes, size of tnode: 36 bytes.
Main:
        Aver depth:     3.79
        Max depth:      9
        Leaves:         15518
        Prefixes:       15933
        Internal nodes: 3973
          1: 2260  2: 674  3: 518  4: 268  5: 164  6: 79  7: 5  8: 2  9: 1  10: 2
        Pointers: 29664
Null ptrs: 10174
Total size: 995  kB

Counters:
---------
gets = 17863461
backtracks = 13345457
semantic match passed = 17305229
semantic match miss = 419
null node hit= 17602641
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
gets = 17865423
backtracks = 4964174
semantic match passed = 2126
semantic match miss = 0
null node hit= 1853
skipped node resize = 0


----------- After 30sec ----------------
cat /proc/net/fib_triestat
Basic info: size of leaf: 20 bytes, size of tnode: 36 bytes.
Main:
        Aver depth:     3.79
        Max depth:      9
        Leaves:         15686
        Prefixes:       16111
        Internal nodes: 4002
          1: 2259  2: 679  3: 536  4: 274  5: 165  6: 79  7: 5  8: 2  9: 1  10: 2
        Pointers: 29954
Null ptrs: 10267
Total size: 1005  kB

Counters:
---------
gets = 18042821
backtracks = 13523292
semantic match passed = 17484572
semantic match miss = 419
null node hit= 17799334
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
gets = 18044798
backtracks = 5012942
semantic match passed = 2140
semantic match miss = 0
null node hit= 1865
skipped node resize = 0


--------------030500080501090106040509--
