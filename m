From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/2] POHMELFS - network filesystem with local coherent cache.
Date: Fri, 1 Feb 2008 10:39:46 +0300
Message-ID: <20080201073946.GA893@2ka.mipt.ru>
References: <11972872493911@2ka.mipt.ru> <Pine.LNX.4.64.0802010159460.4864@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Jan Engelhardt <jengelh@computergmbh.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:49707 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934804AbYBAHkJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 02:40:09 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802010159460.4864@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Fri, Feb 01, 2008 at 02:04:39AM +0100, Jan Engelhardt (jengelh@computergmbh.de) wrote:
> >POHMELFS stands for Parallel Optimized Host Message Exchange
> >Layered File System. It allows to mount remote servers to local
> >directory via network. This filesystem supports local caching
> >and writeback flushing.
> >POHMELFS is a brick in a future distributed filesystem.
> 
> A brick is usually something that is in the way -
> Or you also say "the user has bricked his machine"
> when it's quite unusable :)
> Hope you did not mean /that/.

No, this brick as a building block :)

> >This set includes two patches:
> > * network filesystem with write-through cache (slow, but works with
> > 	remote userspace server)
> > * hack to show how local cache works and how faster it is compared
> > 	to async NFS (see below). hack disables writeback flush and
> >	performs local allocation of the objects only.
> >
> >Now, some vaporware aka food for thoughts and your brains.
> >
> >A small benchmark of the local cached mode (above hack):
> >
> >$ time tar -xf /home/zbr/threading.tar
> >
> >	POHMELFS	NFS v3 (async)
> >real    0m0.043s	0m1.679s
> >
> >Which is damn 40 times!
> 
> Needs a bigger data set to compare. But what is much more
> important: does it use a single port for networing, or some
> firewall-unfriendly-by-default multiple dynamic-port-allocation
> like NFS?

It uses single port, configurable at mount time.
POHMELFS client can connect to different addresses (including ipv6) and
via different protocols (like sctp). Metadata server will provide that
information dynamically, so pohmelfs client will be able to connect to
different nodes and perform operations in parallell.

> >Next task is to think about how to generically solve the problem with
> >syncing local changes with remote server, when remote server maintains inodes with
> >completely different numbers.
> >This, among others, will allow offline work with automatic syncing after reconnect.
> 
> What will happen when both nodes change an inode in disconnected state?
> Which inode wins out?

Who will be online first. Second node will be told that there is a
merge collision and it has to be resolved by hands.

> >This is not intended for inclusion, CRFS by Zach Brown is a bit ahead of POHMELFS,
> >but it is not generic enough (because of above problem), works only with BTRFS,
> >and was closed by Oracle so far :)
> 
> btrfs is all we need :p

Well, at least it has some very interesting ideas.
Although there are things which are not that good imho, time will
show, maybe there will be another state-of-the-art filesystem at the
moment...

This was for information.
 
> Where's the parallelism that is advertised by the "POH" in pohmelfs?

First, clients work with local caches and sync them either in writeback
or via cache coherency algorithm. This work is effectively parallel.
Second, pohmelfs as in distributed filesystem is developed as a transport
layer to eliminate mount operation for each different node, so that
after client asks for data it would be just sent to different server.
This allows to make parallel transactions. Essentially it looks like
mounting different remote server to virtual directory working with it,
except that connection setup should be done not at mount time, but at
run time.

-- 
	Evgeniy Polyakov
