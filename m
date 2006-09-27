From: Michal Ostrowski <mostrows@earthlink.net>
Subject: Re: [PATCH] Advertise PPPoE MTU / avoid memory leak.
Date: Wed, 27 Sep 2006 08:53:38 -0500
Message-ID: <1159365219.23197.340.camel@brick.austin.ibm.com>
References: <115903262344-git-send-email-mostrows@earthlink.net>
	 <Pine.LNX.4.64.0609260931490.3774@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ppp-bugs@dp.samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from igw2.watson.ibm.com ([129.34.20.6]:41430 "EHLO
	igw2.watson.ibm.com") by vger.kernel.org with ESMTP id S932209AbWI0N4Y
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 09:56:24 -0400
To: Pekka Savola <pekkas@netcore.fi>
In-Reply-To: <Pine.LNX.4.64.0609260931490.3774@netcore.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is not currently supported.

Looking at the RFC, this is an issue that must be solved in the pppoe
plugin that performs the PPPoE negotiation/discovery.  The kernel code
that runs the regular session traffic should be able to adjust (with
minimal or no changes) as it does not depend on a hardcoded MTU.



-- 
Michal Ostrowski <mostrows@earthlink.net>

On Tue, 2006-09-26 at 09:32 +0300, Pekka Savola wrote:
> Speaking of PPPoE and MTU, does Linux support recently-published RFC 
> 4638:
> 
>    Accommodating a Maximum Transit Unit/Maximum Receive Unit (MTU/MRU)
>                         Greater Than 1492 in the
>               Point-to-Point Protocol over Ethernet (PPPoE)
> 
> On Sat, 23 Sep 2006, mostrows@earthlink.net wrote:
> > PPPoE must advertise the underlying device's MTU via the ppp channel
> > descriptor structure, as multilink functionality depends on it.
> >
> > __pppoe_xmit must free any skb it allocates if there is an error
> > submitting the skb downstream.
> >
> > Signed-off-by: Michal Ostrowski <mostrows@earthlink.net>
> > ---
> > drivers/net/pppoe.c |    5 ++++-
> > 1 files changed, 4 insertions(+), 1 deletions(-)
> >
> > diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
> > index 475dc93..b4dc516 100644
> > --- a/drivers/net/pppoe.c
> > +++ b/drivers/net/pppoe.c
> > @@ -600,6 +600,7 @@ static int pppoe_connect(struct socket *
> > 		po->chan.hdrlen = (sizeof(struct pppoe_hdr) +
> > 				   dev->hard_header_len);
> >
> > +		po->chan.mtu = dev->mtu - sizeof(struct pppoe_hdr);
> > 		po->chan.private = sk;
> > 		po->chan.ops = &pppoe_chan_ops;
> >
> > @@ -831,7 +832,7 @@ static int __pppoe_xmit(struct sock *sk,
> > 	struct pppoe_hdr *ph;
> > 	int headroom = skb_headroom(skb);
> > 	int data_len = skb->len;
> > -	struct sk_buff *skb2;
> > +	struct sk_buff *skb2 = NULL;
> >
> > 	if (sock_flag(sk, SOCK_DEAD) || !(sk->sk_state & PPPOX_CONNECTED))
> > 		goto abort;
> > @@ -887,6 +888,8 @@ static int __pppoe_xmit(struct sock *sk,
> > 	return 1;
> >
> > abort:
> > +	if (skb2)
> > +		kfree_skb(skb2);
> > 	return 0;
> > }
> >
> >
> 

