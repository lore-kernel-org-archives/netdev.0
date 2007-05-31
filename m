From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 3/9] [TCP]: Tighten tcp_sock's belt, drop left_out
Date: Thu, 31 May 2007 19:31:21 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0705311846390.14736@kivilampi-30.cs.helsinki.fi>
References: <11801685621267-git-send-email-ilpo.jarvinen@helsinki.fi>
 <11801685626-git-send-email-ilpo.jarvinen@helsinki.fi>
 <11801685623173-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20070531.014241.28790645.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-699144447-1180628570=:14736"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:39382 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753155AbXEaQbY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 May 2007 12:31:24 -0400
In-Reply-To: <20070531.014241.28790645.davem@davemloft.net>
Content-ID: <Pine.LNX.4.64.0705311923180.14736@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-699144447-1180628570=:14736
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0705311923181.14736@kivilampi-30.cs.helsinki.fi>

Thanks for you comments...

On Thu, 31 May 2007, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Sat, 26 May 2007 11:35:56 +0300
> 
> > It is easily calculable when needed and user are not that many
> > after all.
>
> This looks good, but are you absolutely sure we never used
> a stale value of tp->left_out on purpose?
> 
> I tried to audit this but there are so many cases :-)

Yes I know... So often complexity in these kind of things really
perplexes me too, in a way this is somewhat similar to the case with FRTO 
and no SACKed bits touched (which just looked very obvious and safe) but 
would have caused the dreaded S+L situation unless special handling for 
IsReno(tp) case would have been added.

> What I mean here is, was there a case where we updated
> sacked_out or lost_out, but then used left_out before
> it was updated, and we were doing this on purpose?

I understand what you mean even though I think that such approach would be 
very fragile if being done (and should be fixed). I was actually wondering 
earlier that could it be the only reason for the separate variable in the 
first place. Though so far I don't know any cases... ...but the code ain't 
always that trivial like you say :-), however, this after proven safe, 
will make it cleaner and will save next one to come from the same
wondering... ;-)

Anyway, I'll be try to do some grep tricks in order to reduce the number 
of cases that need an expensive manual audit to a smaller set where 
tcp_sync_left_out is not right after the adjustment. As plenty of 
functions end to tcp_sync_left_out without returning in between, it could 
help a lot, of course the calls within that function could have issues too 
but they're relatively easy to check then (common pattern is a trivial 
loop + sync as you know)... Usually only when the "stale state" leaks from 
a function, we're in troubles with the number of possible paths. ...I'll 
come back to this later on after verifying it and perhaps provide the 
same shortened list for you too so that you can see if I overlooked 
something... 

It might actually end up being easier to audit all tcp_packets_in_flight 
callers instead to see if there's always sync_left_out before them.


Another thing, I was thinking of renaming tcp_sync_left_out to 
tcp_verify_left_out now that it does only BUG traps... Do you have a hunch 
about this (from patch 8 msg): I wonder if we could get that BUG_ON place 
pinpointed more exactly in oops because now inlining makes it lose its 
original context as they always seem to be in tcp_ack, #define helps?
(i.e, how does it show up in oops if tcp_verify_left_out looks like this):

#define tcp_verify_left_out(tp) BUG_ON(...)

...does it still point to the tcp.h line xxxx then or to the
tcp_sync_left_out(tp) @ line yyyy in tcp_input.c? ...I'll test that
later on by myself in case you don't know the answer.


-- 
 i.
---696243703-699144447-1180628570=:14736--
