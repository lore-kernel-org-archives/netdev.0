From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH net-next] veth: extend features to support tunneling
Date: Mon, 18 Nov 2013 12:55:15 -0500
Message-ID: <OFF76C3619.82D931F7-ON85257C27.005F4843-85257C27.006270D6@us.ibm.com>
References: <CAJZOPZ+jUanPW2mT_HiSWdvGfdRMHpX6vWyrboS3Zf_gH7rEgQ@mail.gmail.com>	<1384638027.8604.22.camel@edumazet-glaptop2.roam.corp.google.com> <CAMEtUuzkwVSetLKb0AK7U=iB5ArhAhs-0vx9cX+WeZ2Fz04kqg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org, Or Gerlitz <or.gerlitz@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:47745 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751421Ab3KRRzW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 12:55:22 -0500
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Mon, 18 Nov 2013 10:55:21 -0700
In-Reply-To: <CAMEtUuzkwVSetLKb0AK7U=iB5ArhAhs-0vx9cX+WeZ2Fz04kqg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 11/17/2013 02:31:08 AM:

> From: Alexei Starovoitov <ast@plumgrid.com>
 
> when host mtu doesn't account for overhead of tunnel, the neat trick
> we can do is to decrease gso_size while adding tunnel header.

Won't this possibly result in ip_id collision if you generate more 
segments
than the VM thinks you did? Not an issue of DF is set, I suppose.

> This way when skb_gso_segment() kicks in during tx the packets will be
> segmented into host mtu sized packets.

        I've been looking at something like this, but going the other way.
In the VXLAN case, other VXLAN VMs are reachable via the virtual L2 
network
so we *ought* to use large packets in the whole path if the underlay
network can do that. PMTUD should not apply within the virtual L2 network,
but the code as-is will segment to the VM gso_size (say 1500) even if the
underlay network can send jumbo frames (say 9K).
        I think what we want for best performance is to send GSO packets 
from
the VM and use underlay network MTU minus VXLAN headers as the gso_size 
for
those.
        One complication there is that we would actually want to use the 
VM
gso_size if the destination is a router taking us off of the VXLAN 
network,
but we can tell that from the fdb entry when route-short-circuiting is 
enabled.

> Receiving vm on the other side will be seeing packets of size
> guest_mtu - tunnel_header_size,
> but imo that's much better than sending ip fragments over vxlan fabric.
> It will work for guests sending tcp/udp, but there is no good solution
> for icmp other than ip frags.

My idea for solving this ICMP issue is to forge an ICMP2BIG with the
source address of the destination and send it back to the originating VM
directly. It's complicated a bit because we don't want to use icmp_send()
on the host, which will go through host routing tables when we don't
necessarily have an IP address or routing for the bridged domain. So, to
do this, we really should just have a stand-alone icmp sender for use by
tunnel endpoints. But if we do this, the VM can get the correct gso_size
accounting for the tunnel overhead too, although it's abusing PMTUD a bit
since it doesn't ordinarily apply to hosts on the same L2 network.

I haven't gotten working patches for either of these extensions yet--
if your work overlaps before I do, I'd be happy to see these two things
incorporated in it:

1) ICMP2BIG reflected from the tunnel endpoint without host routing and
        using the destination IP as the forged source address, thus 
appropriate
        for bridge-only hosting.
2) Allowing larger-than-gso_size segmentation as well as smaller when the
        final destination is on the virtual L2 network.

                                                                +-DLS
