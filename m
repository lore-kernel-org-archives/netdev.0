From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH v3 6/7] fs: struct file move from call_rcu() to SLAB_DESTROY_BY_RCU
Date: Fri, 12 Dec 2008 05:45:25 +0100
Message-ID: <4941EC65.5040903@cosmosbay.com>
References: <Pine.LNX.4.64.0811201727070.9089@quilx.com> <493100B0.6090104@cosmosbay.com> <494196DD.5070600@cosmosbay.com> <200707241113.46834.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>,
	Christoph Hellwig <hch@infradead.org>,
	David Miller <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, linux-kernel@vger.kernel.org,
	"kernel-testers@vger.kernel.org >> Kernel Testers List"
	<kernel-testers@vger.kernel.org>, Mike Galbraith <efault@gmx.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	linux-fsdevel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:42404 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755258AbYLLEq2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 23:46:28 -0500
In-Reply-To: <200707241113.46834.nickpiggin@yahoo.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nick Piggin a =E9crit :
> On Friday 12 December 2008 09:40, Eric Dumazet wrote:
>> From: Christoph Lameter <cl@linux-foundation.org>
>>
>> [PATCH] fs: struct file move from call_rcu() to SLAB_DESTROY_BY_RCU
>>
>> Currently we schedule RCU frees for each file we free separately. Th=
at has
>> several drawbacks against the earlier file handling (in 2.6.5 f.e.),=
 which
>> did not require RCU callbacks:
>>
>> 1. Excessive number of RCU callbacks can be generated causing long R=
CU
>>   queues that in turn cause long latencies. We hit SLUB page allocat=
ion
>>   more often than necessary.
>>
>> 2. The cache hot object is not preserved between free and realloc. A=
 close
>>   followed by another open is very fast with the RCUless approach be=
cause
>>   the last freed object is returned by the slab allocator that is
>>   still cache hot. RCU free means that the object is not immediately
>>   available again. The new object is cache cold and therefore open/c=
lose
>>   performance tests show a significant degradation with the RCU
>>   implementation.
>>
>> One solution to this problem is to move the RCU freeing into the Sla=
b
>> allocator by specifying SLAB_DESTROY_BY_RCU as an option at slab cre=
ation
>> time. The slab allocator will do RCU frees only when it is necessary
>> to dispose of slabs of objects (rare). So with that approach we can =
cut
>> out the RCU overhead significantly.
>>
>> However, the slab allocator may return the object for another use ev=
en
>> before the RCU period has expired under SLAB_DESTROY_BY_RCU. This me=
ans
>> there is the (unlikely) possibility that the object is going to be
>> switched under us in sections protected by rcu_read_lock() and
>> rcu_read_unlock(). So we need to verify that we have acquired the co=
rrect
>> object after establishing a stable object reference (incrementing th=
e
>> refcounter does that).
>>
>>
>> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>> Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
>> ---
>>  Documentation/filesystems/files.txt |   21 ++++++++++++++--
>>  fs/file_table.c                     |   33 ++++++++++++++++++------=
--
>>  include/linux/fs.h                  |    5 ---
>>  3 files changed, 42 insertions(+), 17 deletions(-)
>>
>> diff --git a/Documentation/filesystems/files.txt
>> b/Documentation/filesystems/files.txt index ac2facc..6916baa 100644
>> --- a/Documentation/filesystems/files.txt
>> +++ b/Documentation/filesystems/files.txt
>> @@ -78,13 +78,28 @@ the fdtable structure -
>>     that look-up may race with the last put() operation on the
>>     file structure. This is avoided using atomic_long_inc_not_zero()
>>     on ->f_count :
>> +   As file structures are allocated with SLAB_DESTROY_BY_RCU,
>> +   they can also be freed before a RCU grace period, and reused,
>> +   but still as a struct file.
>> +   It is necessary to check again after getting
>> +   a stable reference (ie after atomic_long_inc_not_zero()),
>> +   that fcheck_files(files, fd) points to the same file.
>>
>>  	rcu_read_lock();
>>  	file =3D fcheck_files(files, fd);
>>  	if (file) {
>> -		if (atomic_long_inc_not_zero(&file->f_count))
>> +		if (atomic_long_inc_not_zero(&file->f_count)) {
>>  			*fput_needed =3D 1;
>> -		else
>> +			/*
>> +			 * Now we have a stable reference to an object.
>> +			 * Check if other threads freed file and reallocated it.
>> +			 */
>> +			if (file !=3D fcheck_files(files, fd)) {
>> +				*fput_needed =3D 0;
>> +				put_filp(file);
>> +				file =3D NULL;
>> +			}
>> +		} else
>>  		/* Didn't get the reference, someone's freed */
>>  			file =3D NULL;
>>  	}
>> @@ -95,6 +110,8 @@ the fdtable structure -
>>     atomic_long_inc_not_zero() detects if refcounts is already zero =
or
>>     goes to zero during increment. If it does, we fail
>>     fget()/fget_light().
>> +   The second call to fcheck_files(files, fd) checks that this filp
>> +   was not freed, then reused by an other thread.
>>
>>  6. Since both fdtable and file structures can be looked up
>>     lock-free, they must be installed using rcu_assign_pointer()
>> diff --git a/fs/file_table.c b/fs/file_table.c
>> index a46e880..3e9259d 100644
>> --- a/fs/file_table.c
>> +++ b/fs/file_table.c
>> @@ -37,17 +37,11 @@ static struct kmem_cache *filp_cachep __read_mos=
tly;
>>
>>  static struct percpu_counter nr_files __cacheline_aligned_in_smp;
>>
>> -static inline void file_free_rcu(struct rcu_head *head)
>> -{
>> -	struct file *f =3D  container_of(head, struct file, f_u.fu_rcuhead=
);
>> -	kmem_cache_free(filp_cachep, f);
>> -}
>> -
>>  static inline void file_free(struct file *f)
>>  {
>>  	percpu_counter_dec(&nr_files);
>>  	file_check_state(f);
>> -	call_rcu(&f->f_u.fu_rcuhead, file_free_rcu);
>> +	kmem_cache_free(filp_cachep, f);
>>  }
>>
>>  /*
>> @@ -306,6 +300,14 @@ struct file *fget(unsigned int fd)
>>  			rcu_read_unlock();
>>  			return NULL;
>>  		}
>> +		/*
>> +		 * Now we have a stable reference to an object.
>> +		 * Check if other threads freed file and re-allocated it.
>> +		 */
>> +		if (unlikely(file !=3D fcheck_files(files, fd))) {
>> +			put_filp(file);
>> +			file =3D NULL;
>> +		}
>=20
> This is a non-trivial change, because that put_filp may drop the last
> reference to the file. So now we have the case where we free the file
> from a context in which it had never been allocated.

If we got at this point, we :

=46ound a non NULL pointer in our fd table.
Then, another thread came, closed the file while we not yet added our r=
eference.
This file was freed (kmem_cache_free(filp_cachep, file))
This file was reused and inserted on another thread fd table.
We added our reference on refcount.
We checked if this file is still ours (in our fd tab).
We found this file is not anymore the file we wanted.
Calling put_filp() here is our only choice to safely remove the referen=
ce on
a truly allocated file. At this point the file is
a truly allocated file but not anymore ours.
Unfortunatly we added a reference on it : we must release it.
If the other thread already called put_filp() because it wanted to clos=
e its new file,
we must see f_refcnt going to zero, and we must call __fput(), to perfo=
rm
all the relevant file cleanup ourself.


>=20
>>From a quick glance though the callchains, I can't seen an obvious
> problem. But it needs to have documentation in put_filp, or at least
> a mention in the changelog, and also cc'ed to the security lists.

I see your point. But currently, any thread can be "releasing the last
reference on a file". That is not always the thread that called close(f=
d)
We extend this to "any thread of any process", so it might have
a security effect you are absolutely right.

>=20
> Also, it adds code and cost to the get/put path in return for
> improvement in the free path. get/put is the more common path, but
> it is a small loss for a big improvement. So it might be worth it. Bu=
t
> it is not justified by your microbenchmark. Do we have a more useful
> case that it helps?

Any real world program that open and close files, or said better,
that close and open files :)

sizeof(struct file) is 192 bytes. Thats three cache lines.
Being able to reuse a hot "struct file" avoids three cache line misses.

Thats about 120 ns.

Then, using call_rcu() is also a latency killer, since we explicitly sa=
y :
I dont want to free this file right now, I delegate this job to another=
 layer
in two or three milli second (or more)

A final point is that SLUB doesnt need to allocate or free a slab in ma=
ny cases.
(This is probably why Christoph needed this patch in 2006 :) )
In my case, I need all these patches to speedup http servers.
They obviously open and close many files per second.

The added code has a cost of less than 3 ns, but I suspect we can cut i=
t to less than 1ns
We prefered with Christoph and Paul to keep patch as short as possible =
to focus
on essential points.

               :c0287656:       mov    -0x14(%ebp),%esi
               :c0287659:       mov    -0x24(%ebp),%edi
               :c028765c:       mov    0x4(%esi),%eax
               :c028765f:       cmp    (%eax),%edi
               :c0287661:       jb     c0287678 <fget+0xc8>
               :c0287663:       mov    %ebx,%eax
               :c0287665:       xor    %ebx,%ebx
               :c0287667:       call   c0287450 <put_filp>
               :c028766c:       jmp    c02875ec <fget+0x3c>
               :c0287671:       lea    0x0(%esi,%eiz,1),%esi
               :c0287678:       mov    0x4(%eax),%edi
               :c028767b:       add    %edi,-0x10(%ebp)
               :c028767e:       mov    -0x10(%ebp),%edx
     1 8.8e-05 :c0287681:       mov    (%edx),%eax
               :c0287683:       cmp    %eax,%ebx
               :c0287685:       je     c02875ec <fget+0x3c>
               :c028768b:       jmp    c0287663 <fget+0xb3>

We could avoid doing the full test, because there is no way the files->=
max_fds could
become lower under us, or even fdt itself, and fdt->fd

So instead of using twice this function :

static inline struct file * fcheck_files(struct files_struct *files, un=
signed int fd)
{
        struct file * file =3D NULL;
        struct fdtable *fdt =3D files_fdtable(files);

        if (fd < fdt->max_fds)
                file =3D rcu_dereference(fdt->fd[fd]);
        return file;
}

We could use the attached patch


This becomes a matter of three instructions, including a 99.99% predict=
ed branch :

c0287646:       8b 03                   mov    (%ebx),%eax
c0287648:       39 45 e4                cmp    %eax,-0x1c(%ebp)
c028764b:       74 a1                   je     c02875ee <fget+0x3e>

c028764d:       8b 45 e4                mov    -0x1c(%ebp),%eax
c0287650:       e8 fb fd ff ff          call   c0287450 <put_filp>
c0287655:       31 c0                   xor    %eax,%eax
c0287657:       eb 98                   jmp    c02875f1 <fget+0x41>
=09

At the time Christoph sent its patch (in 2006), nobody cared, because
we had no benchmark or real world workload that demonstrated the gain=20
of his patch, only intuitions.
We had too many contended cache lines that slow down the whole process.

SLAB_DESTROY_BY_RCU is a must on current hardware, where memory cache l=
ine
misses costs become really problematic. This patch series clearly demon=
strate
it.

Thanks Nick for your feedback and comments.

Eric

[PATCH] fs: optimize fget() & fget_light()

Instead of calling fcheck_files() a second time, we can take into accou=
nt we
already did part of the job, in a rcu read locked section. We need a
struct file **filp pointer so that we only dereference it a second time=
=2E

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 fs/file_table.c |   23 +++++++++++++++++------
 1 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/fs/file_table.c b/fs/file_table.c
index 3e9259d..4bc019f 100644
--- a/fs/file_table.c
+++ b/fs/file_table.c
@@ -289,11 +289,16 @@ void __fput(struct file *file)
=20
 struct file *fget(unsigned int fd)
 {
-	struct file *file;
+	struct file *file =3D NULL, **filp;
 	struct files_struct *files =3D current->files;
+	struct fdtable *fdt;
=20
 	rcu_read_lock();
-	file =3D fcheck_files(files, fd);
+	fdt =3D files_fdtable(files);
+	if (likely(fd < fdt->max_fds)) {
+		filp =3D &fdt->fd[fd];
+		file =3D rcu_dereference(*filp);
+	}
 	if (file) {
 		if (!atomic_long_inc_not_zero(&file->f_count)) {
 			/* File object ref couldn't be taken */
@@ -304,7 +309,7 @@ struct file *fget(unsigned int fd)
 		 * Now we have a stable reference to an object.
 		 * Check if other threads freed file and re-allocated it.
 		 */
-		if (unlikely(file !=3D fcheck_files(files, fd))) {
+		if (unlikely(file !=3D rcu_dereference(*filp))) {
 			put_filp(file);
 			file =3D NULL;
 		}
@@ -325,15 +330,21 @@ EXPORT_SYMBOL(fget);
  */
 struct file *fget_light(unsigned int fd, int *fput_needed)
 {
-	struct file *file;
+	struct file *file, **filp;
 	struct files_struct *files =3D current->files;
+	struct fdtable *fdt;
=20
 	*fput_needed =3D 0;
 	if (likely((atomic_read(&files->count) =3D=3D 1))) {
 		file =3D fcheck_files(files, fd);
 	} else {
 		rcu_read_lock();
-		file =3D fcheck_files(files, fd);
+		fdt =3D files_fdtable(files);
+		file =3D NULL;
+		if (likely(fd < fdt->max_fds)) {
+			filp =3D &fdt->fd[fd];
+			file =3D rcu_dereference(*filp);
+		}
 		if (file) {
 			if (atomic_long_inc_not_zero(&file->f_count)) {
 				*fput_needed =3D 1;
@@ -342,7 +353,7 @@ struct file *fget_light(unsigned int fd, int *fput_=
needed)
 				 * Check if other threads freed this file and
 				 * re-allocated it.
 				 */
-				if (unlikely(file !=3D fcheck_files(files, fd))) {
+				if (unlikely(file !=3D rcu_dereference(*filp))) {
 					*fput_needed =3D 0;
 					put_filp(file);
 					file =3D NULL;

