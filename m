From: Anton Ivanov <anton.ivanov@cambridgegreys.com>
Subject: Re: BUG:af_packet fails to TX TSO frames
Date: Thu, 12 Oct 2017 07:11:54 +0100
Message-ID: <2f973588-e193-86c1-a645-7a158b17ebdc@cambridgegreys.com>
References: <c3002d4f-62ff-1d0b-65fb-b366be45a6d8@cambridgegreys.com>
 <CAF=yD-+SxQTHxiU5Yi2f8dm6X1s7SA6PdkbeJP-K_9ZuTMAaTA@mail.gmail.com>
 <f2fe3f46-2ef1-0029-1c44-3576ca19d34b@cambridgegreys.com>
 <844d6e0f-6ee7-74bc-b961-faa77b240303@cambridgegreys.com>
 <CAF=yD-+JaS8JwEC2TyUG=Ebaho-MM+gjumrbHYM-H0EK1Hu62Q@mail.gmail.com>
 <23ace6d6-afa7-9a3a-aa61-1245ee6c0498@kot-begemot.co.uk>
 <CAF=yD-+MCLAoP5=orUyG0tQjXykde++QrOdE7v44srR54yP32Q@mail.gmail.com>
 <d6c1cda2-f7df-9132-304d-075c62d4d83d@kot-begemot.co.uk>
 <CAF=yD-+gc5oQ=XT0+yw4Wt_h3rObETti3FvXm+V-nu=87zaMyA@mail.gmail.com>
 <1e9c4f8b-2eb6-24cf-764f-b0a98aa0d044@kot-begemot.co.uk>
 <40e87e75-742f-3542-b79e-1e7fee9b4485@cambridgegreys.com>
 <CAF=yD-+YUZdCCLXdQEG5AA0Pkrf-OrWGwySWf7mqH5BhO-Vr+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Anton Ivanov <anton.ivanov@kot-begemot.co.uk>,
        Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ivanoab5.miniserver.com ([78.31.111.25]:36678 "EHLO
        www.kot-begemot.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751034AbdJLGMF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 02:12:05 -0400
In-Reply-To: <CAF=yD-+YUZdCCLXdQEG5AA0Pkrf-OrWGwySWf7mqH5BhO-Vr+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/10/17 01:19, Willem de Bruijn wrote:
> On Wed, Oct 11, 2017 at 6:01 PM, Anton Ivanov
> <anton.ivanov@cambridgegreys.com> wrote:
>> [snip]
>>
>>> This will be tomorrow though, it is late here.
>>>
>>> The only obvious difference I can see at this point is that I am using
>>> iovs and sending the vnet header as iov[0] and the data in pieces after
>>> that while your code is doing a send() for the whole frame. This should
>>> not make any difference though - it all ends up as an iov internally in
>>> the kernel.
>> Spoke too soon. It is not reporting any errors, but there is nothing
>> coming out on the actual Ethernet.

Different issue - switch was blacklisting the fake dst MAC after the
first packet as a suspected flood attack.

It worked after I changed the mac in the source to a "real" one. In
fact, an argument for that
would be nice :)

I will go through it step by step now and figure out exactly what and
where is wrong with the framing on my side.

Thanks for your help.

A.

> It works for me on various platforms. On the receiver, drop these fake
> tcp packets in iptables and read them with tcpdump
>
>    iptables -A PREROUTING -t raw -p tcp --dport 9 -j DROP
>    tcpdump src $src_ip
>
> Note that not all combinations of flags are supported by the kernel
> and that some flags have non-obvious behavior (disable a feature, in
> place of enable it).
>
> Specifically, mtu sized packets either must not pass a vnet_hdr or
> must pass one with gso explicitly disabled ('-G').
>
>   psock_txring_vnet -s $src_ip $dst_ip -l 1400
>   psock_txring_vnet -s $src_ip $dst_ip -l 1400 -v -G
>   psock_txring_vnet -s $src_ip $dst_ip -l 1400 -N
>   psock_txring_vnet -s $src_ip $dst_ip -l 1400 -N -v -G
>
> Conversely, packets that exceed mtu have to have the gso flags in the
> virtio_net_hdr:
>
>   psock_txring_vnet -s $src_ip $dst_ip -l 4400 -v
>   psock_txring_vnet -s $src_ip $dst_ip -l 4400 -N -v
>
> When sending a large packet, but not passing a virtio_net_hdr along
> ('-v'), the test fails with
>
>   psock_txring_vnet: send: Message too long
>
> When passing a header along, but not disabling gso, the packet is
> indeed dropped silently.
>
> I verified correct segmentation with three modes of ethtool
>
>   ethtool -K eth0 tso off gso off
>   ethtool -K eth0 tso off gso on
>   ethtool -K eth0 tso on gso on
>
> by reading tcpdump on the sender.
>
> The receive side results are the same with dev_queue_xmit and
> packet_direct_xmit ('-q') mode. With direct_xmit, the packets are not
> observed on the send side.
>


-- 
Anton R. Ivanov
Cambridgegreys Limited. Registered in England. Company Number 10273661
