From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCHSET 0/18] FRTO: fixes and small changes + SACK enhanced version
Date: Mon, 19 Feb 2007 13:37:54 +0200
Message-ID: <11718850923446-git-send-email-ilpo.jarvinen@helsinki.fi>
Cc: David Miller <davem@davemloft.net>,
	Pasi Sarolahti <pasi.sarolahti@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46068 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932120AbXBSLiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Feb 2007 06:38:14 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Here is a set of patches that fix most of the flaws the current FRTO
implementation (specified in RFC4138) has, besides that, the last two
patches add SACK-enhanced FRTO (not enabled unless frto sysctl is set
to 2, which allows using of the basic version also with SACK). There
are some depencies to the earlier patches in the set (hard to list
all thoughts I've had, but not all combinations are not good ones
even if they apply cleanly).

 Documentation/networking/ip-sysctl.txt |    5 -
 include/net/tcp.h                      |   14 --
 net/ipv4/tcp_input.c                   |  265 ++++++++++++++++++++++++++------
 3 files changed, 221 insertions(+), 63 deletions(-)

(At least) one interpretation issue exists, see patch "FRTO: Entry is
allowed only during (New)Reno like recovery".

Besides that, these things should/could be solved (later on):
	- Setting undo_marker when RTO is not spurious (FRTO has been
	  clearing it, which disabled DSACK undos for conventional
	  recovery).
	- Interaction with Eifel
	- Different response (new sysctl to select them?)
	- When cumulative ACK arrives to the frto_highseq during FRTO,
	  it could be useful to go directly to CA_Open because then
	  duplicate ACKs for that segment could then be used initiate
	  recovery if it was lost. Most of the time, the duplicate ACKs
	  won't be false ones (we might have made too many unnecessary
	  retransmission but that's less likely with FRTO and it could
	  be consider while making state decision).
	- Maybe the frto_highmark should be reset somewhere during a
	  connection due to wrapping of seqnos (reord adjustment relies
	  on it having a valid after relation...)?
	- tcp_use_frto and tcp_enter_loss now both scan skb list from
	  the beginning, it might be possible to take advantage of this
	  either by combining them or by passing skb from use_frto
	  iteration to tcp_enter_loss.

I did some tests with FACK + SACK FRTO, results seemed to be correct but
the conservative response had really poor performance. I'm more familiar
with more aggressive response time-seq graphs and I was really wondering
does this thing really work at all (in couple of cases), but yes, I found
after tracing that it worked although the results was not a very good
looking one due to interaction with rate halving, maybe a "rate-halving
aware" response could do much better (or alternatively one that does more
aggressive undo).

# Test 1: normal TCP
# Test 2: spurious RTO
# Test 3: drop the segment
# Test 4: drop a delayed segment
# Test 5: drop the next segment
# Test 6: drop in window segment
# Test 7: drop the segment and the next segment
# Test 8: drop the segment and in window segment
# Test 9: delay the first and next (spurious RTOs, for different segments)
# Test 10: delay the first excessively (two spurious RTOs)
# Test n+1: drop rexmission
# Test n+2: delay rexmission (spurious RTO also after frto_highmark)
# Test n+3: delay rexmission (spurious RTO also after highmark), drop RTO seg
# Test n+4: drop the segment and rexmit
# Test n+5: drop the segment and first new data
# Test n+6: drop the segment and second new data

The tests were run in 2.6.18, I have quite a lot of own modifications
included in but they were disable using sysctls except for a change in
mark_head_lost: if condition from !TAGBITS -> !(TAGBITS & ~SACKED_RETRANS)
but afaict, it shouldn't affect, and if it does, it should be included
(if you received this mail from previous send attempt, I claimed by a
mistakenly that SACKED_ACKED was the bit that was excluded and had
incorrect parenthesized it here). I couldn't come up with a scenario in
mainline only code where SACKED_RETRANS would be set for a skb when LOST
has not been set, except for the head by FRTO itself which will not be a
problem. I have checked that the FRTO parts used in tests were identical
to the result of this patchset. Compile tested againts the net-2.6 (also
intermediate steps).


-- 
 i.

ps. I'm sorry if you receive these twice, the previous attempted had some
charset problems and was rejected at least by netdev.

