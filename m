From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 5/6] tcp: allow one skb to be received per
 socket under memory pressure
Date: Fri, 15 May 2015 11:22:50 -0700
Message-ID: <1431714170.27831.118.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1431701638-24451-1-git-send-email-edumazet@google.com>
	 <1431701638-24451-6-git-send-email-edumazet@google.com>
	 <55563902.402@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Jason Baron <jbaron@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36405 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752893AbbEOSWx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 14:22:53 -0400
Received: by pabts4 with SMTP id ts4so21633076pab.3
        for <netdev@vger.kernel.org>; Fri, 15 May 2015 11:22:52 -0700 (PDT)
In-Reply-To: <55563902.402@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-05-15 at 14:20 -0400, Jason Baron wrote:
> On 05/15/2015 10:53 AM, Eric Dumazet wrote:
> > While testing tight tcp_mem settings, I found tcp sessions could be
> > stuck because we do not allow even one skb to be received on them.
> >
> > By allowing one skb to be received, we introduce fairness and
> > eventuallu force memory hogs to release their allocation.
> >
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > ---
> >  net/ipv4/tcp_input.c | 10 ++++++----
> >  1 file changed, 6 insertions(+), 4 deletions(-)
> >
> > diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> > index 093779f7e893..f6763faf0a60 100644
> > --- a/net/ipv4/tcp_input.c
> > +++ b/net/ipv4/tcp_input.c
> > @@ -4507,10 +4507,12 @@ static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
> >  
> >  		if (eaten <= 0) {
> >  queue_and_out:
> > -			if (eaten < 0 &&
> > -			    tcp_try_rmem_schedule(sk, skb, skb->truesize))
> > -				goto drop;
> > -
> > +			if (eaten < 0) {
> > +				if (skb_queue_len(&sk->sk_write_queue) == 0)
> 
> I'm confused here. Isn't this about the sk->sk_receive_queue being
> empty? Maybe a comment to help clarify?

Arg you are right of course !

I'll use the proper queue in v2.

Note that only in order packets are going to use this, not out of order
ones.

Thanks
