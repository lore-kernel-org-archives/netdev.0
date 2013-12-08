From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: vxlan/veth performance issues on net.git + latest kernels
Date: Sun, 8 Dec 2013 16:30:55 +0200
Message-ID: <20131208143054.GA6984@zed.ravello.local>
References: <alpine.LFD.2.03.1312031500020.570@intel.com>
 <CAJZOPZLT_3msfz_XY45GOBMWK_y8WEYBTq3rGRUijpYyXE1ddg@mail.gmail.com>
 <alpine.LFD.2.03.1312031626400.7539@intel.com>
 <CAJZOPZJKsrj2+SQJsgq-w7BrNwDR0OsYWiF+1CcRQ3-KhejZhQ@mail.gmail.com>
 <alpine.LFD.2.03.1312040113290.14367@intel.com>
 <CAJZOPZJVBpqm-OduV4K2YwbXESP7awhsk0HbjuHazAiQJZTLWQ@mail.gmail.com>
 <52A197DF.5010806@mellanox.com>
 <CAJZOPZJ20j9KaaMkyQmhYDkimzAM5tvxJLDzmpiAcvG0Bcky6w@mail.gmail.com>
 <20131208124352.GA7935@zed.ravello.local>
 <52A46F2A.40101@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jerry Chu <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	John Fastabend <john.fastabend@gmail.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:61820 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753817Ab3LHObB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 09:31:01 -0500
Received: by mail-ee0-f48.google.com with SMTP id e49so1072345eek.21
        for <netdev@vger.kernel.org>; Sun, 08 Dec 2013 06:30:59 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <52A46F2A.40101@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 08, 2013 at 03:07:54PM +0200, Or Gerlitz wrote:
> On 08/12/2013 14:43, Mike Rapoport wrote:
> > On Fri, Dec 06, 2013 at 11:30:37AM +0200, Or Gerlitz wrote:
> >>> On 04/12/2013 11:41, Or Gerlitz wrote:
> >> BTW guys, I saw the issues with both bridge/openvswitch configuration
> >> - seems that we might have here somehow large breakage of the system
> >> w.r.t vxlan traffic for rates that go over few Gbs -- so would love to
> >> get feedback of any kind from the people that were involved with vxlan
> >> over the last months/year.
> > I've seen similar problems with vxlan traffic. In our scenario I had two VMs running on the same host and both VMs having the { veth --> bridge --> vlxan --> IP stack --> NIC } chain.
> 
> How the VMs were connected to the veth NICs? what kernel were you using?
> 
> 
> > Running iperf on veth showed rate ~6 times slower than direct NIC <-> NIC. With a hack that forces large gso_size in vxlan's handle_offloads, I've got veth performing only slightly slower than NICs ... The explanation I thought of is that performing the split of the packet as late as possible reduces processing overhead and allows more data to be processed.
> 
> thanks for the tip! few quick clarifications -- so you artificially 
> enlarged the gso_size of the skb? can you provide the line you added here
 
It was something *very* hacky:

static int handle_offloads(struct sk_buff *skb)
{
	if (skb_is_gso(skb)) {
		int err = skb_unclone(skb, GFP_ATOMIC);
		if (unlikely(err))
			return err;
 
		skb_shinfo(skb)->gso_type |= SKB_GSO_UDP_TUNNEL;

		if (skb->len < 64000)
			skb_shinfo(skb)->gso_size = skb->len;
		else
			skb_shinfo(skb)->gso_size = 64000;

	} else if (skb->ip_summed != CHECKSUM_PARTIAL)
		skb->ip_summed = CHECKSUM_NONE;
 
	return 0;
}
 
> also, why enlarging the gso size for skb's cause the actual segmentation 
> to come into play lower in the stack?
> 
> Or.
> 
