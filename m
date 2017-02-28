From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: Extending socket timestamping API for NTP
Date: Tue, 28 Feb 2017 16:05:23 -0500
Message-ID: <CAF=yD-JeJpL1fYnOmoKnF3eMSyO+=hfF3naKuD9Rbutuog0t7w@mail.gmail.com>
References: <20170207140144.GA11233@localhost> <02874ECE860811409154E81DA85FBB5857D6DC87@ORSMSX115.amr.corp.intel.com>
 <CAF=yD-JLiABx6TcVg_8mS5ZhomRaZ+cZ8edx00hJNG8PDrsSjg@mail.gmail.com>
 <20170227152339.GB12043@localhost> <CAF=yD-JJ2nMYg1soRzCv2CKH0c_i2+Ku-UK8-mMYFtbfbn__kw@mail.gmail.com>
 <20170228082632.GA14857@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Keller, Jacob E" <jacob.e.keller@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Jiri Benc <jbenc@redhat.com>, Denny Page <dennypage@me.com>,
        Willem de Bruijn <willemb@google.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f173.google.com ([209.85.128.173]:34804 "EHLO
        mail-wr0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751648AbdB1Vbe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 16:31:34 -0500
Received: by mail-wr0-f173.google.com with SMTP id l37so17488364wrc.1
        for <netdev@vger.kernel.org>; Tue, 28 Feb 2017 13:31:33 -0800 (PST)
In-Reply-To: <20170228082632.GA14857@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> > With this change I'm getting two error messages per transmission, but
>> > it looks like it may need some additional changes.
>> >
>> > If the first error message is received after the HW timestamp was
>> > captured,
>>
>> When does this happen? The first timestamp is generated from
>> skb_tx_timestamp in the device driver's ndo_start_xmit before
>> passing the packet to the NIC, the second when the device
>> driver cleans the tx descriptor on completion.
>
> As I understand it, it happens when the first skb (created by the
> skb_tx_timestamp() call) is received by the application after the
> driver called skb_tstamp_tx() with the HW timestamp. The SW timestamps
> are separate, but the HW timestamp is shared between clones. It

Oh right, the conversion to struct scm_timestamping only happens
on socket read in __sock_recv_timestamp.

> probably doesn't happen with the TSONLY option as it allocates a new
> skb. When I print timestamps from scm_timestamping I see a mix of two
> cases:
>
> TX 1488268812.193945472 0.000000000 1488286813.273760139
> TX 0.000000000 0.000000000 1488286813.273760139
> RX 1488268812.354356188 0.000000000 1488286813.434096389
>
> TX 1488268816.364407934 0.000000000 0.000000000
> TX 0.000000000 0.000000000 1488286817.444251014
> RX 1488268816.525150589 0.000000000 1488286817.604749889
>
> In the first case I assume the HW timestamp was saved before the first
> error message was received, so both error messages have the same HW
> timestamp, but only one has the SW timestamp. In the second case, the
> HW timestamp was saved later, so there is one message with SW
> timestamp and one message with HW timestamp.
>
> From the application point of view it would make sense if in the first
> case there was only one error message containing both timestamps. I'm

Agreed. I just proposed something similar on the error queue for
zerocopy notifications in http://patchwork.ozlabs.org/patch/731214/

> not sure how easy/safe it would be to drop the second skb. The other
> approach would be to not put HW timestamp in the first message when
> this "dual TX timestamping" option is enabled, so each error message
> has only one timestamp.

If it's possible to avoid one skb_clone completely, then that is preferable
over creating both and consuming one. If either approach becomes
complex, then queuing two separate messages is fine. A process
can recvmmsg(), after all. As long as the behavior is consistent.
