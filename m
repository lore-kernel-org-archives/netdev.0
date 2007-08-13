From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: ATA over ethernet swapping
Date: Mon, 13 Aug 2007 09:45:57 +0200
Message-ID: <1186991157.20108.47.camel@twins>
References: <20070731135831.GA4604@elf.ucw.cz>
	 <20070731150324.GE3206@coraid.com> <20070731152924.GM2087@elf.ucw.cz>
	 <20070731162140.GI3206@coraid.com> <20070731222742.GR2087@elf.ucw.cz>
	 <1185959909.12034.38.camel@twins>  <20070809101105.GA7581@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Ed L. Cashin" <ecashin@coraid.com>,
	kernel list <linux-kernel@vger.kernel.org>, ak@suse.de,
	Netdev list <netdev@vger.kernel.org>
To: Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:48064 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S942593AbXHMHqG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Aug 2007 03:46:06 -0400
In-Reply-To: <20070809101105.GA7581@elf.ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-08-09 at 12:11 +0200, Pavel Machek wrote:
> Hi!
> 
> > I've been working on this for quite some time. And should post again
> > soon. Please see the patches:
> > 
> >   http://programming.kicks-ass.net/kernel-patches/vm_deadlock/current/
> > 
> > For now it requires one uses SLUB, I hope that SLAB will go away (will
> > save me the trouble of adding support) and I guess I ought to do SLOB
> > some time (if that does stay).
> > 
> > You'd need the first 22 patches of that series, and then call
> > sk_set_memalloc(sk) on the proper socket, and do some fiddling with the
> > reconnect logic. See nfs-swapfile.patch for examples.
> 
> What do you use for testing? I set up ata over ethernet... swapping
> over that should deadlock w/o your patches.
> 
> But I'm able to compile kernel (-j 10) on 128MB machine, and I tried
> cat /dev/zero | grep foo to exhaust memory... and could not reproduce
> the deadlock. Should I pingflood? Tweak down ammount of atomic memory
> avaialable to make deadlocks easier to reproduce?

I usually test swap over NFS in the following manner, I setup a regular
inet service on the machine (apache or a bunch of ncat sockets piping to
files or something) and run a heavy workload on the machine (128M):
2*64M file backed thrashers and 2*64M anonymous thrashers. Then I start
clients for the regular inet service, wait for a bit, and shut down the
NFS server.

This makes the machine grind to a halt, I then restart the NFS server,
wait for it to reconnect and the client to come alive again.

Without the last few swap-over-NFS patches this last bit - getting back
out of that situation - never happens.

The basic idea is to make connectivity to the machine where swap traffic
goes very hard (pull a cable, cleanly shut down the server) and to keep
other network traffic pounding the machine.

