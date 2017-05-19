From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH v4 net-next 6/7] net: allow simultaneous SW and HW
 transmit timestamping
Date: Fri, 19 May 2017 10:52:24 -0400
Message-ID: <CAF=yD-JGbHujR_f9zj53t+ga7-pYSFTd6FiqV4H=m9gJES4H6g@mail.gmail.com>
References: <20170518130656.24163-1-mlichvar@redhat.com> <20170518130656.24163-7-mlichvar@redhat.com>
 <CAF=yD-KVwq+WXZNoZH+Vbs8-aMWF969AxzTqBZSKfFyDqszRNQ@mail.gmail.com> <20170519100040.GB21003@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:32789 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750746AbdESOxG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 10:53:06 -0400
Received: by mail-oi0-f65.google.com with SMTP id h4so12748640oib.0
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 07:53:05 -0700 (PDT)
In-Reply-To: <20170519100040.GB21003@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 19, 2017 at 6:00 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
> On Thu, May 18, 2017 at 04:16:26PM -0400, Willem de Bruijn wrote:
>> On Thu, May 18, 2017 at 9:06 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
>> > +/* On transmit, software and hardware timestamps are returned independently.
>> > + * As the two skb clones share the hardware timestamp, which may be updated
>> > + * before the software timestamp is received, a hardware TX timestamp may be
>> > + * returned only if there is no software TX timestamp. A false software
>> > + * timestamp made for SOCK_RCVTSTAMP when a real timestamp is missing must
>> > + * be ignored.
>>
>> Please expand on why this case can be ignored. It is quite subtle. How about
>> something like
>>
>> *
>> * A false software timestamp is one made inside the __sock_recv_timestamp
>> * call itself. These are generated whenever SO_TIMESTAMP(NS) is enabled
>> * on the socket, even when the timestamp reported is for another option, such
>> * as hardware tx timestamp.
>> *
>> * Ignore these when deciding whether a timestamp source is hw or sw.
>> */
>
> That seems a bit too verbose to me. :) Would the following work?
>
> /* On transmit, software and hardware timestamps are returned independently.
>  * As the two skb clones share the hardware timestamp, which may be updated
>  * before the software timestamp is received, a hardware TX timestamp may be
>  * returned only if there is no software TX timestamp. Ignore false software
>  * timestamps, which may be made in the __sock_recv_timestamp() call when the
>  * option SO_TIMESTAMP(NS) is enabled on the socket, even when the skb has a
>  * hardware timestamp.
>  */

Looks great, thanks.

>
>> > +static bool skb_is_swtx_tstamp(const struct sk_buff *skb,
>> > +                              const struct sock *sk, int false_tstamp)
>> > +{
>> > +       if (false_tstamp && sk->sk_tsflags & SOF_TIMESTAMPING_OPT_TX_SWHW)
>>
>> Also, why is it ignored only for the new mode?
>
> Good point. That should not be there. The function can be now reduced
> to a single line again. I originally tried a different approach,
> disabling false timestamps in the new mode, but then I thought it's
> better to not complicate it unnecessarily and keep it consistent.
>
> --
> Miroslav Lichvar
