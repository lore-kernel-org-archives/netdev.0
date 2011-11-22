From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 5/5] tcp: skip cwnd moderation in TCP_CA_Open in
 tcp_try_to_open
Date: Tue, 22 Nov 2011 13:47:13 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1111221146060.31705@wel-95.cs.helsinki.fi>
References: <1321469885-10885-1-git-send-email-ncardwell@google.com> <1321469885-10885-5-git-send-email-ncardwell@google.com> <alpine.DEB.2.00.1111170706330.23028@melkinpaasi.cs.helsinki.fi> <CADVnQymPTWsD0Hx060qYUMrFPxgQPdJWwPA9oDce6qMVL4tVpA@mail.gmail.com>
 <alpine.DEB.2.00.1111201024080.22397@melkinpaasi.cs.helsinki.fi> <CAK6E8=cNBCJbQs9dKcOwU1yZMC6czgMEuZt4Ubt=t-kBzHfFmw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="8323329-1989853668-1321955292=:31705"
Cc: Neal Cardwell <ncardwell@google.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Nandita Dukkipati <nanditad@google.com>,
	Tom Herbert <therbert@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41136 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758498Ab1KVLrP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 06:47:15 -0500
In-Reply-To: <CAK6E8=cNBCJbQs9dKcOwU1yZMC6czgMEuZt4Ubt=t-kBzHfFmw@mail.gmail.com>
Content-ID: <alpine.DEB.2.00.1111221343070.31705@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1989853668-1321955292=:31705
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.1111221148501.31705@wel-95.cs.helsinki.fi>

On Mon, 21 Nov 2011, Yuchung Cheng wrote:

> On Sun, Nov 20, 2011 at 12:38 AM, Ilpo Järvinen
> <ilpo.jarvinen@helsinki.fi> wrote:
> > On Sat, 19 Nov 2011, Neal Cardwell wrote:
> >> If your concern is receivers lying, then there are other easy ways
> >> that a misbehaving receiver can get a sender to send too fast
> >> (e.g. cumulatively ACKing the highest sequence number seen,
> >> irrespective of holes). IMHO it would be a shame to penalize the vast
> >> majority of well-behaved users to plug one potential attack vector
> >> when there are other easy holes that an attacker would use.
> >
> > I disagree... there is huge difference as the receiver then has to gamble
> > with the reliability of the flow. DSACK attack is nasty in that that it
> > allows maintaining reliability while cheating bw.
> 
> I feel the original change Neal is proposing is getting lost. This patch 
> proposes when
> 
> a. ack is dubious
> b. but it's not time to recover yet
> c. and other checks in tcp_try_keep_open affirms the network is in
> good condition, i.e, stat == Open

Presence of DSACK certainly does disagree with your condition c (which 
was the purpose of this change? Though it could be present in a later 
segment). Network was in such a bad condition that DSACKs were needed in 
the first place.

> 3. do not moderate cwnd (not 3, not 10 or any magic number).
> 
> Your concern is valid, but if that's true for majority then I argue
> all undo logic on dsack or TS are causing major threats since they all
> require some trusts of the remote end. Why even bother processing
> DSACK if we can't trust them?

Right, it seems that DSACK RFCs (RFC 3708 mainly) don't care too much 
about the cheating possibility, just states that it is possible and 
that a non-available nonce solution would help. So yes, I myself find 
DSACK quite useless, albeit fancy, mechanism (there are some other uses 
not related to undo mentioned though in the RFC but I've not spent too 
much thinking the details).

As regards TS, we don't trust them fully either (see e.g., some CUBIC
related change from Stephen Hemminger couple of years ago).

> AFAIK cwnd moderation is to lower bursty drops not to discourage
> (dsack) cheating. I believe the reason is the same in
> tcp_try_to_open(). We are in common cases, e.g., loss-recovery, this
> logic hurts performance.

Quote from the patch description: "Senders were overriding cwnd values 
picked during an undo by calling tcp_moderate_cwnd()" ...so after all it 
has to do with undo being limited. IMHO only up to orig_cwnd/2+IW is safe 
due to cheating opportunities. Also FRTO uses orig_cwnd/2 due to same 
reason (it could do the +IW too but IIRC it is only /2 currently). What 
would be the safeguard there after this one is removed? I kind of see your 
point about this particular line being related to burst mitigation but on 
the same time the end result of removal is that undo becomes potentially 
much more aggressive.


-- 
 i.
--8323329-1989853668-1321955292=:31705--
