From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP SACK issue, hung connection, tcpdump included
Date: Sun, 29 Jul 2007 11:26:00 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0707291052300.10340@kivilampi-30.cs.helsinki.fi>
References: <46AC2CBE.5010500@netbauds.net> <20070729064511.GA18718@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Darryl L. Miles" <darryl-mailinglists@netbauds.net>,
	linux-kernel@vger.kernel.org, Netdev <netdev@vger.kernel.org>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:51885 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760269AbXG2I0F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jul 2007 04:26:05 -0400
In-Reply-To: <20070729064511.GA18718@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 29 Jul 2007, Willy Tarreau wrote:

> On Sun, Jul 29, 2007 at 06:59:26AM +0100, Darryl L. Miles wrote:
> > CLIENT = Linux 2.6.20.1-smp [Customer build]
> > SERVER = Linux 2.6.9-55.ELsmp [Red Hat Enterprise Linux AS release 4 
> > (Nahant Update 5)]
> > 
> > The problems start around time index 09:21:39.860302 when the CLIENT issues 
> > a TCP packet with SACK option set (seemingly for a data segment which has 
> > already been seen) from that point on the connection hangs.

...That's DSACK and it's being correctly sent. To me, it seems unlikely to 
be the cause for this breakage...

> Where was the capture taken ? on CLIENT or on SERVER (I suspect client from
> the timers) ? 

...I would guess the same based on SYN timestamps (and from the DSACK 
timestamps)...

> A possible, but very unlikely reason would be an MTU limitation
> somewhere, because the segment which never gets correctly ACKed is also the
> largest one in this trace.

Limitation for 48 byte segments? You have to be kidding... :-) But yes,
it seems that one of the directions is dropping packets for some reason 
though I would not assume MTU limitation... Or did you mean some other 
segment?

> Also, if everything is right with the packets on the server side, then
> it would means that it's the RHEL kernel which is buggy (which does not
> mean that the same bug does not exist in mainline).

...There are two independed signs that server side is not getting the 
packets (ack field is not advanced nor do the retransmissions of an old 
data cease) so IMHO that would the first thing to rule out.

> > Full dump available via email.
> > 
> > 
> > 09:12:13.444999 IP CLIENT.50727 > SERVER.ssh: S 2919512080:2919512080(0) 
> > win 5840 <mss 1460,sackOK,timestamp 799860259 0,nop,wscale 7>
> > 09:12:13.535643 IP SERVER.ssh > CLIENT.50727: S 492909547:492909547(0) ack 
> > 2919512081 win 5792 <mss 1460,sackOK,timestamp 7126976 799860259,nop,wscale 
> > 2>
> > 09:12:13.535717 IP CLIENT.50727 > SERVER.ssh: . ack 1 win 46 
> > <nop,nop,timestamp 799860282 7126976>
> > 09:12:13.665481 IP SERVER.ssh > CLIENT.50727: P 1:24(23) ack 1 win 1448 
> > <nop,nop,timestamp 7127074 799860282>
> > 09:12:13.665895 IP CLIENT.50727 > SERVER.ssh: . ack 24 win 46 
> > <nop,nop,timestamp 799860314 7127074>
> > 09:12:13.666044 IP CLIENT.50727 > SERVER.ssh: P 1:23(22) ack 24 win 46 
> > <nop,nop,timestamp 799860314 7127074>
> > 09:12:13.776318 IP SERVER.ssh > CLIENT.50727: . ack 23 win 1448 
> > <nop,nop,timestamp 7127216 799860314>
> > 
> > ...SNIPPED SUCCESSFUL TRAFFIC...
> > 
> > 09:21:39.490740 IP SERVER.ssh > CLIENT.50727: P 18200:18464(264) ack 2991 
> > win 2728 <nop,nop,timestamp 7692910 800001727>
> > 09:21:39.490775 IP CLIENT.50727 > SERVER.ssh: . ack 18464 win 378 
> > <nop,nop,timestamp 800001755 7692910>
> > 09:21:39.860245 IP SERVER.ssh > CLIENT.50727: . 12408:13856(1448) ack 2991 
> > win 2728 <nop,nop,timestamp 7693293 800001749>
> > 09:21:39.860302 IP CLIENT.50727 > SERVER.ssh: . ack 18464 win 378 
> > <nop,nop,timestamp 800001847 7692910,nop,nop,sack sack 1 {12408:13856} >
> > 09:21:40.453440 IP SERVER.ssh > CLIENT.50727: . 12408:13856(1448) ack 2991 
> > win 2728 <nop,nop,timestamp 7693887 800001749>
> > 09:21:40.453495 IP CLIENT.50727 > SERVER.ssh: . ack 18464 win 378 
> > <nop,nop,timestamp 800001996 7692910,nop,nop,sack sack 1 {12408:13856} >
> > 09:21:41.641821 IP SERVER.ssh > CLIENT.50727: . 12408:13856(1448) ack 2991 
> > win 2728 <nop,nop,timestamp 7695075 800001749>
> > 09:21:41.641938 IP CLIENT.50727 > SERVER.ssh: . ack 18464 win 378 
> > <nop,nop,timestamp 800002293 7692910,nop,nop,sack sack 1 {12408:13856} >
> > 09:21:44.017552 IP SERVER.ssh > CLIENT.50727: . 12408:13856(1448) ack 2991 
> > win 2728 <nop,nop,timestamp 7697451 800001749>
> > 09:21:44.017622 IP CLIENT.50727 > SERVER.ssh: . ack 18464 win 378 
> > <nop,nop,timestamp 800002887 7692910,nop,nop,sack sack 1 {12408:13856} >
> > 09:21:48.770051 IP SERVER.ssh > CLIENT.50727: . 12408:13856(1448) ack 2991 
> > win 2728 <nop,nop,timestamp 7702203 800001749>
> > 09:21:48.770099 IP CLIENT.50727 > SERVER.ssh: . ack 18464 win 378 
> > <nop,nop,timestamp 800004075 7692910,nop,nop,sack sack 1 {12408:13856} >
> > 09:21:58.274061 IP SERVER.ssh > CLIENT.50727: . 12408:13856(1448) ack 2991 
> > win 2728 <nop,nop,timestamp 7711707 800001749>
> > 09:21:58.274180 IP CLIENT.50727 > SERVER.ssh: . ack 18464 win 378 
> > <nop,nop,timestamp 800006450 7692910,nop,nop,sack sack 1 {12408:13856} >
> > 09:22:17.282035 IP SERVER.ssh > CLIENT.50727: . 12408:13856(1448) ack 2991 
> > win 2728 <nop,nop,timestamp 7730715 800001749>
> > 09:22:17.282153 IP CLIENT.50727 > SERVER.ssh: . ack 18464 win 378 
> > <nop,nop,timestamp 800011202 7692910,nop,nop,sack sack 1 {12408:13856} >
> > 09:22:55.298955 IP SERVER.ssh > CLIENT.50727: . 12408:13856(1448) ack 2991 
> > win 2728 <nop,nop,timestamp 7768731 800001749>
> > 09:22:55.299023 IP CLIENT.50727 > SERVER.ssh: . ack 18464 win 378 
> > <nop,nop,timestamp 800020705 7692910,nop,nop,sack sack 1 {12408:13856} >
> > 09:24:11.329853 IP SERVER.ssh > CLIENT.50727: . 12408:13856(1448) ack 2991 
> > win 2728 <nop,nop,timestamp 7844763 800001749>
> > 09:24:11.329923 IP CLIENT.50727 > SERVER.ssh: . ack 18464 win 378 
> > <nop,nop,timestamp 800039711 7692910,nop,nop,sack sack 1 {12408:13856} >
> > 09:26:11.331578 IP SERVER.ssh > CLIENT.50727: . 12408:13856(1448) ack 2991 
> > win 2728 <nop,nop,timestamp 7964763 800001749>
> > 09:26:11.331699 IP CLIENT.50727 > SERVER.ssh: . ack 18464 win 378 
> > <nop,nop,timestamp 800069708 7692910,nop,nop,sack sack 1 {12408:13856} >
> > 09:26:13.011885 IP CLIENT.50727 > SERVER.ssh: P 2991:3039(48) ack 18464 win 
> > 378 <nop,nop,timestamp 800070128 7692910>
> > 09:26:13.309032 IP CLIENT.50727 > SERVER.ssh: P 2991:3039(48) ack 18464 win 
> > 378 <nop,nop,timestamp 800070202 7692910>
> > 09:26:13.901048 IP CLIENT.50727 > SERVER.ssh: P 2991:3039(48) ack 18464 win 
> > 378 <nop,nop,timestamp 800070350 7692910>
> > 09:26:15.085103 IP CLIENT.50727 > SERVER.ssh: P 2991:3039(48) ack 18464 win 
> > 378 <nop,nop,timestamp 800070646 7692910>
> > 09:26:17.453195 IP CLIENT.50727 > SERVER.ssh: P 2991:3039(48) ack 18464 win 
> > 378 <nop,nop,timestamp 800071238 7692910>
> > 09:26:22.189378 IP CLIENT.50727 > SERVER.ssh: P 2991:3039(48) ack 18464 win 
> > 378 <nop,nop,timestamp 800072422 7692910>
> > 09:26:31.661696 IP CLIENT.50727 > SERVER.ssh: P 2991:3039(48) ack 18464 win 
> > 378 <nop,nop,timestamp 800074790 7692910>
> > 09:26:50.610374 IP CLIENT.50727 > SERVER.ssh: P 2991:3039(48) ack 18464 win 
> > 378 <nop,nop,timestamp 800079526 7692910>
> > 09:27:28.499729 IP CLIENT.50727 > SERVER.ssh: P 2991:3039(48) ack 18464 win 
> > 378 <nop,nop,timestamp 800088998 7692910>
> > 09:28:11.331256 IP SERVER.ssh > CLIENT.50727: . 12408:13856(1448) ack 2991 
> > win 2728 <nop,nop,timestamp 8084763 800001749>
> > 09:28:11.331354 IP CLIENT.50727 > SERVER.ssh: . ack 18464 win 378 
> > <nop,nop,timestamp 800099704 7692910,nop,nop,sack sack 1 {12408:13856} >
> > 09:28:44.286495 IP CLIENT.50727 > SERVER.ssh: P 2991:3039(48) ack 18464 win 
> > 378 <nop,nop,timestamp 800107942 7692910>
> > 09:30:11.330959 IP SERVER.ssh > CLIENT.50727: . 12408:13856(1448) ack 2991 
> > win 2728 <nop,nop,timestamp 8204763 800001749>
> > 09:30:11.331074 IP CLIENT.50727 > SERVER.ssh: . ack 18464 win 378 
> > <nop,nop,timestamp 800129701 7692910,nop,nop,sack sack 1 {12408:13856} >
> > 09:30:44.298756 IP CLIENT.50727 > SERVER.ssh: P 2991:3039(48) ack 18464 win 
> > 378 <nop,nop,timestamp 800137942 7692910>
> > 09:32:11.331661 IP SERVER.ssh > CLIENT.50727: . 12408:13856(1448) ack 2991 
> > win 2728 <nop,nop,timestamp 8324763 800001749>
> > 09:32:11.331727 IP CLIENT.50727 > SERVER.ssh: . ack 18464 win 378 
> > <nop,nop,timestamp 800159698 7692910,nop,nop,sack sack 1 {12408:13856} >
> > 09:32:44.311051 IP CLIENT.50727 > SERVER.ssh: P 2991:3039(48) ack 18464 win 
> > 378 <nop,nop,timestamp 800167942 7692910>
> > 09:34:11.332375 IP SERVER.ssh > CLIENT.50727: . 12408:13856(1448) ack 2991 
> > win 2728 <nop,nop,timestamp 8444763 800001749>
> > 09:34:11.332447 IP CLIENT.50727 > SERVER.ssh: . ack 18464 win 378 
> > <nop,nop,timestamp 800189695 7692910,nop,nop,sack sack 1 {12408:13856} >
> > 09:34:44.323298 IP CLIENT.50727 > SERVER.ssh: P 2991:3039(48) ack 18464 win 
> > 378 <nop,nop,timestamp 800197942 7692910>
> > 09:36:11.332073 IP SERVER.ssh > CLIENT.50727: . 12408:13856(1448) ack 2991 
> > win 2728 <nop,nop,timestamp 8564763 800001749>
> > 09:36:11.332166 IP CLIENT.50727 > SERVER.ssh: . ack 18464 win 378 
> > <nop,nop,timestamp 800219692 7692910,nop,nop,sack sack 1 {12408:13856} >
> > 09:36:44.335591 IP CLIENT.50727 > SERVER.ssh: P 2991:3039(48) ack 18464 win 
> > 378 <nop,nop,timestamp 800227942 7692910>
> > 09:38:44.351950 IP CLIENT.50727 > SERVER.ssh: P 2991:3039(48) ack 18464 win 
> > 378 <nop,nop,timestamp 800257942 7692910>
> > 09:40:44.368172 IP CLIENT.50727 > SERVER.ssh: P 2991:3039(48) ack 18464 win 
> > 378 <nop,nop,timestamp 800287943 7692910>
> > 
> > At the end of the dump here the connection is dropped by the client side.

...There a limit on how many times a retransmission of a segment is tried, 
and in the dump both directions are trying to retransmit (and then they 
finally gave up), perhaps CLIENT->SERVER direction drops all packets after 
09:21:39.490740 (or even before that), so that no cumulative ACK for seq 
18464 ever reaches SERVER (which is still having snd_una @ 12408 I guess) 
nor the retransmissions of 2991:3039 from the CLIENT.

Is this reproducable? Can you somehow verify that the packets CLIENT is 
sending are indeed received by the SERVER...?

-- 
 i.
