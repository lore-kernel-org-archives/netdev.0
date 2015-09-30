From: Tycho Andersen <tycho.andersen@canonical.com>
Subject: Re: [PATCH v3 4/5] kcmp: add KCMP_FILE_PRIVATE_DATA
Date: Wed, 30 Sep 2015 15:39:09 -0600
Message-ID: <20150930213909.GD23065@smitten>
References: <1443636820-17083-1-git-send-email-tycho.andersen@canonical.com>
 <1443636820-17083-5-git-send-email-tycho.andersen@canonical.com>
 <CALCETrUosV+ND1BC-qH3xZMaLwnex50SvMhaSa3FQ19oy1MBVg@mail.gmail.com>
 <20150930184129.GB23065@smitten>
 <CALCETrWjLGLAnf5_tCZohKYtTDi5Jo=bk_BkchTgXi8Bzz9YDA@mail.gmail.com>
 <20150930185504.GC23065@smitten>
 <CALCETrWx_yCF7o6ZnbeoDqw-Fxa3GzARX30SZWeg40FMGqR25Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="2fHTh5uZTiUOsy+g"
Cc: Kees Cook <keescook@chromium.org>,
	Alexei Starovoitov <ast@kernel.org>,
	Will Drewry <wad@chromium.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux API <linux-api@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALCETrWx_yCF7o6ZnbeoDqw-Fxa3GzARX30SZWeg40FMGqR25Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--2fHTh5uZTiUOsy+g
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Sep 30, 2015 at 11:56:25AM -0700, Andy Lutomirski wrote:
> On Wed, Sep 30, 2015 at 11:55 AM, Tycho Andersen
> <tycho.andersen@canonical.com> wrote:
> > On Wed, Sep 30, 2015 at 11:47:05AM -0700, Andy Lutomirski wrote:
> >> On Wed, Sep 30, 2015 at 11:41 AM, Tycho Andersen
> >> <tycho.andersen@canonical.com> wrote:
> >> > On Wed, Sep 30, 2015 at 11:25:41AM -0700, Andy Lutomirski wrote:
> >> >> On Wed, Sep 30, 2015 at 11:13 AM, Tycho Andersen
> >> >> <tycho.andersen@canonical.com> wrote:
> >> >> > This command allows comparing the underling private data of two fds. This
> >> >> > is useful e.g. to find out if a seccomp filter is inherited, since struct
> >> >> > seccomp_filter are unique across tasks and are the private_data seccomp
> >> >> > fds.
> >> >>
> >> >> This is very implementation-specific and may have nasty ABI
> >> >> consequences far outside seccomp.  Let's do something specific to
> >> >> seccomp and/or eBPF.
> >> >
> >> > We could change the name to a less generic KCMP_SECCOMP_FD or
> >> > something, but without some sort of GUID on each struct
> >> > seccomp_filter, the implementation would be effectively the same as it
> >> > is today. Is that enough, or do we need a GUID?
> >> >
> >>
> >> I don't care about the GUID.  I think we should name it
> >> KCMP_SECCOMP_FD and make it only work on seccomp fds.
> >
> > Ok, I can do that.
> >
> >> Alternatively, we could figure out why KCMP_FILE doesn't do the trick
> >> and consider fixing it.  IMO it's really too bad that struct file is
> >> so heavyweight that we can't really just embed one in all kinds of
> >> structures.
> >
> > The problem is that KCMP_FILE compares the file objects themselves,
> > instead of the underlying data. If I ask for a seccomp fd for filter 0
> > twice, I'll have two different file objects and they won't be equal. I
> > suppose we could add some special logic inside KCMP_FILE to compare
> > the underlying data in special cases (seccomp, ebpf, others?), but it
> > seems cleaner to have a separate command as you described above.
> >
> 
> What I meant was that maybe we could get the two requests to actually
> produce the same struct file.  But that could get very messy
> memory-wise.

I see. The attached patch seems to work with KCMP_FILE and doesn't
look too bad if you don't mind the circular references. What do you
think?

Tycho

--2fHTh5uZTiUOsy+g
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-use-exactly-one-seccomp-file-per-filter-object.patch"

>From 5c410df2df219dc9a68074afe5458b5563b89940 Mon Sep 17 00:00:00 2001
From: Tycho Andersen <tycho.andersen@canonical.com>
Date: Wed, 30 Sep 2015 14:53:48 -0600
Subject: [PATCH] use exactly one seccomp file per filter object

Signed-off-by: Tycho Andersen <tycho.andersen@canonical.com>
---
 kernel/seccomp.c | 37 ++++++++++++++++++++++++++++++++-----
 1 file changed, 32 insertions(+), 5 deletions(-)

diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index af58c49..ff3b1bd 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -60,6 +60,13 @@ struct seccomp_filter {
 	atomic_t usage;
 	struct seccomp_filter *prev;
 	struct bpf_prog *prog;
+
+	/* The file representing this seccomp_filter, if there is one. A 1:1
+	 * file:seccomp_filter mapping allows us to compare seccomp_filters via
+	 * kcmp(KCMP_FILE, ...).
+	 */
+	struct file *seccomp_file;
+	struct mutex file_lock;
 };
 
 /* Limit any path through the tree to 256KB worth of instructions. */
@@ -395,6 +402,7 @@ static struct seccomp_filter *seccomp_prepare_filter(struct sock_fprog *fprog)
 	}
 
 	atomic_set(&sfilter->usage, 1);
+	mutex_init(&sfilter->file_lock);
 
 	return sfilter;
 }
@@ -821,7 +829,14 @@ out_free:
 
 int seccomp_fd_release(struct inode *ino, struct file *f)
 {
-	seccomp_filter_decref(f->private_data);
+	struct seccomp_filter *filter = f->private_data;
+
+	mutex_lock(&filter->file_lock);
+	filter->seccomp_file = NULL;
+	mutex_unlock(&filter->file_lock);
+
+	seccomp_filter_decref(filter);
+
 	return 0;
 }
 
@@ -1073,7 +1088,9 @@ long prctl_set_seccomp(unsigned long seccomp_mode, char __user *filter)
 long seccomp_get_filter_fd(struct task_struct *task, long n)
 {
 	struct seccomp_filter *filter;
+	struct file *file;
 	long fd;
+	int flags = O_RDONLY | O_CLOEXEC;
 
 	if (task->seccomp.mode != SECCOMP_MODE_FILTER)
 		return -EINVAL;
@@ -1087,11 +1104,21 @@ long seccomp_get_filter_fd(struct task_struct *task, long n)
 	if (!filter)
 		return -EINVAL;
 
-	atomic_inc(&filter->usage);
-	fd = anon_inode_getfd("seccomp", &seccomp_fops, filter,
-			      O_RDONLY | O_CLOEXEC);
+	fd = get_unused_fd_flags(flags);
 	if (fd < 0)
-		seccomp_filter_decref(filter);
+		return fd;
+
+	mutex_lock(&filter->file_lock);
+	file = filter->seccomp_file;
+	if (!file) {
+		atomic_inc(&filter->usage);
+		file = anon_inode_getfile("seccomp", &seccomp_fops, filter,
+					  flags);
+		filter->seccomp_file = file;
+	}
+	mutex_unlock(&filter->file_lock);
+
+	fd_install(fd, file);
 
 	return fd;
 }
-- 
2.5.0


--2fHTh5uZTiUOsy+g--
