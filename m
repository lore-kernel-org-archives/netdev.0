From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [TCP]: TCP_DEFER_ACCEPT causes leak sockets
Date: Tue, 17 Jun 2008 09:26:58 +0200
Message-ID: <20080617072658.GA12535@elte.hu>
References: <20080613.023208.78649628.davem@davemloft.net> <20080613110913.GB9867@elte.hu> <20080613114746.GA27811@elte.hu> <20080616.165900.189566405.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, vgusev@openvz.org, mcmanus@ducksong.com,
	xemul@openvz.org, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:37600 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753359AbYFQH1T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 03:27:19 -0400
Content-Disposition: inline
In-Reply-To: <20080616.165900.189566405.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* David Miller <davem@davemloft.net> wrote:

> From: Ingo Molnar <mingo@elte.hu>
> Date: Fri, 13 Jun 2008 13:47:46 +0200
> 
> > this threw the warning below - never saw that before in thousands of 
> > bootups and this was the only networking change that happened. 
> > config and bootlog attached. Might be unlucky coincidence.
> 
> So that we can make forward progress here, please confirm that the 
> following patch against -tip makes your problems go away for good.
> 
> Once you can confirm I will push it to Linus.

i triggered the net/sched/sch_generic.c:222 warning once more meanwhile 
(yesterday) with the full revert applied (which i think is the same as 
the patch below).

So i think it's either some unlucky coincidence or some timing 
relationship - perhaps the change impacts packet ordering for certain 
workload patterns? [but that same condition can occur without that patch 
too]

I also checked kerneloops.org and this warning seems to have been 
reported by others as well - although it's not triggering heavily. In 
some of those other reports the warning came together with a dead 
interface, while in my case it's just a warning with still working 
networking.

So since there's no clear bug pattern and no sure reproducability on my 
side i'd suggest we track this problem separately and "do nothing" right 
now. I've excluded this warning from my 'is the freshly booted kernel 
buggy' list of conditions of -tip testing so it's not holding me up.

and i can apply any test-patch if that would be helpful - if it does a 
WARN_ON() i'll notice it. (pure extra debug printks with no stack trace 
are much harder to notice in automated tests)

btw., it would be nice if there was some .config driven networking debug 
option that randomized packet ordering in the tx and rx queue. 
(transparently enabled, with zero-config on the userspace side)

I.e. it would have an (expensive, because O(1)) debug mechanism that 
randomized things - it would insert new packets into a random place 
within the queue where it gets queued. We could hit races and rarer 
codepaths much sooner that way - as especially in LAN based testing 
there's a strong natural ordering of packets so randomizing it 
artificially looks promising to me.

If you make that new option =y enable-able in the .config(dependent on 
DEBUG_KERNEL && default off, etc.), and as long as it does not have to 
be configured on the userspace side (i'm testing unmodified userspace 
images with default distro installs, etc.) the randconfig test will 
still be able to reach it in a percentage of the tests and i think we'll 
be able to hit a lot of exciting races much sooner than with the normal 
in-order/FIFO queueing methods.

it's basically massively parallel coverage testing. It doesnt matter how 
unbelievably slow packet ordering randomization might be, the coverage 
testing it would do would be worth gold i'm sure. (I'd love to test 
something like that in -tip, if it comes in form of some standalone 
patch against a mainline-ish tree.)

	Ingo
