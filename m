From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH v3 5/7] net: Add GSO support for UDP tunnels with checksum
Date: Sat, 27 Sep 2014 23:39:30 +0300
Message-ID: <CAJZOPZKVjQMhBZVoGPVLPOZM1_Jb53iPKr8ZAuNZfG_cDQbQ0Q@mail.gmail.com>
References: <alpine.DEB.2.02.1406041706450.14949@tomh.mtv.corp.google.com>
	<CAJZOPZJTfJtuhWZ91_KOZxr=V7J7KPX5OGeR_7rY52iOjWcEVw@mail.gmail.com>
	<CA+mtBx-FqE70TROzxi=-B9DKaUsMs-=KZk3XbY7_qhOk3b2aNQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:38328 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751651AbaI0Ujb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Sep 2014 16:39:31 -0400
Received: by mail-qg0-f47.google.com with SMTP id i50so329482qgf.20
        for <netdev@vger.kernel.org>; Sat, 27 Sep 2014 13:39:30 -0700 (PDT)
In-Reply-To: <CA+mtBx-FqE70TROzxi=-B9DKaUsMs-=KZk3XbY7_qhOk3b2aNQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 27, 2014 at 12:57 AM, Tom Herbert <therbert@google.com> wrote:
> On Fri, Sep 26, 2014 at 2:05 PM, Or Gerlitz <or.gerlitz@gmail.com> wrote:
>> On Thu, Jun 5, 2014 at 3:20 AM, Tom Herbert <therbert@google.com> wrote:

>>> Added a new netif feature for GSO_UDP_TUNNEL_CSUM. This indicates
>>> that a device is capable of computing the UDP checksum in the
>>> encapsulating header of a UDP tunnel.

>> Do we have upstream driver that supports GSO_UDP_TUNNEL_CSUM? did you
>> had such driver/patch while doing this patches? when a driver
>> advertizes that bit, should they look over the xmit path on the new
>> encap_hdr_csum bit?

> No, no, and encap_hdr_csum should only be set with
> SKB_GSO_UDP_TUNNEL_CSUM or SKB_GSO_GRE_CSUM.

I'm still trying to dig the bigger picture w.r.t checksum of the outer
UDP packet from the patches -- if I got it right, once these patches
were picked upstream, there's a scheme where the kernel either
computes this checksum or let the device do that - when they advertize
NETIF_F_GSO_YYY_CSUM  and in that case
(skb->encap_hdr_csum == true) should be interpreted as a directive to
do that, right?

So what happens when the device isn't capable to compute that checksum
(e.g they don't set _GSO_UDP_TUNNEL_CSUM) but they do advertize the
GSO_UDP_TUNNEL bit?

I was worried that we can run into this scheme - the stack computes
the outer checksum for the giant 64K UDP chunck that encapsulate a 64K
TCP segment, but when the NIC will issue the segmentation, they will
likely to just repeat ~40 times (64K/1500) the original udp checksum
for the packets they send, which will be treated as bad checksum on
the receiving end, bad.

> find . -name '*.[ch]' -exec fgrep -l GSO_UDP_TUNNEL_CSUM {} \;
> returns nothing.

grepping I know, I was just hoping you were able to test such a sensitive change
with HW that cause both code parts (outer udp checksum offloaded vs.
non-offloaded) to be exercised

> find . -name '*.[ch]' -exec fgrep -l GSO_UDP_TUNNEL {} \;
> returns
>
> ./ethernet/intel/i40e/i40e_main.c
> ./ethernet/broadcom/bnx2x/bnx2x_main.c
> ./ethernet/qlogic/qlcnic/qlcnic_main.c
> ./ethernet/mellanox/mlx4/en_netdev.c
> ./ethernet/emulex/benet/be_main.c

cool, I see here four 40Gbs NICs that support GSO offloading of VXLAN
traffic, each of them can serve you for testing new developments you
do in that area.

Or.
