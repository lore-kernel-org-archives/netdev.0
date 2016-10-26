From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net] packet: on direct_xmit, limit tso and csum to
 supported devices
Date: Wed, 26 Oct 2016 11:32:55 -0400
Message-ID: <CAF=yD-JP5re8oq9qLEAAnQW3SxHDLOt1PedPEKw8UsUJ6KNq6w@mail.gmail.com>
References: <1477441683-68242-1-git-send-email-willemdebruijn.kernel@gmail.com>
 <581089BA.4090309@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f68.google.com ([209.85.213.68]:33831 "EHLO
        mail-vk0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754339AbcJZPdg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 11:33:36 -0400
Received: by mail-vk0-f68.google.com with SMTP id 14so266616vke.1
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 08:33:36 -0700 (PDT)
In-Reply-To: <581089BA.4090309@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 26, 2016 at 6:47 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 10/26/2016 02:28 AM, Willem de Bruijn wrote:
>>
>> From: Willem de Bruijn <willemb@google.com>
>>
>> When transmitting on a packet socket with PACKET_VNET_HDR and
>> PACKET_QDISC_BYPASS, validate device support for features requested
>> in vnet_hdr.
>>
>> Drop TSO packets sent to devices that do not support TSO or have the
>> feature disabled. Note that the latter currently do process those
>> packets correctly, regardless of not advertising the feature.
>>
>> Because of SKB_GSO_DODGY, it is not sufficient to test device features
>> with netif_needs_gso. Full validate_xmit_skb is needed.
>>
>> Switch to software checksum for non-TSO packets that request checksum
>> offload if that device feature is unsupported or disabled. Note that
>> similar to the TSO case, device drivers may perform checksum offload
>> correctly even when not advertising it.
>>
>> When switching to software checksum, packets hit skb_checksum_help,
>> which has two BUG_ON checksum not in linear segment. Packet sockets
>> always allocate at least up to csum_start + csum_off + 2 as linear.
>
>
> Ok, for the tpacket_fill_skb() case with SOCK_RAW, it's guaranteed,
> because if we have a vnet header, then copylen would cover that here
> (as opposed to just dev->hard_header_len). With Eric's suggestion,
> looks good to me. Thanks, Willem!

Right. For skb_checksum_help, the important check is that it is only entered
when ip_summed == CHECKSUM_PARTIAL. Packet sockets only set that
field after ensuring hdr_len exceeds the checksum.

But in general, linear headers are not guaranteed. A particularly fun
edge case is a device with mtu > PAGE_SIZE, which allows
packet_alloc_skb to create a packet with any linear length > 0 as long
as it does not ask for checksum offload or gso.

I plan to send a patch to net-next to always allocate headers in the
linear segment. skb_probe_transport_header is called in the send path,
but after allocation, so we may have to settle for simpler MAX_HEADER.

Thanks for reviewing, Daniel!
