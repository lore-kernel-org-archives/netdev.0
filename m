From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Thu, 19 Nov 2015 18:25:33 -0800
Message-ID: <CAHo-OoyN7OgvHSuXxjk7C4FitXhoWffOxY1wkQBWwi+nc013_w@mail.gmail.com>
References: <CAKD1Yr2OgJT0GsrTuws0oapobrU+ML3NpBNBXizg6q035PH4MA@mail.gmail.com>
	<20151119.005318.838757439536205791.davem@davemloft.net>
	<CANP3RGcPRzSL06qZB9oewrvN_AUUodnYzXQO=itoK40z64x8Yw@mail.gmail.com>
	<20151119.104811.1447518072450380661.davem@davemloft.net>
	<1447949964.22599.220.camel@edumazet-glaptop2.roam.corp.google.com>
	<CALx6S363gYA37GnEuArp+PKVjFdLchB_66zuLF5kJnSFKF4t6Q@mail.gmail.com>
	<1447969264.22599.253.camel@edumazet-glaptop2.roam.corp.google.com>
	<CALx6S374xUUzWXUgA27PubceyDckrrfTiq7wvkLxXa0NacqqZA@mail.gmail.com>
	<1447970875.22599.265.camel@edumazet-glaptop2.roam.corp.google.com>
	<CALx6S35CxmsN6Cx0BXCyqzWE67HF9SwTPAyzRnbVFKun8AOTYQ@mail.gmail.com>
	<1447972381.22599.278.camel@edumazet-glaptop2.roam.corp.google.com>
	<CALx6S35Q_pc-vBNpA0hipn5K-vSmPDsV-V=D13sODESNO7Htdw@mail.gmail.com>
	<CAKD1Yr1JWP4jsRHd41NMHZsNbK5_b_kG=Z3AWYd=YpHwpgDgFg@mail.gmail.com>
	<CALx6S36U1e14JEH1bBaJDg3xGRxtnr=7u94opFbD2M0mJhedwQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Lorenzo Colitti <lorenzo@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Erik Kline <ek@google.com>,
	Dmitry Torokhov <dtor@google.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:33186 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934033AbbKTCZf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 21:25:35 -0500
Received: by lbbkw15 with SMTP id kw15so54464761lbb.0
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 18:25:34 -0800 (PST)
In-Reply-To: <CALx6S36U1e14JEH1bBaJDg3xGRxtnr=7u94opFbD2M0mJhedwQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> No, I mean something that kills connections where previously this did
> not happen. The fact that this is done at the process level does not
> justify that it is a right to at do connections. Besides, if you
> really intend to do this then provide a privileged process a means to
> close *any* open file descriptor in the system (why stop at TCP
> sockets)!

There is little reason to be able to kill random processes arbitrary
file descriptors,
while there is ample reason to be able to kill network connections.

Network connections can already (and often are) be killed by the network, but
that's far less true for files (although IO errors and emergency fs remount r/o
can cause similar behaviour).

Userspace doesn't expect file descriptors to local files to suddenly break,
while it already has to handle network connections timing out and the like.

Perhaps we shouldn't be using the word 'kill'.  We're not really killing
these sockets, nor closing them, we just need an out-of-band mechanism
for flagging them with some sort of error (ie. force timing them out, or force
resetting them).

That said, one can certainly come up with cases where killing arbitrary file
descriptors would make sense (or more likely switching them from r/w to r/o
mode or replacing them with some sort of /dev/null like file
descriptor instead).
Example use cases would be umounting a removable usb key which is in the
process of being pulled out of the machine (or was already pulled
out), or remounting
a file system readonly (which still has r/w open files).
