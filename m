From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 12/21] [TCP]: Introduce per skb fack_counts to retransmit
 queue
Date: Sun, 2 Dec 2007 13:29:36 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712021321410.6477@kivilampi-30.cs.helsinki.fi>
References: <1196549296278-git-send-email-ilpo.jarvinen@helsinki.fi>
 <11965492961750-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1196549296588-git-send-email-ilpo.jarvinen@helsinki.fi>
 <11965492962509-git-send-email-ilpo.jarvinen@helsinki.fi>
 <11965492962214-git-send-email-ilpo.jarvinen@helsinki.fi>
 <11965492963057-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1196549296324-git-send-email-ilpo.jarvinen@helsinki.fi>
 <11965492962283-git-send-email-ilpo.jarvinen@helsinki.fi>
 <11965492961234-git-send-email-ilpo.jarvinen@helsinki.fi>
 <11965492963381-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20071202062751.GA30937@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-79147188-1196594551=:6477"
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:56191 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751684AbXLBL3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Dec 2007 06:29:37 -0500
In-Reply-To: <20071202062751.GA30937@gondor.apana.org.au>
Content-ID: <Pine.LNX.4.64.0712021324020.6477@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-79147188-1196594551=:6477
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0712021323091.6477@kivilampi-30.cs.helsinki.fi>

On Sun, 2 Dec 2007, Herbert Xu wrote:

> On Sun, Dec 02, 2007 at 12:48:07AM +0200, Ilpo Järvinen wrote:
> >
> > @@ -1220,6 +1221,11 @@ static inline struct sk_buff *tcp_write_queue_next(struct sock *sk, struct sk_bu
> >  	return skb->next;
> >  }
> > 
> > +static inline struct sk_buff *tcp_write_queue_prev(struct sock *sk, struct sk_buff *skb)
> > +{
> > +	return skb->prev;
> > +}
> > +
> >  #define tcp_for_write_queue(skb, sk)					\
> >  		for (skb = (sk)->sk_write_queue.next;			\
> >  		     (skb != (struct sk_buff *)&(sk)->sk_write_queue);	\
> > @@ -1241,6 +1247,11 @@ static inline struct sk_buff *tcp_send_head(struct sock *sk)
> > 
> >  static inline void tcp_advance_send_head(struct sock *sk, struct sk_buff *skb)
> >  {
> > +	struct sk_buff *prev = tcp_write_queue_prev(sk, skb);
> > +
> > +	TCP_SKB_CB(skb)->fack_count = TCP_SKB_CB(prev)->fack_count +
> > +				      tcp_skb_pcount(prev);
> > +
> >  	sk->sk_send_head = skb->next;
> >  	if (sk->sk_send_head == (struct sk_buff *)&sk->sk_write_queue)
> >  		sk->sk_send_head = NULL;
> 
> This crashed my machine on boot.  The reason is that prev was empty.
> I've added this fix to net-2.6.25.

Hmm didn't crash for me, probably a silent corruption instead :-(.

> [TCP]: Fix crash in tcp_advance_send_head
> 
> We need to check whether there is a prev in tcp_advance_send_head
> before dereferencing it. This patch does just that and leaves the
> fack count at zero if there is no prev.

Maybe I could add catch for invalid skb dereferences (those list heads) to 
TCP_SKB_CB and tcp_skb_pcount if some DEBUG thing is set. Those two should 
catch at least 98% of the invalid users.

...Not sure if CONFIG_DEBUG_LIST is right one to use, suggestion welcome.

-- 
 i.
---696243703-79147188-1196594551=:6477--
