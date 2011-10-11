From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [net-next PATCH] net: allow vlan traffic to be received under bond
Date: Tue, 11 Oct 2011 13:08:51 +0200
Message-ID: <201110111308.53152.hans.schillstrom@ericsson.com>
References: <20111010191641.2496.84845.stgit@jf-dev1-dcblab> <4E93A4D2.10301@intel.com>  <CAEP_g=83tCQMVPOTT82GBw6GamodpqU-SAeYyx9noWnzbGfUpg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Jiri Pirko <jpirko@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"fubar@us.ibm.com" <fubar@us.ibm.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw10.se.ericsson.net ([193.180.251.61]:44885 "EHLO
	mailgw10.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751407Ab1JKLI4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2011 07:08:56 -0400
In-Reply-To: <CAEP_g=83tCQMVPOTT82GBw6GamodpqU-SAeYyx9noWnzbGfUpg@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello
On Tuesday 11 October 2011 04:43:03 Jesse Gross wrote:
> On Mon, Oct 10, 2011 at 7:07 PM, John Fastabend
> <john.r.fastabend@intel.com> wrote:
> > On 10/10/2011 3:37 PM, Jiri Pirko wrote:
> >> Mon, Oct 10, 2011 at 09:16:41PM CEST, john.r.fastabend@intel.com wrote:
> >>> The following configuration used to work as I expected. At least
> >>> we could use the fcoe interfaces to do MPIO and the bond0 iface
> >>> to do load balancing or failover.
> >>>
> >>>       ---eth2.228-fcoe
> >>>       |
> >>> eth2 -----|
> >>>          |
> >>>          |---- bond0
> >>>          |
> >>> eth3 -----|
> >>>       |
> >>>       ---eth3.228-fcoe
> >>>
> >>> This worked because of a change we added to allow inactive slaves
> >>> to rx 'exact' matches. This functionality was kept intact with the
> >>> rx_handler mechanism. However now the vlan interface attached to the
> >>> active slave never receives traffic because the bonding rx_handler
> >>> updates the skb->dev and goto's another_round. Previously, the
> >>> vlan_do_receive() logic was called before the bonding rx_handler.
> >>>
> >>> Now by the time vlan_do_receive calls vlan_find_dev() the
> >>> skb->dev is set to bond0 and it is clear no vlan is attached
> >>> to this iface. The vlan lookup fails.
> >>>
> >>> This patch moves the VLAN check above the rx_handler. A VLAN
> >>> tagged frame is now routed to the eth2.228-fcoe iface in the
> >>> above schematic. Untagged frames continue to the bond0 as
> >>> normal. This case also remains intact,
> >>>
> >>> eth2 --> bond0 --> vlan.228
> >>>
> >>> Here the skb is VLAN tagged but the vlan lookup fails on eth2
> >>> causing the bonding rx_handler to be called. On the second
> >>> pass the vlan lookup is on the bond0 iface and completes as
> >>> expected.
> >>>
> >>> Putting a VLAN.228 on both the bond0 and eth2 device will
> >>> result in eth2.228 receiving the skb. I don't think this is
> >>> completely unexpected and was the result prior to the rx_handler
> >>> result.

I think this OK, but I do have a question
if bond0 is in Active/Backup mode, eth2 and eth3 got the same MAC.addr,
what about the VLAN:s ?
(or is just one of thme working ??)

> >>>
> >>> Note, the same setup is also used for other storage traffic that
> >>> MPIO is used with eg. iSCSI and similar setups can be contrived
> >>> without storage protocols.
> >>>
> >>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> >>> ---
> >>>
> >>> net/core/dev.c |   22 +++++++++++-----------
> >>> 1 files changed, 11 insertions(+), 11 deletions(-)
> >>>
> >>> diff --git a/net/core/dev.c b/net/core/dev.c
> >>> index 70ecb86..8b6118a 100644
> >>> --- a/net/core/dev.c
> >>> +++ b/net/core/dev.c
> >>> @@ -3231,6 +3231,17 @@ another_round:
> >>> ncls:
> >>> #endif
> >>>
> >>> +    if (vlan_tx_tag_present(skb)) {
> >>> +            if (pt_prev) {
> >>> +                    ret = deliver_skb(skb, pt_prev, orig_dev);
> >>> +                    pt_prev = NULL;
> >>> +            }
> >>> +            if (vlan_do_receive(&skb))
> >>> +                    goto another_round;
> >>> +            else if (unlikely(!skb))
> >>> +                    goto out;
> >>> +    }
> >>> +
> >>>      rx_handler = rcu_dereference(skb->dev->rx_handler);
> >>>      if (rx_handler) {
> >>>              if (pt_prev) {
> >>> @@ -3251,17 +3262,6 @@ ncls:
> >>>              }
> >>>      }
> >>>
> >>> -    if (vlan_tx_tag_present(skb)) {
> >>> -            if (pt_prev) {
> >>> -                    ret = deliver_skb(skb, pt_prev, orig_dev);
> >>> -                    pt_prev = NULL;
> >>> -            }
> >>> -            if (vlan_do_receive(&skb))
> >>> -                    goto another_round;
> >>> -            else if (unlikely(!skb))
> >>> -                    goto out;
> >>> -    }
> >>> -
> >>>      /* deliver only exact match when indicated */
> >>>      null_or_dev = deliver_exact ? skb->dev : NULL;
> >>>
> >>>
> >>
> >> Hmm, I must look at this again tomorrow but I have strong feeling this
> >> will break some some scenario including vlan-bridge-macvlan.
> >
> > Yes please review... I tested cases with vlan, bridge, and macvlan
> > components and believe this works unless I missed something.
> >
> > Maybe Jesse, can comment though on why this commit that moved (and
> > cleaned up) the vlan tag handling put the vlan_do_receive below the
> > rx_handler rather than above it. Was this intended to fix something?
> 
> The original reason was to ensure packets received from NICs that do
> stripping behaved the same as those that don't.  At the time, the
> packets with inline vlan tags were handled by the same code that
> handled upper layer protocols so it was important that code for vlan
> stripped tags be immediately before that.  Otherwise, packets might be
> taken either by the bridge hook or vlan code depending the the type of
> device.
> 
> However, that's no longer an issue because we now emulate vlan
> acceleration by untagging packets at the beginning of
> __netif_receive_skb(), so the code path will always be the same.
> Furthermore, based on feedback received since that patch it seems
> pretty clear that people prefer the behavior where vlan devices take
> traffic first, so now that we can have both that and consistent
> behavior it seems to be the way to go.
> 
> This looks correct to me:
> Acked-by: Jesse Gross <jesse@nicira.com>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
