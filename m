From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH v4 for-next 00/12] Add network namespace support in the
 RDMA-CM
Date: Thu, 4 Jun 2015 10:40:58 -0600
Message-ID: <20150604164058.GB27699@obsidianresearch.com>
References: <1432837360.114391.35.camel@redhat.com>
 <CAJ3xEMh2T5-56rFxWVdct2uAZYW1ZrKivWfS45V-mvhAfwyGaA@mail.gmail.com>
 <1432850150.114391.56.camel@redhat.com>
 <556ED0D5.8010502@mellanox.com>
 <20150603161447.GC12073@obsidianresearch.com>
 <CAJ3xEMjM53sYuEgQV3WPaN4WErk_YcojPY2zBcmq-+3W2dfD+A@mail.gmail.com>
 <20150603195325.GC7902@obsidianresearch.com>
 <CAJ3xEMiO+hEzOJ2oJ5G-mmBeaX4ZHvUyhNSAzsrRDui6dFjvCg@mail.gmail.com>
 <20150603234811.GA15128@obsidianresearch.com>
 <556FEF25.80409@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <556FEF25.80409-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 04, 2015 at 09:24:37AM +0300, Haggai Eran wrote:
> > The l2/l3 distinction in ipvlan is also very interesting. The L3 mode
> > solves some of the security type issues. What do you think Haggi?

> I think some issues ipvlan is trying to solve would also affect us using
> the alias GUIDs solution. ipvlan tries to solve among other the problem
> of a limited MAC filter table in NICs, and avoid using promiscuous mode.
> But the GID table is also limited, and we don't have something like
> promiscuous mode for GIDs in InfiniBand. For large scale use of
> containers we would need to also allow the current model.

Yes, that is certainly true.

> As for L3 mode, it does seem more restrictive, as all routing decisions
> are done in the controlling namespace. Our current ipoib child interface
> implementation is more like the L2 version of ipvlan.

The ipoib children are exactly like macvlan, because they all have
unique LLADDRs.

It doesn't start acting like ipvlan until we reach the rdma-cm patches,
and where we see the IP stack side act like macvlan and the rdma-cm
side try to act like ipvlan - that is why it is so ugly/hacky,

> > Is there any chance standard things like ipvlan and macvlan could be
> > used with rdma-cm if their master devices are IPoIB?

> These standard interfaces seem very much connected with Ethernet (both
> have an ARPHDR_ETHER-only check for their upper devices). I think
> macvlan's functionality would be covered by adding alias GUIDs to ipoib,
> and ipvlan L2 is covered by the current behavior. Perhaps it would be
> beneficial to try and make ipvlan more generic so that it would work
> over ipoib, giving us support for L3 mode.

Yes, macvlan seems very well covered already by IPoIB child
interfaces, and I don't see too many reasons to worry about changing
that.

ipvlan on the other hand, as you observe, is valuable for many reasons.

> As for rdma-cm support, the patch I had for ipoib attempts to scan each
> child's upper devices in order to support such topologies. We only
> tested it with bonding, but I think it would also work with such devices.

.. it is so sketchy :|

Firstly: I still think the prior discussion is right, and proceeding
along the reworking of the ingress side of rdma-cm and focusing on the
device,guid,pkey makes 100% sense and will progress things right
away. Every other variation seems to build on that.

But when we get into bonding and the various vlan things, we loose
encapsulation - snooping the children list to guess what the bonding
driver is doing seems very hacky.

Discussion idea: Can we actually use the netstack to process the
RDMA-CM packets? It looks like the netstack wants a skb to do this
mid-layer work, so rdma-cm would have to synthesize a skb for the CM
packets and pass it through netdev to apply all the transformations
and access the various internal states (eg from ipvlan, bonding,
etc). rdma-cm would have to 'catch' the skb once it is done traveling
and resume its normal processing. Very similar to your notion of using
UDP, but without any on-the-wire change.

This would fit in that same ingress spot I suggested adding the
routing lookup, instead of routing we want the full stack to have a go
at figuring out the final netdev.

This seems the most general because it will work for all the *vlan
type drivers, bonding, and all of the RDMA technologies. (each would
have a slightly different way to make the skb, but same basic idea)

Lots and lots of details to do that, but conceptually it seems pretty
solid?

> Yes, for RoCE our goal for the start was to support namespaces in RDMA
> CM through macvlan devices. As long as we can update the RoCE gid table
> correctly for macvlan and ipvlan devices, the RDMA CM implementation
> shouldn't care where the details come from.

Hurm, the gid index tagged on the QP1 packet should not be directly
used for much on ingress. rdma-cm will have to recover the mac address
and vlan to use that as a guide.

Synchronizing the gid table and all the internal state in macvlan,
ipvlan, bonding seems very hard, I do not envy your task :(

> > Any thoughts on the idea we still need ipoib same-guid children if
> > ipvlan is available?
> If we port ipvlan to work over IPoIB interfaces and not just Ethernet,
> then ipvlan L2 would provide exactly the same functionality. There onyl
> difference I can think of is that ipvlan would use a single UD QP for
> all devices (and in connected-mode, a single RC QP between a pair of
> hosts), while ipoib would use a QP per child device, and multiple RC QPs
> for such pairs.

Agree with this.

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
