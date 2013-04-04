From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: Re: [PATCH v2] MPLS: Add limited GSO support
Date: Thu, 4 Apr 2013 09:55:39 +0900
Message-ID: <20130404005539.GA17694@verge.net.au>
References: <1364980315-13649-1-git-send-email-horms@verge.net.au>
	<CAEP_g=_Y0hN2DvyO4JitMrpQvN=TmTO5Pk28DpvF6Ya09AeTcg@mail.gmail.com>
	<20130404002809.GF29678@verge.net.au>
	<CAEP_g=9cnm39i7rBk=Pi_1e6dFDLMa6oVFuO3PufEhODCVBqnw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAEP_g=9cnm39i7rBk=Pi_1e6dFDLMa6oVFuO3PufEhODCVBqnw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

On Wed, Apr 03, 2013 at 05:44:17PM -0700, Jesse Gross wrote:
> On Wed, Apr 3, 2013 at 5:28 PM, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org> wrote:
> > On Wed, Apr 03, 2013 at 04:51:38PM -0700, Jesse Gross wrote:
> >> On Wed, Apr 3, 2013 at 2:11 AM, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org> wrote:
> >> > In the case where a non-MPLS packet is recieved and an MPLS stack is
> >> > added it may well be the case that the original skb is GSO but the
> >> > NIC used for transmit does not support GSO of MPLS packets.
> >> >
> >> > The aim of this code is to provide GSO in software for MPLS packets
> >> > whose skbs are GSO.
> >> >
> >> > When an implementation adds an MPLS stack to a non-MPLS packet it should do
> >> > the following to skb metadata:
> >> >
> >> > * Set skb_mac_header(skb)->protocol to the new MPLS ethertype.
> >> >   That is, either ETH_P_MPLS_UC or ETH_P_MPLS_MC.
> >> >
> >> > * Leave skb->protocol as the old non-MPLS ethertype.
> >> >
> >> > * Set skb->encapsulation = 1.
> >> >
> >> >   This may not strictly be necessary as I believe that checking
> >> >   skb_mac_header(skb)->protocol and skb->protocol should be necessary and
> >> >   sufficient.
> >> >
> >> >   However, it does seem to fit nicely with the current implementation of
> >> >   dev_hard_start_xmit() where the more expensive check of
> >> >   skb_mac_header(skb)->protocol may be guarded by an existing check of
> >> >   skb->encapsulation.
> >> >
> >> > One aspect of this patch that I am unsure about is the modification I have
> >> > made to skb_segment(). This seems to be necessary as checskum accelearation
> >> > may no longer be possible as the packet has changed to be MPLS from some
> >> > other packet type which may have been supported by the hardware in use.
> >> >
> >> > I will post a patch, "[PATCH v3.24] datapath: Add basic MPLS support to
> >> > kernel" which adds MPLS support to the kernel datapath of Open vSwtich.
> >> > That patch sets the above requirements in
> >> > datapath/actions.c:set_ethertype() and was used to exercise the MPLS GSO
> >> > code. The datapath patch is against the Open vSwtich tree but it is
> >> > intended that it be added to the Open vSwtich code present in the mainline
> >> > Linux kernel at some point.
> >> >
> >> > Suggested by Jesse Gross. Based heavily on "v4 GRE: Add TCP segmentation
> >> > offload for GRE" by Pravin B Shelar.
> >> >
> >> > Cc: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
> >> > Cc: Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
> >> > Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
> >>
> >> MPLS is very similar to both the Ethernet header and vlans in that GSO
> >> only requires replication without any modification.  That means that
> >> if we look at the mac_len as containing all three then we can just
> >> copy it without any special knowledge.  I don't know that we carefully
> >> maintain mac_len in all places but you are already doing that in your
> >> MPLS patches.
> >
> > At least for the cases that I am aware of I think that mac_len is
> > predictable. But I'm a little unsure of what you are getting at here.
> 
> If you have the MAC len then you don't need any new MPLS code here at
> all; just replicate the whole thing onto each packet.

The MAC len is set to cover everything up to the top of the MPLS stack.
So it seems that something needs to be done to account for the length
of the MPLS stack.

Are you suggesting that if Open vSwtich set up the MAC len to extend
to the end of the MPLS stack then mpls_gro_segment() would not be necessary?
