From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 5/5] tcp: skip cwnd moderation in TCP_CA_Open in
 tcp_try_to_open
Date: Tue, 29 Nov 2011 12:33:12 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1111291135510.31705@wel-95.cs.helsinki.fi>
References: <alpine.DEB.2.00.1111201024080.22397@melkinpaasi.cs.helsinki.fi> <CAK6E8=cNBCJbQs9dKcOwU1yZMC6czgMEuZt4Ubt=t-kBzHfFmw@mail.gmail.com> <alpine.DEB.2.00.1111221146060.31705@wel-95.cs.helsinki.fi> <20111127.190120.2116987138205753451.davem@davemloft.net>
 <CADVnQykp47igdNbN68nbdd4SzaPoDCVTX-bDog4MDesWBbv9MA@mail.gmail.com> <CAK6E8=dfjZ0tGnihL8cvrg0J=trj2UdB5s3ry+TvdG9Yhzf9jA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, nanditad@google.com,
	therbert@google.com
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35927 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754495Ab1K2KdO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 05:33:14 -0500
In-Reply-To: <CAK6E8=dfjZ0tGnihL8cvrg0J=trj2UdB5s3ry+TvdG9Yhzf9jA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 28 Nov 2011, Yuchung Cheng wrote:

> On Mon, Nov 28, 2011 at 9:35 AM, Neal Cardwell <ncardwell@google.com> wrote:
> > On Sun, Nov 27, 2011 at 7:01 PM, David Miller <davem@davemloft.net> wrote:
> >> I'm apply this patch to net-next now, but Neil and Yucheng are on the hook
> >> to fully look into the issues Ilpo has raised.
> >
> > Thanks! We will spend some time looking into these issues.
> >
> Ilpo do you know any report on these types of cheating? I did some
> literature search but didn't find any.

No I know of, however, I'm not too surprised as so far such attacks have 
lacked a target at least among Linux endhosts. It is only possible to gain 
something now after you have one by one removed all safeguards which 
prevent such misuse :-). This possibility is certainly known to exists 
(even RFC3708 mentions it).

Besides, DSACK adoption, not to speak of adoption of any DSACK undo 
algorithm, is not that high as with SACK alone iirc.

> If the receiver simply responds DSACK on good (non-spurious)
> retransmits, the sender may increase dupthresh (tp->reordering) and
> slows down triggering fast-recovery? given the connection has real
> losses, the receiver may end up shooting his feet.

For some attack variants, yes. However, it is always "safe" to attack 
the current Linux sender with something that is past the acknowledgment 
number, there's only dummy counting done for that (trivial to arrange). If 
the attacker plays safe, no tp->reordering effect is ever imposed but 
attack eventually succeeds to hit the right number of undo_retrans no 
matter what if one keeps trying. This is what you just asked us to 
enable, unlimited attack window! Perhaps we could add a penalty of 
misguessing the number of rexmits but knowing the right number is not that 
hard anyway (and some caveats exist in such approach though to those who 
are hit by HW/path duping).


Btw, another thing that should be auditted now that this was applied: 
check that undo_marker checks do not behave bad due to 32-bit seqno 
wrap-arounds since its needs-to-be-valid period got just extented way 
beyond a single loss event.


-- 
 i.
