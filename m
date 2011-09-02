From: Serge Hallyn <serge@hallyn.com>
Subject: [PATCH 01/15] add Documentation/namespaces/user_namespace.txt (v3)
Date: Fri,  2 Sep 2011 19:56:26 +0000
Message-ID: <1314993400-6910-4-git-send-email-serge@hallyn.com>
References: <1314993400-6910-1-git-send-email-serge@hallyn.com>
Cc: "Serge E. Hallyn" <serge@hallyn.com>,
	"Serge E. Hallyn" <serge.hallyn@canonical.com>
To: akpm@osdl.org, segooon@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	dhowells@redhat.com, ebiederm@xmission.com, rdunlap@xenotime.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1314993400-6910-1-git-send-email-serge@hallyn.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Serge E. Hallyn" <serge@hallyn.com>

Quoting David Howells (dhowells@redhat.com):
> Randy Dunlap <rdunlap@xenotime.net> wrote:
>
> > > +Any task in or resource belonging to the initial user namespace will, to this
> > > +new task, appear to belong to UID and GID -1 - which is usually known as
> >
> > that extra hyphen is confusing.  how about:
> >
> >                               to UID and GID -1, which is
>
> 'which are'.
>
> David

This will hold some info about the design.  Currently it contains
future todos, issues and questions.

Changelog:
   jul 26: incorporate feedback from David Howells.
   jul 29: incorporate feedback from Randy Dunlap.

Signed-off-by: Serge E. Hallyn <serge.hallyn@canonical.com>
Cc: Eric W. Biederman <ebiederm@xmission.com>
Cc: David Howells <dhowells@redhat.com>
Cc: Randy Dunlap <rdunlap@xenotime.net>
---
 Documentation/namespaces/user_namespace.txt |  107 +++++++++++++++++++++++++++
 1 files changed, 107 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/namespaces/user_namespace.txt

diff --git a/Documentation/namespaces/user_namespace.txt b/Documentation/namespaces/user_namespace.txt
new file mode 100644
index 0000000..b0bc480
--- /dev/null
+++ b/Documentation/namespaces/user_namespace.txt
@@ -0,0 +1,107 @@
+Description
+===========
+
+Traditionally, each task is owned by a user ID (UID) and belongs to one or more
+groups (GID).  Both are simple numeric IDs, though userspace usually translates
+them to names.  The user namespace allows tasks to have different views of the
+UIDs and GIDs associated with tasks and other resources.  (See 'UID mapping'
+below for more.)
+
+The user namespace is a simple hierarchical one.  The system starts with all
+tasks belonging to the initial user namespace.  A task creates a new user
+namespace by passing the CLONE_NEWUSER flag to clone(2).  This requires the
+creating task to have the CAP_SETUID, CAP_SETGID, and CAP_CHOWN capabilities,
+but it does not need to be running as root.  The clone(2) call will result in a
+new task which to itself appears to be running as UID and GID 0, but to its
+creator seems to have the creator's credentials.
+
+To this new task, any resource belonging to the initial user namespace will
+appear to belong to user and group 'nobody', which are UID and GID -1.
+Permission to open such files will be granted according to world access
+permissions.  UID comparisons and group membership checks will return false,
+and privilege will be denied.
+
+When a task belonging to (for example) userid 500 in the initial user namespace
+creates a new user namespace, even though the new task will see itself as
+belonging to UID 0, any task in the initial user namespace will see it as
+belonging to UID 500.  Therefore, UID 500 in the initial user namespace will be
+able to kill the new task.  Files created by the new user will (eventually) be
+seen by tasks in its own user namespace as belonging to UID 0, but to tasks in
+the initial user namespace as belonging to UID 500.
+
+Note that this userid mapping for the VFS is not yet implemented, though the
+lkml and containers mailing list archives will show several previous
+prototypes.  In the end, those got hung up waiting on the concept of targeted
+capabilities to be developed, which, thanks to the insight of Eric Biederman,
+they finally did.
+
+Relationship between the User namespace and other namespaces
+============================================================
+
+Other namespaces, such as UTS and network, are owned by a user namespace.  When
+such a namespace is created, it is assigned to the user namespace of the task
+by which it was created.  Therefore, attempts to exercise privilege to
+resources in, for instance, a particular network namespace, can be properly
+validated by checking whether the caller has the needed privilege (i.e.
+CAP_NET_ADMIN) targeted to the user namespace which owns the network namespace.
+This is done using the ns_capable() function.
+
+As an example, if a new task is cloned with a private user namespace but
+no private network namespace, then the task's network namespace is owned
+by the parent user namespace.  The new task has no privilege to the
+parent user namespace, so it will not be able to create or configure
+network devices.  If, instead, the task were cloned with both private
+user and network namespaces, then the private network namespace is owned
+by the private user namespace, and so root in the new user namespace
+will have privilege targeted to the network namespace.  It will be able
+to create and configure network devices.
+
+UID Mapping
+===========
+The current plan (see 'flexible UID mapping' at
+https://wiki.ubuntu.com/UserNamespace) is:
+
+The UID/GID stored on disk will be that in the init_user_ns.  Most likely
+UID/GID in other namespaces will be stored in xattrs.  But Eric was advocating
+(a few years ago) leaving the details up to filesystems while providing a lib/
+stock implementation.  See the thread around here:
+http://www.mail-archive.com/devel@openvz.org/msg09331.html
+
+
+Working notes
+=============
+Capability checks for actions related to syslog must be against the
+init_user_ns until syslog is containerized.
+
+Same is true for reboot and power, control groups, devices, and time.
+
+Perf actions (kernel/event/core.c for instance) will always be constrained to
+init_user_ns.
+
+Q:
+Is accounting considered properly containerized with respect to pidns?  (it
+appears to be).  If so, then we can change the capable() check in
+kernel/acct.c to 'ns_capable(current_pid_ns()->user_ns, CAP_PACCT)'
+
+Q:
+For things like nice and schedaffinity, we could allow root in a container to
+control those, and leave only cgroups to constrain the container.  I'm not sure
+whether that is right, or whether it violates admin expectations.
+
+I deferred some of commoncap.c.  I'm punting on xattr stuff as they take
+dentries, not inodes.
+
+For drivers/tty/tty_io.c and drivers/tty/vt/vt.c, we'll want to (for some of
+them) target the capability checks at the user_ns owning the tty.  That will
+have to wait until we get userns owning files straightened out.
+
+We need to figure out how to label devices.  Should we just toss a user_ns
+right into struct device?
+
+capable(CAP_MAC_ADMIN) checks are always to be against init_user_ns, unless
+some day LSMs were to be containerized, near zero chance.
+
+inode_owner_or_capable() should probably take an optional ns and cap parameter.
+If cap is 0, then CAP_FOWNER is checked.  If ns is NULL, we derive the ns from
+inode.  But if ns is provided, then callers who need to derive
+inode_userns(inode) anyway can save a few cycles.
-- 
1.7.5.4
