From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
Date: Fri, 8 Aug 2008 13:32:14 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0808081256560.4551@wrl-59.cs.helsinki.fi>
References: <47EA0DAB.7080205@securenet.de> <200807310939.42406.thomas.jarosch@intra2net.com>
 <20080731094436.12ec99ae@tux> <200807311547.57189.thomas.jarosch@intra2net.com>
 <20080806155306.72039010@tux> <Pine.LNX.4.64.0808071422360.4551@wrl-59.cs.helsinki.fi>
 <20080808004231.10dd7356.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-778553857-1218191534=:4551"
Cc: "=?ISO-8859-1?Q?\\D=E2niel_Fraga\\?=" <fragabr@gmail.com>,
	Thomas Jarosch <thomas.jarosch@intra2net.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Sven Riedel <sr@securenet.de>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49479 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751914AbYHHKcS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2008 06:32:18 -0400
In-Reply-To: <20080808004231.10dd7356.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-778553857-1218191534=:4551
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Fri, 8 Aug 2008, Bill Fink wrote:

> On Thu, 7 Aug 2008, Ilpo Järvinen wrote:
> 
> > On Wed, 6 Aug 2008, Dâniel Fraga wrote:
> > 
> > > On Thu, 31 Jul 2008 15:47:55 +0200
> > > Thomas Jarosch <thomas.jarosch@intra2net.com> wrote:
> > > 
> > > > If your problem is really FRTO related (that what the patch is for),
> > > > you could try to disable FRTO temporarily:
> > > 
> > > 	Hi, the patch helped, but what's the conclusion? Is the problem
> > > "solved"? Will this patch be merged in the next kernel? This thread
> > > seems to be forgotten.
> > 
> > ...Dave, I think we should probably put this FRTO work-around to net-2.6 
> > and -stable to remain somewhat robust (it's currently worked around only 
> > for newreno anyway). ...But I leave the final decision up to you.
> 
> Since you suspect the problem is being caused by a broken middlebox,

It seems very likely, any split-TCPish approach that tries to hide some 
losses that would happen on access links could cause this though it's 
very stupid to put such box there when there's a physical wire rather than 
wireless. And even with wireless the given configuration is not going to 
help but make things worse :-), the box is plain stupid as is (I guess 
it's deployed because some marketting guy has convinced some clueless 
whoever that they need the box :-)).

In theory it could be at the receiver below the TCP layer too but that's 
quite unlikely that smtp server would run on such stack. And also then 
it's kind of middlebox as TCP works end-to-end (not end host to end host)
while the rest remains as black box to it, even if something is performed 
on the very same host below TCP layer.

Even less likely thing is that TCP receiver would do this and it doesn't 
explain pacing of ACKs at all. ...It would be at least kind of twisting
of specs if not out-of-spec somewhere.

> would it perhaps be a better approach to add a per-route option to
> allow disabling of FRTO for the given destination.  This would be
> similar to Stephen Hemminger's fix for broken middleboxes that don't
> handle window scaling properly.  It seems this would be better than
> modifying FRTO behavior for everyone else that is being compliant.

Sure, but that requires some thought still, I'll try after weekend so
that I can think it a bit more because there are plenty of states where
we can end to after the detection of the first RTO as spurious.

It might even be interesting to run CA_Recovery on RTOs when we detect 
this kind of middlebox because RTOs basically happen because there's lack 
of duplicate ACKs and then we could efficiently use partial ACKs to send 
just the lost segments rather than everything which is causing problems 
after the recovery has finished because we sent with too high rate while 
recovering. Then fallbackto CA_Loss if RTO is triggered again in 
CA_Recovery. But I'm not sure if it's worth of the effort though.

> A question then arises is if the bogus scenario has a TCP signature
> that could be used to print a warning message for the unsuspecting
> user so they could then take necessary corrective action.

Probably yes, but I need to add some state. I could probably also make it 
to switch per flow to more robust approach on-demand when enough evidence 
is gathered. ...I think I'll add 1-bit history counter per flow so that 
it's possible to do print the warning and switch when there's third RTO in 
a single window (while two first were found spurious). IMHO it's unlikely 
enough that there will be three latency spikes (each longer than the 
previous) within a single window to make the decision, I wouldn't trust 
two enough because hand-overs can take time and have non-trivial effects.

-- 
 i.
---696208474-778553857-1218191534=:4551--
