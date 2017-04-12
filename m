From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net/ipv4: use-after-free in ipv4_datagram_support_cmsg
Date: Wed, 12 Apr 2017 13:47:26 -0700
Message-ID: <1492030046.10587.72.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAAeHK+ysUb+yuES_XYYPDWGrXS4VUXLmQRrD2dJTeXDPL5BKpw@mail.gmail.com>
         <CAF=yD-++XtWeaVmdhnrwiYLOG84JTMEuZr9mxyTRnde8vE7AFQ@mail.gmail.com>
         <CAM_iQpVVc1ev8juG8=dQ0wu8c_RoJ8HfDUewRc1AempvV=85kw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34441 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752851AbdDLUr2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 16:47:28 -0400
In-Reply-To: <CAM_iQpVVc1ev8juG8=dQ0wu8c_RoJ8HfDUewRc1AempvV=85kw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-04-12 at 13:07 -0700, Cong Wang wrote:
> On Wed, Apr 12, 2017 at 8:39 AM, Willem de Bruijn
> <willemdebruijn.kernel@gmail.com> wrote:
> > ===================
> >> BUG: KASAN: use-after-free in ipv4_datagram_support_cmsg
> >> net/ipv4/ip_sockglue.c:500 [inline] at addr ffff880059be0128
> >
> > Thanks for the report. This is accessing skb->dev from within recvmsg() at line
> >
> >         info->ipi_ifindex = skb->dev->ifindex;
> >
> > Introduced in 829ae9d61165 ("net-timestamp: allow reading recv cmsg on
> > errqueue with origin tstamp"). At this time the device may indeed have
> > gone away. I'm having a look at a way to read this in the receive BH
> > and store the ifindex.
> 
> Why not use skb_iif?
> 
> diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
> index ebd953b..a2aef45 100644
> --- a/net/ipv4/ip_sockglue.c
> +++ b/net/ipv4/ip_sockglue.c
> @@ -497,7 +497,7 @@ static bool ipv4_datagram_support_cmsg(const
> struct sock *sk,
> 
>         info = PKTINFO_SKB_CB(skb);
>         info->ipi_spec_dst.s_addr = ip_hdr(skb)->saddr;
> -       info->ipi_ifindex = skb->dev->ifindex;
> +       info->ipi_ifindex = skb->skb_iif;
>         return true;
>  }

This seems to differ from the code in ipv4_pktinfo_prepare()

We probably want to unify things a bit.

                /* skb->cb is overloaded: prior to this point it is IP{6}CB
                 * which has interface index (iif) as the first member of the
                 * underlying inet{6}_skb_parm struct. This code then overlays
                 * PKTINFO_SKB_CB and in_pktinfo also has iif as the first
                 * element so the iif is picked up from the prior IPCB. If iif
                 * is the loopback interface, then return the sending interface
                 * (e.g., process binds socket to eth0 for Tx which is
                 * redirected to loopback in the rtable/dst).
                 */
                if (pktinfo->ipi_ifindex == LOOPBACK_IFINDEX)
                        pktinfo->ipi_ifindex = inet_iif(skb);
