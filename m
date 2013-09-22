From: Simon Horman <horms@verge.net.au>
Subject: Re: [ovs-dev] [PATCH v2.39 7/7] datapath: Add basic MPLS support to
 kernel
Date: Sun, 22 Sep 2013 12:54:11 +0900
Message-ID: <20130922035411.GA9693@verge.net.au>
References: <1378711207-29890-1-git-send-email-horms@verge.net.au>
 <1378711207-29890-8-git-send-email-horms@verge.net.au>
 <CALnjE+p9g+GO71yjcNVG+y9ZzvT_==SLSqAAqGHU_jg=sx7Ynw@mail.gmail.com>
 <20130918220756.GA24919@verge.net.au>
 <20130919204214.GA2734@verge.net.au>
 <CALnjE+oY5P5kwyuWNBde3+EbQq8kMqCTSz+KrH=bwOmLE9SSPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	Ravi K <rkerur@gmail.com>, netdev <netdev@vger.kernel.org>,
	Isaku Yamahata <yamahata@valinux.co.jp>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:34925 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752961Ab3IVLYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Sep 2013 07:24:07 -0400
Content-Disposition: inline
In-Reply-To: <CALnjE+oY5P5kwyuWNBde3+EbQq8kMqCTSz+KrH=bwOmLE9SSPQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 19, 2013 at 06:31:14PM -0700, Pravin Shelar wrote:
> On Thu, Sep 19, 2013 at 1:45 PM, Simon Horman <horms@verge.net.au> wrote:
> > On Wed, Sep 18, 2013 at 05:07:59PM -0500, Simon Horman wrote:
> >> On Tue, Sep 17, 2013 at 11:38:18AM -0700, Pravin Shelar wrote:
> >> > On Mon, Sep 9, 2013 at 12:20 AM, Simon Horman <horms@verge.net.au> wrote:
> >> > > Allow datapath to recognize and extract MPLS labels into flow keys
> >> > > and execute actions which push, pop, and set labels on packets.
> >> > >
> >> > > Based heavily on work by Leo Alterman, Ravi K, Isaku Yamahata and Joe Stringer.
> >> > >
> >> > > Cc: Ravi K <rkerur@gmail.com>
> >> > > Cc: Leo Alterman <lalterman@nicira.com>
> >> > > Cc: Isaku Yamahata <yamahata@valinux.co.jp>
> >> > > Cc: Joe Stringer <joe@wand.net.nz>
> >> > > Signed-off-by: Simon Horman <horms@verge.net.au>
> >> > >
> >> > > ---
> >> > ....
> >> > > diff --git a/datapath/datapath.h b/datapath/datapath.h
> >> > > index 5d50dd4..babae3b 100644
> >> > > --- a/datapath/datapath.h
> >> > > +++ b/datapath/datapath.h
> >> > > @@ -36,6 +36,10 @@
> >> > >
> >> > >  #define SAMPLE_ACTION_DEPTH 3
> >> > >
> >> > > +#if LINUX_VERSION_CODE >= KERNEL_VERSION(3,11,0)
> >> > > +#define HAVE_INNER_PROTOCOL
> >> > > +#endif
> >> > > +
> >> > >  /**
> >> > >   * struct dp_stats_percpu - per-cpu packet processing statistics for a given
> >> > >   * datapath.
> >> > > @@ -93,11 +97,16 @@ struct datapath {
> >> > >   * @pkt_key: The flow information extracted from the packet.  Must be nonnull.
> >> > >   * @tun_key: Key for the tunnel that encapsulated this packet. NULL if the
> >> > >   * packet is not being tunneled.
> >> > > + * @inner_protocol: Provides a substitute for the skb->inner_protocol field on
> >> > > + * kernels before 3.11.
> >> > >   */
> >> > >  struct ovs_skb_cb {
> >> > >         struct sw_flow          *flow;
> >> > >         struct sw_flow_key      *pkt_key;
> >> > >         struct ovs_key_ipv4_tunnel  *tun_key;
> >> > > +#ifndef HAVE_INNER_PROTOCOL
> >> > > +       __be16                  inner_protocol;
> >> > > +#endif
> >> > >  };
> >> > >  #define OVS_CB(skb) ((struct ovs_skb_cb *)(skb)->cb)
> >> > >
> >> > Can you move this to compat struct ovs_gso_cb {}
> >>
> >> I think that you are correct and inner_protocol needs
> >> to be in struct ovs_gso_cb so that it can
> >> be accessed via skb_network_protocol() from
> >> rpl___skb_gso_segment().
> >>
> >> However I think it may also need to be present in struct ovs_cb
> >> so that it can be set correctly.
> >>
> >> Currently it is set unconditionally
> >> in ovs_execute_actions() and Jesse has suggested setting
> >> it conditionally in pop_mpls() (which is called by do_execute_actions()).
> >> But regardless it seems to me that the field would need to be available
> >> in struct ovs_cb.
> >
> > Having reviewed the code once more I now notice that struct ovs_gso_cb
> > contains struct ovs_skb_cb dp_cb. Whereas my previous assumption was
> > that they were mutually exclusive.
> >
> > With this in mind I think it should be safe to use ovs_gso_cb from
> > ovs_execute_actions() or do_execute_actions() but I would value
> > your opinion on that.
> >
> > Conversely, if inner_protocol was left in struct ovs_skb_cb there should
> > be no problem with accessing it from GSO code as the code currently does.
> > So I am not sure that I see the value of moving it but I am happy to do
> > so if you think it is safe and it is your preferred option.
> 
> right, access is not issue.
> Value is the code in datapath.c, with compatibility, remains closer to
> upstream ovs module. We have always tried to keep it that way.

Thanks, I understand.
I have moved inner_protocol as you suggest.
