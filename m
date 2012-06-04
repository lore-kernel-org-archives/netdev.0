From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH 3/3] Revert Backoff [v3]: Calculate TCP's connection close
 threshold as a time value.
Date: Mon, 4 Jun 2012 16:57:46 -0700
Message-ID: <CAPshTCiHhYng+jL-stjXLWvkzm-cQwtzsVDWkTYE8DypYOEgkA@mail.gmail.com>
References: <4A950B82.1070807@tvk.rwth-aachen.de>
	<CAFbMe2Mu46N8kRrYkGzYRLuntEd2J9aO_d0Jw_y0gsQA4q-qHw@mail.gmail.com>
	<CAPshTCiFDUb3CVm-joJW_DRVS+C+_BjFO-Mt3uAwrCzVw8MsVg@mail.gmail.com>
	<1338832247.5299.4.camel@nexus>
	<alpine.DEB.2.00.1206042116560.17280@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Damian Lukowski <damian@tvk.rwth-aachen.de>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:34468 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751935Ab2FDX5s convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2012 19:57:48 -0400
Received: by lahd3 with SMTP id d3so3400631lah.19
        for <netdev@vger.kernel.org>; Mon, 04 Jun 2012 16:57:46 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1206042116560.17280@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 4, 2012 at 12:18 PM, Ilpo J=E4rvinen
<ilpo.jarvinen@helsinki.fi> wrote:
> On Mon, 4 Jun 2012, Damian Lukowski wrote:
>
>> please verify, I understood you correctly.
>>
>> You have set TCP_RTO_MIN to a lower value, e.g. 0.002 seconds to imp=
rove
>> your internal low-latency traffic. Because of the improvement, R1
>> timeouts are triggered too fast for external high-RTT traffic. Is th=
at
>> correct?
>> If so, may I suggest to set tcp_retries1 to a higher value? For
>> TCP_RTO_MIN =3D=3D 0.002 and tcp_retries1 =3D=3D =A010, R1 will be c=
alculated to
>> approximately 4 seconds.
>>
>> Is that ok?
>
> I suppose what he meant is that you could have e.g., 60sec RTT and wi=
th
> small enough retries the timeout calculation yields to some timeout
> smaller than 60 secs, and therefore no retransmissions are made which=
 is
> certainly not a desirable property? ...This is valid issue even if no=
 min
> rto tweaking was done but can of course get much worse if min rto is
> shorter.

The extreme case you described above won't happen because there is a
point check at the beginning to return false if inet_csk(sk)->icsk_retr=
ansmits
is zero. But that seems to be a hack because why is 0 so special, not 1=
, 2,...?

>
> I agree with his proposed solution:
>
>> > I think retransmits_timed_out() should check against both time
>> > duration and retrans count (icsk_retransmits).
>
> ...that is, use both pseudo timeout check of the current code and the
> previously used icsk_retransmits compare at the same time.

Yep, it's not an ideal solution, i.e., the problem the original patch
tried to address
may continue to exist if the gap between TCP_RTO_MIN used as an estimat=
or
and the real RTO is large, but it at least addresses the problem we
have locally.

I will submit a patch for this asap.

Thanks,

Jerry

>
> --
> =A0i.
