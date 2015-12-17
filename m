From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 0/2] Local checksum offload for VXLAN
Date: Thu, 17 Dec 2015 10:06:13 -0800
Message-ID: <CALx6S360nGbiD0fV4ggE_XT9SVcP4MZy-yR0Gma4jMdNuSKkug@mail.gmail.com>
References: <5672D466.6050900@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:33659 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751201AbbLQSGN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 13:06:13 -0500
Received: by mail-ig0-f176.google.com with SMTP id mv3so18110579igc.0
        for <netdev@vger.kernel.org>; Thu, 17 Dec 2015 10:06:13 -0800 (PST)
In-Reply-To: <5672D466.6050900@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 17, 2015 at 7:27 AM, Edward Cree <ecree@solarflare.com> wrote:
> When the inner packet checksum is offloaded, the outer UDP checksum is easy
>  to calculate as it doesn't depend on the payload (because the inner checksum
>  cancels out everything from the inner packet except the pseudo header).
> Thus, transmit checksums for VXLAN (and in principle other encapsulations,
>  but I haven't enabled it for / tested with those) can be offloaded on any
>  device supporting NETIF_F_HW_CSUM.  Only the innermost checksum has to be
>  offloaded, the rest are filled in by the stack.
> Tested by hacking a driver to report NETIF_F_HW_CSUM, call skb_checksum_help
>  before transmitting a packet, and not actually offload anything to the hw.
> In principle it should also be possible to apply this technique when the
>  inner packet has been checksummed by software, but only if skb->csum_start
>  and skb->csum_offset have been filled in to describe the inner checksum.
>  However in this case it is easier to use skb->csum and skb->csum_start, as
>  gso_make_checksum() already does - a similar but simpler technique.  It's
>  not clear to me where else this should be done, so this is out of scope for
>  this patch series.
>
Edward, it took me a while to understand how this works, but this
really is an amazing trick! This implies that we don't need to worry
about HW support for offloading multiple checksums.

I'm not sure that we need bits in VXLAN or any other encapsulation. It
should be sufficient in udp_set_csum that if we already have
CHECKSUM_PARTIAL that can always be used to do local checksum offload.
This is also should be independent as to whether the device does
NETIF_F_HW_CSUM or can offload  NETIF_F_IP[V6]_CSUM for encapsulated
packets.

It would be nice to have a more formal documentation also. This is a
very powerful mechanism but the math behind it and requirements are
subtle.

Tom

> Edward Cree (2):
>   net: udp: local checksum offload for encapsulation
>   net: vxlan: enable local checksum offload on HW_CSUM devices
>
>  drivers/net/vxlan.c |  5 ++++-
>  net/ipv4/udp.c      | 34 +++++++++++++++++++++++++++++-----
>  2 files changed, 33 insertions(+), 6 deletions(-)
>
> --
> 2.4.3
>
> The information contained in this message is confidential and is intended for the addressee(s) only. If you have received this message in error, please notify the sender immediately and delete the message. Unless you are an addressee (or authorized to receive for an addressee), you may not use, copy or disclose to anyone this message or any information contained in this message. The unauthorized use, disclosure, copying or alteration of this message is strictly prohibited.
