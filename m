From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Sat, 31 Oct 2015 19:34:49 +0000
Message-ID: <20151031193449.GM22011@ZenIV.linux.org.uk>
References: <20151029001532.GE22011@ZenIV.linux.org.uk>
 <1446089381.7476.114.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151029041611.GF22011@ZenIV.linux.org.uk>
 <1446122119.7476.138.camel@edumazet-glaptop2.roam.corp.google.com>
 <CA+55aFx_BQG4FzSuyL2KAz=c+R0cPv0ZpjboT_=yKjZNGmTUEg@mail.gmail.com>
 <20151030210215.GI22011@ZenIV.linux.org.uk>
 <CA+55aFyoA5sXQvFDavNa7cGkRevunmtPe8F8-_tZ9-826qfkgw@mail.gmail.com>
 <CA+55aFy9fPmbSCJoQiCkjkaiU2HTM6p=o-pJgiV7asyVWBjAEg@mail.gmail.com>
 <20151030223317.GK22011@ZenIV.linux.org.uk>
 <CA+55aFwfFb=LXU77AbiPDHgWcpBwTBoJB4EMCZgTgX32cxMYWw@mail.gmail.com>
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
In-Reply-To: <CA+55aFwfFb=LXU77AbiPDHgWcpBwTBoJB4EMCZgTgX32cxMYWw@mail.gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 30, 2015 at 04:52:41PM -0700, Linus Torvalds wrote:
> I really suspect this patch is "good enough" in reality, and I would
> *much* rather do something like this than add a new non-POSIX flag
> that people have to update their binaries for. I agree with Eric that
> *some* people will do so, but it's still the wrong thing to do. Let's
> just make performance with the normal semantics be good enough that we
> don't need to play odd special games.
> 
> Eric?

... and here's the current variant of mine.  FWIW, it seems to survive
LTP and xfstests + obvious "let's torture the allocator".  On the
"million dups" test it seems to be about 25% faster than the one Linus
had posted, at ten millions - about 80%.  On opensock results seem to be
about 20% better than with the variant Linus has posted, but I'm not sure
if the testbox is anywhere near the expected, so I'd appreciate if you'd
given it a spin on your setups.

It obviously needs saner comments, tuning, etc.  BTW, another obvious
low-hanging fruit with this data structure is count_open_files() (and
that goes for 1:64 bitmap Linus uses) - dup2(0, 10000000); close(10000000);
fork(); and count_open_files() is chewing through the damn bitmap from
about 16M down to low tens.  While holding ->files_lock, at that...
I'm not saying it's critical, and it's definitely a followup patch fodder
in either approach, but it's easy enough to do.

diff --git a/fs/file.c b/fs/file.c
index 6c672ad..fa43cbe 100644
--- a/fs/file.c
+++ b/fs/file.c
@@ -30,6 +30,8 @@ int sysctl_nr_open_min = BITS_PER_LONG;
 int sysctl_nr_open_max = __const_max(INT_MAX, ~(size_t)0/sizeof(void *)) &
 			 -BITS_PER_LONG;
 
+#define BITS_PER_CHUNK 512
+
 static void *alloc_fdmem(size_t size)
 {
 	/*
@@ -46,8 +48,10 @@ static void *alloc_fdmem(size_t size)
 
 static void __free_fdtable(struct fdtable *fdt)
 {
+	int i;
 	kvfree(fdt->fd);
-	kvfree(fdt->open_fds);
+	for (i = 0; i <= 3; i++)
+		kvfree(fdt->bitmaps[i]);
 	kfree(fdt);
 }
 
@@ -62,7 +66,7 @@ static void free_fdtable_rcu(struct rcu_head *rcu)
  */
 static void copy_fdtable(struct fdtable *nfdt, struct fdtable *ofdt)
 {
-	unsigned int cpy, set;
+	unsigned int cpy, set, to, from, level, n;
 
 	BUG_ON(nfdt->max_fds < ofdt->max_fds);
 
@@ -71,18 +75,53 @@ static void copy_fdtable(struct fdtable *nfdt, struct fdtable *ofdt)
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
+	if (unlikely(n != level)) {
+		unsigned long *p = nfdt->bitmaps[level - 1];
+		for (n = 0; n < BITS_PER_CHUNK / BITS_PER_LONG; n++)
+			if (~p[n])
+				return;
+		__set_bit(0, nfdt->bitmaps[level]);
+	}
 }
 
 static struct fdtable * alloc_fdtable(unsigned int nr)
 {
 	struct fdtable *fdt;
 	void *data;
+	int level = 0;
 
 	/*
 	 * Figure out how many fds we actually want to support in this fdtable.
@@ -114,16 +153,28 @@ static struct fdtable * alloc_fdtable(unsigned int nr)
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
@@ -229,14 +280,47 @@ static inline void __clear_close_on_exec(int fd, struct fdtable *fdt)
 	__clear_bit(fd, fdt->close_on_exec);
 }
 
+static bool set_and_check(unsigned long *start, unsigned n)
+{
+	int i;
+	start += (n & -BITS_PER_CHUNK) / BITS_PER_LONG;
+	n %= BITS_PER_CHUNK;
+	__set_bit(n, start);
+	for (i = 0; i < BITS_PER_CHUNK / BITS_PER_LONG; i++)
+		if (~*start++)
+			return true;
+	return false;
+}
+
 static inline void __set_open_fd(int fd, struct fdtable *fdt)
 {
-	__set_bit(fd, fdt->open_fds);
+	int level;
+	for (level = 0; ; level++, fd /= BITS_PER_CHUNK) {
+		if (level == 3 || !fdt->bitmaps[level + 1]) {
+			__set_bit(fd, fdt->bitmaps[level]);
+			break;
+		}
+		if (likely(set_and_check(fdt->bitmaps[level], fd)))
+			break;
+	}
 }
 
 static inline void __clear_open_fd(int fd, struct fdtable *fdt)
 {
-	__clear_bit(fd, fdt->open_fds);
+	int level;
+	unsigned long *p = fdt->bitmaps[0] + fd / BITS_PER_LONG, v;
+	v = *p;
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
@@ -453,70 +561,146 @@ struct files_struct init_files = {
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
+static unsigned scan(unsigned long *start, unsigned size, unsigned from,
+		int check_zeroes)
+{
+	unsigned long *p = start + from / BITS_PER_LONG, *q = p, *end;
+	unsigned bit = from % BITS_PER_LONG, res;
+	unsigned long v = *p, w = v + (1UL<<bit);
+
+	start += (from & -BITS_PER_CHUNK) / BITS_PER_LONG;
+	end = start + size / BITS_PER_LONG;
+
+	if (unlikely(!(w & ~v))) {
+		while (likely(++q < end)) {
+			v = *q;
+			w = v + 1;
+			if (likely(w))
+				goto got_it;
+		}
+		return size;	// not in this chunk
+	}
+got_it:
+	res = __ffs(w & ~v);		// log2, really - it's a power of 2
+	res += (q - start) * BITS_PER_LONG;
+	if (!check_zeroes)
+		return res;
+	if (likely(~(v | w)))		// would zeroes remain in *q?
+		return res;
+	if (p == q || !bit)		// was *p fully checked?
+		p--;
+	while (++q < end)		// any zeros in the tail?
+		if (likely(~*q))
+			return res;
+	if (unlikely(check_zeroes > 1))
+		for (q = start; q <= p; q++)
+			if (~*q)
+				return res;
+	return res | (1U<<31);
+}
+
 int __alloc_fd(struct files_struct *files,
 	       unsigned start, unsigned end, unsigned flags)
 {
-	unsigned int fd;
+	unsigned int fd, base;
 	int error;
 	struct fdtable *fdt;
-
+	unsigned count, level, n;
+	int summary;
 	spin_lock(&files->file_lock);
 repeat:
 	fdt = files_fdtable(files);
+	count = fdt->max_fds;
+	summary = 2;
 	fd = start;
-	if (fd < files->next_fd)
+	if (likely(fd <= files->next_fd)) {
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
+		summary = 1;
+	}
+	base = fd;
+	if (unlikely(base >= count))
+		goto expand2;
+	if (likely(!fdt->bitmaps[1])) {
+		base = scan(fdt->bitmaps[0], count, base, 0);
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
+	n = scan(fdt->bitmaps[0], BITS_PER_CHUNK, base, summary);
+	base &= -BITS_PER_CHUNK;
+	base += n & ~(1U<<31);
+	if (unlikely(n == BITS_PER_CHUNK)) {
+		int bits[3];
+		level = 0;
+		do {
+			bits[level] = count;
+			count = DIV_ROUND_UP(count, BITS_PER_CHUNK);
+			base /= BITS_PER_CHUNK;
+			n = scan(fdt->bitmaps[++level], BITS_PER_CHUNK, base, 0);
+			base &= -BITS_PER_CHUNK;
+			base += n;
+			if (unlikely(base >= count))
+				goto expand;
+		} while (unlikely(n == BITS_PER_CHUNK));
+		while (level--) {
+			base *= BITS_PER_CHUNK;
+			n = scan(fdt->bitmaps[level], BITS_PER_CHUNK, base, !level);
+			if (WARN_ON(n == BITS_PER_CHUNK)) {
+				error = -EINVAL;
+				goto out;
+			}
+			base += n & ~(1U<<31);
+			if (unlikely(base >= bits[level]))
+				goto expand;
+		}
+	}
+	if (unlikely(base >= end)) {
+		error = -EMFILE;
 		goto out;
-
-	/*
-	 * If we needed to expand the fs array we
-	 * might have blocked - try again.
-	 */
-	if (error)
-		goto repeat;
-
-	if (start <= files->next_fd)
+	}
+	fd = base;
+	__set_bit(fd, fdt->bitmaps[0]);
+	if (unlikely(n & (1U << 31))) {
+		for (level = 1; ; level++) {
+			base /= BITS_PER_CHUNK;
+			if (level == 3 || !fdt->bitmaps[level + 1]) {
+				__set_bit(base, fdt->bitmaps[level]);
+				break;
+			}
+			if (likely(set_and_check(fdt->bitmaps[level], base)))
+				break;
+		}
+	}
+found:
+	if (summary == 1)
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
+	base = fdt->max_fds;
+expand2:
+	error = expand_files(files, base);
+	if (error < 0)
+		goto out;
+	goto repeat;
 }
 
 static int alloc_fd(unsigned start, unsigned flags)
@@ -809,7 +993,8 @@ __releases(&files->file_lock)
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
