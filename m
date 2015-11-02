From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Mon, 2 Nov 2015 00:24:22 +0000
Message-ID: <20151102002421.GP22011@ZenIV.linux.org.uk>
References: <1446122119.7476.138.camel@edumazet-glaptop2.roam.corp.google.com>
 <CA+55aFx_BQG4FzSuyL2KAz=c+R0cPv0ZpjboT_=yKjZNGmTUEg@mail.gmail.com>
 <20151030210215.GI22011@ZenIV.linux.org.uk>
 <CA+55aFyoA5sXQvFDavNa7cGkRevunmtPe8F8-_tZ9-826qfkgw@mail.gmail.com>
 <CA+55aFy9fPmbSCJoQiCkjkaiU2HTM6p=o-pJgiV7asyVWBjAEg@mail.gmail.com>
 <20151030223317.GK22011@ZenIV.linux.org.uk>
 <CA+55aFwfFb=LXU77AbiPDHgWcpBwTBoJB4EMCZgTgX32cxMYWw@mail.gmail.com>
 <20151031193449.GM22011@ZenIV.linux.org.uk>
 <CA+55aFxeiVx4wMhWALfU3KYCqhsnr8T8M-dEZc3aAyzobWeRGQ@mail.gmail.com>
 <20151031202929.GN22011@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Network Development <netdev@vger.kernel.org>,
	David Howells <dhowells@redhat.com>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151031202929.GN22011@ZenIV.linux.org.uk>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 31, 2015 at 08:29:29PM +0000, Al Viro wrote:
> On Sat, Oct 31, 2015 at 12:54:50PM -0700, Linus Torvalds wrote:
> > On Sat, Oct 31, 2015 at 12:34 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> > >
> > > ... and here's the current variant of mine.
> > 
> > Ugh. I really liked how simple mine ended up being. Yours is definitely not.
> 
> Note that it's not the final variant - just something that should be
> testable.  There are all kinds of things that still need cleaning/simplifying
> in there - e.g. scan() is definitely more complex than needed (if nothing
> else, the "small bitmap" case is simply find_next_zero_bit(), and the
> rest all have size equal to full cacheline; moreover, I'd overdone the
> "... and check if there are other zero bits left" thing - its callers
> used to use that a lot, and with the execption of two of them it was
> absolutely worthless.  So it ended up more generic than necessary and
> I'm going to trim that crap down.
> 
> It's still going to end up more complex than yours, obviously, but not as
> badly as it is now.  I'm not sure if the speedup will be worth the
> extra complexity, thus asking for testing...  On _some_ loads it is
> considerably faster (at least by factor of 5), but whether those loads
> resemble anything that occurs on real systems...

This ought to be a bit cleaner.  Eric, could you test the variant below on your
setup?

diff --git a/fs/file.c b/fs/file.c
index 6c672ad..0144920 100644
--- a/fs/file.c
+++ b/fs/file.c
@@ -30,6 +30,9 @@ int sysctl_nr_open_min = BITS_PER_LONG;
 int sysctl_nr_open_max = __const_max(INT_MAX, ~(size_t)0/sizeof(void *)) &
 			 -BITS_PER_LONG;
 
+#define BITS_PER_CHUNK 512
+#define BYTES_PER_CHUNK (BITS_PER_CHUNK / 8)
+
 static void *alloc_fdmem(size_t size)
 {
 	/*
@@ -46,8 +49,10 @@ static void *alloc_fdmem(size_t size)
 
 static void __free_fdtable(struct fdtable *fdt)
 {
+	int i;
 	kvfree(fdt->fd);
-	kvfree(fdt->open_fds);
+	for (i = 0; i <= 3; i++)
+		kvfree(fdt->bitmaps[i]);
 	kfree(fdt);
 }
 
@@ -56,13 +61,23 @@ static void free_fdtable_rcu(struct rcu_head *rcu)
 	__free_fdtable(container_of(rcu, struct fdtable, rcu));
 }
 
+static inline bool cacheline_full(unsigned long *p)
+{
+	int n;
+
+	for (n = 0; n < BITS_PER_CHUNK / BITS_PER_LONG; n++)
+		if (likely(~p[n]))
+			return false;
+	return true;
+}
+
 /*
  * Expand the fdset in the files_struct.  Called with the files spinlock
  * held for write.
  */
 static void copy_fdtable(struct fdtable *nfdt, struct fdtable *ofdt)
 {
-	unsigned int cpy, set;
+	unsigned int cpy, set, to, from, level, n;
 
 	BUG_ON(nfdt->max_fds < ofdt->max_fds);
 
@@ -71,18 +86,48 @@ static void copy_fdtable(struct fdtable *nfdt, struct fdtable *ofdt)
 	memcpy(nfdt->fd, ofdt->fd, cpy);
 	memset((char *)(nfdt->fd) + cpy, 0, set);
 
-	cpy = ofdt->max_fds / BITS_PER_BYTE;
-	set = (nfdt->max_fds - ofdt->max_fds) / BITS_PER_BYTE;
-	memcpy(nfdt->open_fds, ofdt->open_fds, cpy);
-	memset((char *)(nfdt->open_fds) + cpy, 0, set);
+	cpy = ofdt->max_fds / 8;
+	set = (nfdt->max_fds - ofdt->max_fds) / 8;
 	memcpy(nfdt->close_on_exec, ofdt->close_on_exec, cpy);
 	memset((char *)(nfdt->close_on_exec) + cpy, 0, set);
+	if (likely(!nfdt->bitmaps[1])) {
+		// flat to flat
+		memcpy(nfdt->bitmaps[0], ofdt->bitmaps[0], cpy);
+		memset((char *)(nfdt->bitmaps[0]) + cpy, 0, set);
+		return;
+	}
+	to = round_up(nfdt->max_fds, BITS_PER_CHUNK);
+	set = (to - ofdt->max_fds) / 8;
+	// copy and pad the primary
+	memcpy(nfdt->bitmaps[0], ofdt->bitmaps[0], ofdt->max_fds / 8);
+	memset((char *)nfdt->bitmaps[0] + ofdt->max_fds / 8, 0, set);
+	// copy and pad the old secondaries
+	from = round_up(ofdt->max_fds, BITS_PER_CHUNK);
+	for (level = 1; level <= 3; level++) {
+		if (!ofdt->bitmaps[level])
+			break;
+		to = round_up(to / BITS_PER_CHUNK, BITS_PER_CHUNK);
+		from = round_up(from / BITS_PER_CHUNK, BITS_PER_CHUNK);
+		memcpy(nfdt->bitmaps[level], ofdt->bitmaps[level], from / 8);
+		memset((char *)nfdt->bitmaps[level] + from / 8, 0, (to - from) / 8);
+	}
+	// zero the new ones (if any)
+	for (n = level; n <= 3; n++) {
+		if (!nfdt->bitmaps[n])
+			break;
+		to = round_up(to / BITS_PER_CHUNK, BITS_PER_CHUNK);
+		memset(nfdt->bitmaps[n], 0, to / 8);
+	}
+	// and maybe adjust bit 0 in the first new one.
+	if (unlikely(n != level && cacheline_full(nfdt->bitmaps[level - 1])))
+		__set_bit(0, nfdt->bitmaps[level]);
 }
 
 static struct fdtable * alloc_fdtable(unsigned int nr)
 {
 	struct fdtable *fdt;
 	void *data;
+	int level = 0;
 
 	/*
 	 * Figure out how many fds we actually want to support in this fdtable.
@@ -114,16 +159,28 @@ static struct fdtable * alloc_fdtable(unsigned int nr)
 		goto out_fdt;
 	fdt->fd = data;
 
+	if (nr > BITS_PER_CHUNK)
+		nr = round_up(nr, BITS_PER_CHUNK);
 	data = alloc_fdmem(max_t(size_t,
 				 2 * nr / BITS_PER_BYTE, L1_CACHE_BYTES));
 	if (!data)
 		goto out_arr;
-	fdt->open_fds = data;
+	fdt->bitmaps[0] = data;
 	data += nr / BITS_PER_BYTE;
 	fdt->close_on_exec = data;
-
+	fdt->bitmaps[1] = fdt->bitmaps[2] = fdt->bitmaps[3] = NULL;
+	while (unlikely(nr > BITS_PER_CHUNK)) {
+		nr = round_up(nr / BITS_PER_CHUNK, BITS_PER_CHUNK);
+		data = alloc_fdmem(nr);
+		if (!data)
+			goto out_bitmaps;
+		fdt->bitmaps[++level] = data;
+	}
 	return fdt;
 
+out_bitmaps:
+	while (level >= 0)
+		kvfree(fdt->bitmaps[level--]);
 out_arr:
 	kvfree(fdt->fd);
 out_fdt:
@@ -229,14 +286,41 @@ static inline void __clear_close_on_exec(int fd, struct fdtable *fdt)
 	__clear_bit(fd, fdt->close_on_exec);
 }
 
-static inline void __set_open_fd(int fd, struct fdtable *fdt)
+static inline void __set_open_fd(unsigned fd, struct fdtable *fdt)
 {
-	__set_bit(fd, fdt->open_fds);
+	int level;
+	for (level = 0; ; level++) {
+		unsigned long *p;
+
+		__set_bit(fd, fdt->bitmaps[level]);
+
+		if (level == 3 || !fdt->bitmaps[level + 1])
+			break;
+
+		fd /= BITS_PER_CHUNK;
+
+		p = fdt->bitmaps[level] + BIT_WORD(fd * BITS_PER_CHUNK);
+		if (likely(!cacheline_full(p)))
+			break;
+	}
 }
 
-static inline void __clear_open_fd(int fd, struct fdtable *fdt)
+static inline void __clear_open_fd(unsigned fd, struct fdtable *fdt)
 {
-	__clear_bit(fd, fdt->open_fds);
+	int level;
+	unsigned long *p = fdt->bitmaps[0] + BIT_WORD(fd);
+	unsigned long v = *p;
+	__clear_bit(fd % BITS_PER_LONG, p);
+	if (~v)		// quick test to avoid looking at other cachelines
+		return;
+	for (level = 1; level <= 3; level++) {
+		if (!fdt->bitmaps[level])
+			break;
+		fd /= BITS_PER_CHUNK;
+		if (!test_bit(fd, fdt->bitmaps[level]))
+			break;
+		__clear_bit(fd, fdt->bitmaps[level]);
+	}
 }
 
 static int count_open_files(struct fdtable *fdt)
@@ -246,7 +330,7 @@ static int count_open_files(struct fdtable *fdt)
 
 	/* Find the last open fd */
 	for (i = size / BITS_PER_LONG; i > 0; ) {
-		if (fdt->open_fds[--i])
+		if (fdt->bitmaps[0][--i])
 			break;
 	}
 	i = (i + 1) * BITS_PER_LONG;
@@ -262,7 +346,7 @@ struct files_struct *dup_fd(struct files_struct *oldf, int *errorp)
 {
 	struct files_struct *newf;
 	struct file **old_fds, **new_fds;
-	int open_files, size, i;
+	int open_files, size, i, n;
 	struct fdtable *old_fdt, *new_fdt;
 
 	*errorp = -ENOMEM;
@@ -279,7 +363,8 @@ struct files_struct *dup_fd(struct files_struct *oldf, int *errorp)
 	new_fdt = &newf->fdtab;
 	new_fdt->max_fds = NR_OPEN_DEFAULT;
 	new_fdt->close_on_exec = newf->close_on_exec_init;
-	new_fdt->open_fds = newf->open_fds_init;
+	new_fdt->bitmaps[0] = newf->open_fds_init;
+	new_fdt->bitmaps[1] = new_fdt->bitmaps[2] = new_fdt->bitmaps[3] = NULL;
 	new_fdt->fd = &newf->fd_array[0];
 
 	spin_lock(&oldf->file_lock);
@@ -321,8 +406,17 @@ struct files_struct *dup_fd(struct files_struct *oldf, int *errorp)
 	old_fds = old_fdt->fd;
 	new_fds = new_fdt->fd;
 
-	memcpy(new_fdt->open_fds, old_fdt->open_fds, open_files / 8);
 	memcpy(new_fdt->close_on_exec, old_fdt->close_on_exec, open_files / 8);
+	memcpy(new_fdt->bitmaps[0], old_fdt->bitmaps[0], open_files / 8);
+
+	n = round_up(open_files, BITS_PER_CHUNK);
+	for (i = 1; i <= 3; i++) {
+		if (!new_fdt->bitmaps[i])
+			break;
+		n /= BITS_PER_CHUNK;
+		n = round_up(n, BITS_PER_CHUNK);
+		memcpy(new_fdt->bitmaps[i], old_fdt->bitmaps[i], n / 8);
+	}
 
 	for (i = open_files; i != 0; i--) {
 		struct file *f = *old_fds++;
@@ -351,10 +445,24 @@ struct files_struct *dup_fd(struct files_struct *oldf, int *errorp)
 		int left = (new_fdt->max_fds - open_files) / 8;
 		int start = open_files / BITS_PER_LONG;
 
-		memset(&new_fdt->open_fds[start], 0, left);
-		memset(&new_fdt->close_on_exec[start], 0, left);
+		memset(new_fdt->close_on_exec + start, 0, left);
+		if (likely(!new_fdt->bitmaps[1])) {
+			memset(new_fdt->bitmaps[0] + start, 0, left);
+			goto done;
+		}
+		start = round_up(open_files, BITS_PER_CHUNK);
+		n = round_up(new_fdt->max_fds, BITS_PER_CHUNK);
+		for (i = 0 ; i <= 3; i++) {
+			char *p = (void *)new_fdt->bitmaps[i];
+			if (!p)
+				break;
+			n = round_up(n / BITS_PER_CHUNK, BITS_PER_CHUNK);
+			start = round_up(start / BITS_PER_CHUNK, BITS_PER_CHUNK);
+			memset(p + start / 8, 0, (n - start) / 8);
+		}
 	}
 
+done:
 	rcu_assign_pointer(newf->fdt, new_fdt);
 
 	return newf;
@@ -380,7 +488,7 @@ static struct fdtable *close_files(struct files_struct * files)
 		i = j * BITS_PER_LONG;
 		if (i >= fdt->max_fds)
 			break;
-		set = fdt->open_fds[j++];
+		set = fdt->bitmaps[0][j++];
 		while (set) {
 			if (set & 1) {
 				struct file * file = xchg(&fdt->fd[i], NULL);
@@ -453,70 +561,128 @@ struct files_struct init_files = {
 		.max_fds	= NR_OPEN_DEFAULT,
 		.fd		= &init_files.fd_array[0],
 		.close_on_exec	= init_files.close_on_exec_init,
-		.open_fds	= init_files.open_fds_init,
+		.bitmaps[0]	= init_files.open_fds_init,
 	},
 	.file_lock	= __SPIN_LOCK_UNLOCKED(init_files.file_lock),
 };
 
-/*
- * allocate a file descriptor, mark it busy.
- */
+/* search for the next zero bit in cacheline */
+#define NO_FREE (1ULL<<32)
+#define LAST_FREE (2ULL<<32)
+#define CHUNK_ALIGNED(p) IS_ALIGNED((uintptr_t)p, BYTES_PER_CHUNK)
+
+static __u64 scan(struct fdtable *fdt, int level, unsigned from)
+{
+	unsigned long *p = fdt->bitmaps[level] + BIT_WORD(from);
+	unsigned long v = *p, w = v + BIT_MASK(from);
+
+	from = round_down(from, BITS_PER_CHUNK);
+
+	if (unlikely(!(w & ~v))) {
+		while (!CHUNK_ALIGNED(++p)) {
+			v = *p;
+			w = v + 1;
+			if (likely(w))
+				goto got_it;
+		}
+		return NO_FREE | (from + BITS_PER_CHUNK);
+	}
+got_it:
+	from += __ffs(w & ~v);		// log2, really - it's a power of 2
+	from += 8 * ((uintptr_t)p % BYTES_PER_CHUNK);
+	if (level)			// don't bother with looking for more
+		return from;
+	if (likely(~(v | w)))		// would zeroes remain in *p?
+		return from;
+	while (!CHUNK_ALIGNED(++p))	// any zeros in the tail?
+		if (likely(~*p))
+			return from;
+	return LAST_FREE | from;
+}
+
 int __alloc_fd(struct files_struct *files,
 	       unsigned start, unsigned end, unsigned flags)
 {
 	unsigned int fd;
+	__u64 base;
 	int error;
 	struct fdtable *fdt;
+	unsigned count;
 
 	spin_lock(&files->file_lock);
 repeat:
 	fdt = files_fdtable(files);
+	count = fdt->max_fds;
 	fd = start;
 	if (fd < files->next_fd)
 		fd = files->next_fd;
-
-	if (fd < fdt->max_fds)
-		fd = find_next_zero_bit(fdt->open_fds, fdt->max_fds, fd);
-
-	/*
-	 * N.B. For clone tasks sharing a files structure, this test
-	 * will limit the total number of files that can be opened.
-	 */
-	error = -EMFILE;
-	if (fd >= end)
-		goto out;
-
-	error = expand_files(files, fd);
-	if (error < 0)
-		goto out;
-
-	/*
-	 * If we needed to expand the fs array we
-	 * might have blocked - try again.
-	 */
-	if (error)
+	if (unlikely(fd >= count)) {
+		error = expand_files(files, fd);
+		if (error < 0)
+			goto out;
 		goto repeat;
-
+	}
+	if (likely(!fdt->bitmaps[1])) {
+		base = find_next_zero_bit(fdt->bitmaps[0], count, fd);
+		if (unlikely(base == count))
+			goto expand;
+		if (unlikely(base >= end)) {
+			error = -EMFILE;
+			goto out;
+		}
+		fd = base;
+		__set_bit(fd, fdt->bitmaps[0]);
+		goto found;
+	}
+	base = scan(fdt, 0, fd);
+	if (unlikely(base & NO_FREE)) {
+		int bits[3];
+		int level = 0;
+		do {
+			if (unlikely((u32)base >= count))
+				goto expand;
+			bits[level] = count;
+			count = DIV_ROUND_UP(count, BITS_PER_CHUNK);
+			base = scan(fdt, ++level, (u32)base / BITS_PER_CHUNK);
+		} while (unlikely(base & NO_FREE));
+		while (level) {
+			if (unlikely((u32)base >= count))
+				goto expand;
+			base = scan(fdt, --level, (u32)base * BITS_PER_CHUNK);
+			if (WARN_ON(base & NO_FREE)) {
+				error = -EINVAL;
+				goto out;
+			}
+			count = bits[level];
+		}
+		if (unlikely((u32)base >= count))
+			goto expand;
+	}
+	fd = base;
+	if (unlikely(fd >= end)) {
+		error = -EMFILE;
+		goto out;
+	}
+	if (likely(!(base & LAST_FREE)))
+		__set_bit(fd, fdt->bitmaps[0]);
+	else
+		__set_open_fd(fd, fdt);
+found:
 	if (start <= files->next_fd)
 		files->next_fd = fd + 1;
-
-	__set_open_fd(fd, fdt);
 	if (flags & O_CLOEXEC)
 		__set_close_on_exec(fd, fdt);
 	else
 		__clear_close_on_exec(fd, fdt);
 	error = fd;
-#if 1
-	/* Sanity check */
-	if (rcu_access_pointer(fdt->fd[fd]) != NULL) {
-		printk(KERN_WARNING "alloc_fd: slot %d not NULL!\n", fd);
-		rcu_assign_pointer(fdt->fd[fd], NULL);
-	}
-#endif
-
 out:
 	spin_unlock(&files->file_lock);
 	return error;
+expand:
+	error = expand_files(files, fdt->max_fds);
+	if (error < 0)
+		goto out;
+	goto repeat;
 }
 
 static int alloc_fd(unsigned start, unsigned flags)
@@ -809,7 +975,8 @@ __releases(&files->file_lock)
 		goto Ebusy;
 	get_file(file);
 	rcu_assign_pointer(fdt->fd[fd], file);
-	__set_open_fd(fd, fdt);
+	if (!tofree)
+		__set_open_fd(fd, fdt);
 	if (flags & O_CLOEXEC)
 		__set_close_on_exec(fd, fdt);
 	else
diff --git a/fs/select.c b/fs/select.c
index 0155473..670f542 100644
--- a/fs/select.c
+++ b/fs/select.c
@@ -350,7 +350,7 @@ static int max_select_fd(unsigned long n, fd_set_bits *fds)
 	set = ~(~0UL << (n & (BITS_PER_LONG-1)));
 	n /= BITS_PER_LONG;
 	fdt = files_fdtable(current->files);
-	open_fds = fdt->open_fds + n;
+	open_fds = fdt->bitmaps[0] + n;
 	max = 0;
 	if (set) {
 		set &= BITS(fds, n);
diff --git a/include/linux/fdtable.h b/include/linux/fdtable.h
index 674e3e2..6ef5274 100644
--- a/include/linux/fdtable.h
+++ b/include/linux/fdtable.h
@@ -25,7 +25,7 @@ struct fdtable {
 	unsigned int max_fds;
 	struct file __rcu **fd;      /* current fd array */
 	unsigned long *close_on_exec;
-	unsigned long *open_fds;
+	unsigned long *bitmaps[4];
 	struct rcu_head rcu;
 };
 
@@ -36,7 +36,7 @@ static inline bool close_on_exec(int fd, const struct fdtable *fdt)
 
 static inline bool fd_is_open(int fd, const struct fdtable *fdt)
 {
-	return test_bit(fd, fdt->open_fds);
+	return test_bit(fd, fdt->bitmaps[0]);
 }
 
 /*
