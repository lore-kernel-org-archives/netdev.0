From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: Re: [PATCH v2.39 7/7] datapath: Add basic MPLS support to
 kernel
Date: Thu, 19 Sep 2013 13:45:37 -0700
Message-ID: <20130919204214.GA2734@verge.net.au>
References: <1378711207-29890-1-git-send-email-horms@verge.net.au>
	<1378711207-29890-8-git-send-email-horms@verge.net.au>
	<CALnjE+p9g+GO71yjcNVG+y9ZzvT_==SLSqAAqGHU_jg=sx7Ynw@mail.gmail.com>
	<20130918220756.GA24919@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Isaku Yamahata <yamahata-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
To: Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130918220756.GA24919-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 18, 2013 at 05:07:59PM -0500, Simon Horman wrote:
> On Tue, Sep 17, 2013 at 11:38:18AM -0700, Pravin Shelar wrote:
> > On Mon, Sep 9, 2013 at 12:20 AM, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org> wrote:
> > > Allow datapath to recognize and extract MPLS labels into flow keys
> > > and execute actions which push, pop, and set labels on packets.
> > >
> > > Based heavily on work by Leo Alterman, Ravi K, Isaku Yamahata and Joe Stringer.
> > >
> > > Cc: Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > > Cc: Leo Alterman <lalterman-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
> > > Cc: Isaku Yamahata <yamahata-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
> > > Cc: Joe Stringer <joe-Q1GJJQv1iO6lP80pJB477g@public.gmane.org>
> > > Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
> > >
> > > ---
> > ....
> > > diff --git a/datapath/datapath.h b/datapath/datapath.h
> > > index 5d50dd4..babae3b 100644
> > > --- a/datapath/datapath.h
> > > +++ b/datapath/datapath.h
> > > @@ -36,6 +36,10 @@
> > >
> > >  #define SAMPLE_ACTION_DEPTH 3
> > >
> > > +#if LINUX_VERSION_CODE >= KERNEL_VERSION(3,11,0)
> > > +#define HAVE_INNER_PROTOCOL
> > > +#endif
> > > +
> > >  /**
> > >   * struct dp_stats_percpu - per-cpu packet processing statistics for a given
> > >   * datapath.
> > > @@ -93,11 +97,16 @@ struct datapath {
> > >   * @pkt_key: The flow information extracted from the packet.  Must be nonnull.
> > >   * @tun_key: Key for the tunnel that encapsulated this packet. NULL if the
> > >   * packet is not being tunneled.
> > > + * @inner_protocol: Provides a substitute for the skb->inner_protocol field on
> > > + * kernels before 3.11.
> > >   */
> > >  struct ovs_skb_cb {
> > >         struct sw_flow          *flow;
> > >         struct sw_flow_key      *pkt_key;
> > >         struct ovs_key_ipv4_tunnel  *tun_key;
> > > +#ifndef HAVE_INNER_PROTOCOL
> > > +       __be16                  inner_protocol;
> > > +#endif
> > >  };
> > >  #define OVS_CB(skb) ((struct ovs_skb_cb *)(skb)->cb)
> > >
> > Can you move this to compat struct ovs_gso_cb {}
> 
> I think that you are correct and inner_protocol needs
> to be in struct ovs_gso_cb so that it can
> be accessed via skb_network_protocol() from
> rpl___skb_gso_segment().
> 
> However I think it may also need to be present in struct ovs_cb
> so that it can be set correctly.
> 
> Currently it is set unconditionally
> in ovs_execute_actions() and Jesse has suggested setting
> it conditionally in pop_mpls() (which is called by do_execute_actions()).
> But regardless it seems to me that the field would need to be available
> in struct ovs_cb.

Having reviewed the code once more I now notice that struct ovs_gso_cb
contains struct ovs_skb_cb dp_cb. Whereas my previous assumption was
that they were mutually exclusive.

With this in mind I think it should be safe to use ovs_gso_cb from
ovs_execute_actions() or do_execute_actions() but I would value
your opinion on that.

Conversely, if inner_protocol was left in struct ovs_skb_cb there should
be no problem with accessing it from GSO code as the code currently does.
So I am not sure that I see the value of moving it but I am happy to do
so if you think it is safe and it is your preferred option.
