From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next] packet: fix warnings in rollover lock contention
Date: Thu, 14 May 2015 11:53:20 -0400
Message-ID: <CA+FuTSfQ3xuTjJk-oSDvT0o67vY34Y68zVjuTByhNaGfaNPagg@mail.gmail.com>
References: <1431614560-8866-1-git-send-email-willemb@google.com> <1431617634.27831.60.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:32811 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933508AbbENPxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 11:53:51 -0400
Received: by oica37 with SMTP id a37so58939217oic.0
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 08:53:51 -0700 (PDT)
In-Reply-To: <1431617634.27831.60.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
>> index 31d5856..ac1a589 100644
>> --- a/net/packet/af_packet.c
>> +++ b/net/packet/af_packet.c
>> @@ -1310,8 +1310,7 @@ static int packet_rcv_has_room(struct packet_sock *po, struct sk_buff *skb)
>>       }
>>
>>       has_room = ret == ROOM_NORMAL;
>> -     if (po->pressure == has_room)
>> -             xchg(&po->pressure, !has_room);
>> +     if (atomic_cmpxchg(&po->pressure, has_room, !has_room)) {}
>>
>
> This makes no sense to me.
>
> I thought you wanted to avoid dirtying the cache line.
> No atomic op can help the race here.

I principally want to avoid the lock contention on sk_receive_queue.lock,
which is held for a lot longer while probing frames. But yes, I'd prefer to
avoid the cacheline contention as well.

The alternative is to keep the race and just replace the xchg with a
straight assignment.
