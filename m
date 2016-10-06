From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH v3 net-next 4/4] net/sched: act_mirred: Implement ingress actions
Date: Thu, 6 Oct 2016 10:30:43 -0700
Message-ID: <CAM_iQpXB_LGd0GLmuyjcUqSvBy9nKX_02TEdm4GF3V-yX_rr0g@mail.gmail.com>
References: <1475147012-15538-1-git-send-email-shmulik.ladkani@gmail.com>
 <1475147012-15538-5-git-send-email-shmulik.ladkani@gmail.com>
 <CAM_iQpWwPqbiJ7tjbHqvYfyRL5fh+oXGVFFPmW3wLUCGbK-b4Q@mail.gmail.com> <CAOrmypK=TZ=cDCDwy=wJgCsMgJWaMfr5dudEwHNnQzpeYJRfHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Eric Dumazet <edumazet@google.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:36556 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751201AbcJFRbF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2016 13:31:05 -0400
Received: by mail-it0-f67.google.com with SMTP id o19so2133745ito.3
        for <netdev@vger.kernel.org>; Thu, 06 Oct 2016 10:31:04 -0700 (PDT)
In-Reply-To: <CAOrmypK=TZ=cDCDwy=wJgCsMgJWaMfr5dudEwHNnQzpeYJRfHw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 6, 2016 at 6:30 AM, Shmulik Ladkani
<shmulik.ladkani@gmail.com> wrote:
> Hi,
>
> On Mon, Oct 3, 2016 at 12:45 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> On Thu, Sep 29, 2016 at 4:03 AM, Shmulik Ladkani
>> <shmulik.ladkani@gmail.com> wrote:
>>>         skb2->skb_iif = skb->dev->ifindex;
>>>         skb2->dev = dev;
>>> -       err = dev_queue_xmit(skb2);
>>> +       if (tcf_mirred_act_direction(m_eaction) & AT_EGRESS)
>>> +               err = dev_queue_xmit(skb2);
>>> +       else
>>> +               netif_receive_skb(skb2);
>>
>> Any reason why not check the return value here?
>
> Rationale: netif_receive_skb returns err if there was no protocol
> handler to deliver the skb to.
> If skb is not caught by any protocol handler, this should not be
> considered an "ingress redirect" error. The redirect action should be
> considered successful.

A quick grep shows there are many places returning NET_RX_DROP:
E.g.

net/ipv4/arp.c: return NET_RX_DROP;
net/ipv4/arp.c: return NET_RX_DROP;
net/ipv4/gre_demux.c:   return NET_RX_DROP;
net/ipv4/ip_forward.c:  return NET_RX_DROP;
net/ipv4/ip_input.c:    return NET_RX_DROP;
net/ipv4/ip_input.c:    return NET_RX_DROP;
net/ipv4/ipconfig.c:            return NET_RX_DROP;
net/ipv4/ipconfig.c:            return NET_RX_DROP;
net/ipv4/raw.c:         return NET_RX_DROP;
net/ipv4/raw.c:         return NET_RX_DROP;
net/ipv4/xfrm4_input.c: return NET_RX_DROP;
net/ipv6/ip6_input.c:           return NET_RX_DROP;
net/ipv6/ip6_input.c:                   return NET_RX_DROP;
net/ipv6/ip6_input.c:   return NET_RX_DROP;
net/ipv6/raw.c:         return NET_RX_DROP;
net/ipv6/raw.c:         return NET_RX_DROP;
net/ipv6/raw.c:         return NET_RX_DROP;
net/ipv6/raw.c:                 return NET_RX_DROP;
