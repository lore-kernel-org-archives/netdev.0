From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH net-2.6 0/3]: Three TCP fixes
Date: Wed, 5 Dec 2007 13:30:32 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712051248380.18529@kivilampi-30.cs.helsinki.fi>
References: <11967869303114-git-send-email-ilpo.jarvinen@helsinki.fi>
 <47559FA1.2090104@psc.edu> <20071205.023030.125862645.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-1271621461-1196852610=:18529"
Cc: John Heffner <jheffner@psc.edu>, Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:36733 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750964AbXLELad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 06:30:33 -0500
In-Reply-To: <20071205.023030.125862645.davem@davemloft.net>
Content-ID: <Pine.LNX.4.64.0712051324590.18529@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1271621461-1196852610=:18529
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0712051318401.18529@kivilampi-30.cs.helsinki.fi>

On Wed, 5 Dec 2007, David Miller wrote:

> From: John Heffner <jheffner@psc.edu>
> Date: Tue, 04 Dec 2007 13:42:41 -0500
> 
> > Ilpo Järvinen wrote:
> > > ...I'm still to figure out why tcp_cwnd_down uses snd_ssthresh/2
> > > as lower bound even though the ssthresh was already halved, 
> > > so snd_ssthresh should suffice.
> > 
> > I remember this coming up at least once before, so it's probably worth a 
> > comment in the code.  Rate-halving attempts to actually reduce cwnd to 
> > half the delivered window.  Here, cwnd/4 (ssthresh/2) is a lower bound 
> > on how far rate-halving can reduce cwnd.  See the "Bounding Parameters" 
> > section of <http://www.psc.edu/networking/papers/FACKnotes/current/>.
> 
> I assume we're talking about the tcp_cwnd_min() usage in
> tcp_cwnd_down(), I don't see where it's dividing by two
> there.

...Ah, it's because I'm not using cubic which is not setting cwnd_min
callback. In tcp_cong.c it is:

/* Lower bound on congestion window with halving. */
u32 tcp_reno_min_cwnd(const struct sock *sk)
{
        const struct tcp_sock *tp = tcp_sk(sk);
        return tp->snd_ssthresh/2;
}

That snd_ssthresh is already halved when CA_Recovery/CA_CWR was
entered. Thus the amount of reduction is not 1/2 * orig_cwnd but
1/4 of it.

> Anyways, someone please enlighten me and please also cook
> up a patch to add the descriptive comment :-)

Not sure if a too simple patch here is correct thing to do... Matt has a 
point regarding slow-start cwnd behavior. For FACK/SACK which can estimate 
losses very accurately it works very well, where as NewReno discovers 
those losses only one by one when cumulative ACKs arrive and until then, 
the other losses are counted as outstanding segments. As a result, every 
undiscovered loss is "missing from ACK clock" which in here results in the 
bad performance because ACK clock slows down and (almost) dies out (ie., 
cumulative ACKs keep it going, though its rate is not very astonishing). 
There might be some other bug to make it worse in the end of the recovery 
but I'm yet to uncover it. With SACK/FACK, ACK clock keeps running at 
expected rate and if cwnd becomes < ssthresh, the difference is quickly 
regained in slow start.

...I've not yet decided what is the best way to deal with it but I'll try 
to figure something out.


-- 
 i.
---696243703-1271621461-1196852610=:18529--
