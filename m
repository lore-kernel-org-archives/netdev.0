From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: Extending socket timestamping API for NTP
Date: Mon, 27 Feb 2017 19:01:54 -0500
Message-ID: <CAF=yD-JJ2nMYg1soRzCv2CKH0c_i2+Ku-UK8-mMYFtbfbn__kw@mail.gmail.com>
References: <20170207140144.GA11233@localhost> <02874ECE860811409154E81DA85FBB5857D6DC87@ORSMSX115.amr.corp.intel.com>
 <CAF=yD-JLiABx6TcVg_8mS5ZhomRaZ+cZ8edx00hJNG8PDrsSjg@mail.gmail.com> <20170227152339.GB12043@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Keller, Jacob E" <jacob.e.keller@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Jiri Benc <jbenc@redhat.com>, Denny Page <dennypage@me.com>,
        Willem de Bruijn <willemb@google.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:36511 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751774AbdB1A1k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 19:27:40 -0500
Received: by mail-wm0-f54.google.com with SMTP id v77so73297961wmv.1
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 16:27:39 -0800 (PST)
In-Reply-To: <20170227152339.GB12043@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 27, 2017 at 10:23 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
> On Tue, Feb 07, 2017 at 02:32:04PM -0800, Willem de Bruijn wrote:
>> >> 4) allow sockets to use both SW and HW TX timestamping at the same time
>> >>
>> >>    When using a socket which is not bound to a specific interface, it
>> >>    would be nice to get transmit SW timestamps when HW timestamps are
>> >>    missing. I suspect it's difficult to predict if a HW timestamp will
>> >>    be available. Maybe it would be acceptable to get from the error
>> >>    queue two messages per transmission if the interface supports both
>> >>    SW and HW timestamping?
>> >
>> >
>> > This seems useful,
>>
>> Agreed, as long as it is optional so that it does not change the
>> behavior for existing applications.
>
> Do you think it is safe to assume that no application enabled both SW
> and HW TX timestamping?

We cannot rule out that a process set both flags.

> Do we need a new option for this?

Similar to OPT_TSONLY or OPT_ID, but to signal the intent of
receiving both timestamps. Yes, agreed.

>> > but not sure how best to implement it.
>>
>> It might be sufficient to just remove the second line in sw_tx_timestamp
>>
>> static inline void sw_tx_timestamp(struct sk_buff *skb)
>> {
>>         if (skb_shinfo(skb)->tx_flags & SKBTX_SW_TSTAMP &&
>>             !(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS))
>>                 skb_tstamp_tx(skb, NULL);
>> }
>
> With this change I'm getting two error messages per transmission, but
> it looks like it may need some additional changes.
>
> If the first error message is received after the HW timestamp was
> captured,

When does this happen? The first timestamp is generated from
skb_tx_timestamp in the device driver's ndo_start_xmit before
passing the packet to the NIC, the second when the device
driver cleans the tx descriptor on completion.

Is this for drivers that do not have skb_tx_timestamp, as you
mention below? Then the solution is to add that call.

> it contains both timestamps as the HW timestamp is in the
> shared info of the skb. Is it possible it could contain a partially
> updated HW timestamp? I'm not sure how locking works here. Is
> scm_timestamping actually allowed to contain more than one timestamp?
> The timestamping.txt document says "Only one field is non-zero at any
> time.", but that wasn't true even before if both SW and HW RX
> timestamping was enabled.
>
> If SO_TIMESTAMP{,NS} is enabled, ts[0] in the second error message
> will contain a bogus SW timestamp added by __sock_recv_timestamp() for
> a "Race occurred between timestamp enabling and packet receiving".  Is

Good point. That should not be set on transmit timestamps.

> there a guarantee applications will get a timestamp for all messages
> after enabling SO_TIMESTAMP? The original code is older than the git
> repo, so I'm not sure what was the reason for this. To me it would
> make more sense to not add any SCM_TIMESTAMP (and SW timestamp in
> SCM_TIMESTAMPING) when the the timestamp is missing. If that's not
> always acceptable, maybe it could be restricted to sockets that have
> HW timestamping enabled?

I would limit scope to tx timestamping and leave rx semantics as is.

> Some drivers don't call skb_tx_timestamp() when HW timestamp was
> requested. From a cursory look it is e1000e, xgbe, sxgbe, and stmmac.
> This should hopefully be an easy fix.

Indeed. that should be added, then.
