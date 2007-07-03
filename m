From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] [TCP]: Fix logic breakage due to DSACK separation
Date: Tue, 3 Jul 2007 13:52:35 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0707031122490.14307@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0706151606220.15358@kivilampi-30.cs.helsinki.fi>
 <20070615.151439.70217492.davem@davemloft.net>
 <Pine.LNX.4.64.0706160121180.12770@kivilampi-30.cs.helsinki.fi>
 <20070702.221454.18562227.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-319736391-1183451665=:14307"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:44429 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753909AbXGCKwi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2007 06:52:38 -0400
In-Reply-To: <20070702.221454.18562227.davem@davemloft.net>
Content-ID: <Pine.LNX.4.64.0707031340550.14307@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-319736391-1183451665=:14307
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0707031135021.14307@kivilampi-30.cs.helsinki.fi>

On Mon, 2 Jul 2007, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Sat, 16 Jun 2007 02:04:25 +0300 (EEST)
> 
> > There are still some things I must think carefully in sacktag processing 
> > since it does not validate start_seq and end_seq at all which can be 
> > abused currently at least in tcp-2.6. ...I would rather put end to the 
> > whole russian roulette in tcp-2.6 sacktag rather than fix/think individual 
> > cases and leave future modifications of it similarily hazardous. It's not 
> > very clear to me how to handle all possible cases of invalid SACK blocks 
> > though, perhaps TCP should just ignore such sack blocks without doing 
> > any processing based on them, i.e., ignore them whenever start_seq-end_seq 
> > does not fully fit to snd_una-snd_nxt (expect DSACK of course, which 
> > should be processed if it's between undo_marker-snd_nxt). Do you have any 
> > thoughts about this?
> 
> I agree.  This is a problem that basically every single TCP stack out
> there right now is vulnerable to, lots of cpu processing for invalid
> or maliciously created SACK blocks. This is why I even considered the 
> RB-Tree stuff at all.

Yes, without RB-tree TCP is quite much out of luck. However, as long as 
there is depency to skb's fack_count in sacktag, there seems to be some 
room for cpu processing attacks even with RB-tree case because walk 
becomes necessary on the slow path. I've thought about three solutions to 
this, each has some pros & cons so I'm not that sure which path should be 
pursued:

1. fack_count in skb (your proposal months ago)
   + Trivial arithmetics, no walking necessary to find it (ever)
   - Very expensive in storage wise (like you have stated earlier)

2. fackets_out removal like I presented earlier (which you seem to have 
   looked by now). It was really RFC and was somewhat in state of flux 
   still
   + Fast path is fully arithmetics based
   + Saves little (extra) space in tcp_sock too
   + Its effect for one directional flow without nagle is quite
     insignificant I would say (in friendly environment).
   - But alas, I've noticed that any one directional flow could be
     forced to bidirectional slow path by sending some dummy data with 
     gaps (in malicious intend), then the sender would use SACKs to
     inform about those "losses" whenever data is being send, and if 
     window is large enough TCP would be destined to slow path... :-( How 
     easy it is, i.e., with how small window the sent SACKs exceed MSS 
     size which is the fastpath/slowpath selector depends largely on how 
     large fraction the SACK blocks are in bytes of MSS, with 9000 MTU 
     it's perhaps no longer so easy to do is large scale... Thus it's not 
     anymore sender controllable by nagle setting, like I thought earlier, 
     and therefore it's not that attractive anymore.
   * malicious tcp_fragment forcing would have to be also closed before 
     this is of any use. It seems to be easy to do by adding 
     WAS_COLLAPSED bit to skb->sacked (has some unused bits) and ignoring 
     middle skb SACKs too. IIRC you were (almost fully) for this already 
     in the past? Haven't checked but it should be quite easy to do, and 
     it is something I'll probably do anyway...

3. seqno based tp->reordering
   + Trivial to calculate now that there is highest_sack
   - No longer would the pkt counting be fully pkts based. Not that bad
     in the case of no Nagle though (which is fully under sender's
     control :-)). Equal behavior can be estimated by doing rounding
     to MSS size though (requires some divides though), for no-nagle 
     case it could do exactly the same if I have thought it correctly.
   - I'd expect some small skb user will be complaining due to performance
     loss (recovery latency increasing), perhaps we could add sysctl for
     enabling expensive processing for them. Or just try without it and
     see what happens, nobody would notice I guess though it will 
     probably surface later on when somebody is first time looking 
     numbers (and is not pleased)... ...And would then of course claim 
     that 2.6.3x (or something later) has a regression against 
     2.6.(3x-1)... :-) I think that the expensive processing stuff can 
     reuse some work I've already done for the alternative 2 earlier to
     avoid walk-always in case of a flow with "normal usage pattern" on
     the same host.

...I'd say that alternative 3 is most attractive of these... But due to 
small skb recovery affecting change I'm not too sure if it's desired?


With RB-tree things get really interesting since it seems that TCP has 
some chance... :-) There are many things still to handle but it's getting 
closer already after SACK validation is in tcp-2.6. One thing I would be 
happy avoid is the full walk that is necessary when SACK reneging is 
detected... It is already much harder to do in tcp-2.6 and at least the 
amount of work decreases compared to the last reneging (if it was in the 
same window). Maybe that would justify inclusion of SACK-block validation 
similar to what is now in tcp-2.6 to mainline too.

I wouldn't want to cause considerable performance loss either in case of 
legimite reneging, thus waiting e.g. for RTO at some point seems to be
not that attractive alternative though it would place reneging processing 
decicion well under sender's control... Perhaps some special state 
(CA_Reneging) could completely/partially remove the need for walking but 
I haven't yet thought it that much to solve all problems in such
approach.


> Therefore the earlier we toss out bad SACK blocks the better, and thus
> I agree with a scheme that does validation at the earliest stage
> possible as you seem to be suggesting.

It was about the stuff that was still moulding while I wrote those lines, 
it's basically the validation we put to tcp-2.6 already (while you're 
being busy elsewhere, I might have come up patch already :-)). I would 
just add skb boundary checking too (when it's appropriate based on the 
new skb->sacked bit thing I discussed above) to make things ever harder 
for the receiver.


-- 
 i.
---696243703-319736391-1183451665=:14307--
