From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel 4.13.0-rc4-next-20170811 - IP Routing / Forwarding
 performance vs Core/RSS number / HT on
Date: Mon, 14 Aug 2017 18:07:05 -0700
Message-ID: <1502759225.4936.44.camel@edumazet-glaptop3.roam.corp.google.com>
References: <3ac1a817-5c62-2490-64e7-2512f0ee3b3e@itcare.pl>
         <20170812142358.08291888@redhat.com>
         <af5b3482-8f26-52b5-4a00-3a5a42b7449f@itcare.pl>
         <ce33b7b3-ae00-b6f0-e82a-6df3d5a5e995@itcare.pl>
         <20170814181957.5be27906@redhat.com> <1502729870.8411.63.camel@redhat.com>
         <80b3bf71-dc6b-7b96-43d6-dbb3c53c5a8b@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Paolo Abeni <pabeni@redhat.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: =?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35409 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752740AbdHOBHK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 21:07:10 -0400
Received: by mail-pg0-f67.google.com with SMTP id l64so13181657pge.2
        for <netdev@vger.kernel.org>; Mon, 14 Aug 2017 18:07:10 -0700 (PDT)
In-Reply-To: <80b3bf71-dc6b-7b96-43d6-dbb3c53c5a8b@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-08-15 at 02:45 +0200, Paweł Staszewski wrote:
> 
> W dniu 2017-08-14 o 18:57, Paolo Abeni pisze:
> > On Mon, 2017-08-14 at 18:19 +0200, Jesper Dangaard Brouer wrote:
> >> The output (extracted below) didn't show who called 'do_raw_spin_lock',
> >> BUT it showed another interesting thing.  The kernel code
> >> __dev_queue_xmit() in might create route dst-cache problem for itself(?),
> >> as it will first call skb_dst_force() and then skb_dst_drop() when the
> >> packet is transmitted on a VLAN.
> >>
> >>   static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
> >>   {
> >>   [...]
> >> 	/* If device/qdisc don't need skb->dst, release it right now while
> >> 	 * its hot in this cpu cache.
> >> 	 */
> >> 	if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
> >> 		skb_dst_drop(skb);
> >> 	else
> >> 		skb_dst_force(skb);
> > I think that the high impact of the above code in this specific test is
> > mostly due to the following:
> >
> > - ingress packets with different RSS rx hash lands on different CPUs
> yes but isn't this normal ?
> everybody that want to ballance load over cores will try tu use as many 
> as possible :)
> With some limitations  ... best are 6 to 7 RSS queues - so need to use 6 
> to 7 cpu cores
> 
> > - but they use the same dst entry, since the destination IPs belong to
> > the same subnet
> typical for ddos - many sources one destination

Nobody hit this issue yet.

We usually change the kernel, given typical workloads.

In this case, we might need per cpu nh_rth_input

Or try to hack the IFF_XMIT_DST_RELEASE flag on the vlan netdev.
