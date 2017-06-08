From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH v2 1/2] ip_tunnel: fix potential issue in ip_tunnel_rcv
Date: Wed, 7 Jun 2017 21:06:45 -0700
Message-ID: <CAOrHB_DAmU7ZA7S3TkZ+O0xkswQeiDz8vKYeuP-d7yZy4wQtVQ@mail.gmail.com>
References: <1496883476-17445-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
 <CAOrHB_CZ-3TRs2O3KATW_ji_QQxqO=28UeDU_-Gx7ZPxz_RWCg@mail.gmail.com> <1496891711.736.55.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>,
        "=David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>,
        Haishuang Yan <yanhaishuang@cmss.chinamobile.com390e>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:47598 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750786AbdFHEGs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 00:06:48 -0400
In-Reply-To: <1496891711.736.55.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 7, 2017 at 8:15 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2017-06-07 at 19:13 -0700, Pravin Shelar wrote:
>> On Wed, Jun 7, 2017 at 5:57 PM, Haishuang Yan
>> <yanhaishuang@cmss.chinamobile.com> wrote:
>> > When ip_tunnel_rcv fails, the tun_dst won't be freed, so move
>> > skb_dst_set to begin and tun_dst would be freed by kfree_skb.
>> >
>> > CC: Pravin B Shelar <pshelar@nicira.com>
>> > Fixes: 2e15ea390e6f ("ip_gre: Add support to collect tunnel metadata.")
>> > Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com390e>
>> > ---
>> >  net/ipv4/ip_tunnel.c | 6 +++---
>> >  1 file changed, 3 insertions(+), 3 deletions(-)
>> >
>> > diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
>> > index b878ecb..27fc20f 100644
>> > --- a/net/ipv4/ip_tunnel.c
>> > +++ b/net/ipv4/ip_tunnel.c
>> > @@ -386,6 +386,9 @@ int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
>> >         const struct iphdr *iph = ip_hdr(skb);
>> >         int err;
>> >
>> > +       if (tun_dst)
>> > +               skb_dst_set(skb, (struct dst_entry *)tun_dst);
>> > +
>> If dst is set so early, skb_scrub_packet() would remove the tunnel dst
>> reference.
>> It is better to call skb_dst_drop() from error code path.
>
> Do we really want to keep a dst from another namespace if
> skb_scrub_packet() is called with xnet=true ?
>
tun_dst is allocated in same namespace. It is required for LWT to work.
