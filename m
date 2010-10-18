From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [v2] Remaining BKL users, what to do
Date: Mon, 18 Oct 2010 19:38:26 +0200
Message-ID: <201010181938.27076.arnd@arndb.de>
References: <201009161632.59210.arnd@arndb.de> <201010181742.06678.arnd@arndb.de> <20101018161924.GA9571@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: codalist@coda.cs.cmu.edu,
	ksummit-2010-discuss@lists.linux-foundation.org,
	autofs@linux.kernel.org, linux-media@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
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
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101018161924.GA9571@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 18 October 2010 18:19:24 Christoph Hellwig wrote:
> Before we get into all these fringe drivers:
> 
>  - I've not seen any progrss on ->get_sb BKL removal for a while

Not sure what you mean. Jan Blunck did the pushdown into get_sb
last year, which is included into linux-next through my bkl/vfs
tree. Subsequent patches remove it from most file systems along with
the other BKL uses in them. If you like, I can post the series
once more, but it has been posted a few times now.

>  - locks.c is probably a higher priorit, too.

As mentioned in the list, I expect the trivial final patch to
be applied in 2.6.37-rc1 after Linus has pulled the trees that
this depends on (bkl/vfs, nfs, nfsd, ceph), see below.

This is currently not in -next because of the prerequisites.

	Arnd
---

diff --git a/fs/Kconfig b/fs/Kconfig
index c386a9f..25ce2dc 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -50,7 +50,6 @@ endif # BLOCK
 config FILE_LOCKING
 	bool "Enable POSIX file locking API" if EMBEDDED
 	default y
-	select BKL
 	help
 	  This option enables standard file locking support, required
           for filesystems like NFS and for the flock() system
diff --git a/fs/locks.c b/fs/locks.c
index 8b2b6ad..02b6e0e 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -142,6 +142,7 @@ int lease_break_time = 45;
 
 static LIST_HEAD(file_lock_list);
 static LIST_HEAD(blocked_list);
+static DEFINE_SPINLOCK(file_lock_lock);
 
 /*
  * Protects the two list heads above, plus the inode->i_flock list
@@ -149,13 +150,13 @@ static LIST_HEAD(blocked_list);
  */
 void lock_flocks(void)
 {
-	lock_kernel();
+	spin_lock(&file_lock_lock);
 }
 EXPORT_SYMBOL_GPL(lock_flocks);
 
 void unlock_flocks(void)
 {
-	unlock_kernel();
+	spin_unlock(&file_lock_lock);
 }
 EXPORT_SYMBOL_GPL(unlock_flocks);
 
