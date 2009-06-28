From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: Re: rib_trie / Fix inflate_threshold_root. Now=15 size=11 bits
Date: Sun, 28 Jun 2009 17:48:19 +0200
Message-ID: <4A4790C3.508@itcare.pl>
References: <19012.37515.146191.198843@robur.slu.se> <20090627192057.GA5041@ami.dom.local> <19015.20051.432572.460207@robur.slu.se> <20090628143511.GA20541@ami.dom.local> <4A478D02.10805@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Robert Olsson <robert@robur.slu.se>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	"Jorge Boncompte [DTI2]" <jorge@dti2.net>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Robert Olsson <robert.olsson@its.uu.se>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:60716 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752789AbZF1PsS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Jun 2009 11:48:18 -0400
In-Reply-To: <4A478D02.10805@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


After apply this patch something is wrong

Traffic is not forwarded
no info in dmesg / no info from bgp
and also i can't connect to bgpd process

I revert kernel to past version with first Jarek patch



Pawe=C5=82 Staszewski pisze:
>
>
> After 18 hours from apply first Jarek patch i have no info about Fix=20
> inflate_threshold_root
> even if i make: "clear ip bgp *" on router
> So i change Jarek patch from previous to this new one for test and we=
=20
> will see ...
>
> Regards
> Pawel Staszewski
>
>
> Jarek Poplawski pisze:
>> On Sun, Jun 28, 2009 at 01:04:51PM +0200, Robert Olsson wrote:
>> ...
>> =20
>>>  The memory patches and "manual RCU" are also interesting to addres=
s
>>>  the case with PREEMTP's.
>>>    =20
>>
>> Since 2.6.29 looks like prefered here, and there were a lot of takes
>> in this thread, I attach below a combined all-in-one patch including=
:
>> - 2.6.29 -> 2.6.30 preemption disable patch
>> - 2 RCU vs. preemption fixes from 2.6.31-rc
>> - "manual RCU" patch to force vfree/kfree before root's resize (take=
 3)
>> - "automatic" inflate_threshold_root fix (take 2)
>>
>> Thanks,
>> Jarek P.
>>
>> --- (for 2.6.29.x or even .28 or .27; any testing appreciated)
>>
>> diff -Nurp a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
>> --- a/net/ipv4/fib_trie.c    2009-06-27 20:25:06.000000000 +0200
>> +++ b/net/ipv4/fib_trie.c    2009-06-28 15:45:02.000000000 +0200
>> @@ -123,6 +123,7 @@ struct tnode {
>>      union {
>>          struct rcu_head rcu;
>>          struct work_struct work;
>> +        struct tnode *tnode_free;
>>      };
>>      struct node *child[0];
>>  };
>> @@ -161,6 +162,8 @@ static void tnode_put_child_reorg(struct
>>  static struct node *resize(struct trie *t, struct tnode *tn);
>>  static struct tnode *inflate(struct trie *t, struct tnode *tn);
>>  static struct tnode *halve(struct trie *t, struct tnode *tn);
>> +/* tnodes to free after resize(); protected by RTNL */
>> +static struct tnode *tnode_free_head;
>> =20
>>  static struct kmem_cache *fn_alias_kmem __read_mostly;
>>  static struct kmem_cache *trie_leaf_kmem __read_mostly;
>> @@ -315,6 +318,7 @@ static const int halve_threshold =3D 25;
>>  static const int inflate_threshold =3D 50;
>>  static const int halve_threshold_root =3D 8;
>>  static const int inflate_threshold_root =3D 15;
>> +static int inflate_threshold_root_fix;
>> =20
>> =20
>>  static void __alias_free_mem(struct rcu_head *head)
>> @@ -363,6 +367,17 @@ static void __tnode_vfree(struct work_st
>>      vfree(tn);
>>  }
>> =20
>> +static void __tnode_free(struct tnode *tn)
>> +{
>> +    size_t size =3D sizeof(struct tnode) +
>> +              (sizeof(struct node *) << tn->bits);
>> +
>> +    if (size <=3D PAGE_SIZE)
>> +        kfree(tn);
>> +    else
>> +        vfree(tn);
>> +}
>> +
>>  static void __tnode_free_rcu(struct rcu_head *head)
>>  {
>>      struct tnode *tn =3D container_of(head, struct tnode, rcu);
>> @@ -385,6 +400,24 @@ static inline void tnode_free(struct tno
>>          call_rcu(&tn->rcu, __tnode_free_rcu);
>>  }
>> =20
>> +static void tnode_free_safe(struct tnode *tn)
>> +{
>> +    BUG_ON(IS_LEAF(tn));
>> +    tn->tnode_free =3D tnode_free_head;
>> +    tnode_free_head =3D tn;
>> +}
>> +
>> +static void tnode_free_flush(void)
>> +{
>> +    struct tnode *tn;
>> +
>> +    while ((tn =3D tnode_free_head)) {
>> +        tnode_free_head =3D tn->tnode_free;
>> +        tn->tnode_free =3D NULL;
>> +        __tnode_free(tn);
>> +    }
>> +}
>> +
>>  static struct leaf *leaf_new(void)
>>  {
>>      struct leaf *l =3D kmem_cache_alloc(trie_leaf_kmem, GFP_KERNEL)=
;
>> @@ -495,7 +528,7 @@ static struct node *resize(struct trie *
>> =20
>>      /* No children */
>>      if (tn->empty_children =3D=3D tnode_child_length(tn)) {
>> -        tnode_free(tn);
>> +        tnode_free_safe(tn);
>>          return NULL;
>>      }
>>      /* One child */
>> @@ -509,7 +542,7 @@ static struct node *resize(struct trie *
>> =20
>>              /* compress one level */
>>              node_set_parent(n, NULL);
>> -            tnode_free(tn);
>> +            tnode_free_safe(tn);
>>              return n;
>>          }
>>      /*
>> @@ -581,7 +614,8 @@ static struct node *resize(struct trie *
>>      /* Keep root node larger  */
>> =20
>>      if (!tn->parent)
>> -        inflate_threshold_use =3D inflate_threshold_root;
>> +        inflate_threshold_use =3D inflate_threshold_root +
>> +                    inflate_threshold_root_fix;
>>      else
>>          inflate_threshold_use =3D inflate_threshold;
>> =20
>> @@ -605,15 +639,22 @@ static struct node *resize(struct trie *
>>      }
>> =20
>>      if (max_resize < 0) {
>> -        if (!tn->parent)
>> -            pr_warning("Fix inflate_threshold_root."
>> -                   " Now=3D%d size=3D%d bits\n",
>> -                   inflate_threshold_root, tn->bits);
>> -        else
>> +        if (!tn->parent) {
>> +            if (inflate_threshold_root_fix * 2 <
>> +                inflate_threshold_root)
>> +                inflate_threshold_root_fix++;
>> +            else
>> +                pr_warning("Fix inflate_threshold_root."
>> +                       " Now=3D%d size=3D%d bits fix=3D%d\n",
>> +                       inflate_threshold_root, tn->bits,
>> +                       inflate_threshold_root_fix);
>> +        } else {
>>              pr_warning("Fix inflate_threshold."
>>                     " Now=3D%d size=3D%d bits\n",
>>                     inflate_threshold, tn->bits);
>> -    }
>> +        }
>> +    } else if (max_resize > 4 && !tn->parent &&=20
>> inflate_threshold_root_fix)
>> +        inflate_threshold_root_fix--;
>> =20
>>      check_tnode(tn);
>> =20
>> @@ -670,7 +711,7 @@ static struct node *resize(struct trie *
>>              /* compress one level */
>> =20
>>              node_set_parent(n, NULL);
>> -            tnode_free(tn);
>> +            tnode_free_safe(tn);
>>              return n;
>>          }
>> =20
>> @@ -756,7 +797,7 @@ static struct tnode *inflate(struct trie
>>              put_child(t, tn, 2*i, inode->child[0]);
>>              put_child(t, tn, 2*i+1, inode->child[1]);
>> =20
>> -            tnode_free(inode);
>> +            tnode_free_safe(inode);
>>              continue;
>>          }
>> =20
>> @@ -801,9 +842,9 @@ static struct tnode *inflate(struct trie
>>          put_child(t, tn, 2*i, resize(t, left));
>>          put_child(t, tn, 2*i+1, resize(t, right));
>> =20
>> -        tnode_free(inode);
>> +        tnode_free_safe(inode);
>>      }
>> -    tnode_free(oldtnode);
>> +    tnode_free_safe(oldtnode);
>>      return tn;
>>  nomem:
>>      {
>> @@ -885,7 +926,7 @@ static struct tnode *halve(struct trie *
>>          put_child(t, newBinNode, 1, right);
>>          put_child(t, tn, i/2, resize(t, newBinNode));
>>      }
>> -    tnode_free(oldtnode);
>> +    tnode_free_safe(oldtnode);
>>      return tn;
>>  nomem:
>>      {
>> @@ -983,12 +1024,14 @@ fib_find_node(struct trie *t, u32 key)
>>      return NULL;
>>  }
>> =20
>> -static struct node *trie_rebalance(struct trie *t, struct tnode *tn=
)
>> +static void trie_rebalance(struct trie *t, struct tnode *tn)
>>  {
>>      int wasfull;
>> -    t_key cindex, key =3D tn->key;
>> +    t_key cindex, key;
>>      struct tnode *tp;
>> =20
>> +    key =3D tn->key;
>> +
>>      while (tn !=3D NULL && (tp =3D node_parent((struct node *)tn)) =
!=3D=20
>> NULL) {
>>          cindex =3D tkey_extract_bits(key, tp->pos, tp->bits);
>>          wasfull =3D tnode_full(tp, tnode_get_child(tp, cindex));
>> @@ -1003,11 +1046,22 @@ static struct node *trie_rebalance(struc
>>          tn =3D tp;
>>      }
>> =20
>> +    if (tnode_free_head) {
>> +        synchronize_rcu();
>> +        tnode_free_flush();
>> +    }
>> +
>>      /* Handle last (top) tnode */
>> -    if (IS_TNODE(tn))
>> +    if (IS_TNODE(tn)) {
>>          tn =3D (struct tnode *)resize(t, (struct tnode *)tn);
>> +        rcu_assign_pointer(t->trie, (struct node *)tn);
>> +        synchronize_rcu();
>> +        tnode_free_flush();
>> +    } else {
>> +        rcu_assign_pointer(t->trie, (struct node *)tn);
>> +    }
>> =20
>> -    return (struct node *)tn;
>> +    return;
>>  }
>> =20
>>  /* only used from updater-side */
>> @@ -1155,7 +1209,7 @@ static struct list_head *fib_insert_node
>> =20
>>      /* Rebalance the trie */
>> =20
>> -    rcu_assign_pointer(t->trie, trie_rebalance(t, tp));
>> +    trie_rebalance(t, tp);
>>  done:
>>      return fa_head;
>>  }
>> @@ -1575,7 +1629,7 @@ static void trie_leaf_remove(struct trie
>>      if (tp) {
>>          t_key cindex =3D tkey_extract_bits(l->key, tp->pos, tp->bit=
s);
>>          put_child(t, (struct tnode *)tp, cindex, NULL);
>> -        rcu_assign_pointer(t->trie, trie_rebalance(t, tp));
>> +        trie_rebalance(t, tp);
>>      } else
>>          rcu_assign_pointer(t->trie, NULL);
>> =20
>> --=20
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>
>>  =20
>
> --=20
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>

