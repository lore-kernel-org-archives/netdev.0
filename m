From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] veth: extend features to support tunneling
Date: Sun, 17 Nov 2013 11:00:52 -0800
Message-ID: <CAMEtUuw1VUtafKVnBOKAy+rNyKDYnDsst8ygwqEtKX75w96Q-w@mail.gmail.com>
References: <CAJZOPZ+jUanPW2mT_HiSWdvGfdRMHpX6vWyrboS3Zf_gH7rEgQ@mail.gmail.com>
	<1384638027.8604.22.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAMEtUuzkwVSetLKb0AK7U=iB5ArhAhs-0vx9cX+WeZ2Fz04kqg@mail.gmail.com>
	<1384708847.8604.50.camel@edumazet-glaptop2.roam.corp.google.com>
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
Received: from mail-we0-f172.google.com ([74.125.82.172]:38779 "EHLO
	mail-we0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751446Ab3KQTAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Nov 2013 14:00:54 -0500
Received: by mail-we0-f172.google.com with SMTP id t60so394586wes.17
        for <netdev@vger.kernel.org>; Sun, 17 Nov 2013 11:00:53 -0800 (PST)
In-Reply-To: <1384708847.8604.50.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 17, 2013 at 9:20 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sat, 2013-11-16 at 23:31 -0800, Alexei Starovoitov wrote:
>
>> In case of VMs sending gso packets over tap and tunnel in the host,
>> ip_forward is not in the picture.
>>
>
> I was specifically answering to #2 which should use ip forwarding, of
> course. Note that my patch was a POC : We have many other places where
> the typical MTU check is simply disabled as soon as skb is GSO.

I don't think #2 will do ip_forward either. veth goes into a bridge
and vxlan just adds encap.

>> when host mtu doesn't account for overhead of tunnel, the neat trick
>> we can do is to decrease gso_size while adding tunnel header.
>
> That would be very broken to change gso_size, this breaks DF flag
> semantic. You need to send an ICMP, and the sender will take appropriate
> action.
>
> GRO + GSO request that forwarded segments are the same than incoming
> ones. It's not like a proxy that can chose to aggregate as it wants.

In case of ip_forwarding - yes, but in case of tunnel we may look at
gso differently.
I'm not saying that 'gso_size -= tunnel_header' trick should be unconditional.
Obviously DF flag needs to be respected for pmtu to work.
ip_tunnel_xmit() already suppose to send icmp_frag_needed back, I'm
not sure it works for vxlan though.
What I'm proposing if tunnel receives normal gso packet with df bit
not set, it can safely
decrease that skb's gso_size. This way guest vm can have 1500 mtu just
like host mtu 1500,
until guest tries to pmtu, then vxlan sends icmp into guest and guest
adjusts itself if it can.
Since host cannot guarantee that guest will do the right thing with
icmp_frag_needed, it may continue doing 'gso_size -= tunnel_header'
trick without breaking anything.
