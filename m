From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next] veth: extend features to support tunneling
Date: Sat, 16 Nov 2013 23:11:20 +0200
Message-ID: <CAJZOPZ+jUanPW2mT_HiSWdvGfdRMHpX6vWyrboS3Zf_gH7rEgQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:37477 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752600Ab3KPVLV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Nov 2013 16:11:21 -0500
Received: by mail-pa0-f44.google.com with SMTP id fb1so3473919pad.3
        for <netdev@vger.kernel.org>; Sat, 16 Nov 2013 13:11:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 26, 2013 at 6:13 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2013-10-25 at 19:22 -0700, Alexei Starovoitov wrote:
>> On Fri, Oct 25, 2013 at 6:25 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > From: Eric Dumazet <edumazet@google.com>
>> >
>> > While investigating on a recent vxlan regression, I found veth
>> > was using a zero features set for vxlan tunnels.
>>
>> oneliner can be better :)
>
> Yes, I'll post the gso fix as well, of course ;)
>
>>
>> > We have to segment GSO frames, copy the payload, and do the checksum.
>> >
>> > This patch brings a ~200% performance increase
>> >
>> > We probably have to add hw_enc_features support
>> > on other virtual devices.
>> >
>> > Signed-off-by: Eric Dumazet <edumazet@google.com>
>> > Cc: Alexei Starovoitov <ast@plumgrid.com>
>> > ---
>>
>> iperf over veth with gre/vxlan tunneling is now ~4Gbps. 20x gain as advertised.
>> Thanks!
>
> Wow, such a difference might show another bug somewhere else...

Guys (thanks Eric for the clarification over the other vxlan thread),
with the latest networking code (e.g 3.12 or net-next)  do you expect
notable performance (throughput) difference between these two configs?

1. bridge --> vxlan --> NIC
2. veth --> bridge --> vxlan --> NIC

BTW #2 doesn't work when packets start to be large unless I manually
decrease the veth device pair MTU. E.g if the NIC MTU is 1500, vxlan
advertizes an MTU of 1450 (= 1500 - (14 + 20 + 8 + 8)) and the bridge
inherits that, but not the veth device. Should someone/somewhere here
generate an ICMP packet which will cause the stack to decreate the
path mtu for the neighbour created on the veth device? what about
para-virtualized guests which are plugged into this (or any host based
tunneling) scheme, e.g in this scheme

3. guest virtio NIC --> vhost  --> tap/macvtap --> bridge --> vxlan --> NIC

Who/how do we want the guest NIC mtu/path mtu to take into account the
tunneling over-head?

Or.
