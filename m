From: Neal Cardwell <ncardwell@google.com>
Subject: Re: TCP fast retransmit issues
Date: Wed, 26 Jul 2017 13:06:40 -0400
Message-ID: <CADVnQykEX-LzhsqyfHNmV6fF9-d_2R0v+mOX-PnyagUhC1qQzQ@mail.gmail.com>
References: <200d9a12e9f2f5791d4c5ce2d47a1239@vsen.dk> <1501069756.12695.11.camel@edumazet-glaptop3.roam.corp.google.com>
 <a025f5b2ed6e1f287f68b6bb5137a988@vsen.dk> <1501075881.12695.15.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170726134242.GB1737@1wt.eu> <1501079532.12695.17.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170726145059.GE1737@1wt.eu> <CADVnQymKZAc+SFD7X-FoP9UwHgB2MBCY48=dL8mH6XuKumkx4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Klavs Klavsen <kl@vsen.dk>,
        Netdev <netdev@vger.kernel.org>,
        Yuchung Cheng <ycheng@google.com>,
        Nandita Dukkipati <nanditad@google.com>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:36137 "EHLO
        mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751202AbdGZRHL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 13:07:11 -0400
Received: by mail-oi0-f53.google.com with SMTP id g131so85884815oic.3
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2017 10:07:11 -0700 (PDT)
In-Reply-To: <CADVnQymKZAc+SFD7X-FoP9UwHgB2MBCY48=dL8mH6XuKumkx4g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 26, 2017 at 12:43 PM, Neal Cardwell <ncardwell@google.com> wrote:
> (1) Because the connection negotiated SACK, the Linux TCP sender does
> not get to its tcp_add_reno_sack() code to count dupacks and enter
> fast recovery on the 3rd dupack. The sender keeps waiting for specific
> packets to be SACKed that would signal that something has probably
> been lost. We could probably mitigate this by having the sender turn
> off SACK once it sees SACKed ranges that are completely invalid (way
> out of window). Then it should use the old non-SACK "Recovery on 3rd
> dupack" path.
>
> (2) It looks like there is a bug in the sender code where it seems to
> be repeatedly using a TLP timer firing 211ms after every ACK is
> received to transmit another TLP probe (a new packet in this case).
> Somehow these weird invalid SACKs seem to be triggering a code path
> that makes us think we can send another TLP, when we probably should
> be firing an RTO. That's my interpretation, anyway. I will try to
> reproduce this with packetdrill.

Hmm. It looks like this might be a general issue, where any time we
get an ACK that doesn't ACK/SACK anything new (whether because it's
incoming data in a bi-directional flow, or a middlebox breaking the
SACKs), then we schedule a TLP timer further out in time. Probably we
should only push the TLP timer out if something is cumulatively ACKed.

But that's not a trivial thing to do, because by the time we are
deciding whether to schedule another TLP, we have already canceled the
previous TLP and reinstalled an RTO. Hmm.

neal
