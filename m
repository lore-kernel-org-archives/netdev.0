From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC] breakage in sysfs_readdir() and s_instances abuse in sysfs
Date: Sat, 4 Jun 2011 23:25:31 +0100
Message-ID: <20110604222531.GA11521@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@aristanetworks.com>,
	linux-fsdevel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:38593 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753783Ab1FDWZc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jun 2011 18:25:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Forwarded to netdev]

On Sat, Jun 04, 2011 at 01:15:19AM +0100, Al Viro wrote:
> Granted, sysfs_dir_pos() doesn't dereference ns; however, it does compare
> with it.  And ns might have been freed and reused by that point.
> 
> I don't like what's going on there; that code looks inherently racy.
> We never set ->ns[...] non-NULL outside of mount().  So it looks like
> the intended behaviour is to have all ns-specific entries of that type
> disappear forever from that fs instance.  Having entries for _another_
> namespace to show up for a (short) while, and that only in readdir()
> (lookup runs completely under sysfs_mutex, so we don't have that race
> there)...

Eeep...  We do not have a *race* in lookup.  However, any lookup done
after that ->ns[...] = NULL is going to do the following:

        mutex_lock(&sysfs_mutex);

        type = sysfs_ns_type(parent_sd);
        ns = sysfs_info(dir->i_sb)->ns[type];
/* i.e. ns = NULL */
        sd = sysfs_find_dirent(parent_sd, ns, dentry->d_name.name);
which will do rather unpleasant things:
        for (sd = parent_sd->s_dir.children; sd; sd = sd->s_sibling) {
                if (ns && sd->s_ns && (sd->s_ns != ns))
                        continue;
                if (!strcmp(sd->s_name, name))
                        return sd;
        }
i.e. with ns == NULL it will outright ignore sd->s_ns and look for name
match and nothing else.  Any sysfs node with that name will do, whatever
it might have in ->s_ns.  E.g. for lookups in /sys/class/net it will find
the first sysfs node of network interface with that name in _some_ namespace.
Back to sysfs_lookup():
        /* no such entry */
        if (!sd) {
                ret = ERR_PTR(-ENOENT);
                goto out_unlock;
        }

        /* attach dentry and inode */
        inode = sysfs_get_inode(dir->i_sb, sd);
        if (!inode) {
                ret = ERR_PTR(-ENOMEM);
                goto out_unlock;
        }

and if there was an entry from some surviving net_ns with that name,
sysfs_get_inode() will cheerfully allocate an inode for us and associate
it with that sd.  Then we complete the lookup and return a shiny positive
dentry to caller...

Just what is that code supposed to do?  Somehow I doubt that "after net_ns
is gone, lookups for class/net/name succeed when there is an interface called
name in at least one net_ns; resulting object refers to one of such
interfaces, with no promises regarding which net_ns it is about" is the
intended behaviour here, especially since readdir() called after that
will skip all sysfs nodes with non-NULL ->s_ns, i.e. show empty class/net.

Frankly, my preference would be to kill the void * nonsense, introduce a
structure we'll embed into struct net (and all future tags) containing
refcount and "it is doomed, skip it" flag.  Purely passive refs - i.e. all
they guarantee is that memory won't be freed under you.  Having *active* refs
(i.e. your current net->count being non-zero) contributes 1 to that counter,
kfree() is done when that counter reaches zero.  With info->ns[] contributing
to passive refcount and exit_ns logics tagging the sucker as doomed and leaving
it at that.  kill_sb() would drop references, lookup and readdir check if
ns is doomed and skip the entry in that case.

However, it's your code and I don't know in which direction do you plan to take
it.  IMO it's badly overdesigned...

Are you OK with the sketch above?  I can probably cook a patch along those
lines by tomorrow...
