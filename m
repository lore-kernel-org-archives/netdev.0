From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] sch_htb.c consume the classes's tokens bellow the
 HTB_CAN_SEND level
Date: Wed, 4 Nov 2009 00:00:35 +0100
Message-ID: <20091103230035.GA2352@ami.dom.local>
References: <4AEF9862.8040404@gmail.com>
 <20091103080022.GA6718@ff.dom.local>
 <412e6f7f0911030147k659e0079ibd1f424fef0a487f@mail.gmail.com>
 <20091103100538.GC6718@ff.dom.local>
 <412e6f7f0911030518w7a5f02a4ue8a4b6539496dd8f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@cyberus.ca>, devik@cdi.cz,
	netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:41525 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751039AbZKCXBN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 18:01:13 -0500
Received: by bwz27 with SMTP id 27so8200717bwz.21
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2009 15:01:17 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <412e6f7f0911030518w7a5f02a4ue8a4b6539496dd8f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 03, 2009 at 09:18:49PM +0800, Changli Gao wrote:
> On Tue, Nov 3, 2009 at 6:05 PM, Jarek Poplawski <jarkao2@gmail.com> wrote:
> >
> > The ceil specification is controlled only by ctokens, which are always
> > updated, so no such risk.
> >
> Nevertheless, updating tokens is necessary too.

If it's really necessary you should present some test case fixed by
your patch, I guess.

In the meantime let's consider what could be broken:
class 1:1 (parent) rate 10 packets/sec
class 1:2 rate 5 packets/sec ceil 10 packets/sec
class 1:3 rate 5 packets/sec ceil 10 packets/sec

class 1:2 doesn't use all its rate, and sends every other second
	(in even seconds)
class 1:3 sends 10 packets during the first second, so with your
	patch it will use its tokens for 2 seconds
class 1:2 uses its rate in the second second..., so class 1:1
	can't lend anything
class 1:3 can only borrow, so it won't be able to send during
	this second anything

So, the effect would be class 1:3 sending every odd second 10 packets
while every even second - nothing...

Of course the example is a simplification of the htb algorithm. There
should be also considered priority of borrowing, which should add
similar effects even with regular traffic. But generally the
guaranteed rates would be simply...  less guaranteed.

Regards,
Jarek P.
