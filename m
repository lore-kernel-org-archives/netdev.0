From: "Dan Reader" <Dan.Reader@neterion.com>
Subject: RE: [PATCH]NET: Add ECN support for TSO
Date: Fri, 14 Jul 2006 12:12:22 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7793B29B@nekter>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <herbert@gondor.apana.org.au>, <netdev@vger.kernel.org>,
	<steve.arden@neterion.com>,
	"Leonid Grossman" <Leonid.Grossman@neterion.com>,
	"Ananda Raju" <Ananda.Raju@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:17570 "EHLO
	barracuda.mail.s2io.com") by vger.kernel.org with ESMTP
	id S1161155AbWGNQMz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2006 12:12:55 -0400
Received: from owa.neterion.com (unknown [72.1.205.142])
	by barracuda.mail.s2io.com (Spam Firewall) with ESMTP id 414AC201AB36
	for <netdev@vger.kernel.org>; Fri, 14 Jul 2006 12:12:54 -0400 (EDT)
Content-class: urn:content-classes:message
To: "Michael Chan" <mchan@broadcom.com>,
	"Ravinandan Arakali" <Ravinandan.Arakali@neterion.com>,
	"David Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> My take is that the ECT code point should also be replicated on
> all TSO segments.  When RFC3540 is implemented, the stack will
> randomly use ECT(0) or ECT(1) on the TSO super segments.  On
> each of these super segments, the hardware will replicate the ECT
> code point.  This will keep everything stateless.  The stack
> only needs to know the TSO factor (number of divided segements)
> for each TSO super segement to keep track of the NS.

My concern with this approach is that it goes even farther from the
spirit of RFC3540 than our other proposals.  The intent of the RFC, as I
understand it, is to protect against misbehaving receivers by using a
parity code that the sender knows and the receiver can't reliably guess.
If a receiver gets a Congestion Experienced codepoint, it shouldn't be
able to determine what the original codepoint was and thereby ignore its
ECN requirements.

If we implement the approach you suggest and all data sent uses TSO, the
receiver can easily determine the expected codepoint of almost any
isolated CE packet.  It simply has to look at the segment before and the
segment after (which it can wait for, thanks to delayed ACKs).  If they
have the same ECT value, use that one.  If they're different, then it
just has to perform a check for non-MSS (i.e. the boundary between TSOs
if send ops do not yield a multiple of MSS) and it might know.

>From my point of view, the one thing we have to do for TSO is make sure
that at least one packet per send op have a random codepoint that has no
greater chance of being "guessed" by the receiver than packets sent
without TSO.

To critique the other options, then, I see the following problems: Using
ECT(0) for all but one packet will mean that only one packet per TSO
can't be reliably guessed by the receiver.  Assuming all packets sent in
a TSO have an equal probability of being flagged with CE when it occurs,
a misbehaving receiver will have an increased ability to reliably ignore
and override CE that is in proportion to the number of packets generated
by a single TSO.  Using an adapter randomized value is better because
we're then generating a parity sum across all segments of the TSO.  It's
potential for compromise lies in the ability of the receiver to never
ACK the last received segment of a TSO.  If it ACKs other packets, the
sender wouldn't be able to check the sum...  I still prefer that
approach, though, because it yields more robustness if security
enhancements are built into the sender (e.g. occasionally send non-TSO
packets of MSS size or use TSO ops that yield an integral multiple of
MSS segments; in either case, the sender obfuscates the points where the
sum is being checked).

Yet another option would be to add a field to the TSO descriptor that
indicates a random segment on which to oppose the rule or achieve the
desired NS (e.g. when replicating, if all other composite segments are
using ECT(0) or ECT(1), set the opposite on the indicated segment).
Then, the sender will get a point per TSO where it can check the ACKed
NS, that can't be reliably guessed by the receiver...

