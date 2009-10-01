From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 2/5] Implement loss counting on TFRC-SP receiver
Date: Thu, 1 Oct 2009 22:40:03 +0200
Message-ID: <20091001204003.GA5632@gerrit.erg.abdn.ac.uk>
References: <4AA6A25F.4060100@embedded.ufcg.edu.br> <20090913161224.GA5121@gerrit.erg.abdn.ac.uk> <cb00fa210909141739y234302b3x9c6df23b057a9473@mail.gmail.com> <5001.72.11.80.242.1253362279.squirrel@72.11.80.242> <425e6efa0909231501p499059a4y3530d1a9f55b5a2a@mail.gmail.com> <cb00fa210909231843q7f13b2c3i32672e883a017b7b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dccp@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:56027 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756407AbZJBF2L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Oct 2009 01:28:11 -0400
Content-Disposition: inline
In-Reply-To: <cb00fa210909231843q7f13b2c3i32672e883a017b7b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| >> The following code would be correct then?
| >>
| >>	 if ((len <=3D 0) ||
| >>	     (!tfrc_lh_closed_check(cur, cong_evt->tfrchrx_ccval)))
| > {
| >> +		 cur->li_losses +=3D rh->num_losses;
| >> + 		 rh->num_losses =A0=3D 0;
| >> 		 return false;
| >> With this change I suppose the could be fixed. With that, the
| >> rh->num_losses couldn't added twice. Am I correct?
| >>
| >>
| > The function tfrc_lh_interval_add() is called when
| >  * __two_after_loss() returns true (a new loss is detected) or
| >  * a data packet is ECN-CE marked.
| >
| > I am still not sure about the 'len <=3D 0' case; this would be true
| > if an ECN-marked packet arrives whose sequence number is 'before'
| > the start of the current loss interval, or if a loss is detected
| > which is older than the start of the current loss interval.
| >
| > The other case (tfrc_lh_closed_check) returns 1 if the current loss
| > interval is 'closed' according to RFC 4342, 10.2.
| >
| > Intuitively, in the first case it refers to the preceding loss
| > interval (i.e. not cur->...), in the second case it seems correct.
| >
| > Doing the first case is complicated due to going back in history.
| > The simplest solution I can think of at the moment is to ignore
| > the exception-case of reordered packets and do something like
| >
| >  if (len <=3D 0) {
| >     /* FIXME: this belongs into the previous loss interval */
| >     tfrc_pr_debug("Warning: ignoring loss due to reordering");
| > 	return false;
| > }
| >  if (!tfrc_lh_closed_check(...)) {
| >     // your code from above
| > }
|=20
| Okay, i'll add your sugestion. But i don't know how this would be fix=
ed at all.
|
If it doesn't we will just do another iteration and fix it.



| > So it is necessary to decide whether to go the full way, which mean=
s
| >  * support Loss Intervals and Dropped Packets alike
| >  * modify TFRC library (it will be a redesign)
| >  * modify receiver code
| >  * modify sender code,
| >    or to use the present approach where
| >  * the receiver computes the Loss Rate and
| >  * a Mandatory Send Loss Event Rate feature is present during featu=
re
| >    negotiation, to avoid problems with incompatible senders
| >   (there is a comment explaining this, in net/dccp/feat.c).
| >
| > Thoughts?
|=20
<snip>

| I believe that the first way is better (to "support Loss Intervals an=
d
| Dropped Packets alike..."), because RFC requires loss intervals optio=
n
| to be sent. And so, proceed and implement dropped packets option for
| TFRC-SP. You are right, this would need a redesign and rewrite of
| sender and receiver code.
|=20
Agree, then let's do that. It requires some coordination on how to arra=
nge
the patches, but we can simplify the process by using the test tree to=20
store all intermediate results (i.e. use a separate tree for the rewrit=
e
until it is sufficiently stable/useful).
