From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: RFC: Audit Kernel Container IDs
Date: Wed, 13 Sep 2017 13:13:28 -0400
Message-ID: <20170913171328.GP3405@madcap2.tricolour.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Aristeu Rozanski <arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
        Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>, jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        Paul Moore <pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>,
        Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, trondmy-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org,
        Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
To: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Audit <linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Containers are a userspace concept.  The kernel knows nothing of them.

The Linux audit system needs a way to be able to track the container
provenance of events and actions.  Audit needs the kernel's help to do
this.

Since the concept of a container is entirely a userspace concept, a
trigger signal from the userspace container orchestration system
initiates this.  This will define a point in time and a set of resources
associated with a particular container with an audit container ID.

The trigger is a pseudo filesystem (proc, since PID tree already exists)
write of a u64 representing the container ID to a file representing a
process that will become the first process in a new container.
This might place restrictions on mount namespaces required to define a
container, or at least careful checking of namespaces in the kernel to
verify permissions of the orchestrator so it can't change its own
container ID.
A bind mount of nsfs may be necessary in the container orchestrator's
mntNS.

Require a new CAP_CONTAINER_ADMIN to be able to write to the pseudo
filesystem to have this action permitted.  At that time, record the
child container's user-supplied 64-bit container identifier along with
the child container's first process (which may become the container's
"init" process) process ID (referenced from the initial PID namespace),
all namespace IDs (in the form of a nsfs device number and inode number
tuple) in a new auxilliary record AUDIT_CONTAINER with a qualifying
op=$action field.

Issue a new auxilliary record AUDIT_CONTAINER_INFO for each valid
container ID present on an auditable action or event.

Forked and cloned processes inherit their parent's container ID,
referenced in the process' audit_context struct.

Log the creation of every namespace, inheriting/adding its spawning
process' containerID(s), if applicable.  Include the spawning and
spawned namespace IDs (device and inode number tuples).
[AUDIT_NS_CREATE, AUDIT_NS_DESTROY] [clone(2), unshare(2), setns(2)]
Note: At this point it appears only network namespaces may need to track
container IDs apart from processes since incoming packets may cause an
auditable event before being associated with a process.

Log the destruction of every namespace when it is no longer used by any
process, include the namespace IDs (device and inode number tuples).
[AUDIT_NS_DESTROY] [process exit, unshare(2), setns(2)]

Issue a new auxilliary record AUDIT_NS_CHANGE listing (opt: op=$action)
the parent and child namespace IDs for any changes to a process'
namespaces. [setns(2)]
Note: It may be possible to combine AUDIT_NS_* record formats and
distinguish them with an op=$action field depending on the fields
required for each message type.

A process can be moved from one container to another by using the
container assignment method outlined above a second time.

When a container ceases to exist because the last process in that
container has exited and hence the last namespace has been destroyed and
its refcount dropping to zero, log the fact.
(This latter is likely needed for certification accountability.)  A
container object may need a list of processes and/or namespaces.

A namespace cannot directly migrate from one container to another but
could be assigned to a newly spawned container.  A namespace can be
moved from one container to another indirectly by having that namespace
used in a second process in another container and then ending all the
processes in the first container.

Feedback please.

- RGB

--
Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sr. S/W Engineer, Kernel Security, Base Operating Systems
Remote, Ottawa, Red Hat Canada
IRC: rgb, SunRaycer
Voice: +1.647.777.2635, Internal: (81) 32635
