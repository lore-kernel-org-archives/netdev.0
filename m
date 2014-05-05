From: Andi Kleen <andi@firstfloor.org>
Subject: RFC: A reduced Linux network stack for small systems
Date: Mon,  5 May 2014 15:25:49 -0700
Message-ID: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, tom.zanussi@linux.intel.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There has been a lot of interest recently to run Linux on very small systems,
like Quark systems. These may have only 2-4MB memory. They are also limited
by flash space.

One problem on these small system is the size of the network stack.
Currently enabling IPv4 costs about 400k in text, which is prohibitive on
a 2MB system, and very expensive with 4MB.

There were proposals to instead use LWIP in user space. LWIP with 
its socket interface comes in at a bit over 100k overhead per application.

I maintain that the Linux network stack is actually not that bloated,
it just has a lot of features :-)  The goal of this project was to
subset it in a sensible way so that the native kernel stack becomes
competitive with LWIP.

It turns out that the standard stack has a couple of features that
are not really needed on client systems. Luckily it is also 
relatively well modularized, so it becomes possible to stub
out these features at the edge.

With removing these features we still have a powerful TCP/IP stack,
but one that fits better into small systems.

It would have been prohibitive to ifdef every optional feature.
This patchkit relies heavily on LTO to effectively remove unused
code. This allows to disable features only at the module boundaries,
and rely on the compiler to drop unreferenced code and data.

A few features have been also reimplemented in a simpler way.
And I shrank a number of data structures based on CONFIG_BASE_SMALL.

With these changes I can get a fully featured network stack down
to about 170k with LTO. Without LTO there are also benefits,
but somewhat less.

There are essentially three sensible configurations:
- Full featured like today.
- Client only subset, but still works with standard distribution userland.
Remove some obscure features like fastopen, make all tables smaller, 
packet socket mmap code, use a simpler routing table, remove
high speed networking features like RPX, XPS, GRO offload. 
Disable SNMP, TCP metrics
- Minimal subset for deeply embedded systems that can use special userland.
Remove rtnetlink (ioctl only), remove ethtool, raw sockets.

Right now I'm using own Kconfigs for every removed features. I realize
this somewhat increases the compile test matrix. It would be possible
to hide some of the options and select them using higher level
configurations like the ones listed above. I haven't done this
in this version.

At this point I'm mainly interested in review and comments.

Git trees:

git://git.kernel.org/pub/scm/linux/kernel/git/ak/linux-misc net/debloat
Main tree

git://git.kernel.org/pub/scm/linux/kernel/git/ak/linux-misc net/debloat-3.14
3.14 based tree.

Thanks to Tom Zanussi for contributions and testing.

Andi Kleen
