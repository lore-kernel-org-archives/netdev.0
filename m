From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: 2.6.34-rc5-git7 (plus all patches) -- another suspicious
 rcu_dereference_check() usage.
Date: Thu, 29 Apr 2010 17:48:29 -0700
Message-ID: <20100430004829.GA18979@linux.vnet.ibm.com>
References: <h2ya44ae5cd1004261751waa5cb65ei3d139cbcfa2cc5cf@mail.gmail.com>
 <20100428175426.GK2540@linux.vnet.ibm.com>
 <1272483491.2201.9.camel@edumazet-laptop>
 <20100428200904.GS2540@linux.vnet.ibm.com>
 <1272485923.2201.22.camel@edumazet-laptop>
 <20100428204403.GT2540@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Miles Lane <miles.lane@gmail.com>, Vivek Goyal <vgoyal@redhat.com>,
	Eric Paris <eparis@redhat.com>,
	Lai Jiangshan <laijs@cn.fujitsu.com>,
	Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, nauman@google.com,
	netdev@vger.kernel.org, Jens Axboe <jens.axboe@oracle.com>,
	Gui Jianfeng <guijianfeng@cn.fujitsu.com>,
	Li Zefan <lizf@cn.fujitsu.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	shemminger@vyatta.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100428204403.GT2540@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 28, 2010 at 01:44:03PM -0700, Paul E. McKenney wrote:
> On Wed, Apr 28, 2010 at 10:18:43PM +0200, Eric Dumazet wrote:
> > Le mercredi 28 avril 2010 =E0 13:09 -0700, Paul E. McKenney a =E9cr=
it :
> > > On Wed, Apr 28, 2010 at 09:38:11PM +0200, Eric Dumazet wrote:
> > > > Le mercredi 28 avril 2010 =E0 10:54 -0700, Paul E. McKenney a =E9=
crit :
> > > > > On Mon, Apr 26, 2010 at 08:51:06PM -0400, Miles Lane wrote:
> > > > > > This one occurred during the wakeup from suspend to RAM.
> > > > > >=20
> > > > > > [  984.724697] [ INFO: suspicious rcu_dereference_check() u=
sage. ]
> > > > > > [  984.724700] --------------------------------------------=
-------
> > > > > > [  984.724703] include/linux/fdtable.h:88 invoked
> > > > > > rcu_dereference_check() without protection!
> > > > > > [  984.724706]
> > > > > > [  984.724707] other info that might help us debug this:
> > > > > > [  984.724708]
> > > > > > [  984.724711]
> > > > > > [  984.724711] rcu_scheduler_active =3D 1, debug_locks =3D =
1
> > > > > > [  984.724714] no locks held by dbus-daemon/4680.
> > > > > > [  984.724717]
> > > > > > [  984.724717] stack backtrace:
> > > > > > [  984.724721] Pid: 4680, comm: dbus-daemon Not tainted 2.6=
=2E34-rc5-git7 #33
> > > > > > [  984.724724] Call Trace:
> > > > > > [  984.724734]  [<ffffffff81074556>] lockdep_rcu_dereferenc=
e+0x9d/0xa6
> > > > > > [  984.724740]  [<ffffffff810fc785>] fcheck_files+0xb1/0xc9
> > > > > > [  984.724745]  [<ffffffff810fc7f5>] fget_light+0x35/0xab
> > > > > > [  984.724751]  [<ffffffff81433e1b>] ? sock_poll_wait+0x13/=
0x18
> > > > > > [  984.724755]  [<ffffffff81433e39>] ? unix_poll+0x19/0x95
> > > > > > [  984.724762]  [<ffffffff8110aa95>] do_sys_poll+0x1ff/0x3e=
5
> > > > > > [  984.724766]  [<ffffffff8110a19e>] ? __pollwait+0x0/0xc7
> > > > > > [  984.724771]  [<ffffffff8110a265>] ? pollwake+0x0/0x4f
> > > > > > [  984.724776]  [<ffffffff8110a265>] ? pollwake+0x0/0x4f
> > > > > > [  984.724780]  [<ffffffff8110a265>] ? pollwake+0x0/0x4f
> > > > > > [  984.724784]  [<ffffffff8110a265>] ? pollwake+0x0/0x4f
> > > > > > [  984.724788]  [<ffffffff8110a265>] ? pollwake+0x0/0x4f
> > > > > > [  984.724793]  [<ffffffff8110a265>] ? pollwake+0x0/0x4f
> > > > > > [  984.724797]  [<ffffffff8110a265>] ? pollwake+0x0/0x4f
> > > > > > [  984.724802]  [<ffffffff8110a265>] ? pollwake+0x0/0x4f
> > > > > > [  984.724806]  [<ffffffff8110a265>] ? pollwake+0x0/0x4f
> > > > > > [  984.724812]  [<ffffffff8110ae0f>] sys_poll+0x50/0xbb
> > > > > > [  984.724818]  [<ffffffff81009d82>] system_call_fastpath+0=
x16/0x1b
> > > > >=20
> > > > > Hmmm...  I am not convinced that this is a false positive.  C=
ouldn't
> > > > > there be a multi-threaded process where one thread is invokin=
g poll()
> > > > > on a UNIX socket just as another thread is calling close() on=
 it?
> > > > >=20
> > > > > The current fcheck_files() logic requires that the caller eit=
her (1) be in
> > > > > an RCU read-side critical section, (2) hold ->files_lock, or =
(3) passing
> > > > > in a files_struct with ->count equal to 1 (initialization or =
cleanup).
> > > > >=20
> > > > > So I don't feel comfortable just slapping an RCU read-side cr=
itical
> > > > > section around this one, at least not unless someone who unde=
rstands
> > > > > the locking says that doing so is OK.
> > > > >=20
> > > > > 	=09
> > > >=20
> > > > Its a single threaded program.
> > > >=20
> > > > So fget_light() calls fcheck_files(files, fd); without rcu lock=
,
> > > > but some /proc/pid/fd/... user temporarly raised files->count j=
ust
> > > > before we perform the condition check.
> > >=20
> > > So I should add a single-threaded check.  My first thought was to=
 use
> > > current_is_single_threaded(), but the bit about scanning the full=
 list
> > > of processes does give me pause.  However, thread_group_empty() l=
ooks
> > > like a much lighter-weight alternative.
> > >=20
> > > I believe that it is possible for a pair of single-threaded proce=
sses
> > > to share a file descriptor, but that should not be a problem, as =
both
> > > of them would need to close it for it to go away.
> > >=20
> > > But what happens if someone does a clone() with CLONE_FILES, as s=
ome
> > > of the AIO stuff seems to do?  Won't that allow one of the result=
ing
> > > processes to close the file for both of them, even though both ar=
e
> > > otherwise single-threaded?  And the ->count seems to be the only
> > > distinction between these two cases.
> > >=20
> > > And AIO does CLONE_VM as well as CLONE_FILES, but that seems to m=
ean that
> > > the check must scan the processes with current_is_single_threaded=
().
> > > Besides which, a user could invoke clone() with only CLONE_FILES
> > > specified, right?
> > >=20
> > > Or am I just confused here?

Not confused, just stupid.  You would think that after almost 20 years
doing parallel programming, I would understand that concurrent debuggin=
g
assertions usually cannot be exact.  In this case, I really don't want
false positives, so I must accept some false negatives.  -That- I shoul=
d
be able to do without adding runtime overhead when !PROVE_RCU.

I will put together a patch, test it, and send it out.

							Thanx, Paul

> > If a program is mono threaded, and doing a fget_light() syscall, it
> > cannot possibly do a clone() in // ;)
>=20
> The sequence of events that I am worried about is as follows:
>=20
> 1.	Single-threaded process does clone(CLONE_FILES).  The
> 	result is a pair of single-threaded processes that share
> 	file descriptors.
>=20
> 2.	One of these processes does files_fdtable(i) at the same
> 	time as the other process closes file descriptor i.
>=20
> So, clone and -then- do fget_light().
>=20
> > If we want to be picky, we could add a user provided condition, aka=
 "we
> > are sure we are allowed to do this because we are the owner of the =
files
> > struct".
>=20
> But yes, if I understand your trick below, the race conditions from
> the above sequence of events would simply force the processes off
> of the fget_light() path, which should be OK.
>=20
> 						Thanx, Paul
>=20
> > diff --git a/drivers/char/tty_io.c b/drivers/char/tty_io.c
> > index 6da962c..027f5e1 100644
> > --- a/drivers/char/tty_io.c
> > +++ b/drivers/char/tty_io.c
> > @@ -2694,7 +2694,7 @@ void __do_SAK(struct tty_struct *tty)
> >  			spin_lock(&p->files->file_lock);
> >  			fdt =3D files_fdtable(p->files);
> >  			for (i =3D 0; i < fdt->max_fds; i++) {
> > -				filp =3D fcheck_files(p->files, i);
> > +				filp =3D fcheck_files(p->files, i, false);
> >  				if (!filp)
> >  					continue;
> >  				if (filp->f_op->read =3D=3D tty_read &&
> > diff --git a/fs/fcntl.c b/fs/fcntl.c
> > index 452d02f..dabf4d8 100644
> > --- a/fs/fcntl.c
> > +++ b/fs/fcntl.c
> > @@ -119,7 +119,7 @@ SYSCALL_DEFINE2(dup2, unsigned int, oldfd, unsi=
gned int, newfd)
> >  		int retval =3D oldfd;
> >=20
> >  		rcu_read_lock();
> > -		if (!fcheck_files(files, oldfd))
> > +		if (!fcheck_files(files, oldfd, false))
> >  			retval =3D -EBADF;
> >  		rcu_read_unlock();
> >  		return retval;
> > diff --git a/fs/file_table.c b/fs/file_table.c
> > index 32d12b7..2865f72 100644
> > --- a/fs/file_table.c
> > +++ b/fs/file_table.c
> > @@ -274,7 +274,7 @@ struct file *fget(unsigned int fd)
> >  	struct files_struct *files =3D current->files;
> >=20
> >  	rcu_read_lock();
> > -	file =3D fcheck_files(files, fd);
> > +	file =3D fcheck_files(files, fd, false);
> >  	if (file) {
> >  		if (!atomic_long_inc_not_zero(&file->f_count)) {
> >  			/* File object ref couldn't be taken */
> > @@ -303,10 +303,10 @@ struct file *fget_light(unsigned int fd, int =
*fput_needed)
> >=20
> >  	*fput_needed =3D 0;
> >  	if (likely((atomic_read(&files->count) =3D=3D 1))) {
> > -		file =3D fcheck_files(files, fd);
> > +		file =3D fcheck_files(files, fd, true);
> >  	} else {
> >  		rcu_read_lock();
> > -		file =3D fcheck_files(files, fd);
> > +		file =3D fcheck_files(files, fd, false);
> >  		if (file) {
> >  			if (atomic_long_inc_not_zero(&file->f_count))
> >  				*fput_needed =3D 1;
> > diff --git a/fs/proc/base.c b/fs/proc/base.c
> > index 8418fcc..0e89448 100644
> > --- a/fs/proc/base.c
> > +++ b/fs/proc/base.c
> > @@ -1716,7 +1716,7 @@ static int proc_fd_info(struct inode *inode, =
struct path *path, char *info)
> >  		 * hold ->file_lock.
> >  		 */
> >  		spin_lock(&files->file_lock);
> > -		file =3D fcheck_files(files, fd);
> > +		file =3D fcheck_files(files, fd, false);
> >  		if (file) {
> >  			if (path) {
> >  				*path =3D file->f_path;
> > @@ -1755,7 +1755,7 @@ static int tid_fd_revalidate(struct dentry *d=
entry, struct nameidata *nd)
> >  		files =3D get_files_struct(task);
> >  		if (files) {
> >  			rcu_read_lock();
> > -			if (fcheck_files(files, fd)) {
> > +			if (fcheck_files(files, fd, false)) {
> >  				rcu_read_unlock();
> >  				put_files_struct(files);
> >  				if (task_dumpable(task)) {
> > @@ -1813,7 +1813,7 @@ static struct dentry *proc_fd_instantiate(str=
uct inode *dir,
> >  	 * hold ->file_lock.
> >  	 */
> >  	spin_lock(&files->file_lock);
> > -	file =3D fcheck_files(files, fd);
> > +	file =3D fcheck_files(files, fd, false);
> >  	if (!file)
> >  		goto out_unlock;
> >  	if (file->f_mode & FMODE_READ)
> > @@ -1899,7 +1899,7 @@ static int proc_readfd_common(struct file * f=
ilp, void * dirent,
> >  				char name[PROC_NUMBUF];
> >  				int len;
> >=20
> > -				if (!fcheck_files(files, fd))
> > +				if (!fcheck_files(files, fd, false))
> >  					continue;
> >  				rcu_read_unlock();
> >=20
> > diff --git a/include/linux/fdtable.h b/include/linux/fdtable.h
> > index 013dc52..76423ad 100644
> > --- a/include/linux/fdtable.h
> > +++ b/include/linux/fdtable.h
> > @@ -57,11 +57,12 @@ struct files_struct {
> >  	struct file * fd_array[NR_OPEN_DEFAULT];
> >  };
> >=20
> > -#define rcu_dereference_check_fdtable(files, fdtfd) \
> > +#define rcu_dereference_check_fdtable(files, fdtfd, cond) \
> >  	(rcu_dereference_check((fdtfd), \
> >  			       rcu_read_lock_held() || \
> >  			       lockdep_is_held(&(files)->file_lock) || \
> > -			       atomic_read(&(files)->count) =3D=3D 1))
> > +			       atomic_read(&(files)->count) =3D=3D 1 || \
> > +			       cond))
> >=20
> >  #define files_fdtable(files) \
> >  		(rcu_dereference_check_fdtable((files), (files)->fdt))
> > @@ -79,13 +80,13 @@ static inline void free_fdtable(struct fdtable =
*fdt)
> >  	call_rcu(&fdt->rcu, free_fdtable_rcu);
> >  }
> >=20
> > -static inline struct file * fcheck_files(struct files_struct *file=
s, unsigned int fd)
> > +static inline struct file * fcheck_files(struct files_struct *file=
s, unsigned int fd, bool cond)
> >  {
> >  	struct file * file =3D NULL;
> >  	struct fdtable *fdt =3D files_fdtable(files);
> >=20
> >  	if (fd < fdt->max_fds)
> > -		file =3D rcu_dereference_check_fdtable(files, fdt->fd[fd]);
> > +		file =3D rcu_dereference_check_fdtable(files, fdt->fd[fd], cond)=
;
> >  	return file;
> >  }
> >=20
> >=20
> >=20
