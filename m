From: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Subject: Re: [PATCH v3 6/7] fs: struct file move from call_rcu() to SLAB_DESTROY_BY_RCU
Date: Fri, 12 Dec 2008 17:48:06 +0100
Message-ID: <494295C6.2020906@cosmosbay.com>
References: <Pine.LNX.4.64.0811201727070.9089@quilx.com> <493100B0.6090104@cosmosbay.com> <494196DD.5070600@cosmosbay.com> <200707241113.46834.nickpiggin@yahoo.com.au> <4941EC65.5040903@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nick Piggin <nickpiggin-/E1597aS9LT0CCvOHzKKcA@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>,
	Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org >> Kernel Testers List"
	<kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
To: Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4941EC65.5040903-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Eric Dumazet a =E9crit :
> Nick Piggin a =E9crit :
>> On Friday 12 December 2008 09:40, Eric Dumazet wrote:
>>> From: Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
>>>
>>> [PATCH] fs: struct file move from call_rcu() to SLAB_DESTROY_BY_RCU
>>>
>>> Currently we schedule RCU frees for each file we free separately. T=
hat has
>>> several drawbacks against the earlier file handling (in 2.6.5 f.e.)=
, which
>>> did not require RCU callbacks:
>>>
>>> 1. Excessive number of RCU callbacks can be generated causing long =
RCU
>>>   queues that in turn cause long latencies. We hit SLUB page alloca=
tion
>>>   more often than necessary.
>>>
>>> 2. The cache hot object is not preserved between free and realloc. =
A close
>>>   followed by another open is very fast with the RCUless approach b=
ecause
>>>   the last freed object is returned by the slab allocator that is
>>>   still cache hot. RCU free means that the object is not immediatel=
y
>>>   available again. The new object is cache cold and therefore open/=
close
>>>   performance tests show a significant degradation with the RCU
>>>   implementation.
>>>
>>> One solution to this problem is to move the RCU freeing into the Sl=
ab
>>> allocator by specifying SLAB_DESTROY_BY_RCU as an option at slab cr=
eation
>>> time. The slab allocator will do RCU frees only when it is necessar=
y
>>> to dispose of slabs of objects (rare). So with that approach we can=
 cut
>>> out the RCU overhead significantly.
>>>
>>> However, the slab allocator may return the object for another use e=
ven
>>> before the RCU period has expired under SLAB_DESTROY_BY_RCU. This m=
eans
>>> there is the (unlikely) possibility that the object is going to be
>>> switched under us in sections protected by rcu_read_lock() and
>>> rcu_read_unlock(). So we need to verify that we have acquired the c=
orrect
>>> object after establishing a stable object reference (incrementing t=
he
>>> refcounter does that).
>>>
>>>
>>> Signed-off-by: Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
>>> Signed-off-by: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
>>> Signed-off-by: Paul E. McKenney <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
>>> ---
>>>  Documentation/filesystems/files.txt |   21 ++++++++++++++--
>>>  fs/file_table.c                     |   33 ++++++++++++++++++-----=
---
>>>  include/linux/fs.h                  |    5 ---
>>>  3 files changed, 42 insertions(+), 17 deletions(-)
>>>
>>> diff --git a/Documentation/filesystems/files.txt
>>> b/Documentation/filesystems/files.txt index ac2facc..6916baa 100644
>>> --- a/Documentation/filesystems/files.txt
>>> +++ b/Documentation/filesystems/files.txt
>>> @@ -78,13 +78,28 @@ the fdtable structure -
>>>     that look-up may race with the last put() operation on the
>>>     file structure. This is avoided using atomic_long_inc_not_zero(=
)
>>>     on ->f_count :
>>> +   As file structures are allocated with SLAB_DESTROY_BY_RCU,
>>> +   they can also be freed before a RCU grace period, and reused,
>>> +   but still as a struct file.
>>> +   It is necessary to check again after getting
>>> +   a stable reference (ie after atomic_long_inc_not_zero()),
>>> +   that fcheck_files(files, fd) points to the same file.
>>>
>>>  	rcu_read_lock();
>>>  	file =3D fcheck_files(files, fd);
>>>  	if (file) {
>>> -		if (atomic_long_inc_not_zero(&file->f_count))
>>> +		if (atomic_long_inc_not_zero(&file->f_count)) {
>>>  			*fput_needed =3D 1;
>>> -		else
>>> +			/*
>>> +			 * Now we have a stable reference to an object.
>>> +			 * Check if other threads freed file and reallocated it.
>>> +			 */
>>> +			if (file !=3D fcheck_files(files, fd)) {
>>> +				*fput_needed =3D 0;
>>> +				put_filp(file);
>>> +				file =3D NULL;
>>> +			}
>>> +		} else
>>>  		/* Didn't get the reference, someone's freed */
>>>  			file =3D NULL;
>>>  	}
>>> @@ -95,6 +110,8 @@ the fdtable structure -
>>>     atomic_long_inc_not_zero() detects if refcounts is already zero=
 or
>>>     goes to zero during increment. If it does, we fail
>>>     fget()/fget_light().
>>> +   The second call to fcheck_files(files, fd) checks that this fil=
p
>>> +   was not freed, then reused by an other thread.
>>>
>>>  6. Since both fdtable and file structures can be looked up
>>>     lock-free, they must be installed using rcu_assign_pointer()
>>> diff --git a/fs/file_table.c b/fs/file_table.c
>>> index a46e880..3e9259d 100644
>>> --- a/fs/file_table.c
>>> +++ b/fs/file_table.c
>>> @@ -37,17 +37,11 @@ static struct kmem_cache *filp_cachep __read_mo=
stly;
>>>
>>>  static struct percpu_counter nr_files __cacheline_aligned_in_smp;
>>>
>>> -static inline void file_free_rcu(struct rcu_head *head)
>>> -{
>>> -	struct file *f =3D  container_of(head, struct file, f_u.fu_rcuhea=
d);
>>> -	kmem_cache_free(filp_cachep, f);
>>> -}
>>> -
>>>  static inline void file_free(struct file *f)
>>>  {
>>>  	percpu_counter_dec(&nr_files);
>>>  	file_check_state(f);
>>> -	call_rcu(&f->f_u.fu_rcuhead, file_free_rcu);
>>> +	kmem_cache_free(filp_cachep, f);
>>>  }
>>>
>>>  /*
>>> @@ -306,6 +300,14 @@ struct file *fget(unsigned int fd)
>>>  			rcu_read_unlock();
>>>  			return NULL;
>>>  		}
>>> +		/*
>>> +		 * Now we have a stable reference to an object.
>>> +		 * Check if other threads freed file and re-allocated it.
>>> +		 */
>>> +		if (unlikely(file !=3D fcheck_files(files, fd))) {
>>> +			put_filp(file);
>>> +			file =3D NULL;
>>> +		}
>> This is a non-trivial change, because that put_filp may drop the las=
t
>> reference to the file. So now we have the case where we free the fil=
e
>> from a context in which it had never been allocated.
>=20
> If we got at this point, we :
>=20
> Found a non NULL pointer in our fd table.
> Then, another thread came, closed the file while we not yet added our=
 reference.
> This file was freed (kmem_cache_free(filp_cachep, file))
> This file was reused and inserted on another thread fd table.
> We added our reference on refcount.
> We checked if this file is still ours (in our fd tab).
> We found this file is not anymore the file we wanted.
> Calling put_filp() here is our only choice to safely remove the refer=
ence on
> a truly allocated file. At this point the file is
> a truly allocated file but not anymore ours.
> Unfortunatly we added a reference on it : we must release it.
> If the other thread already called put_filp() because it wanted to cl=
ose its new file,
> we must see f_refcnt going to zero, and we must call __fput(), to per=
form
> all the relevant file cleanup ourself.

Reading again this mail I realise we call put_filp(file), while this sh=
ould
be fput(file) or put_filp(file), we dont know.

Damned, this patch is wrong as is.

Christoph, Paul, do you see the problem ?

In fget()/fget_light() we dont know if the other thread (the one who re=
-allocated the file,
and tried to close it while we got a reference on file) had to call put=
_filp() or fput()
to release its own reference. So we call atomic_long_dec_and_test() and=
 cannot
take the appropriate action (calling the full __fput() version or the s=
mall one,
that some systems use to 'close' an not really opened file.

void put_filp(struct file *file)
{
        if (atomic_long_dec_and_test(&file->f_count)) {
                security_file_free(file);
                file_kill(file);
                file_free(file);
        }
}

void fput(struct file *file)
{
        if (atomic_long_dec_and_test(&file->f_count))
                __fput(file);
}

I believe put_filp() is only called on slowpath (error cases).

Should we just zap it and always call fput() ?
