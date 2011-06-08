From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH] RFC2988bis + taking RTT sample from 3WHS for the passive
 open side
Date: Wed, 8 Jun 2011 15:06:26 -0700
Message-ID: <BANLkTinnROK1MNAbWJWEdQa8-h_K9yN531gxdp__r_Tf55e9Lg@mail.gmail.com>
References: <1307509203-30973-1-git-send-email-hkchu@google.com>
	<BANLkTimXgK03tM1e3FYe+wausHT15W6H-2eMNCWaj8LLxRvbZw@mail.gmail.com>
	<20110608211639.GA2876@nuttenaction>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>, tsunanet@gmail.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:37612 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751895Ab1FHWG3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 18:06:29 -0400
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id p58M6RU4004054
	for <netdev@vger.kernel.org>; Wed, 8 Jun 2011 15:06:28 -0700
Received: from gxk10 (gxk10.prod.google.com [10.202.11.10])
	by kpbe19.cbf.corp.google.com with ESMTP id p58M5DoE018397
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 8 Jun 2011 15:06:26 -0700
Received: by gxk10 with SMTP id 10so831090gxk.25
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2011 15:06:26 -0700 (PDT)
In-Reply-To: <20110608211639.GA2876@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hagen,

On Wed, Jun 8, 2011 at 2:16 PM, Hagen Paul Pfeifer <hagen@jauu.net> wro=
te:
> Hello Jerry
>
> * Jerry Chu | 2011-06-08 11:04:22 [-0700]:
>
>>+ =A0 =A0 =A0 /* Cut cwnd down to 1 per RFC5681 if SYN or SYN-ACK has=
 been
>>+ =A0 =A0 =A0 =A0* retransmitted. In light of RFC2988bis' more aggres=
sive 1sec
>>+ =A0 =A0 =A0 =A0* initRTO, we only reset cwnd when more than 1 SYN/S=
YN-ACK
>>+ =A0 =A0 =A0 =A0* retransmission has occurred.
>>+ =A0 =A0 =A0 =A0*/
>>+ =A0 =A0 =A0 if (tp->total_retrans > 1)
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp->snd_cwnd =3D 1;
>>+ =A0 =A0 =A0 else
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp->snd_cwnd =3D tcp_init_cwnd(tp, dst)=
;
>
> Is this behavior somewhere documented? In RFC2988bis I cannot find so=
mething
> similar.

See my 5/20/11 mail on this subject. The short answer is, no, it's not
part of RFC2988bis. The long answer is, when we (Vern, Mark and I)
were working
on RFC2988bis we shared a common design goal to minimize the negative
impact to those paths with RTT > 1sec as much as possible.

RFC3390 and later RFC5681 have the following clause:
"... Further, if the SYN or SYN/ACK is lost, the initial window used by=
 a
sender after a correctly transmitted SYN MUST be one segment
consisting of at most SMSS bytes."

Unfortunately, with initRTO reduced to 1sec, unless the stack can relia=
bly
detect spurious retransmissions of SYN or SYN-ACK, the paths with RTT >
1sec may be penalized unnecessarily with initcwnd =3D 1 if the stack
implementation follows the above clause faithfully. We can't really ame=
nd
the clause as part of RFC2988bis because it doesn't belong there, as th=
e
latter only covers RTO computation, not the congestion control algorith=
m.
In the end Vern/Mark suggested me to add the amendment to the IW10
proposal I was working on (now becomes draft-ietf-tcpm-initcwnd-01.txt)
So I did, with following paragraph:
"...
   Furthermore, RFC 3390 and RFC 5681 [RFC5681] state that

         "If the SYN or SYN/ACK is lost, the initial window used by a
         sender after a correctly transmitted SYN MUST be one segment
         consisting of MSS bytes."

   The proposed change to reduce the default RTO to 1 second [PACS11]
   increases the chance for spurious SYN or SYN/ACK retransmission, thu=
s
   unnecessarily penalizing connections with RTT > 1 second if their
   initial window is reduced to 1 segment. For this reason, it is
   RECOMMENDED that implementations refrain from resetting the initial
   window to 1 segment, unless either there have been multiple SYN or
   SYN/ACK retransmissions, or true loss detection has been made."

The patch follows the intent of the co-authors. It also moves the
implementation closer to the spec. Without the patch the existing
implementation will reduce ssthresh (active open side only), but not th=
e
cwnd upon SYN or SYN-ACK retransmission.

Best,

Jerry

>
>
> Cheers, Hagen
>
