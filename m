From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Distributed storage. Move away from char device ioctls.
Date: Sat, 15 Sep 2007 16:29:57 +0400
Message-ID: <20070915122957.GA25752@2ka.mipt.ru>
References: <20070914185429.GA9439@2ka.mipt.ru> <46EADC02.9070409@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:50538 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750927AbXIOMaN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Sep 2007 08:30:13 -0400
Content-Disposition: inline
In-Reply-To: <46EADC02.9070409@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff.

On Fri, Sep 14, 2007 at 03:07:46PM -0400, Jeff Garzik (jeff@garzik.org) wrote:
> >Further TODO list includes:
> >* implement optional saving of mirroring/linear information on the remote
> >	nodes (simple)
> >* new redundancy algorithm (complex)
> >* some thoughts about distributed filesystem tightly connected to DST
> >	(far-far planes so far)
> >
> >Homepage:
> >http://tservice.net.ru/~s0mbre/old/?section=projects&item=dst
> >
> >Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> 
> My thoughts.  But first a disclaimer:   Perhaps you will recall me as 
> one of the people who really reads all your patches, and examines your 
> code and proposals closely.  So, with that in mind...

:)

> I question the value of distributed block services (DBS), whether its 
> your version or the others out there.  DBS are not very useful, because 
> it still relies on a useful filesystem sitting on top of the DBS.  It 
> devolves into one of two cases:  (1) multi-path much like today's SCSI, 
> with distributed filesystem arbitrarion to ensure coherency, or (2) the 
> filesystem running on top of the DBS is on a single host, and thus, a 
> single point of failure (SPOF).
> 
> It is quite logical to extend the concepts of RAID across the network, 
> but ultimately you are still bound by the inflexibility and simplicity 
> of the block device.

Yes, block device itself is not able to scale well, but it is the place
for redundancy, since filesystem will just fail if underlying device
does not work correctly and FS actually does not know about where it
should place redundancy bits - it might happen to be the same broken 
disk, so I created a low-level device which distribute requests itself.
It is not allowed to mount it via multiple points, that is where
distributed filesystem must enter the show - multiple remote nodes
export its devices via network, each client gets address of the remote
node to work with, connect to it and process requests. All those bits
are already in the DST, next logical step is to connect it with
higher-layer filesystem.

> In contrast, a distributed filesystem offers far more scalability, 
> eliminates single points of failure, and offers more room for 
> optimization and redundancy across the cluster.
> 
> A distributed filesystem is also much more complex, which is why 
> distributed block devices are so appealing :)
> 
> With a redundant, distributed filesystem, you simply do not need any 
> complexity at all at the block device level.  You don't even need RAID.
> 
> It is my hope that you will put your skills towards a distributed 
> filesystem :)  Of the current solutions, GFS (currently in kernel) 
> scales poorly, and NFS v4.1 is amazingly bloated and overly complex.
> 
> I've been waiting for years for a smart person to come along and write a 
> POSIX-only distributed filesystem.

Well, originally (about half a year ago) I started to draft a generic
filesystem which would be just superior to existing designs, not
overbloated like zfs, and just faster.
I do believe it can be implemented.
Further I added network capabilities (since what I saw that time 
(AFS was proposed) I did not like - I'm not saying it is bad or 
something like that at all, but I would implement things differently) 
into design drafts.

When Chris Mason announced btrfs, I found that quite a few new ideas 
are already implemented there, so I postponed project (although
direction of the developement of the btrfs seems to move to the zfs side
with some questionable imho points, so I think I can jump to the wagon
of new filesystems right now). 

DST is low level for my (theoretical so far) filesystem (actually its 
network part) like kevent was a low level system for network AIO (originally).

No matter what filesystem works with network it implements some kind 
of logic completed in DST.
Sometimes it is very simple, sometimes a bit more complex, but
eventually it is a network entity with parts of stuff I put into DST.
Since I postponed the project (looking at btrfs and its results), I
completed DST as a standalone block device.

So, essentially, a filesystem with simple distributed facilities is on
(my) radar, but so far you are first who requested it :)

-- 
	Evgeniy Polyakov
