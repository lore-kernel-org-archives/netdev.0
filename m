From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] r8169: keep firmware in memory.
Date: Fri, 14 Jan 2011 08:05:22 -0800
Message-ID: <AANLkTikiGeSfae3guWRMp_hsh61JibacPpwGZVbgSy7h@mail.gmail.com>
References: <20110113230753.GA2750@electric-eye.fr.zoreil.com> <4D2FF29C.1050101@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	=?ISO-8859-2?Q?Jarek_Kami=F1ski?= <jarek@vilo.eu.org>,
	Hayes <hayeswang@realtek.com>, Ben Hutchings <benh@debian.org>
To: Michael Tokarev <mjt@tls.msk.ru>,
	David Woodhouse <dwmw2@infradead.org>,
	Johannes Berg <johannes.berg@intel.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:46111 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757771Ab1ANQGU convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jan 2011 11:06:20 -0500
Received: from mail-iy0-f174.google.com (mail-iy0-f174.google.com [209.85.210.174])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p0EG5inE016527
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Fri, 14 Jan 2011 08:05:44 -0800
Received: by iyj18 with SMTP id 18so2629789iyj.19
        for <netdev@vger.kernel.org>; Fri, 14 Jan 2011 08:05:43 -0800 (PST)
In-Reply-To: <4D2FF29C.1050101@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ background for new people in discussion: once more, a driver resume
didn't get a working firmware load. ]

On Thu, Jan 13, 2011 at 10:52 PM, Michael Tokarev <mjt@tls.msk.ru> wrot=
e:
>
> Given all this I think this is somewhat clumsy still. =A0How
> does other NIC drivers handles this situation - e.g. tg3?
> Maybe this needs to be a generic solution instead of per-driver?

We've had this bug several times - and not just for network drivers
either. It's almost universal that drivers just load their firmware at
initialization, and then don't realize that they need to do it at
resume too and have no filesystems accessible. I think the firmware
access interface is partly to blame, because I suspect both the
documentation and the code (and probably any examples: as mentioned,
this is very common) tends to be about that initial one-shot "bring
the device up" rather than thinking about "oh, resume is a bootup too,
and unlike initial boot, it needs to come up in a configured state".

Maybe the firmware loader could be made more useful to automatically
handle the caching (it already knows about built-in firmware) for the
case where CONFIG_PM is enabled. So that drivers _could_ just
basically do "request_firmware()" in their resume functions, and it
would get satisfied from RAM for the re-request case.

Or maybe we could have some honking big comments, at least ;)

Added some device core/fw-class people to the discussion for comments.
Clearly the fw loading _works_, but it does end up being a common bug
that it's messed up at resume. This time it was the "oh, I moved the
firmware loading around so now it's done at a different stage", but
quite often it's literally just "oh, it never worked, I had just
forgotten about resume".

                       Linus
