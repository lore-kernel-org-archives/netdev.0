From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] vxlan: use ether header as fallback hash
Date: Thu, 4 Oct 2012 09:43:33 -0700
Message-ID: <20121004094333.748158e2@nehalam.linuxnetplumber.net>
References: <20121001223232.566037595@vyatta.com>
	<20121001223254.349753999@vyatta.com>
	<CAEP_g=9Y3MmsABQJyi508FEgs4635tnaVqk4Ncwbpm41bLskhg@mail.gmail.com>
	<20121003213906.09b57539@nehalam.linuxnetplumber.net>
	<CAEP_g=8F_s3H4MCBf=xKWdASdtpZ7V_tOSGtZpv7ONULegP4ow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37373 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932263Ab2JDQoK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Oct 2012 12:44:10 -0400
In-Reply-To: <CAEP_g=8F_s3H4MCBf=xKWdASdtpZ7V_tOSGtZpv7ONULegP4ow@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 4 Oct 2012 09:27:14 -0700
Jesse Gross <jesse@nicira.com> wrote:

> On Wed, Oct 3, 2012 at 9:39 PM, Stephen Hemminger <shemminger@vyatta.com> wrote:
> > VXLAN bases source UDP port based on flow to help the
> > receiver to be able to load balance based on outer header
> > contents.
> >
> > This patches changes the algorithm to better handle packets
> > that can not be categorized by the rxhash() function.
> > It adds a fallback to use jhash on the Ether header.
> >
> > It also fixes a bug where the old code could assign 0 as a port
> > value.
> >
> >
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >
> > ---
> > RFC for now, compile tested only
> >
> > --- a/drivers/net/vxlan.c       2012-10-03 21:25:43.747968165 -0700
> > +++ b/drivers/net/vxlan.c       2012-10-03 21:36:10.213805422 -0700
> > @@ -622,12 +622,30 @@ static inline u8 vxlan_ecn_encap(u8 tos,
> >         return INET_ECN_encapsulate(tos, inner);
> >  }
> >
> > +/* Compute hash to use for source port
> > + *   first choice to use L4 flow hash since it will spread
> > + *     better and maybe available from hardware
> > + *   secondary choice is to use jhash on the Ethernet header
> > + * Always returns non-zero value
> > + */
> > +static u16 vxlan_flow_hash(struct sk_buff *skb)
> > +{
> > +       u16 hash = skb_get_rxhash(skb);
> > +
> > +       if (!hash)
> > +               hash = jhash(skb->data, 3, skb->protocol);
> 
> Shouldn't this be jhash2 for words?

No. for a couple of reasons. First, the ethernet header may not be aligned.
Second we want to get source/destination and type.  The source/destination
is 12 bytes (3 words) and the ether type is already in skb->protocol.
