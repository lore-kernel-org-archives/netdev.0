From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH v9 net-next 3/7] openvswitch: add support to push and pop
 mpls for layer3 packets
Date: Fri, 6 May 2016 13:33:06 +0900
Message-ID: <20160506043304.GA9342@penelope.isobedori.kobe.vergenet.net>
References: <1462347393-22354-1-git-send-email-simon.horman@netronome.com>
 <1462347393-22354-4-git-send-email-simon.horman@netronome.com>
 <CAOrHB_A__kJiHOTRNd3Vj4sF2dcEw5w33_PpJLR_hosvbKG52A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ovs dev <dev@openvswitch.org>
To: pravin shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34675 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbcEFEdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 00:33:16 -0400
Received: by mail-pa0-f43.google.com with SMTP id r5so44370423pag.1
        for <netdev@vger.kernel.org>; Thu, 05 May 2016 21:33:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAOrHB_A__kJiHOTRNd3Vj4sF2dcEw5w33_PpJLR_hosvbKG52A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 05, 2016 at 10:35:52AM -0700, pravin shelar wrote:
> On Wed, May 4, 2016 at 12:36 AM, Simon Horman
> <simon.horman@netronome.com> wrote:
> > Allow push and pop mpls actions to act on layer 3 packets by teaching
> > them not to access non-existent L2 headers of such packets.
> >
> > Signed-off-by: Simon Horman <simon.horman@netronome.com>
> > ---
> > v9
> > * New Patch
> > ---
> >  net/openvswitch/actions.c | 22 ++++++++++++++--------
> >  1 file changed, 14 insertions(+), 8 deletions(-)
> >
> > diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> > index 879185fe183f..fe885a89f501 100644
> > --- a/net/openvswitch/actions.c
> > +++ b/net/openvswitch/actions.c
> > @@ -160,8 +160,10 @@ static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
> >
> >         skb_postpush_rcsum(skb, new_mpls_lse, MPLS_HLEN);
> >
> > -       hdr = eth_hdr(skb);
> > -       hdr->h_proto = mpls->mpls_ethertype;
> > +       if (skb->mac_len) {
> can you move hdr definition to this block?

Sure, sorry for overlooking that.

> > +               hdr = eth_hdr(skb);
> > +               hdr->h_proto = mpls->mpls_ethertype;
> > +       }
> >
> We need to update skb checksum here.  This bug is not related to your
> patch. since you are changing this code can you also fix this?

Yes, of course. Would something like this broken out into a patch earlier
in the series resolve the problem you see? If so it looks like a similar
fix is also needed for pop_mpls().

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 63d29263d51a..89ad0027420a 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -161,6 +160,14 @@ static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 		struct ethhdr *hdr;
 
 		hdr = eth_hdr(skb);
+
+		if (skb->ip_summed == CHECKSUM_COMPLETE) {
+			__be16 diff[] = { ~(hdr->h_proto), mpls->mpls_ethertype };
+
+			skb->csum = ~csum_partial((char *)diff, sizeof(diff),
+						~skb->csum);
+		}
+
 		hdr->h_proto = mpls->mpls_ethertype;
 	}
 

> 
> >         if (!skb->inner_protocol)
> >                 skb_set_inner_protocol(skb, skb->protocol);
> > @@ -174,7 +176,6 @@ static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
> >  static int pop_mpls(struct sk_buff *skb, struct sw_flow_key *key,
> >                     const __be16 ethertype)
> >  {
> > -       struct ethhdr *hdr;
> >         int err;
> >
