From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net] gso: do GSO for local skb with size bigger than MTU
Date: Mon, 1 Dec 2014 13:52:25 +0000
Message-ID: <20141201135225.GA16814@casper.infradead.org>
References: <1417156385-18276-1-git-send-email-fan.du@intel.com>
 <1417158128.3268.2@smtp.corp.redhat.com>
 <5A90DA2E42F8AE43BC4A093BF0678848DED92B@SHSMSX104.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Jason Wang' <jasowang@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"fw@strlen.de" <fw@strlen.de>, dev@openvswitch.org, mst@redhat.com,
	jesse@nicira.com, pshelar@nicira.com
To: "Du, Fan" <fan.du@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:59095 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753440AbaLANwa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2014 08:52:30 -0500
Content-Disposition: inline
In-Reply-To: <5A90DA2E42F8AE43BC4A093BF0678848DED92B@SHSMSX104.ccr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/30/14 at 10:08am, Du, Fan wrote:
> >-----Original Message-----
> >From: Jason Wang [mailto:jasowang@redhat.com]
> >Sent: Friday, November 28, 2014 3:02 PM
> >To: Du, Fan
> >Cc: netdev@vger.kernel.org; davem@davemloft.net; fw@strlen.de; Du, Fan
> >Subject: Re: [PATCH net] gso: do GSO for local skb with size bigger than MTU
> >On Fri, Nov 28, 2014 at 2:33 PM, Fan Du <fan.du@intel.com> wrote:
> >> Test scenario: two KVM guests sitting in different hosts communicate
> >> to each other with a vxlan tunnel.
> >>
> >> All interface MTU is default 1500 Bytes, from guest point of view, its
> >> skb gso_size could be as bigger as 1448Bytes, however after guest skb
> >> goes through vxlan encapuslation, individual segments length of a gso
> >> packet could exceed physical NIC MTU 1500, which will be lost at
> >> recevier side.
> >>
> >> So it's possible in virtualized environment, locally created skb len
> >> after encapslation could be bigger than underlayer MTU. In such case,
> >> it's reasonable to do GSO first, then fragment any packet bigger than
> >> MTU as possible.
> >>
> >> +---------------+ TX     RX +---------------+
> >> |   KVM Guest   | -> ... -> |   KVM Guest   |
> >> +-+-----------+-+           +-+-----------+-+
> >>   |Qemu/VirtIO|               |Qemu/VirtIO|
> >>   +-----------+               +-----------+
> >>        |                            |
> >>        v tap0                  tap0 v
> >>   +-----------+               +-----------+
> >>   | ovs bridge|               | ovs bridge|
> >>   +-----------+               +-----------+
> >>        | vxlan                vxlan |
> >>        v                            v
> >>   +-----------+               +-----------+
> >>   |    NIC    |    <------>   |    NIC    |
> >>   +-----------+               +-----------+
> >>
> >> Steps to reproduce:
> >>  1. Using kernel builtin openvswitch module to setup ovs bridge.
> >>  2. Runing iperf without -M, communication will stuck.
> >
> >Is this issue specific to ovs or ipv4? Path MTU discovery should help in this case I
> >believe.
> 
> Problem here is host stack push local over-sized gso skb down to NIC, and perform GSO there
> without any further ip segmentation.
> 
> Reasonable behavior is do gso first at ip level, if gso-ed skb is bigger than MTU && df is set, 
> Then push ICMP_DEST_UNREACH/ICMP_FRAG_NEEDED message back to sender to adjust mtu.

Aside from this. I think Virtio should provide a MTU hint to the guest
to adjust MTU in the vNIC to account for both overhead or support for
jumbo frames in the underlay transparently without relying on PMTU or
MSS hints. I remember we talked about this a while ago with at least
Michael but haven't done actual code work on it yet.

> For PMTU to work, that's another issue I will try to address later on.

PMTU discovery was explicitly removed from the OVS datapath. Maybe
Pravin or Jesse can provide some background on that
