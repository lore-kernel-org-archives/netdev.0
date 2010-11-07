From: Urs Thuermann <urs@isnogud.escape.de>
Subject: Re: [PATCH 0/9] Fix leaking of kernel heap addresses in net/
Date: 07 Nov 2010 22:53:54 +0100
Message-ID: <ygfwroodclp.fsf@janus.isnogud.escape.de>
References: <1289147492.3090.137.camel@Dan>
	<1289149416.2478.143.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Rosenberg <drosenberg@vsecurity.com>, chas@cmf.nrl.navy.mil,
	davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	remi.denis-courmont@nokia.com, netdev@vger.kernel.org,
	security@kernel.org, stable@kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:40891 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752368Ab0KGWE7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Nov 2010 17:04:59 -0500
In-Reply-To: <1289149416.2478.143.camel@edumazet-laptop>; from Eric Dumazet on Sun, 07 Nov 2010 18:03:36 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> You are basically ruining a lot of debugging facilities we use every
> day to find and fix _real_ bugs. The bugs that happen to crash
> machines of our customers.
> 
> If you want to avoid a user reading kernel syslog, why dont you fix
> the problem for non root users able to "dmesg" ? I personally dont
> care.

dmesg and syslog aren't the only problem.  There are files in
/proc/net/ that must be readable by all users in order for a number of
tools to work, e.g. netstat(8), and those files contain kernel
addresses of sock structs.

> There are pretty easy ways to not disclose "information", but your
> way of using '0' for all values is the dumbest idea one could ever
> had.
> 
> A single XOR with a "root only visible, random value chosen at boot"
> would be OK. At least we could continue our work, with litle burden.

Simple XOR with a secret constant doesn't help very much.  Many bits
of that hidden constant can be revealed quite easily.  On x86-32 for
example all addresses are in the high 1 GB address space so the
highest two address bits are 1.  Many structs of type sock are aligned
to 64 or higher powers of two so you can easily infer the lower 6 or
more bits of that hidden XOR constant.  If you know two structs of
alignment 2^n are contiguous in memory you can infer the lower n+1
bits.

I suggest either one of the following two solutions:

1. Make the contents of the proc-files in question dependent on some
   capability, e.g. CAP_SYS_ADMIN or some new CAP_KERNEL_DEBUG.  If
   the process opening the file owns that capability it will see the
   kernel address, otherwise it will see 0.

2. Replace the kernel address by the socket inode number or some other
   identifying value (as our patch for CAN does) and provide some
   mechanism for root only to translate that value to the
   corresponding kernel address.


urs
