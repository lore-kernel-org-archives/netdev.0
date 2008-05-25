From: Theodore Tso <tytso@MIT.EDU>
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses of
	IRQF_SAMPLE_RANDOM
Date: Sun, 25 May 2008 19:27:12 -0400
Message-ID: <20080525232712.GF5970@mit.edu>
References: <482C7E53.3050300@hp.com> <482C8184.2030906@garzik.org> <482C8550.5000909@intel.com> <482C8D4D.3040702@garzik.org> <20080516132107.GA11304@csclub.uwaterloo.ca> <20080516161029.44ded734@core> <20080516173610.GA27126@csclub.uwaterloo.ca> <20080516191125.46f59ad6@core> <a24804730805162155m72e6b40aweb8822515c880c50@mail.gmail.com> <1211728189.5913.71.camel@andromache>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Peterson <cpeterso@cpeterso.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Lennart Sorensen <lsorense@csclub.uwaterloo.ca>,
	Jeff Garzik <jeff@garzik.org>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Rick Jones <rick.jones2@hp.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Glen Turner <gdt@gdt.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from BISCAYNE-ONE-STATION.MIT.EDU ([18.7.7.80]:64258 "EHLO
	biscayne-one-station.mit.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750849AbYEYX20 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 May 2008 19:28:26 -0400
Content-Disposition: inline
In-Reply-To: <1211728189.5913.71.camel@andromache>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 26, 2008 at 12:39:49AM +0930, Glen Turner wrote:
> 
> For example, /dev/random has run out. So the output of /dev/urandom
> is now determined by previous values of /dev/random.  I then send in
> a stack of network packets at regular intervals. So the output of
> /dev/urandom is now greatly determined by those packets.  My search
> space for the resulting key is small since /dev/urandom appears to
> be random, but in fact is periodic.

That's not how it works.  Basically, as long as there is *some*
entropy in the system, even from the /var/lib/random-seed, or from
keyboard interrupts, or from mouse interrupts, which is unknown to the
attacker, in the worse case /dev/urandom will be no worse than a
cryptographic random number generator.

Even if you feed it huge amounts of known data, it won't allow you to
"influence" the cryptographic random number generator --- unless of
course SHA-1 is totally and thoroughly broken as a cryptographic hash
algorithm (invalidating all public key certificates and digital
signatures made using SHA-1 algorithm).

There is a reason why /dev/random is world-writeable; it's perfectly
safe to write arbitary amounts of data into /dev/random.  If the
attacker doesn't know what has been fixed into the entropy pool, his
life just got a lot harder.  If it is the attacker mixing known data
into the pool, it's no worse.

The problems with /dev/urandom only appear if there *all* of the data
is known by the attacker --- so all of the keyboard interrupts, all of
the network interrupts, all of the mouse interrupts, the initial
random seed file --- everything.  In practice the time when this has
come up is very early in the initial install process, where there is
no random seed file, and before any interrupt entropy has had a chance
to be mixed into the pool, particularly if it is a headless (i.e., no
keyboard, no mouse, no monitor) install process.

And here there is no magic bullet.  If you are doing a headless
install, and there is no entropy, and you don't have a way of
accessing a real hardware random number generator, THIS IS NOT THE
RIGHT TIME TO BE GENERATING SSH HOST KEYS.  

> I'll also note that there is a huge number of periodic packets seen by
> hosts on quiet networks -- such as a preparation VLAN where a system
> administrator might choose to run up a new machine.

If the attacker has the power to monitor your preparation/installation
network exactly when the machine is being installed, you probably have
worse problems on your hands --- for example, most distribution
installs off of CD include the RPM, and then get on the network to
grab the security updates.  If you have an attacker on your
preparation/install VLAN, they might be able to attack your machine
and install rootkit before you have a chance to install the security
errata RPM's.  That would be much simpler than trying to record all of
the network packet arrival times so you can try to guess the random
number generator!

		      	     	     	- Ted
