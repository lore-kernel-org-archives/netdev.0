From: Jim Westfall <jwestfall@surrealistic.net>
Subject: Re: kernel BUG at net/core/skbuff.c:95!
Date: Thu, 21 Feb 2008 11:13:52 -0800
Message-ID: <20080221191352.GV84358@surrealistic.net>
References: <20080220002000.GS84358@surrealistic.net> <20080221054648.GU84358@surrealistic.net> <20080220.215707.194209573.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, acme@ghostprotocols.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from snapper.surrealistic.net ([67.40.222.186]:57549 "EHLO
	snapper.surrealistic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752119AbYBUTOJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 14:14:09 -0500
Content-Disposition: inline
In-Reply-To: <20080220.215707.194209573.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote [02.20.08]:
> From: Jim Westfall <jwestfall@surrealistic.net>
> Date: Wed, 20 Feb 2008 21:46:48 -0800
> 
> > static inline void llc_pdu_init_as_test_rsp(struct sk_buff *skb,
> >                                             struct sk_buff *ev_skb)
> > {
> >         struct llc_pdu_un *pdu = llc_pdu_un_hdr(skb);
> >          
> >         pdu->ctrl_1  = LLC_PDU_TYPE_U;
> >         pdu->ctrl_1 |= LLC_1_PDU_CMD_TEST;
> >         pdu->ctrl_1 |= LLC_U_PF_BIT_MASK;
> >         if (ev_skb->protocol == htons(ETH_P_802_2)) {
> >                 struct llc_pdu_un *ev_pdu = llc_pdu_un_hdr(ev_skb);
> >                 int dsize;
> > 
> >                 dsize = ntohs(eth_hdr(ev_skb)->h_proto) - 3;
> >                 memcpy(((u8 *)pdu) + 3, ((u8 *)ev_pdu) + 3, dsize);
> >                 skb_put(skb, dsize);
> >         }
> > ..
> > }
> 
> Probably what should happen is:
> 

I just started looking at the skbuff|net|llc code last night, hopefully 
these aren't totally stupid questions/comments.

> 1) First this function validates that there are really
>    'dsize' bytes available in the ev_skb source.

looks like this can be done easily with skb_tailroom()..  

I am curious if we should also be verifying that dsize is valid?  Its 
value is coming from a recv'd llc packet.  

The llc header is |mac|mac|16bit length|.  The above code seems to be 
piggy backing a normal ethernet header struct, by using h_proto as the 
llc length.  I am not sure if that length value can be trusted and we run 
the risk of memcpy'ing off the end of the source structure/skbuff?

> 
> 2) Second, skb_realloc_headroom() is called on 'skb' with
>    a second argument of 'dsize'.

This suggestion escapes me.  The skb_put() call in the above 
code would increase skb->tail.  Wont skb_realloc_headroom() create 
additional space between skb->head and skb->data when we really want it 
between skb->tail and skb->end?

thanks
jim

> 
> That means also this function now needs to return error
> values, and the callers updated to handle that.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
