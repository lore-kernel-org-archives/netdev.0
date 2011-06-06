From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC] breakage in sysfs_readdir() and s_instances abuse in sysfs
Date: Mon, 06 Jun 2011 12:03:52 -0700
Message-ID: <m1k4cy6auf.fsf@fess.ebiederm.org>
References: <20110604001518.GT11521@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	<netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20110604001518.GT11521@ZenIV.linux.org.uk> (Al Viro's message of
	"Sat, 4 Jun 2011 01:15:19 +0100")
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Al Viro <viro@ZenIV.linux.org.uk> writes:

> What I'm planning to do (for unrelated reasons - ubifs needs it) is to add
> an analog of iterate_supers() that would go over the superblocks of given
> type and call a function on them.  I would like to convert sysfs_exit_ns()
> to it and kill the last abuser of s_instances (and one of the last sb_lock
> ones), but that really depends on what kind of locking is needed for
> readdir() and friends - as it is, the damn thing looks *wrong*.

Answering your primary question first, what locking is needed in
sysfs_exit_ns().

Wrapping my head around this code again, to the best of my memory
the intent was.

For consistency "info->type[ns]" is an atomic value (void *) so
it can be safely read and written without relying on locks.  For
things like lookup 

The assumption is that is primarily an atomic value and so it can
be safely read by things like sysfs_readdir() and get a valid value
without relying on the locks. 

sysfs_mutex is needed in things like sysfs_lookup if we want the
value to not change.

There is indeed a small race in sysfs_readdir.

As for sysfs_lookup it looks like my code to handle untagged members in
directories where everything else is tagged, such as
"/sys/class/net/bonding_masters" introduced an overloading of what NULL
means in the context of sysfs_readdir and sysfs_lookup.   ns == NULL can
either mean that we have type == KOBJ_NS_TYPE_NONE, or ns == NULL can
mean that the namespace has gone away beneath us.  I looks like I need
to fix that.

To sysfs_exit_ns() we have the call chain:
cleanup_net()
  ops_exit_list()
     net_kobj_ns_exit()
        sysfs_exit_ns()

Which makes the locking order needed for that call path.
net_mutex()
   rtnl_lock()
   sysfs_mutex()

Now somewhere I was also careful that mount did not cause problems,
with sysfs_exit_ns() but I forget where.

You were asking about kobj_ns_current.
kboj_ns_current()
  net_current_ns()
     current->nsproxy->net_ns

And current has a reference on it's network namespace.

Other pieces of information that should be helpful to know.
- All sysfs directory entries for a network namespace should be
  removed from sysfs by the time sysfs_exit_ns is called.

Al hopefully that is enough to get you going and I will what I can
do with the rest of the sysfs ugliness.

Eric
