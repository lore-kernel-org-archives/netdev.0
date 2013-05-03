From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH net-next] af_unix: fix a fatal race with bit fields
Date: Fri, 03 May 2013 22:57:27 +1000
Message-ID: <1367585847.4389.65.camel@pasglop>
References: <1367370761.11020.22.camel@edumazet-glaptop>
	 <20130501115103.58e40f37@kryten>
	 <1367375060.11020.24.camel@edumazet-glaptop>
	 <20130501035425.GD5221@bubble.grove.modra.org>
	 <1367384672.11020.34.camel@edumazet-glaptop>
	 <20130503013136.GN5221@bubble.grove.modra.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Ambrose Feinstein <ambrose@google.com>,
	Paul Mackerras <paulus@samba.org>,
	Anton Blanchard <anton@samba.org>,
	linuxppc-dev@lists.ozlabs.org, David Miller <davem@davemloft.net>
To: Alan Modra <amodra@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:51941 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755821Ab3ECM5z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 May 2013 08:57:55 -0400
In-Reply-To: <20130503013136.GN5221@bubble.grove.modra.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-03 at 11:01 +0930, Alan Modra wrote:
> On Tue, Apr 30, 2013 at 10:04:32PM -0700, Eric Dumazet wrote:
> > These kind of errors are pretty hard to find, its a pity to spend time
> > on them.
> 
> Well, yes.  From the first comment in gcc PR52080.  "For the following
> testcase we generate a 8 byte RMW cycle on IA64 which causes locking
> problems in the linux kernel btrfs filesystem."
> 
> Did someone fix btrfs, but not check other kernel locks?  Having now
> hit the same problem again, have you checked that other kernel locks
> don't have adjacent bit fields in the same 64-bit word?  And comment
> the struct to ensure someone doesn't optimize those unsigned chars
> back to bit fields.

Unfortunately, fixing "other" kernel locks is near impossible.

One could try to grep for all spinlock_t and maybe even all atomic_t,
may even write a script to spot automatically if a bitfield appears
to be around (though it could be hidden behind a structure etc...) but
what about an int accessed with cmxchg (a kernel macro doing a
lwarx/stwcx. loop on a value) for example ? There's plenty of these...

I don't think we can realistically "fix" all potential occurrences of
that bug in the kernel short of geting rid of all bitfields, which isn't
going to happen any time soon.

I'm afraid this *must* be fixed at the compiler level, with as backports
much as can realistically be done back to distros.

Ben.
 
