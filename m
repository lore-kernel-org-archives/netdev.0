From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Ksummit-2010-discuss] [v2] Remaining BKL users, what to do
Date: Wed, 20 Oct 2010 08:50:07 +0200
Message-ID: <201010200850.07906.arnd@arndb.de>
References: <201009161632.59210.arnd@arndb.de> <201010192244.41913.arnd@arndb.de> <AANLkTimRFxKT5p1K=Rd1MxXZymonx_t6rHKBhn=8CsW=@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, Oliver Neukum <oliver@neukum.org>,
	Valdis.Kletnieks@vt.edu, Dave Airlie <airlied@gmail.com>,
	codalist@telemann.coda.cs.cmu.edu,
	ksummit-2010-discuss@lists.linux-foundation.org,
	autofs@linux.kernel.org, Jan Harkes <jaharkes@cs.cmu.edu>,
	Samuel Ortiz <samuel@sortiz.org>, Jan Kara <jack@suse.cz>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	netdev@vger.kernel.org, Anders Larsen <al@alarsen.net>,
	linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
	Bryan Schumaker <bjschuma@netapp.com>,
	Christoph Hellwig <hch@infradead.org>,
	Petr Vandrovec <vandrove@vc.cvut.cz>,
	Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>,
	linux-fsdevel@vger.kernel.org,
	Evgeniy Dushistov <dushistov@mail.ru>,
	Ingo Molnar <mingo@elte.hu>,
	Andrew Hendry <andrew.hendry@gmail.com>,
	linux-media@vger.kernel.org
To: Dave Young <hidave.darkstar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:64739 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758181Ab0JTGuJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Oct 2010 02:50:09 -0400
In-Reply-To: <AANLkTimRFxKT5p1K=Rd1MxXZymonx_t6rHKBhn=8CsW=@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 20 October 2010, Dave Young wrote:
> be curious, why can't just fix the lock_kernel logic of i810? Fixing
> is too hard?
> 
> Find a i810 hardware should be possible, even if the hardware does not
> support SMP, can't we test the fix with preemption?

Yes, that should work too. My usual approach for removing the BKL without
having the hardware myself was to make locking stricter, i.e. replace
the BKL with a new spinlock or mutex. This way all the code would still
be serialized and if I did something wrong, lockdep would complain about
it, but there would be no risk of silent data corruption.

In case of i810, locking across DRM is rather complicated and there is no
way of doing this without making changes to other DRM code.

In fact, the only critical section that is actually protected by the BKL
are the few lines in i810_mmap_buffers. They look like they might not even
need the BKL to start with and we can just remove it even on SMP/PREEMPT,
except for perhaps the assignment to buf_priv->currently_mapped.
Someone who understands more about the driver than I do can probably figure
this out easily, but I couldn't come up with a way that doesn't risk
breaking in corner cases.

	Arnd
