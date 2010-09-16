From: Arnd Bergmann <arnd@arndb.de>
Subject: Remaining BKL users, what to do
Date: Thu, 16 Sep 2010 16:32:59 +0200
Message-ID: <201009161632.59210.arnd@arndb.de>
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
	Andrew Hendry <andrew.hendry@gmail.com>
To: codalist@coda.cs.cmu.edu
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The big kernel lock is gone from almost all code in linux-next, this is
the status of what I think will happen to the remaining users:

drivers/gpu/drm/i810/{i810,i830}_dma.c:
	Fixable, but needs someone with the hardware to test. Can probably be
	marked CONFIG_BROKEN_ON_SMP if nobody cares.

drivers/media/video (V4L):
	Mauro is working on it, some drivers get moved to staging while the
	others get fixed. An easy workaround would be possible by adding
	per-driver mutexes, but Mauro wants to it properly by locking all
	the right places.

fs/adfs:
	Probably not hard to fix, but needs someone to test it.
	adfs has only seen janitorial fixes for the last 5 years.
	Do we know of any users?

fs/autofs:
	Pretty much dead, replaced by autofs4. I'd suggest moving this
	to drivers/staging in 2.6.37 and letting it die there.

fs/coda:
	Coda seems to have an active community, but not all of their
	code is actually part of linux (pioctl!), while the last official
	release is missing many of the cleanups that were don in Linux.
	Not sure what to do, if someone is interested, the best way might
	be a fresh start with a merger of the mainline linux and the
	coda.cs.cmu.edu	codebase in drivers/staging.
	Just removing the BKL without the Coda community seems like a heap
	of pointless work.

fs/freevxfs:
	Uses the BKL in readdir and lookup, should be easy to fix. Christoph?

fs/hpfs:
	Looks fixable, if anyone cares. Maybe it's time for retirement in
	drivers/staging though. The web page only has a Link to the
	linux-2.2 version.

fs/lockd:
	Trond writes that he has someone working on BKL removal here.

fs/locks.c:
	Patch is under discussion, blocked by work on fs/lockd currently.

fs/ncpfs:
	Should be fixable if Petr still cares about it. Otherwise suggest
	moving to drivers/staging if there are no users left.

fs/qnx4:
	Should be easy to fix, there are only a few places in the code that
	use the BKL. Anders?

fs/smbfs:
	Last I heard this was considered obsolete. Should be move it to
	drivers/staging now?

fs/udf:
	Not completely trivial, but probably necessary to fix. Project web
	site is dead, I hope that Jan Kara can be motivated to fix it though.

fs/ufs:
	Evgeniy Dushistov is maintaining this, I hope he can take care of
	getting rid of the BKL in UFS.

kernel/trace/blktrace.c:
	Should be easy. Ingo? Steven?

net/appletalk:
net/ipx/af_ipx.c:
net/irda/af_irda.c:
	Can probably be saved from retirement in drivers/staging if the
	maintainers still care.
	
net/x25:
	Andrew Hendry has started working on it.

This is all that's left now. I still need to submit a few patches for
simple file system changes, but it seems we're getting closer to finally
killing it for good.

	Arnd
