From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH v1 net-next 5/6] net: allow simultaneous SW and HW
 transmit timestamping
Date: Fri, 28 Apr 2017 16:07:29 -0400
Message-ID: <CAF=yD-Ku30zqECeK-68o5Vuk+u4BaU8U3TZR32ZY4mq1y8f6jw@mail.gmail.com>
References: <20170426145035.25846-1-mlichvar@redhat.com> <20170426145035.25846-6-mlichvar@redhat.com>
 <CAF=yD-+GSK491AWQx8=6yd3=-HHwxdWq677ubwdjbV5AXzRbog@mail.gmail.com>
 <20170428085422.GD3401@localhost> <CAF=yD-+DYwBbhU0fOMOj4XO+diG4-GLn6Ruh9ZMoXVv5ZS4PgQ@mail.gmail.com>
 <20170428162325.GA2932@localhost>
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
Received: from mail-io0-f195.google.com ([209.85.223.195]:34432 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034678AbdD1UIL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 16:08:11 -0400
Received: by mail-io0-f195.google.com with SMTP id h41so13736920ioi.1
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2017 13:08:11 -0700 (PDT)
In-Reply-To: <20170428162325.GA2932@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 28, 2017 at 12:23 PM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
> On Fri, Apr 28, 2017 at 11:50:28AM -0400, Willem de Bruijn wrote:
>> On Fri, Apr 28, 2017 at 4:54 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
>> >>   if (skb_shinfo(skb)->tx_flags & SKBTX_SW_TSTAMP &&
>> >> -        !(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS))
>> >> +      (!(skb_shinfo(orig_skb)->tx_flags & SKBTX_IN_PROGRESS)) ||
>> >> +      (skb->sk && skb->sk->sk_tsflags & SOF_TIMESTAMPING_OPT_TX_SWHW)
>> >
>> > I'm not sure if this can work. sk_buff.h would need to include sock.h
>> > in order to get the definition of struct sock. Any suggestions?
>>
>> A more elegant solution would be to not set SKBTX_IN_PROGRESS
>> at all if SOF_TIMESTAMPING_OPT_TX_SWHW is set on the socket.
>> But the patch to do so is not elegant, having to update callsites in many
>> device drivers.
>
> Also, it would change the meaning of the flag as it seems some drivers
> actually use the SKBTX_IN_PROGRESS flag to check if they expect a
> timestamp.
>
> How about allocating the last bit of tx_flags for SKBTX_SWHW_TSTAMP?

That is such a scarce resource that I really would prefer to avoid using
that if we can.

>> Otherwise you may indeed have to call skb_tstamp_tx for every packet
>> that has SKBTX_SW_TSTAMP set, as you do. We can at least move
>> the skb->sk != NULL check into skb_tx_timestamp in skbuff.h.
>>
>> By the way, if changing this code, I think that it's time to get rid of
>> sw_tx_timestamp. It is only called from skb_tx_timestamp. Let's
>> just move the condition in there.
>
> Ok. I assume that should be a separate patch.

It's a single statement, I think we can do it as part of this one. Thanks.
