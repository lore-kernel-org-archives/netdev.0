From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [RFC] tcp: add support for scheduling TCP options on TCP sockets
Date: Wed, 7 May 2014 15:46:20 +0200
Message-ID: <20140507134620.GF4686@cpaasch-mac>
References: <1399399524-28550-1-git-send-email-octavian.purdila@intel.com>
 <20140507.013820.1357850416047414291.davem@davemloft.net>
 <bc98535539ef4d2c9cb6f53f85068b65@UCL-MBX03.OASIS.UCLOUVAIN.BE>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Octavian Purdila <octavian.purdila@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:57837 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755400AbaEGNy7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 09:54:59 -0400
Content-Disposition: inline
In-Reply-To: <bc98535539ef4d2c9cb6f53f85068b65@UCL-MBX03.OASIS.UCLOUVAIN.BE>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Octavian,

On 07/05/14 - 07:30:23, Octavian Purdila wrote:
> On Wed, May 7, 2014 at 8:38 AM, David Miller <davem@davemloft.net> wrote:
> > Sorry I don't like this.
> >
> > Walking a linked list unnecessary is going to add overhead to every
> > single packet transmission.  I think more people want our TCP stack to
> > be fast (everyone) than those who want option processing to be
> > abstracted enough to be modular (you).
> >
> > Just make the intrusive changes, they are necessary as they force you
> > to think fully about how one option might interact with another.
> >
> 
> Unfortunately skb_tcp_cb does not have enough space to hold
> information for new large options. To work around that, the MPTCP
> implementation is pushing the option data in the skb and then
> occasionally uses the following when the pskb_copy is used:
> 
> -               else
> +               if (unlikely(skb_cloned(skb))) {
> +                       struct sk_buff *newskb;
> +                       if (mptcp_is_data_seq(skb))
> +                               skb_push(skb, MPTCP_SUB_LEN_DSS_ALIGN +
> +                                             MPTCP_SUB_LEN_ACK_ALIGN +
> +                                             MPTCP_SUB_LEN_SEQ_ALIGN);
> +
> +                       newskb = pskb_copy(skb, gfp_mask);
> +
> +                       if (mptcp_is_data_seq(skb)) {
> +                               skb_pull(skb, MPTCP_SUB_LEN_DSS_ALIGN +
> +                                             MPTCP_SUB_LEN_ACK_ALIGN +
> +                                             MPTCP_SUB_LEN_SEQ_ALIGN);
> +                               if (newskb)
> +                                       skb_pull(newskb,
> MPTCP_SUB_LEN_DSS_ALIGN +
> +
> MPTCP_SUB_LEN_ACK_ALIGN +
> +
> MPTCP_SUB_LEN_SEQ_ALIGN);
> +                       }
> +                       skb = newskb;
> +               } else {
>                         skb = skb_clone(skb, gfp_mask);
> +               }
> 
> MPTCP has many other intrusive changes in the TCP stack. To avoid that
> complexity, we could do the bulk of the implementation in a separate
> layer, on top of TCP. But we would need a mechanism to pass the
> options down to the TCP layer somehow.

Why not extend the head-space of the linear data of the skb as we discussed
already previously on mptcp-dev? Just in a similar way as 'struct can_skb_priv'
is being used. This would avoid this expensive list-processing and clean up
the above example you give.

Or did something else prevented to do it in such a way?

> > I also disagree with the "if the option doesn't fit, send it in the
> > next packet" idea.  Where did that come from?
> >
> > For SACK for example, that doesn't make any sense, and it's SACK
> > that usually can put us past the amount of space available.  For
> > SACK the thing to do is send the SACK information for the area
> > closest to what we've fully ACKd and just forget about advertising
> > the rest of the SACK blocks.
> 
> It is useful for MPTCP. A few MPTCP options are 12-20 bytes but if you
> already have timestamps and SACK in the packet there is not enough
> space to include it. However, MPTCP does not bound you to sent the
> options immediately, they can be sent at a later time.

Be careful which options you defer to a later time.

For the DSS-option it is better to temporarily reduce the number of 
SACK-blocks to 2 instead of ommitting the DSS-option. Otherwise, you
need to support at the receiver late receival of DSS-options inside pure acks 
(probably out-of-order) - and thus be able to store a list of DSS-options.

Only ADD_ADDR/REMOVE_ADDR and MP_PRIO should be allowed to be sent at a
'later' time. But for them you can also explicitly schedule an ack.


Cheers,
Christoph

> The patch may look like an "abstraction bloat", but it is just a way
> of trying to to keep adding more complexity in the TCP stack when
> implementing MPTCP. If people have other ideas of how can we
> accomplish that, so that we can integrate MPTCP upstream, I am keenly
> looking for suggestions.
