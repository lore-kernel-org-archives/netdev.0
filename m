From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH] tcp: detect loss above high_seq in recovery
Date: Thu, 29 Dec 2011 10:21:18 -0800
Message-ID: <CAK6E8=fu_KAnzMhKYa368BzhGkLGtjjPhvDUezQ_b6Nsd5o6Zw@mail.gmail.com>
References: <1325033182-25905-1-git-send-email-ycheng@google.com> <alpine.DEB.2.00.1112281736480.7752@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, ncardwell@google.com,
	nanditad@google.com, Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:53256 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751200Ab1L2SVk convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Dec 2011 13:21:40 -0500
Received: by obcwo16 with SMTP id wo16so9469573obc.19
        for <netdev@vger.kernel.org>; Thu, 29 Dec 2011 10:21:39 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1112281736480.7752@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo,
On Wed, Dec 28, 2011 at 7:42 AM, Ilpo J=E4rvinen
<ilpo.jarvinen@helsinki.fi> wrote:
>
> On Tue, 27 Dec 2011, Yuchung Cheng wrote:
> > The new sequences sent during fast-recovery maybe marked as lost
> > and/or retransmitted. It is possible these (new) losses are recover=
ed
> > within the current fast recovery and the state moves back to CA_Ope=
n
> > without entering another fast recovery / cwnd redunction. This is
> > especially possible for light losses. =A0Note RFC 3517 (implicitly)
> > allows this as well.
>
> No it doesn't! It does not allow you to avoid the second cwnd reducti=
on.
> They're from different RTT. What you now claim is that we never need =
to
> do cwnd reduction until we visit CA_Open in between. That's very very
> dangerous if the congestion suddently spikes because nobody reduces t=
wice
> causing everyone to get losses and continues in the recovery forever.

Should TCP perform another CWR for sequences lost after recovery point?
my colleagues and I all agree with you it should. But my commit message=
 did a
poor job explain some subtle deviations in standard and current Linux.

RFC3517 supports this by principle; however, it may repair such new dat=
a losses
in the current recovery: Rue 1.b and 1.c in NextSeg() allow retransmitt=
ing any
segment below highest sacked sequence. Thus it may repair every loss in=
 the
current recovery and won't never go into another.

As a matter of fact, Linux already does that today, by implementing rul=
e 3 in
NextSeg(), aka forward-retransmit. But Linux won't mark these packets l=
ost even
if there are >=3D tp->reordering packets sacked above. This change fixe=
s this.

How often is second CWR avoided? it's probably rare b/c it requires new=
 data
during the recovery RTT and a complete repair any losses of them. It's =
arguably
 OK to fix small new data losses during current recovery, and RFC/Linux=
 seem
to do so.

To summarize:
1) this change does NOT forbid TCP performing further CWR on new losses
2) this change (merely) marks some forward-retransmitted packets LOST.
3) the commit message is to be explicit that CWR may not always be perf=
ormed,
    in both my change and current kernel.


HTH. I will update commit message if people can make sense of it :)
