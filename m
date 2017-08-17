From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net] datagram: When peeking datagrams with offset < 0
 don't skip empty skbs
Date: Wed, 16 Aug 2017 20:10:14 -0400
Message-ID: <CAF=yD-J-DeeWcZxZ7_2dr8rBJNOZOFF5skL31QHiYy99NzzjHA@mail.gmail.com>
References: <20170814055259.31078-1-matthew@mjdsystems.ca> <1502914822.2796.6.camel@redhat.com>
 <CAF=yD-JryS8g=8nB7yq9WVdCOjqSb7uNwncrRfWPmMQbdYrh3w@mail.gmail.com> <2308911.oTjYErtyEh@tjmaciei-mobl1>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Paolo Abeni <pabeni@redhat.com>,
        Matthew Dawson <matthew@mjdsystems.ca>,
        Network Development <netdev@vger.kernel.org>
To: Thiago Macieira <thiago.macieira@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:37779 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751490AbdHQAK4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 20:10:56 -0400
Received: by mail-oi0-f66.google.com with SMTP id j194so5018517oib.4
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 17:10:55 -0700 (PDT)
In-Reply-To: <2308911.oTjYErtyEh@tjmaciei-mobl1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 16, 2017 at 7:55 PM, Thiago Macieira
<thiago.macieira@intel.com> wrote:
> On Wednesday, 16 August 2017 16:27:17 PDT Willem de Bruijn wrote:
>> Actually, it is safe even without the check. Overflow of the signed integer
>> is benign here.
>
> Usually, it's a bad idea to allow UB to happen.
>
> Where is the overflow? I didn't see it in the patches so far.

There isn't. Instead of using a shift, as I proposed earlier, the latest
patch just passes the raw value of sk_peek_off.

The shift was an attempt to disambiguate between the cases that
return zero in sk_peek_offset:
(a) peek without SO_PEEK_OFF:
      each consecutive peek must look at the first packet
(b) peek with offset zero:
      peek at the first packet, move forward with each call

After coding up a version that shifts by one to differentiate the two
cases of zero it was obvious that there is no need to shift at all:
the case without SO_PEEK_OFF is identified by all negative values
if sk_peek_offset just does not explicitly return 0 for this case.

Of course, then all callers need to be verified to correctly handle
negative values. __sk_try_recv_from_queue uses this information.
The only other cases, unix stream, does not care about the difference,
as the bytestream has no record separators.

What is UB in this context?
