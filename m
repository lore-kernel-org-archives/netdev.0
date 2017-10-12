From: Anton Ivanov <anton.ivanov@cambridgegreys.com>
Subject: Re: BUG:af_packet fails to TX TSO frames
Date: Thu, 12 Oct 2017 20:55:31 +0100
Message-ID: <872e2660-01fd-82ae-7a8f-16535dbc91d8@cambridgegreys.com>
References: <c3002d4f-62ff-1d0b-65fb-b366be45a6d8@cambridgegreys.com>
 <d6c1cda2-f7df-9132-304d-075c62d4d83d@kot-begemot.co.uk>
 <CAF=yD-+gc5oQ=XT0+yw4Wt_h3rObETti3FvXm+V-nu=87zaMyA@mail.gmail.com>
 <1e9c4f8b-2eb6-24cf-764f-b0a98aa0d044@kot-begemot.co.uk>
 <40e87e75-742f-3542-b79e-1e7fee9b4485@cambridgegreys.com>
 <CAF=yD-+YUZdCCLXdQEG5AA0Pkrf-OrWGwySWf7mqH5BhO-Vr+g@mail.gmail.com>
 <2f973588-e193-86c1-a645-7a158b17ebdc@cambridgegreys.com>
 <529ff560-8230-c799-2948-fae711de382e@kot-begemot.co.uk>
 <CAF=yD-+q_h4SE0E9RjE59i2FDYZQ_wV+L6RQjE9B_fszen-y0A@mail.gmail.com>
 <f046dbf4-0b46-2d7c-c82c-fe9f50c11f71@cambridgegreys.com>
 <e301fbfd-a283-caa1-5915-8be15677ed74@cambridgegreys.com>
 <CAF=yD-+W2tyXqCS_ueZgu11BB8ON5hdKGOZQOWtfr+HfvqW=Sg@mail.gmail.com>
 <CAF=yD-KiMWMwvD-s=z4brqUrNbRe4-fRZAKupEc2FvVn0MQxuQ@mail.gmail.com>
 <beef71a3-2cfc-95d7-f334-04685d31b640@cambridgegreys.com>
 <CAF=yD-K6f_+dw=ivu=jgrqdv+og4gvzPanYSBzizJBvM5rbiig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ivanoab5.miniserver.com ([78.31.111.25]:36718 "EHLO
        www.kot-begemot.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751996AbdJLTzi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 15:55:38 -0400
In-Reply-To: <CAF=yD-K6f_+dw=ivu=jgrqdv+og4gvzPanYSBzizJBvM5rbiig@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[snip]

>> There is no requirement to bind to ETH_P_IP either and most code examples
>> going back more than 10 years to the days of TCP Illustrated use ALL.
> For send only sockets, it is often advised to pass 0 as protocol to
> socket(), so as to avoid having to spend cycles on packet reception
> at all.

Normally, it would have been a single rw socket. Thankfully, I built
into the UML vector IO patchset the ability to use different fds for
read and write per virtual NIC.

Coming back to "normally" - as an application developer I would have
expected a rw socket to work and not to need 2+ sockets for this. Having
to work around at that level is IMHO a bit over the top.

>
> Commit c72219b75fde ("packet: infer protocol from ethernet header
> if unset") explicitly added logic to infer skb->protocol for this common
> case of sockets, if using rings.
I will look into it.

>
>> I just did the v6 test - if you bind with ETH_P_IP GSO on TCPv6 is broken
>> and returns NOBUF and vice versa.
> Given that skb->protocol is set from proto, that is indeed not expected to work.
>
>>>>> I think what is happening is that this value is taken into account when
>>>>> looking at "what should I use to segment it with" in skb_mac_gso_segment
>>>>> which is invoked at the end of the verification chain which starts in
>>>>> packet_direct_xmit in af_packet.c
>>>> packet_snd sets skb->protocol based on the protocol that the packet
>>>> socket is bound to. Binding to ETH_P_IP is the right choice here.
>>> To avoid having to open multiple sockets for different protocols,
>>> sockaddr_ll can also be passed in the msg_name argument on
>>> each call.
>>
>> Does not work for vnet headers - it honors what you bound with. I tried to
>> bind with ETH_ALL and pass ETH_P_IP as an arg and it ENOBUF-ed
> Odd. The code for looking up proto in packet_snd looks fairly straightforward:

I will double-check it tomorrow and send you a pull request for the
updated test application.

>
>         /*
>          *      Get and verify the address.
>          */
>
>         if (likely(saddr == NULL)) {
>                 dev     = packet_cached_dev_get(po);
>                 proto   = po->num;
>                 addr    = NULL;
>         } else {
>                 err = -EINVAL;
>                 if (msg->msg_namelen < sizeof(struct sockaddr_ll))
>                         goto out;
>                 if (msg->msg_namelen < (saddr->sll_halen +
> offsetof(struct sockaddr_ll, sll_addr)))
>                         goto out;
>                 proto   = saddr->sll_protocol;
>                 addr    = saddr->sll_addr;
>                 dev = dev_get_by_index(sock_net(sk), saddr->sll_ifindex);
>         }
>
> followed later by
>
>         skb->protocol = proto;
>         skb->dev = dev;
>


-- 
Anton R. Ivanov
Cambridgegreys Limited. Registered in England. Company Number 10273661
