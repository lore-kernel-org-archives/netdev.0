From: Arnd Bergmann <arnd@arndb.de>
Subject: [v2] Remaining BKL users, what to do
Date: Mon, 18 Oct 2010 17:42:06 +0200
Message-ID: <201010181742.06678.arnd@arndb.de>
References: <201009161632.59210.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: autofs@linux.kernel.org, linux-media@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	Christoph Hellwig <hch@infradead.org>,
	Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Petr Vandrovec <vandrove@vc.cvut.cz>,
	Anders Larsen <al@alarsen.net>, Jan Kara <jack@suse.cz>,
	Evgeniy Dushistov <dushistov@mail.ru>,
	Ingo Molnar <mingo@elte.hu>, netdev@vger.kernel.org,
	Samuel Ortiz <samuel@sortiz.org>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Andrew Hendry <andrew.hendry@gmail.com>,
	David Miller <davem@davemloft.net>,
	Jan Harkes <jaharkes@cs.cmu.edu>,
	Bryan Schumaker <bjschuma@netapp.com>
To: codalist@coda.cs.cmu.edu,
	ksummit-2010-discuss@lists.linux-foundation.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <201009161632.59210.arnd@arndb.de>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a update on the current progress for the BKL removal, reflecting
what is currently in linux-next.

Maybe we can briefly discuss this at the kernel summit to decide if we
want a quick death of the BKL, i.e. fixing/disabling/staging-out the
remaining users in 2.6.38 or rather leave them there indefinitely.

On Thursday 16 September 2010, Arnd Bergmann wrote:
> The big kernel lock is gone from almost all code in linux-next, this is
> the status of what I think will happen to the remaining users:
> 
> drivers/gpu/drm/i810/{i810,i830}_dma.c:
> 	Fixable, but needs someone with the hardware to test. Can probably be
> 	marked CONFIG_BROKEN_ON_SMP if nobody cares.

Still open, no good solution for this.

> drivers/media/video (V4L):
> 	Mauro is working on it, some drivers get moved to staging while the
> 	others get fixed. An easy workaround would be possible by adding
> 	per-driver mutexes, but Mauro wants to it properly by locking all
> 	the right places.

Progressing well, patches are being worked on.

> fs/adfs:
> 	Probably not hard to fix, but needs someone to test it.
> 	adfs has only seen janitorial fixes for the last 5 years.
> 	Do we know of any users?

Nobody replied.

> fs/autofs:
> 	Pretty much dead, replaced by autofs4. I'd suggest moving this
> 	to drivers/staging in 2.6.37 and letting it die there.

Now in staging.

> fs/coda:
> 	Coda seems to have an active community, but not all of their
> 	code is actually part of linux (pioctl!), while the last official
> 	release is missing many of the cleanups that were don in Linux.
> 	Not sure what to do, if someone is interested, the best way might
> 	be a fresh start with a merger of the mainline linux and the
> 	coda.cs.cmu.edu	codebase in drivers/staging.
> 	Just removing the BKL without the Coda community seems like a heap
> 	of pointless work.

Jan Harkes showed interest, looks like this will get fixed eventually,
but probably not in time for 2.6.37.

> fs/freevxfs:
> 	Uses the BKL in readdir and lookup, should be easy to fix. Christoph?

Still waiting for confirmation from Christoph Hellwig that the BKL
is not needed here. I can do the patch to remove it then.

> fs/hpfs:
> 	Looks fixable, if anyone cares. Maybe it's time for retirement in
> 	drivers/staging though. The web page only has a Link to the
> 	linux-2.2 version.

No replies.

> fs/lockd:
> 	Trond writes that he has someone working on BKL removal here.

Bryan Schumaker took care of this, looks like the locking is independent
of the fs/locks.c locking now, although it still uses the BKL internally.

I assume that this will get fixed as well, doesn't seem hard. As long
as lockd uses the BKL, both nfs and nfsd depend on the BKL implicitly.

> fs/locks.c:
> 	Patch is under discussion, blocked by work on fs/lockd currently.

No longer blocked now, both lockd and ceph can deal with this converted
to spinlocks. I will follow up with the final patch once they hit mainline.

> fs/ncpfs:
> 	Should be fixable if Petr still cares about it. Otherwise suggest
> 	moving to drivers/staging if there are no users left.

Fixed by Petr Vandrovec.

> fs/qnx4:
> 	Should be easy to fix, there are only a few places in the code that
> 	use the BKL. Anders?

Anders Larsen volunteered.

> fs/smbfs:
> 	Last I heard this was considered obsolete. Should be move it to
> 	drivers/staging now?

Now in staging.

> fs/udf:
> 	Not completely trivial, but probably necessary to fix. Project web
> 	site is dead, I hope that Jan Kara can be motivated to fix it though.

Jan Kara volunteered to do it.

> fs/ufs:
> 	Evgeniy Dushistov is maintaining this, I hope he can take care of
> 	getting rid of the BKL in UFS.

No replies.

> kernel/trace/blktrace.c:
> 	Should be easy. Ingo? Steven?

Done.

> net/appletalk:
> net/ipx/af_ipx.c:
> net/irda/af_irda.c:
> 	Can probably be saved from retirement in drivers/staging if the
> 	maintainers still care.

Samuel Ortiz fixed irda.

David Miller volunteered to do appletalk and ipx.

> net/x25:
> 	Andrew Hendry has started working on it.

Patches have shown up in -next now, I suppose Andrew will finish it soon.

Out of the remaining modules, I guess i810/i830, adfs, hpfs and ufs might end
up not getting fixed at all, we can either mark them non-SMP or move them
to drivers/staging once all the others are done.

	Arnd
