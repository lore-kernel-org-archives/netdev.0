From: Lutz Vieweg <lvml@5t9.de>
Subject: Re: [PATCH net-next 1/2] tcp: remove per-destination timestamp cache
Date: Thu, 16 Mar 2017 18:30:49 +0100
Message-ID: <58CACBC9.40900@5t9.de>
References: <20170315203046.158791-1-soheil.kdev@gmail.com> <20170315.154044.170788541865531834.davem@davemloft.net> <20170315225508.GB14761@1wt.eu> <58CA778D.9020208@5t9.de> <CADVnQy=Bxs-e-KxQsA8nPSfm9fVtogouxCRdgmrR0WyBkMS=Xw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>,
        Soheil Hassas Yeganeh <soheil.kdev@gmail.com>,
        Netdev <netdev@vger.kernel.org>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Florian Westphal <fw@strlen.de>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p05-ob.smtp.rzone.de ([81.169.146.180]:21718 "EHLO
        mo4-p05-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752072AbdCPRb0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 13:31:26 -0400
In-Reply-To: <CADVnQy=Bxs-e-KxQsA8nPSfm9fVtogouxCRdgmrR0WyBkMS=Xw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/16/2017 04:40 PM, Neal Cardwell wrote:
>> I currently wonder: What it the correct advise to an operator who need=
s
>> to run one server instance that is meant to accept thousands of new,
>> short-lived TCP connections per minute?
>
> Note that for this to be a problem there would have to be thousands of
> new, short-lived TCP connections per minute from a single source IP
> address to a single destination IP address. Normal client software
> should not be doing this. AFAIK this is pretty rare, unless someone is
> running a load test or has an overly-aggressive monitoring system.

Indeed, I meanwhile found that a load/regression test scenario had
been the rationale for the tcp_tw_recycle =3D 1 setting - when a
recorded log of hundreds of thousands connections (each placing
one or a few requests) was replayed, this failed due to excessive
number of TIME_WAIT state connections.

Do I understand correctly that "tcp_tw_recycle =3D 1" is fine
in such a scenario as one can be sure both client and server
are at fixed, not-NATed IP addresses?

I wonder whether there might be a possibility to limit the use
of "tcp_tw_recycle =3D 1" to either a certain address or listen-port rang=
e?

If not, I guess our best option at this time is to advise
enabling "tcp_tw_recycle =3D 1" only while explicitely performing
local load/regression tests, and to disable it otherwise.
(This however means that running both automated continous integration
tests and any services for remote clients on the same system
would not mix well, as the setting could be "right" for only one
of them.)


> (1) use longer connections from the client side

Sure, in cases where that is under our control, we do exactly that.

> (2) have the client do the close(), so the client is the side to carry =
the
>      TIME_WAIT state

In the load/regression test scenario, we are both server and client,
so I guess this would not help.

> (3) have the server use SO_LINGER with a timeout of 0, so that
>      the connection is closed with a RST and the server carries no
>      TIME_WAIT state

Potentially losing the end of some conversation is not really
an option for most protocols / use cases.

Regards,

Lutz Vieweg
