From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: ipv6: handle -EFAULT from skb_copy_bits
Date: Wed, 21 Dec 2016 22:33:20 +0100
Message-ID: <1482356000.2260.13.camel@stressinduktion.org>
References: <CAM_iQpXWCWMKDjLVTLuHNSKKGq5MWf5ZRLpyE=PDD3EgQ7PS4Q@mail.gmail.com>
         <1482323232.2260.2.camel@stressinduktion.org>
         <1482324073.2260.4.camel@stressinduktion.org>
         <20161221.140431.1651188849352763159.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: xiyou.wangcong@gmail.com, davej@codemonkey.org.uk,
        netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:38218 "EHLO
        out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756183AbcLUVd3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 16:33:29 -0500
In-Reply-To: <20161221.140431.1651188849352763159.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-12-21 at 14:04 -0500, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Wed, 21 Dec 2016 13:41:13 +0100
> 
> > On Wed, 2016-12-21 at 13:27 +0100, Hannes Frederic Sowa wrote: 
> >> @@ -555,8 +566,8 @@ static int rawv6_push_pending_frames(struct sock *sk, struct flowi6 *fl6,
> >>                 goto out;
> >>  
> >>         offset = rp->offset;
> >> -       total_len = inet_sk(sk)->cork.base.length;
> >> -       if (offset >= total_len - 1) {
> >> +       transport_len = raw6_corked_transport_len(sk);
> >> +       if (offset >= transport_len - 1) {
> >>                 err = -EINVAL;
> >>                 ip6_flush_pending_frames(sk);
> >>                 goto out;
> >> @@ -598,7 +609,7 @@ static int rawv6_push_pending_frames(struct sock *sk, struct flowi6 *fl6,
> >>                 tmp_csum = csum_sub(tmp_csum, csum_unfold(csum));
> >>  
> >>         csum = csum_ipv6_magic(&fl6->saddr, &fl6->daddr,
> >> -                              total_len, fl6->flowi6_proto, tmp_csum);
> >> +                              transport_len, fl6->flowi6_proto, tmp_csum);
> >>  
> >> 
> > 
> > Ops, here we need actually the total_len plus the opt->opt_nflen to
> > always calculate the correct checksum.
> 
> It's a real shame we can't just use skb_transport_offset().  This value
> has essentially been calculated for us already.

This code path is called when we want to send out the socket write
queue. Because of MSG_MORE we might have multiple skbs in there, but
only the first one actually carries the true header, the others are
optimized for the ipv6 fragmentation fast path, thus we need to use
skb_transport_offset to find the correct offset but we must not
touch/read the data area before, as it is undefined data at that point.

Basically total_len so far accumulated all the payload length written
to the socket from the syscall argument from the user, but
unfortunately it also accounts for the first sendmsg's synthesized
extension header length in the write queue. We need to reverse this
calculation at this point in time.

So total_len is independent from the loop we do below and the length
should always reflect the length of all skbs stored in the write queue.

The loop adjusts the offset of the checksum in case the checksum offset
points to data in one of the later skbs, but we know before if that can
happen or not because of the cork length.

> Also, if we iterate over multiple SKBs in the write queue, don't you have
> to redo this calculation for every SKB we iterate over?

All the skb's payload length are summed up in the cork's length field,
so we don't need to sum it up again but just can use that value as is
minus the extension header adjustment.

> Furthermore, what if the user queued up some SKBs in the raw socket
> with MSG_MORE, and then changed some of the options for a subsequent
> sendmsg() call?

We only refresh the extension headers the next time we prepare an ipv6
header, which is the first sendmsg after one without MSG_MORE. We are
protected in this situation and don't change header lengths later
during further MSG_MORE sendmsgs.

> Given all of this, I think the best thing to do is validate the offset
> after the queue walks, which is pretty much what Dave Jones's original
> patch was doing.

I think both approaches protect against the bug reasonably well, but
Dave's patch has a bug: we must either call ip6_flush_pending_frames to
clear the socket write queue with the buggy send request.

> Sigh... well, at least we now understand what's going on here.

Yep, the code is more than a bit complex. :/

Bye,
Hannes
