From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] veth: extend features to support tunneling
Date: Sat, 16 Nov 2013 23:31:08 -0800
Message-ID: <CAMEtUuzkwVSetLKb0AK7U=iB5ArhAhs-0vx9cX+WeZ2Fz04kqg@mail.gmail.com>
References: <CAJZOPZ+jUanPW2mT_HiSWdvGfdRMHpX6vWyrboS3Zf_gH7rEgQ@mail.gmail.com>
	<1384638027.8604.22.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:53889 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750743Ab3KQHbK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Nov 2013 02:31:10 -0500
Received: by mail-wg0-f41.google.com with SMTP id n12so3462541wgh.4
        for <netdev@vger.kernel.org>; Sat, 16 Nov 2013 23:31:08 -0800 (PST)
In-Reply-To: <1384638027.8604.22.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 16, 2013 at 1:40 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sat, 2013-11-16 at 23:11 +0200, Or Gerlitz wrote:
>
>> Guys (thanks Eric for the clarification over the other vxlan thread),
>> with the latest networking code (e.g 3.12 or net-next)  do you expect
>> notable performance (throughput) difference between these two configs?
>>
>> 1. bridge --> vxlan --> NIC
>> 2. veth --> bridge --> vxlan --> NIC
>>
>> BTW #2 doesn't work when packets start to be large unless I manually
>> decrease the veth device pair MTU. E.g if the NIC MTU is 1500, vxlan
>> advertizes an MTU of 1450 (= 1500 - (14 + 20 + 8 + 8)) and the bridge
>> inherits that, but not the veth device. Should someone/somewhere here
>> generate an ICMP packet which will cause the stack to decreate the
>> path mtu for the neighbour created on the veth device? what about
>> para-virtualized guests which are plugged into this (or any host based
>> tunneling) scheme, e.g in this scheme
>>
>> 3. guest virtio NIC --> vhost  --> tap/macvtap --> bridge --> vxlan --> NIC
>>
>> Who/how do we want the guest NIC mtu/path mtu to take into account the
>> tunneling over-head?
>
> I mentioned this problem on another thread : gso packets escape the
> normal mtu checks in ip forwarding.
>
> vi +91 net/ipv4/ip_forward.c
>
> gso_size contains the size of the segment minus all headers.

In case of VMs sending gso packets over tap and tunnel in the host,
ip_forward is not in the picture.

when host mtu doesn't account for overhead of tunnel, the neat trick
we can do is to decrease gso_size while adding tunnel header.
This way when skb_gso_segment() kicks in during tx the packets will be
segmented into host mtu sized packets.
Receiving vm on the other side will be seeing packets of size
guest_mtu - tunnel_header_size,
but imo that's much better than sending ip fragments over vxlan fabric.
It will work for guests sending tcp/udp, but there is no good solution
for icmp other than ip frags.
This trick should work for hw offloaded vxlan, but we yet to
experiment with it on such nic.
