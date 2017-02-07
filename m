From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: Extending socket timestamping API for NTP
Date: Tue, 7 Feb 2017 14:32:04 -0800
Message-ID: <CAF=yD-JLiABx6TcVg_8mS5ZhomRaZ+cZ8edx00hJNG8PDrsSjg@mail.gmail.com>
References: <20170207140144.GA11233@localhost> <02874ECE860811409154E81DA85FBB5857D6DC87@ORSMSX115.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Miroslav Lichvar <mlichvar@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Jiri Benc <jbenc@redhat.com>, Denny Page <dennypage@me.com>,
        Willem de Bruijn <willemb@google.com>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:37819 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755355AbdBGWcr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 17:32:47 -0500
Received: by mail-wm0-f49.google.com with SMTP id v77so174209163wmv.0
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 14:32:46 -0800 (PST)
In-Reply-To: <02874ECE860811409154E81DA85FBB5857D6DC87@ORSMSX115.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> 2) new SO_TIMESTAMPING option to receive from the error queue only
>>    user data as was passed to sendmsg() instead of Ethernet frames
>>
>>    Parsing Ethernet and IP headers (especially IPv6 options) is not
>>    fun and SOF_TIMESTAMPING_OPT_ID is not always practical, e.g. in
>>    applications which process messages from the error queue
>>    asynchronously and don't bind/connect their sockets.
>
> This would be useful for application writing.

What kind of user data are you suggesting? Just a user-defined ID
passed as a cmsg? Allowing such metadata to override
skb_shinfo(skb)->tskey sounds fine.

>> 3) target address in msg_name of messages from the error queue
>>
>>    With 2) and unconnected sockets, there needs to be a way to get the
>>    address to which the packet was sent. Is it ok to always fill
>>    msg_name, or does it need to be a new option?
>
>
> I'm not sure.

This would be an argument to just loop the original packet.

>> 4) allow sockets to use both SW and HW TX timestamping at the same time
>>
>>    When using a socket which is not bound to a specific interface, it
>>    would be nice to get transmit SW timestamps when HW timestamps are
>>    missing. I suspect it's difficult to predict if a HW timestamp will
>>    be available. Maybe it would be acceptable to get from the error
>>    queue two messages per transmission if the interface supports both
>>    SW and HW timestamping?
>
>
> This seems useful,

Agreed, as long as it is optional so that it does not change the
behavior for existing applications.

> but not sure how best to implement it.

It might be sufficient to just remove the second line in sw_tx_timestamp

static inline void sw_tx_timestamp(struct sk_buff *skb)
{
        if (skb_shinfo(skb)->tx_flags & SKBTX_SW_TSTAMP &&
            !(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS))
                skb_tstamp_tx(skb, NULL);
}
