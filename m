From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCHv2 2/2] tcp: Stalling connections: Fix timeout calculation
 routine
Date: Mon, 7 Dec 2009 14:32:39 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0912071428470.7024@wel-95.cs.helsinki.fi>
References: <4B1C4C25.1070104@tvk.rwth-aachen.de> <4B1C9D94.3070504@gmail.com> <4B1CE45A.9010908@tvk.rwth-aachen.de> <4B1CE9EE.1040903@tvk.rwth-aachen.de> <alpine.DEB.2.00.0912071405200.7024@wel-95.cs.helsinki.fi> <op.u4kh8gosp498uc@nexus>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-712598392-1260189159=:7024"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	Frederic Leroy <fredo@starox.org>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Greg KH <gregkh@suse.de>
To: Damian Lukowski <damian@tvk.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45254 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934067AbZLGMce (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 07:32:34 -0500
In-Reply-To: <op.u4kh8gosp498uc@nexus>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-712598392-1260189159=:7024
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: 8BIT

On Mon, 7 Dec 2009, Damian Lukowski wrote:

> Am 07.12.2009, 13:08 Uhr, schrieb Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>:
> 
> > On Mon, 7 Dec 2009, Damian Lukowski wrote:
> > 
> > > This patch fixes a problem in the TCP connection timeout calculation.
> > > Currently, timeout decisions are made on the basis of the current
> > > tcp_time_stamp and retrans_stamp, which is usually set at the first
> > > retransmission.
> > > However, if the retransmission fails in tcp_retransmit_skb(),
> > > retrans_stamp is not updated and remains zero. This leads to wrong
> > > decisions in retransmits_timed_out() if tcp_time_stamp is larger than
> > > the specified timeout, which is very likely.
> > > In this case, the TCP connection dies after the first attempted
> > > (and unsuccessful) retransmission.
> > > 
> > > With this patch, tcp_skb_cb->when is used instead, when retrans_stamp
> > > is not available.
> > > 
> > > This bug has been introduced together with retransmits_timed_out()
> > > in 2.6.32, as the number of retransmissions has been used for timeout
> > > decisions before.
> > > 
> > > Thanks to Ilpo Järvinen for code suggestions and Frederic Leroy for
> > > testing.
> > > 
> > > Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>
> > > ---
> > > net/ipv4/tcp_timer.c |    9 ++++++++-
> > > 1 files changed, 8 insertions(+), 1 deletions(-)
> > > 
> > > diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
> > > index 5c5f739..a9d2891 100644
> > > --- a/net/ipv4/tcp_timer.c
> > > +++ b/net/ipv4/tcp_timer.c
> > > @@ -140,10 +140,17 @@ static bool retransmits_timed_out(const struct sock
> > > *sk,
> > > 				  unsigned int boundary)
> > > {
> > > 	unsigned int timeout, linear_backoff_thresh;
> > > +	unsigned int start_ts;
> > > 
> > > 	if (!inet_csk(sk)->icsk_retransmits)
> > > 		return false;
> > > 
> > > +	if (unlikely(!tcp_sk(sk)->retrans_stamp))
> > > +		start_ts = TCP_SKB_CB(tcp_write_queue_head(
> > > +					(struct sock *)sk))->when;
> > 
> > Grr, a cast....
> 
> I'm a little bit confused now (not the first time :)).
> Without the cast, there are a lot of compiler warnings.
> Also, I remember that I have specified const in the function signature
> on purpose because of other warnings.
> But now, it seems to work without const and no cast ...

I guess you could just drop the const? Maybe you called it from some other 
place back then? To me it seems that both functions which call 
retransmits_timed_out have a non-const sk?

> > Also, in here it's more useful to provide the fix as the first patch (1/2)
> > since it's going to stable and those people don't want the move patch
> > there.
> 
> Ok, I will patch the other way round, without the cast.

Thanks.

-- 
 i.
--8323329-712598392-1260189159=:7024--
