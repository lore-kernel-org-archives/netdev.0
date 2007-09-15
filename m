From: Andreas Dilger <adilger@clusterfs.com>
Subject: Re: Distributed storage. Move away from char device ioctls.
Date: Sat, 15 Sep 2007 11:51:08 -0600
Message-ID: <20070915175108.GD2990@schatzie.adilger.int>
References: <20070914185429.GA9439@2ka.mipt.ru> <46EADC02.9070409@garzik.org> <20070915135633.GA19482@lemming.cita.utoronto.ca> <46EBEDA4.3070103@garzik.org> <20070915162056.GA31576@lemming.cita.utoronto.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Robin Humble <rjh@cita.utoronto.ca>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070915162056.GA31576@lemming.cita.utoronto.ca>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sep 15, 2007  12:20 -0400, Robin Humble wrote:
> On Sat, Sep 15, 2007 at 10:35:16AM -0400, Jeff Garzik wrote:
> >Lustre is tilted far too much towards high-priced storage,
> 
> many (most?) Lustre deployments are with SATA and md raid5 and GigE -
> can't get much cheaper than that.

I have to agree - while Lustre CAN scale up to huge servers and fat pipes,
it can definitely also scale down (which is a LOT easier to do :-).  I can
run a client + MDS + 5 OSTs in a single UML instance using loop devices
for testing w/o problems.

> interestingly, one of the ways to provide dual-attached storage behind
> a failover pair of lustre servers (apart from buying SAS) would be via
> a networked-raid-1 device like Evgeniy's, so I don't see distributed
> block devices and distributed filesystems as being mutually exclusive.

That is definitely true, and there are a number of users who run in
this mode.  We're also working to make Lustre handle the replication
internally (RAID5/6+ at the OST level) so you wouldn't need any kind of
block-level redundancy at all.  I suspect some sites may still use RAID5/6
back-ends anyways to avoid performance loss from taking out a whole OST
due to a single disk failure, but that would definitely not be required.

> >and needs improvement before it could be considered for mainline.

It's definitely true, and we are always working at improving it.  It
used to be in the past that one of the reasons we DIDN'T want to go
into mainline was because this would restrict our ability to make
network protocol changes.  Because our install base is large enough
and many of the large sites with mutliple supercomputers mounting
multiple global filesystems we aren't at liberty to change the network
protocol at will anymore.  That said, we also have network protocol
versioning that is akin to the ext3 COMPAT/INCOMPAT feature flags, so
we are able to add/change features without breaking old clients

> from what I understand (hopefully I am mistaken) they consider a merge
> task to be too daunting as the number of kernel subsystems that any
> scalable distributed filesystem touches is necessarily large.

That's partly true - Lustre has its own RDMA RPC mechanism, but it does
not need kernel patches anymore (we removed the zero-copy callback and
do this at the protocol level because there was too much resistance to it).
We are now also able to run a client filesystem that doesn't require any
kernel patches, since we've given up on trying to get the intents and
raw operations into the VFS, and have worked out other ways to improve
the performance to compensate.  Likewise with parallel directory operations.

It's a bit sad, in a way, because these are features that other filesystems
(especially network fs) could have benefitted from also.

> roadmaps indicate that parts of lustre are likely to move to userspace
> (partly to ease solaris and ZFS ports) so perhaps those performance
> critical parts that remain kernel space will be easier to merge.

This is also true - when that is done the only parts that will remain
in the kernel are the network drivers.  With some network stacks there
is even direct userspace acceleration.  We'll use RDMA and direct IO to
avoid doing any user<->kernel data copies.

Cheers, Andreas
--
Andreas Dilger
Principal Software Engineer
Cluster File Systems, Inc.

