From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2.41 5/5] datapath: Add basic MPLS support to kernel
Date: Fri, 4 Oct 2013 15:40:16 +0900
Message-ID: <20131004064016.GA8861@verge.net.au>
References: <1380610064-14856-1-git-send-email-horms@verge.net.au>
 <1380610064-14856-6-git-send-email-horms@verge.net.au>
 <CALnjE+qOwkY0NJ=LbT0SgZFmnzvqRHcTS35xWVfMyPtjj4r0ZA@mail.gmail.com>
 <20131003002052.GA13111@verge.net.au>
 <CALnjE+o6TK_2OGbWjZ4EwXMnXw5bzMQH2PeTMJM6nJQV+V147Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>,
	Ben Pfaff <blp@nicira.com>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Joe Stringer <joe@wand.net.nz>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:43466 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750728Ab3JDGkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 02:40:19 -0400
Content-Disposition: inline
In-Reply-To: <CALnjE+o6TK_2OGbWjZ4EwXMnXw5bzMQH2PeTMJM6nJQV+V147Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 03, 2013 at 07:46:46PM -0700, Pravin Shelar wrote:
> On Wed, Oct 2, 2013 at 5:20 PM, Simon Horman <horms@verge.net.au> wrote:
> > On Wed, Oct 02, 2013 at 11:03:57AM -0700, Pravin Shelar wrote:
> >> On Mon, Sep 30, 2013 at 11:47 PM, Simon Horman <horms@verge.net.au> wrote:
> >> > Allow datapath to recognize and extract MPLS labels into flow keys
> >> > and execute actions which push, pop, and set labels on packets.
> >> >
> >> > Based heavily on work by Leo Alterman, Ravi K, Isaku Yamahata and Joe Stringer.
> >> >
> >> > Cc: Ravi K <rkerur@gmail.com>
> >> > Cc: Leo Alterman <lalterman@nicira.com>
> >> > Cc: Isaku Yamahata <yamahata@valinux.co.jp>
> >> > Cc: Joe Stringer <joe@wand.net.nz>
> >> > Signed-off-by: Simon Horman <horms@verge.net.au>
> >> >
> >> > ---
> >> >
> >> > +
> >> > +       /* this hack needed to get regular skb_gso_segment() */
> >> > +#ifdef HAVE___SKB_GSO_SEGMENT
> >> > +#undef __skb_gso_segment
> >> > +       skb_gso = __skb_gso_segment(skb, features, tx_path);
> >> > +#else
> >> > +#undef skb_gso_segment
> >> > +       skb_gso = skb_gso_segment(skb, features);
> >> > +#endif
> >> > +
> >>
> >> We can get rid of #ifdefs by just using different name for
> >> rpl___skb_gso_segment(), something like mpls_vlan_skb_gso_segment().
> >> The way it is done for tnl-gso.
> >
> > Thanks.
> >
> > The reason that I had the code arranged this way was so that
> > calls to __skb_gso_segment() would go via rpl___skb_gso_segment()
> > on kernels older than v3.11. In particular calls outside of gso.c.
> >
> > On closer examination the only such case is in ovs_dp_upcall().
> > Currently there should be no need to perform MPLS GSO segmentation in that
> > case because MPLS GSO segmentation can only be needed after actions are
> > applied.
> >
> > However, I am concerned that it may be necessary later when
> > recirculation is introduced as in that case an upcall may occur
> > on a packet which has had actions applied.
> 
> good point.
> 
> currently we define __skb_gso_segment using skb_gso_segemt(). You have
> reversed it. Is there any reason?
> if you keep it as it is, it can simplify code a bit.

Thanks. I believe that I wanted to use the real __skb_gso_segment()
to back the compat version of __skb_gso_segment(). I can't recall
specifically why and that change seems to be orthogonal to the
MPLS patches.

I have switched things around as you suggested and the code
looks much cleaner. Thanks for the suggestion.
