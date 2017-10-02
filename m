From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net 3/3] net: skb_queue_purge(): lock/unlock the queue
 only once
Date: Sun, 1 Oct 2017 17:59:09 -0700
Message-ID: <20171001175909.4b9e53d8@xeon-e3>
References: <45aab5effc0c424a992646a97cf2ec14-mfwitten@gmail.com>
        <14527e6c082e4ea282a3f833118c68df-mfwitten@gmail.com>
        <ccfa23a0f76c4c9ebd07fc991db2f829-mfwitten@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Michael Witten <mfwitten@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ccfa23a0f76c4c9ebd07fc991db2f829-mfwitten@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 01 Oct 2017 22:19:20 -0000
Michael Witten <mfwitten@gmail.com> wrote:

> +	spin_lock_irqsave(&q->lock, flags);
> +	skb = q->next;
> +	__skb_queue_head_init(q);
> +	spin_unlock_irqrestore(&q->lock, flags);

Other code manipulating lists uses splice operation and
a sk_buff_head temporary on the stack. That would be easier
to understand.

	struct sk_buf_head head;

	__skb_queue_head_init(&head);
	spin_lock_irqsave(&q->lock, flags);
	skb_queue_splice_init(q, &head);
	spin_unlock_irqrestore(&q->lock, flags);


> +	while (skb != head) {
> +		next = skb->next;
>  		kfree_skb(skb);
> +		skb = next;
> +	}

It would be cleaner if you could use
skb_queue_walk_safe rather than open coding the loop.

	skb_queue_walk_safe(&head, skb,  tmp)
		kfree_skb(skb);
