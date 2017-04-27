From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH v1 net-next 5/6] net: allow simultaneous SW and HW
 transmit timestamping
Date: Thu, 27 Apr 2017 12:48:50 -0400
Message-ID: <CAF=yD-LYVZWP2doqj9cV1iBP2NKQXojTUZ4Xpgy5a9TTHXG=1g@mail.gmail.com>
References: <20170426145035.25846-1-mlichvar@redhat.com> <20170426145035.25846-6-mlichvar@redhat.com>
 <CAF=yD-+GSK491AWQx8=6yd3=-HHwxdWq677ubwdjbV5AXzRbog@mail.gmail.com>
 <20170427161700.GB3401@localhost> <CAF=yD-+HK-dCG_XjqBKfkSF1bjJavTr7EFgeFNH2yRc2CXgOxA@mail.gmail.com>
 <20170427163911.GC3401@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>, Jiri Benc <jbenc@redhat.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36265 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936393AbdD0Qtc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 12:49:32 -0400
Received: by mail-io0-f193.google.com with SMTP id x86so4686546ioe.3
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 09:49:31 -0700 (PDT)
In-Reply-To: <20170427163911.GC3401@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 27, 2017 at 12:39 PM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
> On Thu, Apr 27, 2017 at 12:21:00PM -0400, Willem de Bruijn wrote:
>> >> > @@ -720,6 +720,7 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
>> >> >                 empty = 0;
>> >> >         if (shhwtstamps &&
>> >> >             (sk->sk_tsflags & SOF_TIMESTAMPING_RAW_HARDWARE) &&
>> >> > +           (empty || !skb_is_err_queue(skb)) &&
>> >> >             ktime_to_timespec_cond(shhwtstamps->hwtstamp, tss.ts + 2)) {
>> >>
>> >> I find skb->tstamp == 0 easier to understand than the condition on empty.
>> >>
>> >> Indeed, this is so non-obvious that I would suggest another helper function
>> >> skb_is_hwtx_tstamp with a concise comment about the race condition
>> >> between tx software and hardware timestamps (as in the last sentence of
>> >> the commit message).
>> >
>> > Should it include also the skb_is_err_queue() check? If it returned
>> > true for both TX and RX HW timestamps, maybe it could be called
>> > skb_has_hw_tstamp?
>>
>> For the purpose of documenting why this complex condition exists,
>> I would call the skb_is_err_queue in that helper function and make
>> it tx + hw specific.
>
> Hm, like this?
>
>         if (shhwtstamps &&
>             (sk->sk_tsflags & SOF_TIMESTAMPING_RAW_HARDWARE) &&
> +           (skb_is_hwtx_tstamp(skb) || !skb_is_err_queue(skb)) &&
>             ktime_to_timespec_cond(shhwtstamps->hwtstamp, tss.ts + 2)) {
>
> where skb_is_hwtx_tstamp() has
>         return skb->tstamp == 0 && skb_is_err_queue(skb);
>
> I was just not sure about the unnecessary skb_is_err_queue() call.

Oh, good point. If the condition is

  (skb_is_err_queue(skb) && !skb->tstamp) || !skb_is_err_queue(skb)

then it makes more sense to just use the simpler expression

  (!skb_is_err_queue(skb)) || (!skb->tstamp)

This cannot be called skb_is_hwtx_tstamp, as this does not imply
skb_hwtstamps(skb). Perhaps instead define

  /* On transmit, software and hardware timestamps are returned independently.
   * Do not return hardware timestamps even if skb_hwtstamps(skb) is true if
   * skb->tstamp is set
   */
  static bool skb_is_swtx_tstamp(skb) {
    return skb_is_err_queue(skb) && skb->tstamp;
  }

and use !skb_is_swtx_tstamp(skb) in this condition. The comment is
just a quick first try, can probably be improved.
