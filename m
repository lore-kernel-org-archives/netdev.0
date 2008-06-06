From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [fixed] [patch] Re: [bug] stuck localhost TCP connections,
 v2.6.26-rc3+
Date: Fri, 6 Jun 2008 22:49:59 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0806062151490.9424@wrl-59.cs.helsinki.fi>
References: <20080603.150344.145518113.davem@davemloft.net>
 <Pine.LNX.4.64.0806040208350.7315@wrl-59.cs.helsinki.fi> <20080605142244.GA19216@elte.hu>
 <Pine.LNX.4.64.0806052059380.31672@wrl-59.cs.helsinki.fi>
 <Pine.LNX.4.64.0806052355420.2522@wrl-59.cs.helsinki.fi> <1212708571.19522.10.camel@tng>
 <Pine.LNX.4.64.0806061248410.16829@wrl-59.cs.helsinki.fi> <1212772293.23706.22.camel@tng>
 <20080606173339.GA30894@elte.hu> <Pine.LNX.4.64.0806062037240.9424@wrl-59.cs.helsinki.fi>
 <20080606183926.GB12651@elte.hu>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-368817069-1212778513=:9424"
Cc: Patrick McManus <mcmanus@ducksong.com>,
	David Miller <davem@davemloft.net>, peterz@infradead.org,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, rjw@sisk.pl,
	Andrew Morton <akpm@linux-foundation.org>, johnpol@2ka.mipt.ru
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33295 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754800AbYFFTuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2008 15:50:03 -0400
In-Reply-To: <20080606183926.GB12651@elte.hu>
Content-ID: <Pine.LNX.4.64.0806062227352.9424@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-368817069-1212778513=:9424
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0806062200351.9424@wrl-59.cs.helsinki.fi>

On Fri, 6 Jun 2008, Ingo Molnar wrote:

> 
> * Ilpo Järvinen <ilpo.jarvinen@helsinki.fi> wrote:
> 
> > If you want an older kernel, you would have to go basically to 2.6.25 
> > or so.
> 
> correct, that's what i use as fallback, some distro kernel which is 
> 2.6.25 or older.
> 
> but i'm confused a bit, you say v2.6.25-rc6-475-gec3c098 introduced the 
> locking problem - so 2.6.25 is affected as well?

No, you're probably just falling into a git-describe trap I also used
to fall:

ijjarvin@pointhope:~/linux/mainline$ git-log -n 1 --pretty=oneline 
ec3c0982a2dd1e671bad8e9d26c28dcba0039d87 ^v2.6.25 | cat -
ec3c0982a2dd1e671bad8e9d26c28dcba0039d87 [TCP]: TCP_DEFER_ACCEPT updates - 
process as established
ijjarvin@pointhope:~/linux/mainline$ git-log -n 1 --pretty=oneline 
ec3c0982a2dd1e671bad8e9d26c28dcba0039d87 ^v2.6.26-rc1 | cat -
ijjarvin@pointhope:~/linux/mainline$ git-describe 
ec3c0982a2dd1e671bad8e9d26c28dcba0039d87
v2.6.25-rc6-475-gec3c098
ijjarvin@pointhope:~/linux/mainline$ 

The git-describe is not the way one can determine into which mainline
tag a commit was included, it basically just provides the closest tag 
among ancestors, which can be a vastly different one and has _no_ 
relation whatsoever to the tag we'd desire to get. In here, Dave had 
net-2.6 based on 2.5.25-rc6ish (or alternatively last merge to net-2.6 
from Linus' tree's content came from that point of time), but Linus did 
the merge from 2.6.25 but git-describe won't look anything that happens 
after the asked commit. This is similar to the 
bisect-lands-lower-tag-than-select-good-commit-was "mystery" that was 
recently discussed extensively, again the Makefile only tracks ancestors, 
not the future.

If somebody knows a trivial command to get that future information (to
where merged info), I'd pretty interested to hear.

> This is a significant 
> question because the fallback kernel is kernel-2.6.25.3-18.fc9.x86_64 on 
> the 16-way box. (all other build-boxes have 2.6.24 or older as a 
> fallback kernel)

Please do get the receiver state if you still see such problem with it, 
it is also relevant but it a different problem then (I'm yet to analyze 
the data Håkan was collecting, dl it already by didn't even look into 
that yet).

...Or also if you see stuck TCPs with other cases I've told should fix it:

1. 2.6.25 (pre-ec3c to be accurate)
2. 3+1 revert
3. ec3c+locking fix (this is the most unsure one because it still would 
have the reversed socket lock taking order though nothing bad has been 
found by some review neither by me nor Patrick)

Please collect at least /proc/net/tcp and the netstat -np, if there's 
process associated to the flow with _Recv-Q_ (in localhost case there 
are two of them, the other with Send-Q), also where the process is
waiting is useful. Hopefully clear enough now... :-)

> > To summarize. Both 3changes+1fix revert (you refer to it only as 
> > 3-patch revert) _and_ the locking fix I made should fix the problem 
> > (obviously they exclude each other). ...And end which is significant 
> > is the one which has LISTENing sockets (please keep this in mind if 
> > you still get the hang and provide some info).
> 
> ok.
> 
> For completeness, let me repeat the patch i referred to as the 
> '3-patch-revert' below. (which indeed is 3+1 as you note)

...I know because there never have been any 3-patch-revert made... :-)

> this is the patch that appears to be working empirically. (Disclaimer: 
> it might just hide the problem, change timings, have a lucky code 
> layout, etc.)

Sure, but the revert also removes the obvious locking problem that was 
introduced in ec3c.


--
 i.

---696208474-368817069-1212778513=:9424--
