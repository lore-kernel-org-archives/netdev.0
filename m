From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/1] TCP: increase default initial receive window.
Date: Mon, 20 Dec 2010 09:03:52 -0800
Message-ID: <20101220090352.3ea7ade2@nehalam>
References: <1292642451-892-1-git-send-email-nanditad@google.com>
	<20101217.211309.226761639.davem@davemloft.net>
	<AANLkTimSH_NfX2qno7sO3A4CHLsONmRUDHzWXY4reD28@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	therbert@google.com, chavey@google.com, ycheng@google.com
To: Nandita Dukkipati <nanditad@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33037 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932890Ab0LTRD5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 12:03:57 -0500
In-Reply-To: <AANLkTimSH_NfX2qno7sO3A4CHLsONmRUDHzWXY4reD28@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 18 Dec 2010 01:08:33 -0800
Nandita Dukkipati <nanditad@google.com> wrote:

> resend in plain text.
>=20
> On Fri, Dec 17, 2010 at 9:13 PM, David Miller <davem@davemloft.net> w=
rote:
> > From: Nandita Dukkipati <nanditad@google.com>
> > Date: Fri, 17 Dec 2010 19:20:51 -0800
> >
> >> This patch changes the default initial receive window to 10 mss
> >> (defined constant). The default window is limited to the maximum
> >> of 10*1460 and 2*mss (when mss > 1460).
> >>
> >> Signed-off-by: Nandita Dukkipati <nanditad@google.com>
> >
> > That's an incredibly terse explanation for a very non-trivial
> > change with very non-trivial implications.
> >
> > What analysis have you performed to lead you to decide that this
> > was a reasonable change to make? =A0Where can people see that
> > analysis and look over it to see if they agree with your
> > assesment of the data?
>=20
> Apologies for the terse comment. Here's a longer explanation.
>=20
> Background:
> A recent proposal to the IETF [Ref: 5] recommends increasing TCP's
> initial congestion window to 10 mss or about 15KB. This proposal,
> backed with data from several large-scale live experiments as well as
> controlled testbed experiments, is under active discussion in the TCP=
M
> working group.
>=20
> Analysis performed:
> Leading up to this proposal were several large-scale Internet
> experiments [Ref: 2] with an initial congestion window of 10 mss
> (IW10), where we showed that the average latency of HTTP responses
> improved by approximately 10%. This was accompanied by a slight
> increase in retransmission rate (0.5%), most of which is coming from
> applications opening multiple simultaneous connections. To understand
> the extreme
> worst case scenarios, as well as fairness issues with IW10 versus IW3
> traffic, we further conducted controlled testbed experiments
> (end-hosts are all Linux based). We came away finding minimal negativ=
e
> impact even under low link bandwidths (dial-ups) and small buffers
> [Ref: 3]. These results are extremely encouraging to adopting IW10.
>=20
> But obviously, an initial congestion window of 10 mss is useless
> unless a TCP receiver advertises an initial receive window of at leas=
t
> 10 mss. Fortunately, in the large-scale Internet experiments we found
> that most of the operating systems advertised a large enough initial
> receive window, allowing us to experiment with various values of
> initial congestion windows. Linux systems were among the few
> exceptions that advertised a small receive window. This patch intends
> to fix that.
>=20
> References:
>=20
> 1. This site has a comprehensive list of all IW10 references to date.
> http://code.google.com/speed/protocols/tcpm-IW10.html
>=20
> 2. Paper describing results from large-scale Internet experiments wit=
h IW10.
> http://ccr.sigcomm.org/drupal/?q=3Dnode/621
>=20
> 3. Controlled testbed experiments with IW10 under worst case scenario=
s
> http://www.ietf.org/proceedings/79/slides/tcpm-0.pdf
>=20
> 4. Raw test data from testbed experiments (Linux senders/receivers)
> with initial congestion window and initial receive window of 10 mss.
> http://research.csc.ncsu.edu/netsrv/?q=3Dcontent/iw10
>=20
> 5. Internet-Draft. Increasing TCP's Initial Window.
> https://datatracker.ietf.org/doc/draft-ietf-tcpm-initcwnd/

Agree this is a good idea, but some further notes:
  * The control of receive window is a local function not covered by
    RFC.
  * Linux manipulates receive window automatically, unlike some other
    implementations.

But any change to TCP risks breaking other broken implementations
and users need a good way to recover. Therefore I recommend this
be made a sysctl to allow for quick workaround for the user who has
to connect to some Elbonian printer.  Doing it per route is okay,
but for the worst case, it needs to be a sysctl.

The default value of the sysctl should be your new value (10),
and it should allow the old rfc usage if zero.
