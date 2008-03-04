From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP IPv4 strange retransmits
Date: Tue, 4 Mar 2008 23:07:39 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0803042243050.15040@kivilampi-30.cs.helsinki.fi>
References: <47CD4808.1050202@nets.rwth-aachen.de>
 <Pine.LNX.4.64.0803041507001.5423@kivilampi-30.cs.helsinki.fi>
 <47CD5D43.9020408@nets.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-735047333-1204664168=:15040"
Cc: Netdev <netdev@vger.kernel.org>
To: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:56465 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756045AbYCDVH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 16:07:56 -0500
In-Reply-To: <47CD5D43.9020408@nets.rwth-aachen.de>
Content-ID: <Pine.LNX.4.64.0803042305290.15040@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-735047333-1204664168=:15040
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0803042256361.15040@kivilampi-30.cs.helsinki.fi>

On Tue, 4 Mar 2008, Arnd Hannemann wrote:

> Hi,
> 
> Ilpo Järvinen wrote:
> > On Tue, 4 Mar 2008, Arnd Hannemann wrote:
> > 
> >> I'm observing some retransmits with kernel 2.6.24.2, which I don't 
> >> understand. For instance in this cutout[1] of a sequence diagram which 
> >> was captured[2] on the TCP sender, 4 retransmits are made.
> > 
> > They don't correspond to each other?
> 
> Hmm, they should.

Yeah, they probably do, I was just too hasty and failed to notice those 
small negative offsets.

> >> According to netstat -st output[3][4] all those 4 retransmits were "fast 
> >> retransmit".
> >> But there are no three DUPACKs which I expected would be needed for fast 
> >> retransmit?
> > 
> > With FACK it's enough that you have fackets_out > tp->reordering 
> > (=dupThresh).
> 
> If it is FACK shouldn't it be accounted for LINUX_MIB_TCPFORWARDRETRANS
> instead of LINUX_MIB_TCPFASTRETRANS?

No, if there's any skb which is more than fackets_out-tp->reordering from 
the highest SACKed skb, it will be marked TCPCB_LOST (see 
tcp_mark_head_lost & it's caller), and all LOST segments are retransmitted 
by the earlier loop (for a while still as I'm going to very likely change 
that in net-2.6.26, commits for consolidating both, nearly identical loops 
are already in my local git and await some testing).

Forwardretrans is only incremented when there isn't TCPCB_LOST set for a 
segment and it doesn't apply in this case anyway because you have new data 
to send (see the decision making for forward retransmits, it's well 
commented btw).

> >> Also interesting all retransmits happen _after_ those segments were
> >> already acked and sacked, internal queuing or latency issues?
> > 
> > I think your viewer is doing something wrong, sender.dump is not giving 
> > such information (or you draw that from wrong end?). Or it just draws
> > DSACK like that?
> 
> Viewer is tcptrace and xplot. So nothing special at all.
> You see it also in wireshark, if you draw a sequence diagram.

Ah, now I noticed those small timeleaps, very small enough to not
catch my eye earlier as the amount of numbers in such screen is just
overhelming... :-)

> You also see it in wireshark if you sort by capture timestamp. I always 
> thought that capture timestamp order is correct and not dump order, but 
> maybe I'm wrong?

I'm not sure, in the other order they make very much sense. In addition, 
the ACKs are processed in order and their effects are immediate even if 
there's more information awaiting to be processed.

> Tcpdump:
> 
> 12:08:20.667538 IP 192.168.0.7.33824 > 192.168.0.5.50139: . ack 23485 win 22720 <nop,nop,timestamp 969759 972885,nop,nop,sack 2 {24905:26325}{27745:29165}>
> ^^^^^ got acked at .667538

Did you paste wrong timestamp as 667538 == 667538? ...It just makes no 
sense for me, what are you trying to say here?

> 12:08:20.646749 IP 192.168.0.5.50139 > 192.168.0.7.33824: . 22065:23485(1420) ack 1 win 2864 <nop,nop,timestamp 972885 969754>
> ^^^^^ got retransmitted at .646749

What's the problem here? At .646749 something was retransmitted, but only 
after .667538 it was acked? Again, this makes very little sense for me...
Why did you copy them wrong way around from the tcpdump log? Or are these 
two lines related at all?


-- 
 i.
---696243703-735047333-1204664168=:15040--
