From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH] tcp: Increase the initial congestion window to 10.
Date: Fri, 4 Feb 2011 19:39:46 -0800
Message-ID: <AANLkTimGjUN6ZuCLhKX-A6h6PytL4eKPGTdzF7OtSuBd@mail.gmail.com>
References: <20110202.170750.229739784.davem@davemloft.net>
	<alpine.DEB.2.00.1102040027060.25125@melkinpaasi.cs.helsinki.fi>
	<AANLkTinkwzts5ysW26fHqX4u89Q=kW2kSOArqL=o6RLM@mail.gmail.com>
	<alpine.DEB.2.00.1102042126440.28937@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, therbert@google.com
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:12154 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753041Ab1BEDju convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Feb 2011 22:39:50 -0500
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id p153dmq9014402
	for <netdev@vger.kernel.org>; Fri, 4 Feb 2011 19:39:48 -0800
Received: from qwe4 (qwe4.prod.google.com [10.241.194.4])
	by kpbe14.cbf.corp.google.com with ESMTP id p153dlN8020984
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 4 Feb 2011 19:39:47 -0800
Received: by qwe4 with SMTP id 4so2289725qwe.35
        for <netdev@vger.kernel.org>; Fri, 04 Feb 2011 19:39:47 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1102042126440.28937@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 4, 2011 at 11:43 AM, Ilpo J=E4rvinen
<ilpo.jarvinen@helsinki.fi> wrote:
>
> On Thu, 3 Feb 2011, H.K. Jerry Chu wrote:
>
> > On Thu, Feb 3, 2011 at 2:43 PM, Ilpo J=E4rvinen <ilpo.jarvinen@hels=
inki.fi> wrote:
> > > It would perhaps be useful to change receiver advertized window t=
o include
> > > some extra segs initially. It should be >=3D IW + peer's dupThres=
h-1 as
> > > otherwise limited transmit won't work for the initial window beca=
use we
> > > won't open more receiver window with dupacks (IIRC, I suppose Jer=
ry might
> > > be able to correct me right away if I'm wrong and we open window =
with
> > > dupacks too?).
> >
> > Sorry I don't know how the receive window is updated in Linux,
> > autotuning or not.
> > But I just wonder why would it have to do with dupacks, i.e., why w=
ould
> > it not slide forward as long as the left edge of the window slides
> > forward, regardless of OOO pkt arrival?
>
> ?? DupACK by defination does not slide the left edge?!? :-) ...It
> certainly makes a difference whether the ACK is cumulative or not.
> Anyway, I tcpdumped it now and confirmed that advertized window is no=
t
> advanced if OOO packet arrives.

Cwnd discounts packets that have left the network but rwnd won't discha=
rge
packets until they are consumed by ULP so you are right that in case
the packets from or near the head of the retransmission queue get
dropped rwnd won't
open up room for more packets even though cwnd will. To cover that case=
 initrwnd
needs to be larger than initcwnd.

Jerry

>
> > I am of the opinion that rwnd is for flow control purpose only thus=
 should be
> > fully decoupled from the cwnd of the other (sender) side. Therefore
> > initrwnd should
> > normally be based on projected BDP and local memory pressure, e.g.,=
 64KB, not
> > bearing any relation with IW of the other side. Only under special
> > circumstances should it be used to constrain the sender, e.g., for
> > devices behind slow links with
> > very small buffer.
>
> I also think along the lines that the advertized window autotuning co=
de
> is just unnecessarily preventive (besides the IW change, also Quickst=
art
> couldn't be used that efficiently because of it).
>
> --
> =A0i.
