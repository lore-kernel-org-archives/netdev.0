From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2/3] r8169: code clean-up
Date: Mon, 21 Feb 2005 00:34:05 +0100
Message-ID: <20050220233405.GA14268@electric-eye.fr.zoreil.com>
References: <200502161823.43562.jdmason@us.ibm.com> <200502191147.14845.jdmason@us.ibm.com> <20050219223012.GA3601@electric-eye.fr.zoreil.com> <200502201204.23468.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Jon Mason <jdmason@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <200502201204.23468.jdmason@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jon Mason <jdmason@us.ibm.com> :
[...]
> Actually, I removed it and it causes the partition point to move, similiar to 
> opts2.  I realize this isn't really an acceptable answer, so I will try to 
> determine what is causing this weird behavior.

It is an acceptable answer: the behavior changes.

[...]
> True, but this problem existed before I made the jumbo frames changes.  The 

AFAIKS, if the rx_copybreak fails, be it because the packet is too big or
because the allocation failed, the current skb is sent to the upper layers.


> static inline int rtl8169_rx_copy(struct sk_buff **sk_buff, int pkt_size,
>                               struct RxDesc *desc, struct rtl8169_private *tp)
> {
>         u32 status = le32_to_cpu(desc->opts1);
> 
>         if ((pkt_size > rx_copybreak) &&
>                         ((status & FirstFrag) && (status & LastFrag)))
>                 return -1;
> 
>         if (status & FirstFrag) {
>                 struct sk_buff *skb = dev_alloc_skb(pkt_size + NET_IP_ALIGN);
>                 u32 len = (pkt_size > rx_copybreak) ? tp->desc_part : pkt_size;
> 
>                 if (skb) {
>                         skb_reserve(skb, NET_IP_ALIGN);
>                         memcpy(skb->data, sk_buff[0]->tail, len);
>                         skb_put(skb, len);
>                 } else {
>                         printk(KERN_INFO "no rx skb allocated\n");
>                         if (pkt_size <= rx_copybreak) 
>                                 return -1;
>                 }
> 
>                 tp->new_skb = skb;
>         }
> 
> Is this acceptable?

I'll think more until I can figure I got the whole picture (only copy the
first frament ?). I would have expected something like the mess below:

static int rtl8169_rx_copy(struct sk_buff **sk_buff, int pkt_size,
			   struct RxDesc *desc, struct rtl8169_private *tp)
{
	u32 status = le32_to_cpu(desc->opts1);
	struct sk_buff *skb;
	int ret = -1;

	if ((pkt_size > rx_copybreak) && (status & FirstFrag) &&
	    (status & LastFrag)) {
		goto out;
	}

	if (pkt_size < rx_copybreak) {
		skb = dev_alloc_skb(pkt_size + NET_IP_ALIGN);
		if (!skb)
			goto out;
		skb_reserve(skb, NET_IP_ALIGN);
	} else if (status & FirstFrag)
		skb = tp->new_skb = sk_buff[0];

	if ((pkt_size < rx_copybreak) || !(status & FirstFrag)) {
		memcpy(skb->data, sk_buff[0]->tail, pkt_size);
		rtl8169_return_to_asic(desc, tp->rx_buf_sz);
		*sk_buff = skb;
		ret = 0;
	}

	skb_put(skb, pkt_size);

out:
	return ret;
}

At this point I'd expect "How do you handle rtl8169_rx_copy() return ?" 
(or "yuck").

[...]
> If I am still not making sense, I can be more verbose.

Enlight me with the code, just to be sure.

[...]
> Sorry, I guess I got a little over eager.  I will attempt to avoid this 
> behavior in the future.  Forgiveness please.

No problem, really.

[...]
> I realize this is being a little creative, but it is much cleaner code this 
> way. Otherwise the driver will need a global counter to use as a offset of 
> the skb->tail and call skb_put after it is all over.

Ok, ok, I did not get it in the original patch.

--
Ueimor
