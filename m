From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net] datagram: When peeking datagrams with offset < 0
 don't skip empty skbs
Date: Thu, 17 Aug 2017 12:45:48 -0400
Message-ID: <CAF=yD-Kt7AQ8ZUCky+MQLn13FDPrM=u+Ha9oD5kw17N5Xz8Uuw@mail.gmail.com>
References: <20170814055259.31078-1-matthew@mjdsystems.ca> <1502914822.2796.6.camel@redhat.com>
 <CAF=yD-JryS8g=8nB7yq9WVdCOjqSb7uNwncrRfWPmMQbdYrh3w@mail.gmail.com> <2020045.ridbXvZZ6f@ring00>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Paolo Abeni <pabeni@redhat.com>,
        Network Development <netdev@vger.kernel.org>,
        "Macieira, Thiago" <thiago.macieira@intel.com>
To: Matthew Dawson <matthew@mjdsystems.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:35707 "EHLO
        mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751107AbdHQQqc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 12:46:32 -0400
Received: by mail-oi0-f52.google.com with SMTP id e124so72413641oig.2
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2017 09:46:32 -0700 (PDT)
In-Reply-To: <2020045.ridbXvZZ6f@ring00>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> @@ -169,14 +169,20 @@ struct sk_buff *__skb_try_recv_from_queue(struct sock
>> *sk, int *peeked, int *off, int *err, struct sk_buff **last)
>>  {
>> +       bool peek_at_off = false;
>>         struct sk_buff *skb;
>> -       int _off = *off;
>> +       int _off = 0;
>> +
>> +       if (flags & MSG_PEEK && (*off) >= 0) {
>> +               peek_at_off = true;
>> +               _off = *off;
>> +       }
>>
>>         *last = queue->prev;
>>         skb_queue_walk(queue, skb) {
>>                 if (flags & MSG_PEEK) {
>> -                       if (_off >= skb->len && (skb->len || _off ||
>> -                                                skb->peeked)) {
>> +                       if (peek_at_off && _off >= skb->len &&
>> +                           (skb->len || _off || skb->peeked)) {
>                                 ^ I'm pretty sure we can remove this check
> (that skb->len is not zero) in this if statement.  If _off is zero, then skb-
>>len must also be zero (since _off >= skb->len, if _off is 0, skb->len <= 0.
> If skb->len can't be negative, then skb->len <= 0 => skb->len == 0).  If _off
> is not zero, then checking skb->len is redundant.

Good point.

>>                                 _off -= skb->len;
>>                                 continue;
>>                         }
> Is this queued to go in already? Or can I help by updating my patch with what
> was discussed here?  I can do that today if wanted.

It isn't. Please do if no one else has additional comments.
