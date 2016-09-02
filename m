From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: possible circular locking dependency detected
Date: Fri, 2 Sep 2016 18:02:56 +0100
Message-ID: <20160902170256.GU2356@ZenIV.linux.org.uk>
References: <6f7d587b-3933-7c02-a804-db1732ced1cf@stressinduktion.org>
 <CA+55aFyNJg_brA4rGF0S2ve0V_2vuhZCFKEMFDNhHKEXoVCRGA@mail.gmail.com>
 <20160901204746.GR2356@ZenIV.linux.org.uk>
 <CA+55aFxzRnLCev6i_ehw9LFf-dw3s0znF+nP_c86i=219OZhfg@mail.gmail.com>
 <20160901210142.GS2356@ZenIV.linux.org.uk>
 <CA+55aFzxJM4pbS_jySERnCoOvvPbo+FgM7FZEATLJnCseD0j0g@mail.gmail.com>
 <CA+55aFwntZpaAutp_C=sLBg8ravfYGRoF4TTG1cfE3SjaJEOtw@mail.gmail.com>
 <87lgzae3f7.fsf@doppelsaurus.mobileactivedefense.com>
 <20160902160026.GT2356@ZenIV.linux.org.uk>
 <87d1kme10a.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        CAI Qian <caiqian@redhat.com>,
        Miklos Szeredi <miklos@szeredi.hu>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Rainer Weikusat <rweikusat@mobileactivedefense.com>,
        Eric Sandeen <esandeen@redhat.com>,
        Network Development <netdev@vger.kernel.org>
To: Rainer Weikusat <rweikusat@cyberadapt.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:58812 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932236AbcIBRDD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 13:03:03 -0400
Content-Disposition: inline
In-Reply-To: <87d1kme10a.fsf@doppelsaurus.mobileactivedefense.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 02, 2016 at 05:10:13PM +0100, Rainer Weikusat wrote:

> > Bullshit.  kern_path_create() *does* mean the same thing in all cases.
> > Namely, find the parent, lock it and leave the final name component for
> > the create-type operation.  It sure as hell is not guaranteed to take
> > *all* locks that are going to be taken in process of mknod/mkdir/etc.
> > Never had been.
> 
> This isn't about "all locks", it's about the lock in question. No other
> mknod operation (I'm aware of) calls this with another superblock than
> the one already acted upon by kern_path_create. This may be wrong (if
> so, feel free to correct it) but it's not "bullshit" (intentional
> deception in order to sell something to someone).
> 

Never had been promised.  And it's not just this lock - e.g. ->i_rwsem is
taken on the parent by kern_path_create() and on parent in underlying
filesystem by ecryptfs ->mknod() (as well as overlayfs one).  bind/bind
deadlock - one for a path to ecryptfs, another for that on the raw
filesystem behind it (which can be mounted elsewhere/in another namespace/etc.)
with those paths ending in the matching directories (the last components may
be same or different - doesn't matter)

A: lock parent in ecryptfs (via kern_path_create())
B: lock the directory behind it in underlying fs (ditto)
A: grab ->readlock
B: block on ->readlock
A: call ecryptfs_mknod() and block trying to lock the directory held by B

Deadlock.  And while we are at it, ecryptfs probably ought to claim transient
write access for the duration of modifications of the underlying one similar
to overlayfs.  The point is, it had never been promised that you can stick
random locks just outside of ->mknod()/->mkdir()/etc.  The same goes for e.g.
NFS mount of something exported by localhost; knfsd must lock the parent
directory on server before creating anything in it.  Suppose you have
/srv/nfs/foo exported and mounted on the same host at /mnt/bar.  bind to
/mnt/bar/barf/a vs. bind to /srv/nfs/foo/barf/b:
A: lock /mnt/bar/barf
B: lock /srv/nfs/foo/barf
A: grab ->readlock
B: block on ->readlock
A: call nfs_mknod(), wait for reply
knfsd: block trying to lock /srv/nfs/foo/barf

It's very much _not_ just overlayfs being pathological - that it certainly is,
but the problem is much wider.  You could try to argue that kern_path_create()
should've known to lock all relevant directories in case of overlayfs and
ecryptfs, but it has absolutely no chance to do that in case of NFS - the
protocol doesn't allow "lock this directory, one of my next requests will
be to create something in it".  Even leases are only for regular files...
