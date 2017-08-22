From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net] udp: on peeking bad csum, drop packets even if not at head
Date: Mon, 21 Aug 2017 20:12:04 -0400
Message-ID: <CAF=yD-+oht8gPcNdSU1zuj5TrOhq0cuwzzcwiCn676YzKNsn=Q@mail.gmail.com>
References: <20170821213912.93333-1-willemdebruijn.kernel@gmail.com> <1503355232.2499.15.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Paolo Abeni <pabeni@redhat.com>,
        Willem de Bruijn <willemb@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:35908 "EHLO
        mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754294AbdHVAMq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 20:12:46 -0400
Received: by mail-oi0-f53.google.com with SMTP id g131so170816029oic.3
        for <netdev@vger.kernel.org>; Mon, 21 Aug 2017 17:12:45 -0700 (PDT)
In-Reply-To: <1503355232.2499.15.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 21, 2017 at 6:40 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2017-08-21 at 17:39 -0400, Willem de Bruijn wrote:
>> From: Willem de Bruijn <willemb@google.com>
>>
>> When peeking, if a bad csum is discovered, the skb is unlinked from
>> the queue with __sk_queue_drop_skb and the peek operation restarted.
>>
>> __sk_queue_drop_skb only drops packets that match the queue head. With
>> sk_peek_off, the skb need not be at head, causing the call to fail and
>> the same skb to be found again on restart.
>>
>> Walk the queue to find the correct skb. Limit the walk to sk_peek_off,
>> to bound cycle cost to at most twice the original skb_queue_walk in
>> __skb_try_recv_from_queue.
>>
>> The operation may race with updates to sk_peek_off. As the operation
>> is retried, it will eventually succeed.
>>
>> Signed-off-by: Willem de Bruijn <willemb@google.com>
>
> You forgot the Fixes: tag, that such a bug fix deserves.

Indeed, sorry. I'm looking into that now. It should be the patch that
introduced peeking at offset, but need to verify.

I should also add that this bug was discovered by syzkaller.

> I am not a big fan of your patch and would prefer a solution without the
> loop.

Agreed.
