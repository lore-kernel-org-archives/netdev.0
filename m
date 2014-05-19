From: Michael Spang <spang@chromium.org>
Subject: Re: [PATCH] macvlan: Fix checksum errors when ip_summed is CHECKSUM_PARTIAL
Date: Mon, 19 May 2014 16:05:47 -0400
Message-ID: <CAC5F_1mrXgEtx7sx1ihdm5EA6cxP7cA7mOjVmP8HvWxatgAcRA@mail.gmail.com>
References: <1400520254-5142-1-git-send-email-spang@chromium.org> <1400521493.5367.61.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Daniel Lezcano <daniel.lezcano@free.fr>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f172.google.com ([209.85.220.172]:46672 "EHLO
	mail-vc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755009AbaESUG3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2014 16:06:29 -0400
Received: by mail-vc0-f172.google.com with SMTP id hr9so10277883vcb.3
        for <netdev@vger.kernel.org>; Mon, 19 May 2014 13:06:29 -0700 (PDT)
Received: from mail-ve0-f182.google.com (mail-ve0-f182.google.com [209.85.128.182])
        by mx.google.com with ESMTPSA id l4sm32758295vdb.3.2014.05.19.13.06.28
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 May 2014 13:06:28 -0700 (PDT)
Received: by mail-ve0-f182.google.com with SMTP id sa20so7055909veb.41
        for <netdev@vger.kernel.org>; Mon, 19 May 2014 13:06:27 -0700 (PDT)
In-Reply-To: <1400521493.5367.61.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 19, 2014 at 1:44 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> On Mon, 2014-05-19 at 13:24 -0400, Michael Spang wrote:
> > Changing ip_summed from CHECKSUM_PARTIAL to CHECKSUM_UNNECESSARY
> > will result in an incorrect checksum if the packet is sent off the box.
> >
> > Cc: stable@vger.kernel.org
> > Signed-off-by: Michael Spang <spang@chromium.org>
> > ---
> >  drivers/net/macvlan.c | 4 +++-
> >  1 file changed, 3 insertions(+), 1 deletion(-)
> >
> > diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> > index 753a8c2..806b56a 100644
> > --- a/drivers/net/macvlan.c
> > +++ b/drivers/net/macvlan.c
> > @@ -267,7 +267,9 @@ static int macvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
> >
> >       if (vlan->mode == MACVLAN_MODE_BRIDGE) {
> >               const struct ethhdr *eth = (void *)skb->data;
> > -             skb->ip_summed = CHECKSUM_UNNECESSARY;
> > +
> > +             if (skb->ip_summed == CHECKSUM_NONE)
> > +                     skb->ip_summed = CHECKSUM_UNNECESSARY;
> >
> >               /* send to other bridge ports directly */
> >               if (is_multicast_ether_addr(eth->h_dest)) {
>
> Hi Michael
>
> Any idea why commit 12a2856b604476c27d85a5f9a57ae1661fc46019
> added this stuff then ?
>

I think that patch is wrong. It's not OK to change CHECKSUM_PARTIAL to
CHECKSUM_UNNECESSARY. This code is changing the meaning of the
ip_summed field from "the checksum is incomplete" to "the checksum is
complete and correct". So if the packet bounces around the network
stack and eventually gets sent out a physical NIC, the checksum was
never completed anywhere and the packet is dropped by the receiving
box.

Look at 0b7967503dc97864f283a3a06fbe23e041876138 for a patch that
fixes exactly this problem on veth devices.


>
> You should give more infos of your use case.
>
> CC Daniel Lezcano <daniel.lezcano@free.fr>
>
> I removed stable@ , as stable submissions are not done like that.
>

Perhaps I've misunderstood something, but this suggestion is right
from https://www.kernel.org/doc/Documentation/stable_kernel_rules.txt

 - To have the patch automatically included in the stable tree, add the tag
     Cc: stable@vger.kernel.org
   in the sign-off area. Once the patch is merged it will be applied to
   the stable tree without anything else needing to be done by the author
   or subsystem maintainer.
