From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: commit 64ff3b938ec6782e6585a83d5459b98b0c3f6eb8 breaks rlogin
Date: Mon, 9 Feb 2009 17:11:51 +1100
Message-ID: <20090209061151.GA3982@gondor.apana.org.au>
References: <20090206054541.GA4954@gondor.apana.org.au> <b6a2187b0902060335h646e8d86pf00773035f577665@mail.gmail.com> <20090209055848.GA3889@gondor.apana.org.au> <20090208.220357.261414983.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff.chua.linux@gmail.com, rjw@sisk.pl,
	torvalds@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47262 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753184AbZBIGMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 01:12:05 -0500
Content-Disposition: inline
In-Reply-To: <20090208.220357.261414983.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 08, 2009 at 10:03:57PM -0800, David Miller wrote:
> 
> I would expect to see the URG packets from rlogin not rlogind, from
> things like hitting Ctrl-C etc.

That's what I thought too, however, the strace says otherwise:

connect(3, {sa_family=AF_INET, sin_port=htons(513), sin_addr=inet_addr("192.168.243.118")}, 16) = 0
write(3, "\0", 1)                       = 1
writev(3, [{"root\0", 5}, {"root\0", 5}, {"xterm/38400\0", 12}], 3) = 22
read(3, "\0", 1)                        = 1
rt_sigprocmask(SIG_SETMASK, [USR1 URG], [USR1 URG], 8) = 0
setsockopt(3, SOL_IP, IP_TOS, [16], 4)  = 0
setuid32(0)                             = 0
ioctl(0, SNDCTL_TMR_TIMEBASE or TCGETS, {B38400 opost isig icanon echo ...}) = 0
rt_sigaction(SIGINT, {SIG_IGN}, {SIG_DFL}, 8) = 0
rt_sigprocmask(SIG_BLOCK, [HUP], [USR1 URG], 8) = 0
rt_sigaction(SIGHUP, {0x8048bdc, [HUP], SA_RESTART}, {SIG_IGN}, 8) = 0
rt_sigaction(SIGHUP, {SIG_IGN}, {0x8048bdc, [HUP], SA_RESTART}, 8) = 0
rt_sigprocmask(SIG_SETMASK, [USR1 URG], [HUP USR1 URG], 8) = 0
rt_sigprocmask(SIG_BLOCK, [QUIT], [USR1 URG], 8) = 0
rt_sigaction(SIGQUIT, {0x8048bdc, [QUIT], SA_RESTART}, {SIG_DFL}, 8) = 0
rt_sigprocmask(SIG_SETMASK, [USR1 URG], [QUIT USR1 URG], 8) = 0
rt_sigaction(SIGCHLD, {0x8049f20, [CHLD], SA_RESTART}, {SIG_DFL}, 8) = 0
clone(child_stack=0, flags=CLONE_CHILD_CLEARTID|CLONE_CHILD_SETTID|SIGCHLD, child_tidptr=0xb7d81918) = 6433
rt_sigaction(SIGURG, {0x80491d0, [URG], SA_RESTART}, {SIG_DFL}, 8) = 0
rt_sigaction(SIGUSR1, {0x8048de0, [USR1], SA_RESTART}, {SIG_DFL}, 8) = 0
rt_sigprocmask(SIG_SETMASK, [], [USR1 URG], 8) = 0
--- SIGURG (Urgent I/O condition) @ 0 (0) ---
kill(6433, SIGURG)                      = 0

FD 3 is the TCP socket.  As you can see, the only operations done
were write/writev/read/setsockopt.  None of these can enter urgent
mode for sending, so that's how I concluded that my patch should
have zero effect on this side.

Note also that we got an SIGURG, which indicates that we received
urgent data.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
