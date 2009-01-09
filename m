From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Fri, 9 Jan 2009 22:24:00 +0100
Message-ID: <20090109212400.GA3727@1wt.eu>
References: <20090108173028.GA22531@1wt.eu> <49667534.5060501@zeus.com> <20090108.135515.85489589.davem@davemloft.net> <4966F2F4.9080901@cosmosbay.com> <49677074.5090802@cosmosbay.com> <20090109185448.GA1999@1wt.eu> <4967B8C5.10803@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, ben@zeus.com,
	jarkao2@gmail.com, mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1329 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757502AbZAIVYc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 16:24:32 -0500
Content-Disposition: inline
In-Reply-To: <4967B8C5.10803@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 09, 2009 at 09:51:17PM +0100, Eric Dumazet wrote:
(...)
> > Also, in your second mail, you're saying that your change
> > might return more data than requested by the user. I can't
> > find why, could you please explain to me, as I'm still quite
> > ignorant in this area ?
> 
> Well, I just tested various user programs and indeed got this
> strange result :
> 
> Here I call splice() with len=1000 (0x3e8), and you can see
> it gives a result of 1460 at the second call.

huh, not nice indeed!

While looking at the code to see how this could be possible, I
came across this minor thing (unrelated IMHO) :

	if (__skb_splice_bits(skb, &offset, &tlen, &spd))
		goto done;
>>>>>>	else if (!tlen)    <<<<<<
		goto done;

	/*
	 * now see if we have a frag_list to map
	 */
	if (skb_shinfo(skb)->frag_list) {
		struct sk_buff *list = skb_shinfo(skb)->frag_list;

		for (; list && tlen; list = list->next) {
			if (__skb_splice_bits(list, &offset, &tlen, &spd))
				break;
		}
	}

    done:

Above on the enlighted line, we'd better remove the else and leave a plain
"if (!tlen)". Otherwise, when the first call to __skb_splice_bits() zeroes
tlen, we still enter the if and evaluate the for condition for nothing. But
let's leave that for later.

> I suspect a bug in splice code, that my patch just exposed.

I've checked in skb_splice_bits() and below and can't see how we can move
more than the requested len.

However, with your change, I don't clearly see how we break out of
the loop in tcp_read_sock(). Maybe we first read 1000 then loop again
and read remaining data ? I suspect that we should at least exit when
((struct tcp_splice_state *)desc->arg.data)->len = 0.

At least that's something easy to add just before or after !desc->count
for a test.

Regards,
Willy

