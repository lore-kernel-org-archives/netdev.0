From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net v2 3/3] packet: fix tpacket_snd max frame and vlan
 handling
Date: Wed, 11 Nov 2015 00:12:31 +0100
Message-ID: <564279DF.4080400@iogearbox.net>
References: <cover.1447191361.git.daniel@iogearbox.net> <f664dc9cf1d33a001fcdb0265833c96644db5bfd.1447191361.git.daniel@iogearbox.net> <CA+FuTSfkD4aMciGeqon0cLp=EJ7fWis56nGQsbku82ZC+=nNWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, tklauser@distanz.ch,
	Network Development <netdev@vger.kernel.org>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39389 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753222AbbKJXMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2015 18:12:37 -0500
In-Reply-To: <CA+FuTSfkD4aMciGeqon0cLp=EJ7fWis56nGQsbku82ZC+=nNWg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/10/2015 11:52 PM, Willem de Bruijn wrote:
>>          if (sock->type == SOCK_DGRAM) {
>> -               err = dev_hard_header(skb, dev, ntohs(proto), addr,
>> -                               NULL, tp_len);
>> +               /* In DGRAM sockets, we expect struct sockaddr_ll was filled
>> +                * via struct msghdr, so we have dest mac and skb->protocol.
>> +                * Otherwise there's not too much useful things we can do in
>> +                * this flush run.
>> +                */
>> +               err = dev_hard_header(skb, dev, ntohs(skb->protocol), addr,
>> +                                     NULL, tp_len);
>
> This change is not really necessary.

Sure agreed, I found it helpful though. Don't mind removing it.

>>                  if (unlikely(err < 0))
>>                          return -EINVAL;
>> -       } else if (dev->hard_header_len) {
>
> Why remove the check on hard_header_len?

Hmm, the patch doesn't remove the check (it's moved further below).

>> -               if (ll_header_truncated(dev, tp_len))
>> -                       return -EINVAL;
>> +       } else {
>> +               /* If skb->protocol is still 0, try to infer/guess it. Might
>> +                * not be fully reliable in the sense that a user could still
>> +                * change/race data afterwards, but on the other hand the proto
>
> The race goes away when probing it after the copy in skb_store_bits.
> Then it is also certain that tp_len is long enough to hold the entire
> link layer header.

The skb_store_bits() is only done in case we do have a dev->hard_header_len
or in case where we run into a possible situation where we have the additional
4 bytes on a full frame. In that case we need to check them properly, which
requires copying, otherwise we don't copy any header.

>> +                * can be set arbitrarily anyways. We only need to take care
>> +                * in case of extra large VLAN frames.
>> +                */
>> +               if (!skb->protocol && tp_len >= ETH_HLEN)
>> +                       skb->protocol = ((struct ethhdr *)data)->h_proto;
>
> Packet sockets are not restricted to link layer of type Ethernet.
>
> There are a few other points in this file that also cast mac header
> to eth_hdr(skb).

Ok, the set doesn't address this assumption which we have elsewhere, too.
Do you suggest to also check on dev->type for these cases?

Thanks,
Daniel
