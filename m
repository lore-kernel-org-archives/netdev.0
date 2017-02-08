From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net 2/2] packet: round up linear to header len
Date: Wed, 8 Feb 2017 08:37:19 -0800
Message-ID: <CAF=yD-KoijEsct9YWm5zK3F7Eas3GS+=5zks7-fZw-bgZhi-3Q@mail.gmail.com>
References: <20170207205721.23207-1-willemdebruijn.kernel@gmail.com>
 <20170207205721.23207-3-willemdebruijn.kernel@gmail.com> <20170208153454.GD30741@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Willem de Bruijn <willemb@google.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35203 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752897AbdBHQjZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 11:39:25 -0500
Received: by mail-wm0-f67.google.com with SMTP id u63so34125193wmu.2
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 08:38:01 -0800 (PST)
In-Reply-To: <20170208153454.GD30741@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 8, 2017 at 7:34 AM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (02/07/17 15:57), Willem de Bruijn wrote:
>> @@ -2816,8 +2816,9 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
>>       err = -ENOBUFS;
>>       hlen = LL_RESERVED_SPACE(dev);
>>       tlen = dev->needed_tailroom;
>> -     skb = packet_alloc_skb(sk, hlen + tlen, hlen, len,
>> -                            __virtio16_to_cpu(vio_le(), vnet_hdr.hdr_len),
>> +     linear = __virtio16_to_cpu(vio_le(), vnet_hdr.hdr_len);
>> +     linear = max(linear, min_t(int, len, dev->hard_header_len));
>> +     skb = packet_alloc_skb(sk, hlen + tlen, hlen, len, linear,
>>                              msg->msg_flags & MSG_DONTWAIT, &err);
>
> do we need a similar check in packet_sendsmg_spkt (even if it
> is deprecated, would be better to get it to align with packet_snd?)

That path does not need this check, because it does not support
large packets and always allocates the entire packet as linear.

> Also tpacket_fill_skb should ensure that copylen is set up like
> the code above?

Do you mean the difference that it unconditionally pulls
hard_header_len, optionally with zero padding, whereas this new
path can check against new min_header_len and thus allows
packets shorter than hard_header_len?
