From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [flame^Wreview] net: netprio_cgroup: rework update socket logic
Date: Mon, 13 Aug 2012 02:53:48 +0100
Message-ID: <20120813015348.GZ23464@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:54654 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750900Ab2HMBxz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Aug 2012 21:53:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Ladies and gentlemen, who the devil had reviewed that little gem?

commit 406a3c638ce8b17d9704052c07955490f732c2b8
Author: John Fastabend <john.r.fastabend@intel.com>
Date:   Fri Jul 20 10:39:25 2012 +0000

is a bleeding bogosity that doesn't pass even the most cursory
inspection.  It iterates through descriptor tables of a bunch
of processes, doing this:
                        file = fcheck_files(files, fd);
                        if (!file)
                                continue;

                        path = d_path(&file->f_path, tmp, PAGE_SIZE);
                        rv = sscanf(path, "socket:[%lu]", &s);
                        if (rv <= 0)
                                continue;

                        sock = sock_from_file(file, &err);
                        if (!err)
                                sock_update_netprioidx(sock->sk, p);
Note the charming use of sscanf() for pattern-matching.  's' (inode
number of socket) is completely unused afterwards; what happens here
is a very badly written attempt to skip non-sockets.  Why, will
sock_from_file() blow up on non-sockets?  And isn't there some less
obnoxious way to check that the file is a sockfs one?  Let's see:
struct socket *sock_from_file(struct file *file, int *err)
{
        if (file->f_op == &socket_file_ops)
                return file->private_data;      /* set in sock_map_fd */

        *err = -ENOTSOCK;
        return NULL;
}
... and the first line is exactly that - a check that we are on sockfs.
_Far_ less expensive one, at that, so it's not even that we are avoiding
a costly test.  In other words, all masturbation with d_path() is absolutely
pointless.

Furthermore, it's racy; had been even more so before the delayed fput series
went in, but even now it's not safe.  fcheck_files() does *NOT* guarantee
that file is not getting closed right now.  rcu_read_lock() prevents only
freeing and potential reuse of struct file we'd got; it might go all the
way through final fput() just as we look at it.  So file->f_path is not
protected by anything.  Worse yet, neither is struct socket itself - we
might be going through sock_release() at the same time, so sock->sk might
very well be NULL, leaving us a oops even after we dump d_path() idiocy.

To make it even funnier, there's such thing as SCM_RIGHTS datagrams and
descriptor passing.  In other words, it's *not* going to catch all sockets
that would be caught by the earlier variant.

What the hell it is about cgroups that turns otherwise sane people into
gibbering idiots?  Other than the Old Ones' apparent involvement in
the mental processes that had lead to the entire concept, that is...

Let's take a closer look at the entire net/core/netprio_cgroup.c, shall we?

Right at the beginning of that Fine Piece of Software we find this:
static atomic_t max_prioidx = ATOMIC_INIT(0);
Why is it atomic?  We have all of four accesses to it; one writer and three
readers.  The writer and one of the readers are under the same spinlock;
the rest of readers are under rtnl_lock().  Moreover, the sole writer is
in get_prioidx(), which is called in one place and is immediately followed
by grabbing rtnl_lock().  So shifting it down there would've put *all*
accesses of that sucker under the same mutex...

Next to that one we have
static DEFINE_SPINLOCK(prioidx_map_lock);
What is that one for?  Two places touching that sucker; get_prioidx() and
put_prioidx().  spin_lock_irqsave()/spin_unlock_irqrestore() in both.
Why irqsave?  Somebody calling that from interrupt context?  Looks odd...
OK, there's not a lot of callers - cgrp_create(), cgrp_destroy().  And
neither looks like something that could be called from an interrupt.
The former has GFP_KERNEL allocation right in the beginning.  Oh, lookie -
both do rtnl_lock().  So not only is all this wanking with irqs pure
cargo-culting, the whole spinlock is pointless; we can simply shift all
this stuff under rtnl_lock().

After get_prioidx()/put_priodix() we come to the following gem:
        for (i = 0;
             old_priomap && (i < old_priomap->priomap_len);
             i++)
                new_priomap->priomap[i] = old_priomap->priomap[i];
Why are we checking old_priomap on every step?  Sure, gcc will take
that out of loop, but why obfuscate the damn thing?
	if (old_priomap)
		memcpy(new_priomap->priomap, old_priomap,
			sizeof(u32) * old_priomap->priomap_len);
would be far more idiomatic...  Anyway, we are extending the damn array,
copying contents of the old one to replacement.  Understandable.  Where
do we modify the contents of that array, anyway?  Aha:
        rtnl_lock();
        for_each_netdev(&init_net, dev) {
                map = rtnl_dereference(dev->priomap);
                if (map && cs->prioidx < map->priomap_len)
                        map->priomap[cs->prioidx] = 0;
        }
        rtnl_unlock();
and
        rcu_read_lock();
        map = rcu_dereference(dev->priomap);   
        if (map)
                map->priomap[prioidx] = priority;
        rcu_read_unlock();
The first one is serialized with the reallocate-and-copy by rtnl_lock().
The second one, though, is immediately suspicious - rcu_read_lock() in
updater.  It's in write_priomap(), which is ->write_string() in some object
deep in the bloated bowels of cgroup.  Only one caller: cgroup_write_string().
No locks grabbed.  Called from cgroup_file_write(), again without any locks.
Which is ->write() of file_operations.  And that is callable without any
locks whatsoever.  OK, so we definitely have a race here.

Incidentally, we'd dropped rtnl_lock() just before that point.  IOW, it's
trivially fixed by moving that thing into write_update_netdev_table()...

BTW, speaking of highly non-idiomatic code: strstr(devname, " ").  Why
not introduce strcasestr(), if we are going for maximal obfuscation here?
Sigh...
