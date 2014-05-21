From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: Re: [PATCH v2.57] datapath: Add basic MPLS support to
	kernel
Date: Thu, 22 May 2014 00:31:54 +0900
Message-ID: <20140521153153.GB10390@verge.net.au>
References: <1400195227-21265-1-git-send-email-horms@verge.net.au>
 <1400195227-21265-2-git-send-email-horms@verge.net.au>
 <CAEP_g=8ZEbx0NzCaXOc=ywiBAtejpmO4K-UzVk5uwBmEfUwZ7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAEP_g=8ZEbx0NzCaXOc=ywiBAtejpmO4K-UzVk5uwBmEfUwZ7w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Tue, May 20, 2014 at 07:30:38PM -0700, Jesse Gross wrote:
> On Thu, May 15, 2014 at 4:07 PM, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org> wrote:
> > diff --git a/datapath/linux/compat/gso.c b/datapath/linux/compat/gso.c
> > index 9ded17c..d9b4485 100644
> > --- a/datapath/linux/compat/gso.c
> > +++ b/datapath/linux/compat/gso.c
> > -#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,37)
> > +#if LINUX_VERSION_CODE < KERNEL_VERSION(3,11,0)
> >  static bool dev_supports_vlan_tx(struct net_device *dev)
> >  {
> > -#if defined(HAVE_VLAN_BUG_WORKAROUND)
> > +#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,37)
> > +       return true;
> 
> Should this be greater than 2.6.37 instead of less than?

Yes, thanks.

> > diff --git a/datapath/linux/compat/include/linux/netdevice.h b/datapath/linux/compat/include/linux/netdevice.h
> > index d726390..0381002 100644
> > --- a/datapath/linux/compat/include/linux/netdevice.h
> > +++ b/datapath/linux/compat/include/linux/netdevice.h
> > +#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,38)
> >  #define netif_skb_features rpl_netif_skb_features
> >  netdev_features_t rpl_netif_skb_features(struct sk_buff *skb);
> 
> Currently this function doesn't look at mpls_features. Should it for
> things other than TSO?

It seems to me that rpl_netif_skb_features is only used by
rpl_dev_queue_xmit().

If that is the case then I don't think it is necessary to examine
mpls_features, which was introduced in v3.11, as rpl_dev_queue_xmit()
only exists for older kernel versions.

> > diff --git a/datapath/linux/compat/netdevice.c b/datapath/linux/compat/netdevice.c
> > index 1dc5abf..d22fced 100644
> > --- a/datapath/linux/compat/netdevice.c
> > +++ b/datapath/linux/compat/netdevice.c
> > @@ -78,6 +83,9 @@ struct sk_buff *rpl_skb_gso_segment(struct sk_buff *skb,
> >         __be16 skb_proto;
> >         struct sk_buff *skb_gso;
> >
> > +       if (eth_p_mpls(skb->protocol))
> > +               type = ovs_skb_get_inner_protocol(skb);
> > +
> >         while (type == htons(ETH_P_8021Q)) {
> >                 struct vlan_hdr *vh;
> 
> Is the ordering on this backwards given that we expect that VLANs can
> be on the outside but not the other way around?

Yes, I think so.

I will change this around as follows:

diff --git a/datapath/linux/compat/netdevice.c b/datapath/linux/compat/netdevice.c
index d22fced..d63f1f5 100644
--- a/datapath/linux/compat/netdevice.c
+++ b/datapath/linux/compat/netdevice.c
@@ -83,9 +83,6 @@ struct sk_buff *rpl_skb_gso_segment(struct sk_buff *skb,
 	__be16 skb_proto;
 	struct sk_buff *skb_gso;
 
-	if (eth_p_mpls(skb->protocol))
-		type = ovs_skb_get_inner_protocol(skb);
-
 	while (type == htons(ETH_P_8021Q)) {
 		struct vlan_hdr *vh;
 
@@ -97,6 +94,9 @@ struct sk_buff *rpl_skb_gso_segment(struct sk_buff *skb,
 		vlan_depth += VLAN_HLEN;
 	}
 
+	if (eth_p_mpls(type))
+		type = ovs_skb_get_inner_protocol(skb);
+
 	/* this hack needed to get regular skb_gso_segment() */
 #undef skb_gso_segment
 	skb_proto = skb->protocol;
