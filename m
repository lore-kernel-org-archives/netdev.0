From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP IPv4 strange retransmits
Date: Wed, 5 Mar 2008 09:00:12 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0803050819020.15712@kivilampi-30.cs.helsinki.fi>
References: <47CD4808.1050202@nets.rwth-aachen.de>
 <Pine.LNX.4.64.0803041507001.5423@kivilampi-30.cs.helsinki.fi>
 <47CD5D43.9020408@nets.rwth-aachen.de> <Pine.LNX.4.64.0803042243050.15040@kivilampi-30.cs.helsinki.fi>
 <47CDD543.1090607@nets.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-553561648-1204700412=:15712"
Cc: Netdev <netdev@vger.kernel.org>
To: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58282 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755872AbYCEHAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 02:00:17 -0500
In-Reply-To: <47CDD543.1090607@nets.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-553561648-1204700412=:15712
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 5 Mar 2008, Arnd Hannemann wrote:

> Ilpo Järvinen wrote:
>
> > No, if there's any skb which is more than fackets_out-tp->reordering from 
> > the highest SACKed skb, it will be marked TCPCB_LOST (see 
> > tcp_mark_head_lost & it's caller), and all LOST segments are retransmitted 
> > by the earlier loop (for a while still as I'm going to very likely change 
> > that in net-2.6.26, commits for consolidating both, nearly identical loops 
> > are already in my local git and await some testing).
> > 
> > Forwardretrans is only incremented when there isn't TCPCB_LOST set for a 
> > segment and it doesn't apply in this case anyway because you have new data 
> > to send (see the decision making for forward retransmits, it's well 
> > commented btw).
> 
> Ah, I see. Thank you for clarifying.
> However fackets_out is not so well documented ;-)

I think I've fixed this for 2.6.25... :-) :

...
/* Heurestics to calculate number of duplicate ACKs. There's no dupACKs
 * counter when SACK is enabled (without SACK, sacked_out is used for
 * that purpose).
 *
 * Instead, with FACK TCP uses fackets_out that includes both SACKed
 * segments up to the highest received SACK block so far and holes in
 * between them.
 *
 * With reordering, holes may still be in flight, so RFC3517 recovery
 * uses pure sacked_out (total number of SACKed segments) even though
 * it violates the RFC that uses duplicate ACKs, often these are equal
 * but when e.g. out-of-window ACKs or packet duplication occurs,
 * they differ. Since neither occurs due to loss, TCP should really
 * ignore them.
 */
static inline int tcp_dupack_heurestics(struct tcp_sock *tp)
...

...Though some FACK comments seem to be saying something else still.

> But it now makes all sense (with dump order):
> An ACK 19225 arrives with SACK block {27745:29165}, so fackets_out becomes 
> ~6 ((27745-19225)/1450)
> tp->reordering is 3 at this time so he starts to retransmit.
> However some SACK ACK comes early enough so he stops at 4 retransmits.
> Or something like that...

Another thing you should consider is reordering detection which hopefully 
worked at 13:08:20.667529 through the newly discored SACK block which is 
_lower_ than the highestmost SACK block received so far. That results in 
FACK -> RFC3517, FACK is built on inorder assumptions and whenever we find 
that untrue, e.g., due to SACK/ACK for non-rexmit when something larger 
has been confirmed received we disable it. Ah, but this was 2.6.24.y? It 
doesn't yet do RFC3517 IIRC, but has something remotely resembling 
newreno, but only for the first packet because the next cumulative ACK may 
often trigger timedout loop which basically marks everything lost (I don't 
remember if the latter was changed to occur only with FACK ages ago or 
not).

> >> Tcpdump:
> 
> Sorry, this was just bogus. Just wanted to point out the timestamp 
> differences and made a wrong example. Screen full of numbers... ;-)

I thought so :-).

...Large, nearly equal numbers in two dimensions, maybe at some day 
I wake up and notice I've read them too long noticing that capturing 
this kind of things is no longer a problem to me... :-/

-- 
 i.
---696243703-553561648-1204700412=:15712--
