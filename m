From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: rewriting skb->truesize... good or bad idea
Date: Mon, 02 Oct 2006 10:46:42 -0400
Message-ID: <45212652.5030505@hp.com>
References: <451D6319.1040506@hp.com> <20060929.143139.74560775.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:30357 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S932466AbWJBOqo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2006 10:46:44 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060929.143139.74560775.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David

Thanks for the answer.

David Miller wrote:
> From: Vlad Yasevich <vladislav.yasevich@hp.com>
> Date: Fri, 29 Sep 2006 14:16:57 -0400
> 
>> I've attached the patch, in case people want to look at the code.
>>
>> However, we question if this is a good idea or if this is going to break
>> things...
> 
> Modification of skb->truesize is very dangerous and is only legal
> in a very limited set of circumstances.
> 
> The core problem is that if any other reference exists to the skb
> you could corrupt existing socket accounting by changing skb->truesize.

Yes, that's what I've found in the code.

> 
> Let's say that the packet went into a network tap like tcpdump and
> the packet has been charged to an AF_PACKET socket via skb->truesize.
> If you modify skb->truesize then when the AF_PACKET socket releases
> it's reference it will subtract the wrong amount of skb->truesize
> from the socket receive buffer.

Thankfully, this does not appear to be a problem in this particular
case.  The clones that would have their truesize changed, only exist in
SCTP.  The packet has already gone through all verifications and we just
queue the clones to the socket. The original packet skb remains
unchanged.  SCTP calls kfree_skb on it once all the cloning is done.

> 
> If, on the other hand, you know you have exclusive access to the
> skb and there are no other references, setting skb->truesize can
> be OK.  However setting it to sizeof(struct sk_buff) doesn't make
> sense since there is at least:
> 
> 	sizeof(struct sk_buff) + sizeof(struct skb_shared_info)
> 
> memory assosciated with any SKB whatsoever in the kernel.  That is,
> even for a "zero length" skb->data buffer, we still always allocate
> the skb_shared_info area which must be accounted for.

Well, since we are dealing with clones of the original skb, I didn't
think that we need to include skb_shared_info.  I thought that was
accounted for in the original skb?

The clones, that SCTP creates, point at a subset of data...
something like this:

 clone 1 ------+          clone 2 ------+
               |                        |
               |                        |
               v                        v
  +-------------------------------------------------------
  | proto hdrs | sctp data chunk 1      | data chunk 2
  +-------------------------------------------------------
  ^
  |
  |
  +--- orig_skb->head


Right now, for every clone we use the generic socket accounting code
that uses skb->truesize.

The alternative to changing truesize is to write an SCTP version of
socket accounting.  This is what we did back in 2.6.10 days and we
tried get away from that.

If you have another idea of how we could do this, I'd appreciate it.

> 
> BTW, I think the whole chunking mechanism in the SCTP code is the
> largest source of problems and maintainability issues in that stack.
> Any time I want to make major modifications to SKBs to make them
> smaller or whatever, the most difficult piece of code to adjust is
> this code.
> 

I think you've already removed all the dependencies between chunking and
SKBs.  All we have now are some pointers to skb.  This work actually
made the protocol a lot more stable.

Thanks
-vlad
