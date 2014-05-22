From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: skbuff truesize incorrect.
Date: Thu, 22 May 2014 15:25:29 -0400
Message-ID: <537E4F29.9080103@gmail.com>
References: <537E4AFD.20304@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, kamal@canonical.com,
	Ben Hutchings <bhutchings@solarflare.com>, edumazet@google.com,
	mszeredi@suse.cz, fw@strlen.de
To: Jim Baxter <jim_baxter@mentor.com>, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <537E4AFD.20304@mentor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/22/2014 03:07 PM, Jim Baxter wrote:
> Hi, I was hoping you can help me with some questions.
> 
> I have been investigating a network issue with bursts of network traffic
> over USB CDC-NCM, the issue is that the kernel is dropping packets
> because sk_rcvqueues_full() returns true due to skb2->truesize is always
> 32960 instead of SKB_TRUESIZE(skb2->len) which is about 1800.
> 
> The code I am trying to fix is this code below, it is splitting a set of
> multiple network packets compressed into a single 16k packet into
> individual skb's and sending them up the network stack.
> 
>     skb2 = skb_clone(skb, GFP_ATOMIC);
>     if (skb2 == NULL)
>         goto err;
> 
>     if (!skb_pull(skb2, index)) {
>         ret = -EOVERFLOW;
>         goto err;
>     }

This assumes that you original 16K packet is linear.  Is that
always the case?

> 
>     skb_trim(skb2, dg_len - crc_len);
> 
> My questions are:
> 
> 1) Which buffer size does truesize represent, is it the total buffer or
> just the data related to the relevant skb?

Total buffer size (including the struct sk_buff).

> 
> 2) If truesize is for the skb it is contained within should it be
> updated during the call to skb_trim?

No, because the the buffer/memory is still there.  skb_trim just
sets the tail pointer and adjusts skb->len.


> 
> 3) Why does the truesize default to 32960?

Probably because that's how much buffer space was actually allocated
for the original skb.  When you cloned it, you inherited the truesize
since a clone is just the struct sk_buff that points into the data
of the original.

This is the very same problem that I ran into with SCTP since it
has similar code in it.  You can play games with truesize manually,
but you have to be very careful here.

-vlad
> 
> 
> Thank you for any help,
> Jim Baxter.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
