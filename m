From: Christian Lamparter <chunkeey@googlemail.com>
Subject: Re: PROBLEM: network data corruption (bisected to e5a4b0bb803b)
Date: Tue, 26 Jul 2016 15:59:53 +0200
Message-ID: <2589898.190WVraD7Z@debian64>
References: <201607260457.u6Q4v3pM010082@sdf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	Christian Lamparter <chunkeey@googlemail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, alexmcwhirter@triadic.us
To: Alan Curry <rlwinm@sdf.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201607260457.u6Q4v3pM010082@sdf.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday, July 26, 2016 4:57:03 AM CEST Alan Curry wrote:
> Al Viro wrote:
> > On Sun, Jul 24, 2016 at 07:45:13PM +0200, Christian Lamparter wrote:
> > 
> > > > The symptom is that downloaded files (http, ftp, and probably other
> > > > protocols) have small corrupted segments (about 1-2 kilobytes long) in
> > > > random locations. Only downloads that sustain a high speed for at least a
> > > > few seconds are corrupted. Anything small enough to be received in less
> > > > than about 5 seconds is not affected.
> > 
> > Can that sucker be reproduced with netcat?  That would eliminate all issues
> > with multi-iovec recvmsg(2), narrowing the things down quite bit.
> 
> netcat seems to be immune. Comparing strace results, I didn't see any
> recvmsg() calls in the other programs that have had the problem, but there
> is an interesting difference: netcat calls select() to wait for the socket
> to be ready for reading, where my other test programs just call read() and
> let it block until ready.
> 
> So I wrote a small test program to isolate that difference. It downloads
> a file using only read() and write() and a hardcoded HTTP request. It has
> a select mode (main loop alternates read() and select() on the TCP socket)
> and a noselect mode (main loop just read()s the TCP socket).
> 
> The program is included at the bottom of this message.
> 
> I ran it several times in both modes and got corruption if and only if the
> noselect mode was used.
> 
> > 
> > Another thing (and if that works, it's *NOT* a proper fix - it would be
> > papering over the problem, but at least it would show where to look for
> > it) - try (on top of mainline) the following delta:
> > 
> > diff --git a/net/core/datagram.c b/net/core/datagram.c
> 
> Will try that patch soon. Meanwhile, here's my test:
> 
> /* Demonstration program "dlbug".
>    Usage: dlbug select > outfile
>           or
>           dlbug noselect > outfile
>    outfile will contain the full HTTP response. Edit out the HTTP headers
>    and what's left should be a valid gzip if the download worked. */
> [...]
Thanks, I gave the program a try with my WNDA3100 and a WN821N v2 devices.
I did not see any corruptions in any of the tests though. Can you tell me
something about your wireless network too? I would like to know what router
and firmware are you using? Also important: what's your wireless configuration?
(WPA?, CCMP or TKIP? HT40, HT20 or Legacy rates? ...)

Probably the quickest and easiest way to get that information is by running
the following commands as root, when you are connected to your wifi network
and post the results:
# iw dev wlan0 link
# iw dev wlan0 scan dump

(You can of course remove your device's MACs, but please do it consistently).

Regards,
Christian
