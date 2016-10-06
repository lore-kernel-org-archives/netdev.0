From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next 4/4] net/sched: act_mirred: Implement
 ingress actions
Date: Fri, 07 Oct 2016 04:38:19 +0900
Message-ID: <1475782699.28155.251.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1475147012-15538-1-git-send-email-shmulik.ladkani@gmail.com>
         <1475147012-15538-5-git-send-email-shmulik.ladkani@gmail.com>
         <CAM_iQpWwPqbiJ7tjbHqvYfyRL5fh+oXGVFFPmW3wLUCGbK-b4Q@mail.gmail.com>
         <CAOrmypK=TZ=cDCDwy=wJgCsMgJWaMfr5dudEwHNnQzpeYJRfHw@mail.gmail.com>
         <CAM_iQpXB_LGd0GLmuyjcUqSvBy9nKX_02TEdm4GF3V-yX_rr0g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Eric Dumazet <edumazet@google.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.161.194]:35994 "EHLO
        mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752821AbcJFTiY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2016 15:38:24 -0400
Received: by mail-yw0-f194.google.com with SMTP id r132so1080612ywg.3
        for <netdev@vger.kernel.org>; Thu, 06 Oct 2016 12:38:24 -0700 (PDT)
In-Reply-To: <CAM_iQpXB_LGd0GLmuyjcUqSvBy9nKX_02TEdm4GF3V-yX_rr0g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-10-06 at 10:30 -0700, Cong Wang wrote:
> On Thu, Oct 6, 2016 at 6:30 AM, Shmulik Ladkani
> <shmulik.ladkani@gmail.com> wrote:
> > Hi,
> >
> > On Mon, Oct 3, 2016 at 12:45 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> >> On Thu, Sep 29, 2016 at 4:03 AM, Shmulik Ladkani
> >> <shmulik.ladkani@gmail.com> wrote:
> >>>         skb2->skb_iif = skb->dev->ifindex;
> >>>         skb2->dev = dev;
> >>> -       err = dev_queue_xmit(skb2);
> >>> +       if (tcf_mirred_act_direction(m_eaction) & AT_EGRESS)
> >>> +               err = dev_queue_xmit(skb2);
> >>> +       else
> >>> +               netif_receive_skb(skb2);
> >>
> >> Any reason why not check the return value here?
> >
> > Rationale: netif_receive_skb returns err if there was no protocol
> > handler to deliver the skb to.
> > If skb is not caught by any protocol handler, this should not be
> > considered an "ingress redirect" error. The redirect action should be
> > considered successful.
> 
> A quick grep shows there are many places returning NET_RX_DROP:
> E.g.

And another quick grep shows that out of 142 drivers, only one [1] of
them (incorrectly) checks netif_receive_skb() return value.

Real question is more like : what is the impact of propagating an error
at this point ?

[1] drivers/net/caif/caif_virtio.c 
This is incorrect because at the driver layer, the packet was received
and the rx_packets/rx_bytes counters _should_ be incremented regardless
of packet being dropped or not by upper layers.
