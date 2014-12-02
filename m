From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH net] gso: do GSO for local skb with size bigger than MTU
Date: Tue, 2 Dec 2014 19:32:32 -0200
Message-ID: <20141202213232.GC5344@t520.home>
References: <1417156385-18276-1-git-send-email-fan.du@intel.com>
 <1417158128.3268.2@smtp.corp.redhat.com>
 <5A90DA2E42F8AE43BC4A093BF0678848DED92B@SHSMSX104.ccr.corp.intel.com>
 <20141202154425.GA5344@t520.home>
 <CAEP_g=-wh3rJ2g4Ly=+JGJGOTGa10hbfA5n=8ZS5FF+=XMsxTg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Du, Fan" <fan.du@intel.com>, Jason Wang <jasowang@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"fw@strlen.de" <fw@strlen.de>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51759 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754007AbaLBVcn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Dec 2014 16:32:43 -0500
Content-Disposition: inline
In-Reply-To: <CAEP_g=-wh3rJ2g4Ly=+JGJGOTGa10hbfA5n=8ZS5FF+=XMsxTg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 02, 2014 at 10:06:53AM -0800, Jesse Gross wrote:
> On Tue, Dec 2, 2014 at 7:44 AM, Flavio Leitner <fbl@redhat.com> wrote:
> > On Sun, Nov 30, 2014 at 10:08:32AM +0000, Du, Fan wrote:
> >>
> >>
> >> >-----Original Message-----
> >> >From: Jason Wang [mailto:jasowang@redhat.com]
> >> >Sent: Friday, November 28, 2014 3:02 PM
> >> >To: Du, Fan
> >> >Cc: netdev@vger.kernel.org; davem@davemloft.net; fw@strlen.de; Du, Fan
> >> >Subject: Re: [PATCH net] gso: do GSO for local skb with size bigger than MTU
> >> >
> >> >
> >> >
> >> >On Fri, Nov 28, 2014 at 2:33 PM, Fan Du <fan.du@intel.com> wrote:
> >> >> Test scenario: two KVM guests sitting in different hosts communicate
> >> >> to each other with a vxlan tunnel.
> >> >>
> >> >> All interface MTU is default 1500 Bytes, from guest point of view, its
> >> >> skb gso_size could be as bigger as 1448Bytes, however after guest skb
> >> >> goes through vxlan encapuslation, individual segments length of a gso
> >> >> packet could exceed physical NIC MTU 1500, which will be lost at
> >> >> recevier side.
> >> >>
> >> >> So it's possible in virtualized environment, locally created skb len
> >> >> after encapslation could be bigger than underlayer MTU. In such case,
> >> >> it's reasonable to do GSO first, then fragment any packet bigger than
> >> >> MTU as possible.
> >> >>
> >> >> +---------------+ TX     RX +---------------+
> >> >> |   KVM Guest   | -> ... -> |   KVM Guest   |
> >> >> +-+-----------+-+           +-+-----------+-+
> >> >>   |Qemu/VirtIO|               |Qemu/VirtIO|
> >> >>   +-----------+               +-----------+
> >> >>        |                            |
> >> >>        v tap0                  tap0 v
> >> >>   +-----------+               +-----------+
> >> >>   | ovs bridge|               | ovs bridge|
> >> >>   +-----------+               +-----------+
> >> >>        | vxlan                vxlan |
> >> >>        v                            v
> >> >>   +-----------+               +-----------+
> >> >>   |    NIC    |    <------>   |    NIC    |
> >> >>   +-----------+               +-----------+
> >> >>
> >> >> Steps to reproduce:
> >> >>  1. Using kernel builtin openvswitch module to setup ovs bridge.
> >> >>  2. Runing iperf without -M, communication will stuck.
> >> >
> >> >Is this issue specific to ovs or ipv4? Path MTU discovery should help in this case I
> >> >believe.
> >>
> >> Problem here is host stack push local over-sized gso skb down to NIC, and perform GSO there
> >> without any further ip segmentation.
> >>
> >> Reasonable behavior is do gso first at ip level, if gso-ed skb is bigger than MTU && df is set,
> >> Then push ICMP_DEST_UNREACH/ICMP_FRAG_NEEDED message back to sender to adjust mtu.
> >>
> >> For PMTU to work, that's another issue I will try to address later on.
> >>
> >> >>
> >> >>
> >> >> Signed-off-by: Fan Du <fan.du@intel.com>
> >> >> ---
> >> >>  net/ipv4/ip_output.c |    7 ++++---
> >> >>  1 files changed, 4 insertions(+), 3 deletions(-)
> >> >>
> >> >> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c index
> >> >> bc6471d..558b5f8 100644
> >> >> --- a/net/ipv4/ip_output.c
> >> >> +++ b/net/ipv4/ip_output.c
> >> >> @@ -217,9 +217,10 @@ static int ip_finish_output_gso(struct sk_buff
> >> >> *skb)
> >> >>    struct sk_buff *segs;
> >> >>    int ret = 0;
> >> >>
> >> >> -  /* common case: locally created skb or seglen is <= mtu */
> >> >> -  if (((IPCB(skb)->flags & IPSKB_FORWARDED) == 0) ||
> >> >> -        skb_gso_network_seglen(skb) <= ip_skb_dst_mtu(skb))
> >> >> +  /* Both locally created skb and forwarded skb could exceed
> >> >> +   * MTU size, so make a unified rule for them all.
> >> >> +   */
> >> >> +  if (skb_gso_network_seglen(skb) <= ip_skb_dst_mtu(skb))
> >> >>            return ip_finish_output2(skb);
> >
> >
> > Are you using kernel's vxlan device or openvswitch's vxlan device?
> >
> > Because for kernel's vxlan devices the MTU accounts for the header
> > overhead so I believe your patch would work.  However, the MTU is
> > not visible for the ovs's vxlan devices, so that wouldn't work.
> 
> This is being called after the tunnel code, so the MTU that is being
> looked at in all cases is the physical device's. Since the packet has
> already been encapsulated, tunnel header overhead is already accounted
> for in skb_gso_network_seglen() and this should be fine for both OVS
> and non-OVS cases.

Right, it didn't work on my first try and that explanation came to mind.

Anyway, I am testing this with containers instead of VMs, so I am using
veth and not Virtio-net.

This is the actual stack trace:

[...]
  do_output
  ovs_vport_send
  vxlan_tnl_send
  vxlan_xmit_skb
  udp_tunnel_xmit_skb
  iptunnel_xmit
   \ skb_scrub_packet => skb->ignore_df = 0;
  ip_local_out_sk
  ip_output
  ip_finish_output (_gso is inlined)
  ip_fragment

and on ip_fragment() it does:

 503         if (unlikely(((iph->frag_off & htons(IP_DF)) && !skb->ignore_df) ||
 504                      (IPCB(skb)->frag_max_size &&
 505                       IPCB(skb)->frag_max_size > mtu))) {
 506                 IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
 507                 icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
 508                           htonl(mtu));
 509                 kfree_skb(skb);
 510                 return -EMSGSIZE;
 511         }

Since IP_DF is set and skb->ignore_df is reset to 0, in my case
the packet is dropped and an ICMP is sent back. The connection
remains stuck as before. Doesn't virtio-net set DF bit?

Thanks,
fbl
