From: "Jesper Juhl" <jesper.juhl@gmail.com>
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses of IRQF_SAMPLE_RANDOM
Date: Fri, 16 May 2008 00:57:40 +0200
Message-ID: <9a8748490805151557g5031ad0dr22b75980161f31b6@mail.gmail.com>
References: <Pine.LNX.4.62.0805150009060.18303@ikari.dreamhost.com>
	 <20080515142154.0595e475@core>
	 <36D9DB17C6DE9E40B059440DB8D95F52052D71BB@orsmsx418.amr.corp.intel.com>
	 <20080515215517.GI1936@cs181133002.pp.htv.fi>
	 <9a8748490805151513j74f9b99dla900ebc636941636@mail.gmail.com>
	 <20080515223443.GR18825@mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "Theodore Tso" <tytso@mit.edu>,
	"Jesper Juhl" <jesper.juhl@gmail.com>,
	"Adrian Bunk" <bunk@kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Alan Cox" <alan@lxorguk.uku
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:8007 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761022AbYEOW5m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 18:57:42 -0400
Received: by yw-out-2324.google.com with SMTP id 9so365185ywe.1
        for <netdev@vger.kernel.org>; Thu, 15 May 2008 15:57:41 -0700 (PDT)
In-Reply-To: <20080515223443.GR18825@mit.edu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2008/5/16 Theodore Tso <tytso@mit.edu>:
> On Fri, May 16, 2008 at 12:13:39AM +0200, Jesper Juhl wrote:
>> My point is that the rate (and timing between) syscalls is depending
>> on very many factors; the kernel version (and configuration), the
>> software installed, the software currently executing, the state of the
>> software currently executing, the number of apps executing, the amount
>> of network traffic, the accuracy of the hardware clock, the speed of
>> (various) IO sources (network, disk, USB, etc), the speed (and type)
>> of the CPU, the speed of memory. And various other things.
>
> It Depends.
>
> For certain workloads, a lot of these issues might just boil out, or
> not result in as much entropy as you think.  Think about a certificate
> server which doesn't get much traffic, but when it is contacted, it is
> expected to create new high security RSA keys and the public key
> certificates to go with it.  If the attacker knows the machine type,
> distribution OS loaded, etc., it might not be that hard to brute force
> guess many of the factors you have listed above.
>

Hmm, I would like to know how you'd do that.
Even if you a) know the exact distro installed (and the configuration,
b) know the exact hardware in the machine, c) know the exact time it
was booted and know that there have been no ssh logins or similar that
might have generated syscalls, d) know exactely how many requests (and
of what type) have been made to the server and the exact times they
were made.
How would you go about brute force guessing the contents of the entropy pool?

If the server does, for example, this; every second it samples the
number of syscalls made during that second and uses that number as the
base of adding one or two bits of entropy. Every time a syscall is
made it uses the "time since last syscall in 'us'" to add one bit of
entropy to the pool. I'd say that even if that server sees very little
(and even predictable) traffic, we may have; details of the filesystem
layout on disk, a timer interrupt happening a few microseconds early
due to a flaky chip, a background process initiating some action a
millisecond early/late for scheduling reasons, the switch the machine
is connected to causing a network packet to arrive a tiny bit later
than normal and various other factors like that, to cause the
generated entropy to be off by a bit or two compared to your guess -
and by the time you realize you are off, another spurrious event has
probably happened, so you'll never end up in-sync with the entropy
pool...  Or is there some "obvious entropy pool guessing method" that
I'm just not aware of???


> Basically the question has always been one of the overhead to collect
> and boil down any input data (which after all, any user space process
> can send arbitrary data into the entropy pool via "cat my_secret_data
>> /dev/random") which will never hurt and might help.  The tricky bit
> is estimating how much "entropy" should be ascribed to data which is
> sent into the entropy pool, and this is where you have to be very
> careful.
>
Yes, I'm aware of that, and I'm not suggesting to use syscall rates as
a generator of high amounts of high quality entropy. Im merely
suggesting that sampling syscall rates and time-between and using
those numbers as the source of very low amounts of low quality entropy
might be worth-while. It wouldn't hurt on machines that have other,
higher quality, entropy sources. On machines that have no other
entropy sources it would ensure that we always have a steady (although
slow) trickle of new entropy info available...

> If you screw the entropy credit information then security of
> /dev/random will be impacted.  /dev/urandom won't be impacted since it
> doesn't care about the entropy estimation.  That's why only root is
> allowed to use the ioctl which atomically sends in some "known to be
> random" data and the entropy credit ascribed to that data.
>
I'm only talking about providing some data for /dev/random here.

-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please http://www.expita.com/nomime.html
