From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
Date: Tue, 26 Aug 2008 17:10:46 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0808250948420.27330@wrl-59.cs.helsinki.fi>
References: <20080819213417.45133573@tux> <Pine.LNX.4.64.0808201358490.4551@wrl-59.cs.helsinki.fi>
 <20080822183224.2d52f16c@tux> <20080822.143709.65615512.davem@davemloft.net>
 <20080823111446.06a350a2@tux> <Pine.LNX.4.64.0808231736490.10712@wrl-59.cs.helsinki.fi>
 <20080824163843.33b4f890@tux>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-1103248658-1219647395=:27330"
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "=?ISO-8859-1?Q?D=E2niel?= Fraga" <fragabr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49280 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754161AbYHZOKt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 10:10:49 -0400
In-Reply-To: <20080824163843.33b4f890@tux>
Content-ID: <Pine.LNX.4.64.0808261512590.4551@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1103248658-1219647395=:27330
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0808250957371.27330@wrl-59.cs.helsinki.fi>

On Sun, 24 Aug 2008, Dâniel Fraga wrote:

> On Sat, 23 Aug 2008 17:38:32 +0300 (EEST)
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> wrote:
> 
> > Thanks for verifying it!
> 
> 	Ops! i replied too fast! I just got a stalled connection again!
> 
> 	Important: these files were generated with the HTB patches applied.

snip

> 	What happened?
> 
> 1) the connection was stalled
> 
> 2) these tcpdumps are the *best ones* I got

Easy to read indeed :-).

> because although I started 
> them with the connection already stalled, the connection suddenly is not 
> stalled anymore, and a few minutes later was stalled again...

There is more than one TCP flow in your workload btw (so using 
"connection" is a bit more blurry from my/TCP's pov). Some stall and never 
finish, some get immediately through without any stalling and proceed ok. 
So far I've not seen any cases with mixed behavior.

The client seems to be working as expected. It even responds with DSACKs 
to SYNACK retransmissions indicating that it has processed them on TCP 
level. It might break some foreign systems btw (I don't remember if it was 
specified, so some TCP implementers may miss that possibility and their 
stack give up while seeing that to happen :-)), I hope that nobody demands 
it to be disabled someday (just a sidenote and has no relation to the 
actual problem).

> 3) I keep tcpdump running for more time
> 	
> 	Ps: anyway I could notice that the only two services that
> remain stalled is nntp, ftp, pop3 and smtp... http is never stalled,
> neither ssh. It seems to affect only "old" protocols :)

It could be userspace related thing.

> 	Ps2: anyway, the htb patch seems to help, because the problem
> took much longer to happen. With htb patches the problem happens one
> time a day. Without the htb patches the problem happens more than one 
> time a day.

It seems that there could well be more than one problem, with symptoms 
similar enough that they're hard to distinguish without a packet trace.

> 	Ps3: I really doesn't understand why "nmap -sS server"
> "solves" the stalled connection issue.

Did it solve in this particular case? At least for 995 nothing 
earth-shattering happened. I find it hardly related here. Ie., I clearly 
see the problematic flows, and non-problematic ones. Neither seem to have 
no relation to the nmap generated traffic / timing. There's one 
non-problematic 995 flow where server generates some traffic during nmap 
(5 mins since the previous packet was seen for that connection) but likely 
the NAT in between has timed out that connection because no tear-down 
resets (or anything else) show up in any tcpdump.

> 	Ps4: sorry for my hurry feedback before. I thought the problem had 
> gone. Anyway, I hope this time I provided the best data for you. Thanks.

No problem. It's well possible to have a lucky periods every now and 
then... 

A number of packets have bad tcp cksum for the sender but that's probably 
due to some offloading or so... Receiver-side has correct timestamps 
however, so it shouldn't be a problem after all. On the bright side, -s 0 
allows all timestamps to be visible, this makes me really perplexed:

S 3102907969:3102907969(0) win 5840 <mss 1460,sackOK,timestamp 37188459 0,nop,wscale 7> (DF)
S 3069527876:3069527876(0) ack 3102907970 win 5792 <mss 1460,sackOK,timestamp 258711279 37188459,nop,wscale 6> (DF)
. ack 1 win 46 <nop,nop,timestamp 37188477 258711279> (DF)
P 1:125(124) ack 1 win 46 <nop,nop,timestamp 37188481 258711279> (DF)
P 1:125(124) ack 1 win 46 <nop,nop,timestamp 37188699 258711279> (DF)
P 1:125(124) ack 1 win 46 <nop,nop,timestamp 37189135 258711279> (DF)
P 1:125(124) ack 1 win 46 <nop,nop,timestamp 37190007 258711279> (DF)
P 1:125(124) ack 1 win 46 <nop,nop,timestamp 37191751 258711279> (DF)
S 3069527876:3069527876(0) ack 3102907970 win 5792 <mss 1460,sackOK,timestamp 258712395 37191751,nop,wscale 6> (DF)
. ack 1 win 46 <nop,nop,timestamp 37192938 258712395,nop,nop,sack sack 1 {0:1} > (DF)
P 1:125(124) ack 1 win 46 <nop,nop,timestamp 37195239 258712395> (DF)

...On the latest syn, the ts_recent was updated by the last packet 
with data, so it was definately processed by (some parts of) TCP at the 
server, so at least that wasn't dropped any where in between.

In order for that to happen, I think req->ts_recent = tmp_opt.rcv_tsval
in tcp_check_req must be reached. It seems that there's likely an abort 
on early there because synacks keep being retransmitted. Would a valid 
socket be created the request would be removed from the list.

ListenOverflows might explain this (it can't be ListenDrops since it's 
equal to ListenOverflows and both get incremented on overflow). Are you 
perhaps short on workers at the userspace server? It would be nice to 
capture those mibs often enough (eg., once per 1s with timestamps) during 
the stall to see what actually gets incremented during the event because 
there's currently so much haystack that finding the needle gets impossible 
(ListenOverflows 47410) :-). Also, the corresponding tcpdump would be 
needed to match the events.


-- 
 i.
---696208474-1103248658-1219647395=:27330--
