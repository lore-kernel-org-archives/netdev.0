From: Michael Witten <mfwitten@gmail.com>
Subject: Re: [PATCH net 3/3] net: skb_queue_purge(): lock/unlock the queue only once
Date: Mon, 02 Oct 2017 05:15:32 -0000
Message-ID: <057dd5367241468691b2b9adbc38a3ba-mfwitten@gmail.com>
References: <45aab5effc0c424a992646a97cf2ec14-mfwitten@gmail.com>
            <14527e6c082e4ea282a3f833118c68df-mfwitten@gmail.com>
            <ccfa23a0f76c4c9ebd07fc991db2f829-mfwitten@gmail.com>
            <20171001175909.4b9e53d8@xeon-e3>
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171001175909.4b9e53d8@xeon-e3>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 1 Oct 2017 17:59:09 -0700, Stephen Hemminger wrote:

> On Sun, 01 Oct 2017 22:19:20 -0000 Michael Witten wrote:
>
>> +	spin_lock_irqsave(&q->lock, flags);
>> +	skb = q->next;
>> +	__skb_queue_head_init(q);
>> +	spin_unlock_irqrestore(&q->lock, flags);
>
> Other code manipulating lists uses splice operation and
> a sk_buff_head temporary on the stack. That would be easier
> to understand.
>
> 	struct sk_buf_head head;
>
> 	__skb_queue_head_init(&head);
> 	spin_lock_irqsave(&q->lock, flags);
> 	skb_queue_splice_init(q, &head);
> 	spin_unlock_irqrestore(&q->lock, flags);
>
>
>> +	while (skb != head) {
>> +		next = skb->next;
>>  		kfree_skb(skb);
>> +		skb = next;
>> +	}
>
> It would be cleaner if you could use
> skb_queue_walk_safe rather than open coding the loop.
>
> 	skb_queue_walk_safe(&head, skb,  tmp)
> 		kfree_skb(skb);

I appreciate abstraction as much as anybody, but I do not believe
that such abstractions would actually be an improvement here.

* Splice-initing seems more like an idiom than an abstraction;
  at first blush, it wouldn't be clear to me what the intention
  is.

* Such abstractions are fairly unnecessary.

    * The function as written is already so short as to be
      easily digested.

    * More to the point, this function is not some generic,
      higher-level algorithm that just happens to employ the
      socket buffer interface; rather, it is a function that
      implements part of that very interface, and may thus
      twiddle the intimate bits of these data structures
      without being accused of abusing a leaky abstraction.

* Such abstractions add overhead, if only conceptually. In this
  case, a temporary socket buffer queue allocates *3* unnecessary
  struct members, including a whole `spinlock_t' member:
  
    prev
    qlen
    lock

  It's possible that the compiler will be smart enough to leave
  those out, but I have my suspicions that it won't, not only
  given that the interface contract requires that the temporary
  socket buffer queue be properly initialized before use, but
  also because splicing into the temporary will manipulate its
  `qlen'. Yet, why worry whether optimization happens? The whole
  issue can simply be avoided by exploiting the intimate details
  that are already philosophically available to us.

  Similarly, the function `skb_queue_walk_safe' is nice, but it
  loses value both because a temporary queue loses value (as just
  described), and because it ignores the fact that legitimate
  access to the internals of these data structures allows for
  setting up the requested loop in advance; that is to say, the
  two parts of the function that we are now debating can be woven
  together more tightly than `skb_queue_walk_safe' allows.

For these reasons, I stand by the way that the patch currently
implements this function; it does exactly what is desired, no more
or less.

Sincerely,
Michael Witten
