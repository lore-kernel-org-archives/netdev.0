From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP SACK issue, hung connection, tcpdump included
Date: Sun, 29 Jul 2007 12:28:04 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0707291208230.10340@kivilampi-30.cs.helsinki.fi>
References: <46AC2CBE.5010500@netbauds.net> <20070729064511.GA18718@1wt.eu>
 <Pine.LNX.4.64.0707291052300.10340@kivilampi-30.cs.helsinki.fi>
 <20070729085427.GA22784@1wt.eu>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-1547136570-1185700118=:10340"
Cc: "Darryl L. Miles" <darryl-mailinglists@netbauds.net>,
	linux-kernel@vger.kernel.org, Netdev <netdev@vger.kernel.org>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:51368 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760873AbXG2J2G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jul 2007 05:28:06 -0400
In-Reply-To: <20070729085427.GA22784@1wt.eu>
Content-ID: <Pine.LNX.4.64.0707291225250.10340@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1547136570-1185700118=:10340
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0707291210121.10340@kivilampi-30.cs.helsinki.fi>

On Sun, 29 Jul 2007, Willy Tarreau wrote:

> On Sun, Jul 29, 2007 at 11:26:00AM +0300, Ilpo Järvinen wrote:
> > On Sun, 29 Jul 2007, Willy Tarreau wrote:
> > 
> > > On Sun, Jul 29, 2007 at 06:59:26AM +0100, Darryl L. Miles wrote:
> > > > CLIENT = Linux 2.6.20.1-smp [Customer build]
> > > > SERVER = Linux 2.6.9-55.ELsmp [Red Hat Enterprise Linux AS release 4 
> > > > (Nahant Update 5)]
> > > > 
> > > > The problems start around time index 09:21:39.860302 when the CLIENT issues 
> > > > a TCP packet with SACK option set (seemingly for a data segment which has 
> > > > already been seen) from that point on the connection hangs.
> > 
> > ...That's DSACK and it's being correctly sent. To me, it seems unlikely to 
> > be the cause for this breakage...
> > 
> > > Where was the capture taken ? on CLIENT or on SERVER (I suspect client from
> > > the timers) ? 
> > 
> > ...I would guess the same based on SYN timestamps (and from the DSACK 
> > timestamps)...
> > 
> > > A possible, but very unlikely reason would be an MTU limitation
> > > somewhere, because the segment which never gets correctly ACKed is also the
> > > largest one in this trace.
> > 
> > Limitation for 48 byte segments? You have to be kidding... :-) But yes,
> > it seems that one of the directions is dropping packets for some reason 
> > though I would not assume MTU limitation... Or did you mean some other 
> > segment?
> 
> No, I was talking about the 1448 bytes segments. But in fact I don't
> believe it much because the SACKs are always retransmitted just afterwards.

Ah, but it's ACKed correctly right below it...:

[...snip...]
> > > > 09:21:39.490740 IP SERVER.ssh > CLIENT.50727: P 18200:18464(264) ack 2991 
> > > > win 2728 <nop,nop,timestamp 7692910 800001727>
> > > > 09:21:39.490775 IP CLIENT.50727 > SERVER.ssh: . ack 18464 win 378 
> > > > <nop,nop,timestamp 800001755 7692910>
> > > > 09:21:39.860245 IP SERVER.ssh > CLIENT.50727: . 12408:13856(1448) ack 2991 
> > > > win 2728 <nop,nop,timestamp 7693293 800001749>

...segment below snd_una arrived => snd_una remains 18464, receiver 
generates a duplicate ACK:
 
> > > > 09:21:39.860302 IP CLIENT.50727 > SERVER.ssh: . ack 18464 win 378 
> > > > <nop,nop,timestamp 800001847 7692910,nop,nop,sack sack 1 {12408:13856} >

The cumulative ACK field of it covers _everything_ below 18464 (i.e., it 
ACKs them), including the 1448 bytes in 12408:13856... In addition, the 
SACK block is DSACK information [RFC2883] telling explicitly the address 
of the received duplicate block. However, if this ACK doesn't reach the 
SERVER TCP, RTO is triggered and the first not yet cumulatively ACKed 
segment is retransmitted (I guess cumulative ACKs up to 12408 arrived 
without problems to the SERVER):

> > > > 09:21:40.453440 IP SERVER.ssh > CLIENT.50727: . 12408:13856(1448) ack 2991 
> > > > win 2728 <nop,nop,timestamp 7693887 800001749>
[...snip...]

> BTW, some information are missing. It would have been better if the trace
> had been read with tcpdump -Svv. We would have got seq numbers and ttl.
> Also, we do not know if there's a firewall between both sides. Sometimes,
> some IDS identify attacks in crypted traffic and kill connections. It
> might have been the case here, with the connection closed one way on an
> intermediate firewall.

Yeah, firewall or some other issue, I'd say it's quite unlikely a bug in 
TCP because behavior to both directions indicate client -> sender 
blackhole independently of each other...


-- 
 i.
---696243703-1547136570-1185700118=:10340--
