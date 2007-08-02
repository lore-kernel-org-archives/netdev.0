From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP SACK issue, hung connection, tcpdump included
Date: Thu, 2 Aug 2007 12:23:23 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0708021056560.8788@kivilampi-30.cs.helsinki.fi>
References: <46AC2CBE.5010500@netbauds.net> <20070729064511.GA18718@1wt.eu>
 <Pine.LNX.4.64.0707291052300.10340@kivilampi-30.cs.helsinki.fi>
 <20070729085427.GA22784@1wt.eu> <Pine.LNX.4.64.0707291208230.10340@kivilampi-30.cs.helsinki.fi>
 <20070729160721.GA31276@1wt.eu> <46AEC286.2030302@netbauds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: "Darryl L. Miles" <darryl-mailinglists@netbauds.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:43182 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753455AbXHBJXZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2007 05:23:25 -0400
In-Reply-To: <46AEC286.2030302@netbauds.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 31 Jul 2007, Darryl L. Miles wrote:

> I've been able to capture a tcpdump from both ends during the problem and its
> my belief there is a bug in 2.6.20.1 (at the client side) in that it issues a
> SACK option for an old sequence which the current window being advertised is
> beyond it.  This is the most concerning issue as the integrity of the sequence
> numbers doesn't seem right (to my limited understanding anyhow).

You probably didn't check the reference I explicitly gave to those who 
are not familiar how DSACK works, just in case you didn't pick it up last 
time, here it is again for you: RFC2883... However, if DSACKs really 
bother you still (though it shouldn't :-)), IIRC I also told you how 
you're able to turn it off (tcp_dsack sysctl) but I assure you that it's 
not a bug but feature called DSACK [RFC2883], there's _absolutely_ nothing 
wrong with it, instead, it would be wrong to _not_ send the below snd_una 
SACK in this scenario when tcp_dsack set to 1.

> There is another concern of why the SERVER performed a retransmission in the
> first place, when the tcpdump shows the ack covering it has been seen.

There are only three possible reasons to this thing:
1) The ACK didn't reach the SERVER (your logs prove this to not be the 
case)
2) The ACK got discarded by the SERVER
3) The SERVER (not the client) is buggy and sends an incorrect 
retransmission

...So we have just two options remaining...

> I have made available the full dumps at:
> 
> http://darrylmiles.org/snippets/lkml/20070731/

Thanks about these... Based on a quick check, it is rather clear that the 
SERVER is for some reason discarding the packets it's receiving:

04:11:26.833935 IP CLIENT.43726 > SERVER.ssh: P 4239:4287(48) ack 28176 win 501 <nop,nop,timestamp 819646456 16345815>
04:11:27.132425 IP SERVER.ssh > CLIENT.43726: . 26016:27464(1448) ack 4239 win 2728 <nop,nop,timestamp 17096579 819458864>
04:11:27.230081 IP CLIENT.43726 > SERVER.ssh: . ack 28176 win 501 <nop,nop,timestamp 819646555 16345815,nop,nop

Notice, (cumulative) ack field didn't advance though new data arrived, and 
for the record, it's in advertised window too. There are no DSACK in here 
so your theory about below snd_una SACK won't help to explain this one 
at all... We'll just have to figure out why it's discarding it. And 
there's even more to prove this...

> This sequence is interesting from the client side:
>
> 03:58:56.419034 IP SERVER.ssh > CLIENT.43726: . 26016:27464(1448) ack 4239
> win 2728 <nop,nop,timestamp 16345815 819458859> # S1
> 03:58:56.419100 IP CLIENT.43726 > SERVER.ssh: . ack 27464 win 501
> <nop,nop,timestamp 819458884 16345815> # C1
> 03:58:56.422019 IP SERVER.ssh > CLIENT.43726: P 27464:28176(712) ack 4239
> win 2728 <nop,nop,timestamp 16345815 819458859> # S2
> 03:58:56.422078 IP CLIENT.43726 > SERVER.ssh: . ack 28176 win 501
> <nop,nop,timestamp 819458884 16345815> # C2
>
> The above 4 packets look as expect to me.  Then we suddenly see a
> retransmission of 26016:27464.
> 
> 03:58:56.731597 IP SERVER.ssh > CLIENT.43726: . 26016:27464(1448) ack 4239
> win 2728 <nop,nop,timestamp 16346128 819458864> # S3

...Look at this on the retransmission:
   ... timestamp 16346128 819458864>

...it tells us what really got received by the TCP. The corresponding ACK 
with matching timestamp is, surprise, surprise, this one:

> 03:58:56.340180 IP CLIENT.43726 > SERVER.ssh: . ack 26016 win 501 
> <nop,nop,timestamp 819458864 16345734>

...thus the SERVER has _not_ received but discarded the subsequent 
cumulative ACKs!!! Therefore it's retransmitting from 26016 onward but 
never receives any reply as everything seems to get discarded...

There was one bad checksum btw:

> 03:58:56.365662 IP (tos 0x10, ttl  64, id 28685, offset 0, flags [DF], 
> proto 6, length: 764) SERVER.ssh > CLIENT.43726: P [bad tcp cksum 6662 
> (->ef2b)!] 617734888:617735600(712) ack 2634113543 win 2728 
> <nop,nop,timestamp 16345815 819458859>


> There are some changes in 2.6.22 that appear to affect TCP SACK handling
> does this fix a known issue ?

There is no such "known issue" :-)... This issue has nothing to do with 
TCP SACK handling, since that code _won't_ be reached... We could verify 
that from the timestamps. But if you still insist that SACK under snd_una 
is the issue, please turn tcp_dsack to 0 on the CLIENT, you will not get 
them after that and you can be happy as your out-of-window SACK "issue"
is then fixed :-)... 

...Seriously, somebody else than me is probably better in suggesting what 
could cause the discarding at the SERVER in this case. SNMP stuff Dave was 
asking could help, you can find them from /proc/net/{netstat,snmp}...


-- 
 i.

