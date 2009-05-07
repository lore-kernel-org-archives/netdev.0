From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Strange Application bug, race in MSG_PEEK complaints (was:
 Bug#513695: fetchmail: race in MSG_PEEK)
Date: Thu, 7 May 2009 09:48:48 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0905070931590.12068@wrl-59.cs.helsinki.fi>
References: <200902262310.12791.elendil@planet.nl> <200903091749.50818.elendil@planet.nl>
 <op.uqjiqsol1e62zd@merlin.emma.line.org> <200903141900.14498.elendil@planet.nl>
 <20090506230240.GA10373@merlin.emma.line.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-156204157-1241678928=:12068"
Cc: Netdev <netdev@vger.kernel.org>, Frans Pop <elendil@planet.nl>
To: Matthias Andree <matthias.andree@gmx.de>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35122 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751832AbZEGGsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 02:48:50 -0400
In-Reply-To: <20090506230240.GA10373@merlin.emma.line.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-156204157-1241678928=:12068
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Thu, 7 May 2009, Matthias Andree wrote:

> (Please Cc: Frans and myself on replies, we're not subscribed to netdev@.)
> (Resent from mutt, after Opera trashed my headers...)
> (DaveM, this was Cc:d to you earlier today under a different subject. The
> failing wget is new though.)
> 
> Dear Kernel Hackers,
> 
> I am getting rather frequent "TCP(...): Application bug, race in MSG_PEEK."
> complaints for fetchmail these days.
> The strange part is that fetchmail is a single-threaded application that does
> not deal with URG data.
> I cannot see what fetchmail would race against in this situation.
> 
> Frans Pop has found interesting patterns probably related to segment or
> packet/payload sizes (1460 bytes!) - see his message quoted below.
> 
> His most recent findings are:
> : As further info, I've also got very infrequent MSGPEEK errors on my
> : laptop, which runs nothing strange (... KDE ...)
> : Interesting may be that both systems are dual core, running x86_64.
> :
> : Here are the errors from my laptop (also with my extra debug info):
> : Mar 14 09:23:18 aragorn kernel: TCP(kio_imap4:5646): Application bug, race
> : in MSG_PEEK: 0, 23.
> : Apr  8 12:21:28 aragorn kernel: TCP(kio_imap4:24173): Application bug, race
> : in MSG_PEEK: 38dd5ab8, 8.
> : May  3 23:45:29 aragorn kernel: TCP(wget:4137): Application bug, race in
> : MSG_PEEK: 77093ab8, 3e.
> : Note the last one. A simple wget?!
> 
> Application use: Fetchmail does use MSG_PEEK in several places to look ahead.
> The same process that peeks will later read the data. It can happen that we
> peek at 1 byte, then more bytes, or that we peek at 512 bytes and read only
> smaller amounts (say, 30 - 70) of them before we peek again.
> 
> As to the application source code: Look for instance for fm_peek in the
> function SockRead() in
> <http://mknod.org/svn/fetchmail/branches/BRANCH_6-3/socket.c> and its callers.
> 
> Can we be sure that
> 
> (a) the kernel correctly handles peek_seq and tp->copied_seq and their
> comparison (see Frans's message below - is the != in the if statement actually
> the right thing or should this be a > or <?), and
> 
> (b) that the message is printed only if there is a real app bug (that I fail
> to see), and
> 
> (c) that the kernel handles package boundaries, wraparounds, and buffers
> correctly?
> 
> Might the reception of further data in the socket's receive buffer trigger the
> message? As in: between peek and read, or between read and peek, further data
> arrives, and triggers the message?
> 
> Might the kernel's TCP code be confused about absolute vs. relative
> sequence/position indexes/pointers/counters inside the TCP code?
> 
> Thanks a lot in advance. (Frans's earlier message included below.)
> 
> Best regards
> Matthias
> 
> 
> ------- Weitergeleitete Nachricht -------
> Von: "Frans Pop" <elendil@planet.nl>
> An: "Matthias Andree" <matthias.andree@gmx.de>
> Kopie:
> Betreff: Re: Bug#513695: fetchmail: race in MSG_PEEK - trace data
> Datum: Sat, 14 Mar 2009 19:00:13 +0100
> 
> On Monday 09 March 2009, Matthias Andree wrote:
> >Unfortunately, the strace seems to be incomplete - likely strace macros
> >wrong: I see lots of recvfrom with replies, but not the send or write
> >that actually shows the other half of the conversation. Could I have
> >coordinated full strace logging and kernel messages?
> 
> See attachment. The syslog is complete for the period the tcpdump was
> running, but the tcpdump itself is filtered for only the relevant
> conversation. Again account name and password removed from the traces.
> 
> It took a bit longer because I wanted to get some history from a kernel
> patch I added. I've now automated the creation of the traces, so if you
> want more data, even from the kernel, please ask.
> 
> I've applied the following patch to net/ipv4/tcp.c for the kernel running
> on my server (2.6.29-rc8):
> @@ -1499,8 +1499,9 @@ do_prequeue:
>    		}
>    		if ((flags & MSG_PEEK) && peek_seq != tp->copied_seq) {
>    			if (net_ratelimit())
> -				printk(KERN_DEBUG "TCP(%s:%d): Application
> bug, race in MSG_PEEK.\n",
> -				       current->comm, task_pid_nr(current));
> +				printk(KERN_DEBUG "TCP(%s:%d): Application
> bug, race in MSG_PEEK: %x,
> %x.\n",
> +				       current->comm, task_pid_nr(current)),
> +				       peek_seq, tp->copied_seq;

I cannot resist myself from noting that this certainly wasn't the patch 
one got those printks below... It might happily compile though :-).

>    			peek_seq = tp->copied_seq;
>    		}
>    		continue;
> 
> So, the values you see at the end of the warning are peek_seq and
> tp->copied_seq. This gives messages like:
> kernel: TCP(fetchmail:9311): Application bug, race in MSG_PEEK: 156233,
> 16a.
> kernel: TCP(fetchmail:9311): Application bug, race in MSG_PEEK: 71259ac8,
> 5b4.
> kernel: TCP(fetchmail:31216): Application bug, race in MSG_PEEK: 833fe5,
> c0.
> 
> The distribution for tp->copied_seq is interesting:
>         1 24
>         1 c0
>         1 132
>         1 16a
>         3 248
>         1 2a7
>         1 400
>       166 5b4
> 
> So, 0x5b4 (1460) seems to be special (is it a maximum size maybe?); if

1460 is size of the maximum wire segment when not using timestamps (1500 
MTU - (20+20 headers), would be 1448 with timestamps). So basically the 
skbs in the receiver queue will be of that length (holds until the driver 
of your nic is converted to gro).

> I grep the kernel for that I get:
> net/ipv4/tcp_input.c:           if (tp->mss_cache > 1460)
> net/ipv4/tcp_output.c:          if (mss > 1460 * 3)
> net/ipv4/tcp_output.c:          else if (mss > 1460)
> And:
> net/ipv[46]/syncookies.c:
> static __u16 const msstab[] = {
>           64 - 1,
>           256 - 1,
>           512 - 1,
>           536 - 1,
>           1024 - 1,
>           1440 - 1,
>           1460 - 1,
>           4312 - 1,
>           (__u16)-1
> };
> 
> Not sure if all that means anything, but I thought I'd mention it.

What would you think about the following, untested patch... I suppose it 
is enough to capture the racy situations except with that crazy urg hole, 
grr (I suppose that will need just another variable to do the offset
of one).

-- 
 i.

[RFC PATCH] tcp: fix MSG_PEEK race check

Commit 518a09ef11 (tcp: Fix recvmsg MSG_PEEK influence of
blocking behavior) lets the loop run longer than this check
did previously expect, so we need to be more careful with
this check and consider the work we have been doing.

I'm a bit unsure if this improved check can still fail as
	if (!sock_flag(sk, SOCK_URGINLINE)) {
		++*seq;
		...
does not increment copied.

Compile tested.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>

---
 net/ipv4/tcp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 1d7f49c..ccbd69b 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1532,7 +1532,7 @@ do_prequeue:
 				}
 			}
 		}
-		if ((flags & MSG_PEEK) && peek_seq != tp->copied_seq) {
+		if ((flags & MSG_PEEK) && (peek_seq - copied != tp->copied_seq)) {
 			if (net_ratelimit())
 				printk(KERN_DEBUG "TCP(%s:%d): Application bug, race in MSG_PEEK.\n",
 				       current->comm, task_pid_nr(current));
-- 
tg: (4d5b78c..) fix/msgpeek-race-chk (depends on: origin/master)
---696208474-156204157-1241678928=:12068--
