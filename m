From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: skb_try_coalesce bug?
Date: Tue, 22 Apr 2014 06:11:33 -0700
Message-ID: <1398172293.29946.37.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140422120125.GC7019@eerihug-hybrid.rnd.ki.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Erik Hugne <erik.hugne@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:48051 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754430AbaDVNLe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 09:11:34 -0400
Received: by mail-pd0-f171.google.com with SMTP id r10so4859675pdi.2
        for <netdev@vger.kernel.org>; Tue, 22 Apr 2014 06:11:34 -0700 (PDT)
In-Reply-To: <20140422120125.GC7019@eerihug-hybrid.rnd.ki.sw.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-04-22 at 14:01 +0200, Erik Hugne wrote:
> It seems that if the head skb of a reassembly chain have enough tailroom
> to hold the data of a received fragment, skb_try_coalesce() will append this
> directly to the head, even if preceding fragments have been put on a frag list.
> This will cause a corrupted buffer to be passed to userland when 
> skb_copy_datagram_iovec() later copies the contents of head, and then each frag
> one by one to the target iovec.
>  
> Is skb_try_coalesce() broken, or are we using it wrongly in tipc?

I am not sure how it could happen with the current implementation ?

static inline bool skb_is_nonlinear(const struct sk_buff *skb)
{
	return skb->data_len;
}

static inline int skb_tailroom(const struct sk_buff *skb)
{
	return skb_is_nonlinear(skb) ? 0 : skb->end - skb->tail;
}

/**
 * skb_try_coalesce - try to merge skb to prior one
 * @to: prior buffer
 * @from: buffer to add
 * @fragstolen: pointer to boolean
 * @delta_truesize: how much more was allocated than was requested
 */
bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
                      bool *fragstolen, int *delta_truesize)
{
        int i, delta, len = from->len;

        *fragstolen = false;

        if (skb_cloned(to))
                return false;

        if (len <= skb_tailroom(to)) {
                BUG_ON(skb_copy_bits(from, 0, skb_put(to, len), len));
