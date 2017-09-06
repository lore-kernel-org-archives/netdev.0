From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next RFC 1/2] tun: enable NAPI for TUN/TAP driver
Date: Wed, 6 Sep 2017 11:18:58 +0200
Message-ID: <CAF=yD-JTTmzf_r9uKQkjXNMwLrZx7NSWU3sBG3Kk=8B2ztU0zQ@mail.gmail.com>
References: <20170905223551.27925-1-ppenkov@google.com> <20170905223551.27925-2-ppenkov@google.com>
 <20170905155127.0bd08fb0@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Petar Penkov <ppenkov@google.com>,
        Network Development <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Mahesh Bandewar <maheshb@google.com>,
        Willem de Bruijn <willemb@google.com>,
        David Miller <davem@davemloft.net>, ppenkov@stanford.edu
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:33180 "EHLO
        mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752406AbdIFJTj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 05:19:39 -0400
Received: by mail-oi0-f42.google.com with SMTP id r20so9508856oie.0
        for <netdev@vger.kernel.org>; Wed, 06 Sep 2017 02:19:39 -0700 (PDT)
In-Reply-To: <20170905155127.0bd08fb0@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 6, 2017 at 12:51 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Tue,  5 Sep 2017 15:35:50 -0700
> Petar Penkov <ppenkov@google.com> wrote:
>
>> Changes TUN driver to use napi_gro_receive() upon receiving packets
>> rather than netif_rx_ni(). Adds flag CONFIG_TUN_NAPI that enables
>> these changes and operation is not affected if the flag is disabled.
>> SKBs are constructed upon packet arrival and are queued to be
>> processed later.
>>
>> The new path was evaluated with a benchmark with the following setup:
>> Open two tap devices and a receiver thread that reads in a loop for
>> each device. Start one sender thread and pin all threads to different
>> CPUs. Send 1M minimum UDP packets to each device and measure sending
>> time for each of the sending methods:
>>       napi_gro_receive():     4.90s
>>       netif_rx_ni():          4.90s
>>       netif_receive_skb():    7.20s
>>
>> Signed-off-by: Petar Penkov <ppenkov@google.com>
>> Cc: Eric Dumazet <edumazet@google.com>
>> Cc: Mahesh Bandewar <maheshb@google.com>
>> Cc: Willem de Bruijn <willemb@google.com>
>> Cc: davem@davemloft.net
>> Cc: ppenkov@stanford.edu
>
> Why is this optional? It adds two code paths both of which need
> to be tested.

If the napi_gro_receive path is no more expensive than netif_receive_skb,
as the evaluation indicates, then it is a good candidate to replace that.

The napi_gro_frags path is purely for code coverage. There is no benefit
to applications to treat data copied from userspace as if it consists of raw
pages of data.
