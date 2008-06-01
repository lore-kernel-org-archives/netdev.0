From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Sun, 1 Jun 2008 08:51:34 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0806010826040.18717@wrl-59.cs.helsinki.fi>
References: <20080526115628.GA31316@elte.hu>  <20080529084524.GA24892@elte.hu>
  <Pine.LNX.4.64.0805291332401.16829@wrl-59.cs.helsinki.fi>
 <20080529112257.GA18130@elte.hu> <20080530181839.GA31915@elte.hu>
 <20080531060947.GA26441@elte.hu>  <Pine.LNX.4.64.0805311431100.2329@wrl-59.cs.helsinki.fi>
  <Pine.LNX.4.64.0805311505410.2329@wrl-59.cs.helsinki.fi>
 <20080531125428.GA22111@elte.hu>  <Pine.LNX.4.64.0805311555570.2329@wrl-59.cs.helsinki.fi>
  <20080531163501.GB22607@elte.hu> <1212273974.28319.107.camel@tng>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1771556638-1212299494=:18717"
Cc: Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>
To: Patrick McManus <mcmanus@ducksong.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:55865 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276AbYFAFvh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2008 01:51:37 -0400
In-Reply-To: <1212273974.28319.107.camel@tng>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1771556638-1212299494=:18717
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Sat, 31 May 2008, Patrick McManus wrote:

> On Sat, 2008-05-31 at 18:35 +0200, Ingo Molnar wrote:
> > * Ilpo Järvinen <ilpo.jarvinen@helsinki.fi> wrote:
> > 
> 
> > > ...setsockopt(listenfd, SOL_TCP, TCP_DEFER_ACCEPT, &val, sizeof(val)) 
> > > seems to be the magic trick that is interestion here.
> > 
> > seems to be used:
> > 
> >  22003 write(3, "distccd[22003] (dcc_listen_by_ad"..., 62) = 62
> >  22003 listen(4, 10)                     = 0
> >  22003 setsockopt(4, SOL_TCP, TCP_DEFER_ACCEPT, [1], 4) = 0
> > 
> > i'll queue up your reverts for testing in -tip.
> 
> 
> So the code you will revert came from my fingers. The circumstances here
> make me nervous; while I'm at a loss to explain what might be going on
> in particular, let me offer an apology in advance should the revert help
> resolve the issue.

Yes, don't worry just yet. It far from proven yet that this is the cause 
(or contributes to easiness of reproducal in any way). The patch was just 
for Ingo's testing in his -tip branch. I didn't even bother to cc you yet 
because it's more or less a stab into dark, but it's definately worth of 
testing still even though Ingo probably comes back soon and tells that it 
didn't help any because it's clearly related :-).

> Here's what makes me nervous:
> 
>  * not a lot of code uses DEFER_ACCEPT.. frankly it was pretty broken
> before 26 - but not broken this way .. the correlation of your bug using
> it is significant. 
>
>  * in 26, a server TCP socket (with DA) goes to ESTABLISHED when the 3rd
> part of the handshake is received (as normal without DA), but the socket
> isn't put on the accept queue until a real data packet arrives. (That's
> the point of DA). In <= 25 this socket would have syn-recv until the
> data packet arrived.
> 
>   - I did run tests where the server died in between the handshake being
> completed and first data packet arriving - the client should see RST and
> the server socket should disappear. But maybe something was missed?

Also in this Ingo's case RST seems to be missing, ie., there's unread data 
and both ends remain ESTABLISHED while the receiver is already gone (or 
not referencing to the connection correctly).

> Do I understand this correctly, the server process is gone but the
> socket is still in the table? And the client process is still there
> waiting for the server to do something - having sent a bunch of data?

Yes, this seems to be the case, sender was doing window probes because 
window became to zero.

Because it's distcc, tracking a particular process is not that simple 
task. Either the process is gone or it doesn't correctly reference to the 
connection.

> Do we know if any data bytes (not handshake bytes) have been consumed by
> the server side? If they were, that would seem to vindicate DA.

We don't know. We cannot currently track the particular process which 
would definately be helpful here.

> Also pointing away from DA is that you started seeing this with rc3 -
> that code was included in rc1.Is that a firm observation, or maybe there
> weren't enough datapoints to conclude that rc1 and rc2 were clean?

Timeline won't match too well yes. I also find it quite unlikely, but 
still worth of test because it's hard to know when this begun, luck might 
have just played some role there because it's quite evasive in Ingo's 
case anyway.

Anything you find suspicious between rc1..rc3?

...I suspected my rc3 FRTO fixes first but they have nothing to do with 
window probing and orphan handling.

> The most interesting patch is ec3c0982a2dd1e671bad8e9d26c28dcba0039d87
> if anyone wants to eyeball it.

I personally think it might as well be some other issue which just become 
more visible after DA but lets wait until Ingo has some results which may 
well result in that DA is not making it to become visible in his case. 
...Also, I doubt Arjan's mua has nothing to do with DA.


-- 
 i.
---696208474-1771556638-1212299494=:18717--
