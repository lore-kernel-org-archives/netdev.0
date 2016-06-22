From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH net-next v3] tcp: use RFC6298 compliant TCP RTO
 calculation
Date: Wed, 22 Jun 2016 13:21:20 +0200 (CEST)
Message-ID: <2052282810.48692.1466594480806@office.mailbox.org>
References: <CAK6E8=eeso8OEN_0-znqkuEyVTqzP1mTvwktk4QOsrLJXmuj9Q@mail.gmail.com>
 <20160615180003.28970-1-dmetz@mytum.de>
 <20160617.113235.1099766688971255047.davem@davemloft.net>
 <CAK6E8=eQNkSyAujuqF9hiE1iFk03O4T6op_-g=y87+UQUrS4=Q@mail.gmail.com>
 <CAK6E8=cyrog=2UmVpwP3jzCtFAR9LxxtS+g01R42H9jk=_cZ2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Daniel Metz <dmetz@mytum.de>, netdev <netdev@vger.kernel.org>,
	Daniel Metz <Daniel.Metz@rohde-schwarz.com>,
	Eric Dumazet <edumazet@google.com>
To: Yuchung Cheng <ycheng@google.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.mailbox.org ([80.241.60.212]:51663 "EHLO mx1.mailbox.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752373AbcFVLaq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2016 07:30:46 -0400
In-Reply-To: <CAK6E8=cyrog=2UmVpwP3jzCtFAR9LxxtS+g01R42H9jk=_cZ2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On June 22, 2016 at 7:53 AM Yuchung Cheng <ycheng@google.com> wrote:
> 
> Thanks for the patience. I've collected data from some Google Web
> servers. They serve both a mix of US and SouthAm users using
> HTTP1 and HTTP2. The traffic is Web browsing (e.g., search, maps,
> gmails, etc but not Youtube videos). The mean RTT is about 100ms.
> 
> The user connections were split into 4 groups of different TCP RTO
> configs. Each group has many millions of connections but the
> size variation among groups is well under 1%.
> 
> B: baseline Linux
> D: this patch
> R: change RTTYAR averaging as in D, but bound RTO to 1sec per RFC6298
> Y: change RTTVAR averaging as in D, but bound RTTVAR to 200ms instead (like B)
> 
> For mean TCP latency of HTTP responses (first byte sent to last byte
> acked), B < R < Y < D. But the differences are so insignificant (<1%).
> The median, 95pctl, and 99pctl has similar indifference. In summary
> there's hardly visible impact on latency. I also look at only response
> less than 4KB but do not see a different picture.
> 
> The main difference is the retransmission rate where R =~ Y < B =~D.
> R and Y are ~20% lower than B and D. Parsing the SNMP stats reveal
> more interesting details. The table shows the deltas in percentage to
> the baseline B.
> 
>                 D      R     Y
> ------------------------------
> Timeout      +12%   -16%  -16%
> TailLossProb +28%    -7%   -7%
> DSACK_rcvd   +37%    -7%   -7%
> Cwnd-undo    +16%   -29%  -29%
> 
> RTO change affects TLP because TLP will use the min of RTO and TLP
> timer value to arm the probe timer.
> 
> The stats indicate that the main culprit of spurious timeouts / rtx is
> the RTO lower-bound. But they also show the RFC RTTVAR averaging is as
> good as current Linux approach.
> 
> Given that I would recommend we revise this patch to use the RFC
> averaging but keep existing lower-bound (of RTTVAR to 200ms). We can
> further experiment the lower-bound and change that in a separate
> patch.

Great news Yuchung!

Then Daniel will prepare v4 with a min-rto lower bound:

    max(RTTVAR, tcp_rto_min_us(struct sock))

Any further suggestions Yuchung, Eric? We will also feed this v4 in our test environment to check the behavior for sender limited, non-continuous flows.

Hagen
