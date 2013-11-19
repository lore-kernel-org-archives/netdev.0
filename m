From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] veth: extend features to support tunneling
Date: Mon, 18 Nov 2013 19:51:10 -0800
Message-ID: <CAMEtUuykKUKcwDcaOC7bHcHkU42UMjDkoio=ehzUNiMew30mhw@mail.gmail.com>
References: <CAJZOPZ+jUanPW2mT_HiSWdvGfdRMHpX6vWyrboS3Zf_gH7rEgQ@mail.gmail.com>
	<1384638027.8604.22.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAMEtUuzkwVSetLKb0AK7U=iB5ArhAhs-0vx9cX+WeZ2Fz04kqg@mail.gmail.com>
	<OFF76C3619.82D931F7-ON85257C27.005F4843-85257C27.006270D6@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org, Or Gerlitz <or.gerlitz@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:46563 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751469Ab3KSDvM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 22:51:12 -0500
Received: by mail-we0-f173.google.com with SMTP id t61so468221wes.32
        for <netdev@vger.kernel.org>; Mon, 18 Nov 2013 19:51:11 -0800 (PST)
In-Reply-To: <OFF76C3619.82D931F7-ON85257C27.005F4843-85257C27.006270D6@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 18, 2013 at 9:55 AM, David Stevens <dlstevens@us.ibm.com> wrote:
> 1) ICMP2BIG reflected from the tunnel endpoint without host routing and
>         using the destination IP as the forged source address, thus
> appropriate
>         for bridge-only hosting.

It doesn't look that existing icmp_send() can be hacked this way.
It cannot do route lookup and cannot do neigh lookup.
IPs and macs are valid within VM and known to virtualized networking
components, but
tunnel cannot possibly know what is standing between VM and tunnel.
VM may be sending over tap into a bridge that forwards into netns that
is running ip_fowarding
 between two vethes, then goes into 2nd bridge and only then sent into
vxlan device.
ovs can do many actions before skb from tap is delivered to vport-vxlan.
The generic thing vxlan driver can do is to take mac and ip headers
from inner skb,
swap macs, swap ips, add icmphdr with code=frag_needed and pretend
that such packet
was received and decapsulated by vxlan, and call into vxlan_sock->rcv()
It will go back into ovs or bridge and will proceed through the
reverse network topology path all the way back into VM that can adjust
its mtu accordingly.

> 2) Allowing larger-than-gso_size segmentation as well as smaller when the
>         final destination is on the virtual L2 network.

I think it should be ok for virtual L3 as well. From VM point of view,
it's sending 1500 byte packets and virtual routers/bridges on the path
to destination should check packets against their own mtu values. But
if tunneling infra is smart enough to use large frames between two
hypervisors,
 it should do so. DF bit and pmtu logic applies within virtual
network, so sending icmp_frag_needed back into VM is exposing physical
infrastructure to virtual network.
True virtual distributed bridge with VMs should allow setting 8k mtu
inside VM and on the bridge and still function with 1500 mtu in the
underlying physical network.
