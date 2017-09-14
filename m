From: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: RFC: Audit Kernel Container IDs
Date: Thu, 14 Sep 2017 01:30:08 -0400
Message-ID: <20170914053007.GR3405@madcap2.tricolour.ca>
References: <20170913171328.GP3405@madcap2.tricolour.ca>
 <9043cc5a-e624-10c9-1906-f29010c5f57c@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Audit <linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Aristeu Rozanski <arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
        Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>, jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        Paul Moore <pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>,
        Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, trondmy-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org,
        Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
To: Carlos O'Donell <carlos-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <9043cc5a-e624-10c9-1906-f29010c5f57c-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2017-09-13 14:33, Carlos O'Donell wrote:
> On 09/13/2017 12:13 PM, Richard Guy Briggs wrote:
> > Containers are a userspace concept.  The kernel knows nothing of them.
> 
> I am looking at this RFC from a userspace perspective, particularly from
> the loader's point of view and the unshare syscall and the semantics that
> arise from the use of it.
> 
> At a high level what you are doing is providing a way to group, without
> hierarchy, processes and namespaces. The processes can move between
> container's if they have CAP_CONTAINER_ADMIN and can open and write to
> a special proc file.
> 
> * With unshare a thread may dissociate part of its execution context and
>   therefore see a distinct mount namespace. When you say "process" in this
>   particular RFC do you exclude the fact that a thread might be in a
>   distinct container from the rest of the threads in the process?
> 
> > The Linux audit system needs a way to be able to track the container
> > provenance of events and actions.  Audit needs the kernel's help to do
> > this.
> 
> * Why does the Linux audit system need to tracker container provenance?

- ability to filter unwanted, irrelevant or unimportant messages before
  they fill queue so important messages don't get lost.  This is a
  certification requirement.

- ability to make security claims about containers, require tracking of
  actions within those containers to ensure compliance with established
  security policies.

- ability to route messages from events to relevant audit daemon
  instance or host audit daemon instance or both, as required or
  determined by user-initiated rules

>   - How does it help to provide better audit messages?
> 
>   - Is it be enough to list the namespace that a process occupies?

We started with that approach back more than 4 years ago and found it
helped, but didn't go far enough in terms of quick and inexpensive
record filtering and left some doubt about provenance of events in the
case of non-user context events (incoming network packets).

> * Why does it need the kernel's help?
> 
>   - Is there a race condition that is only fixable with kernel support?

This was a concern, but relatively minor compared with the other benefits.

>   - Or is it easier with kernel help but not required?

It is much easier and much less expensive.

> Providing background on these questions would help clarify the
> design requirements.

Here are some references that should help provide some background:
	https://github.com/linux-audit/audit-kernel/issues/32
	RFE: add namespace IDs to audit records

	https://github.com/linux-audit/audit-documentation/wiki/SPEC-Virtualization-Manager-Guest-Lifecycle-Events
	SPEC Virtualization Manager Guest Lifecycle Events

	https://lwn.net/Articles/699819/
	Audit, namespaces, and containers

	https://lwn.net/Articles/723561/
	Containers as kernel objects
	(my reply, with references: https://lkml.org/lkml/2017/8/14/15 )

	https://bugzilla.redhat.com/show_bug.cgi?id=1045666
	audit: add namespace IDs to log records

> > Since the concept of a container is entirely a userspace concept, a
> > trigger signal from the userspace container orchestration system
> > initiates this.  This will define a point in time and a set of resources
> > associated with a particular container with an audit container ID.
> 
> Please don't use the word 'signal', I suggest 'register' since you are
> writing to a filesystem.

Ok, that's a very reasonable request.  'signal' has a previous meaning.

> > The trigger is a pseudo filesystem (proc, since PID tree already exists)
> > write of a u64 representing the container ID to a file representing a
> > process that will become the first process in a new container.
> > This might place restrictions on mount namespaces required to define a
> > container, or at least careful checking of namespaces in the kernel to
> > verify permissions of the orchestrator so it can't change its own
> > container ID.
> > A bind mount of nsfs may be necessary in the container orchestrator's
> > mntNS.
> > 
> > Require a new CAP_CONTAINER_ADMIN to be able to write to the pseudo
> > filesystem to have this action permitted.  At that time, record the
> > child container's user-supplied 64-bit container identifier along with
> 
> What is a "child container?" Containers don't have any hierarchy.

Maybe some don't, but that's not likely to last long given the
abstraction and nesting of orchestration tools.  This must be nestable.

> I assume that if you don't have CAP_CONTAINER_ADMIN, that nothing prevents
> your continued operation as we have today?

Correct.  It won't prevent processes that otherwise have permissions
today from creating all the namespaces it wishes.

> > the child container's first process (which may become the container's
> > "init" process) process ID (referenced from the initial PID namespace),
> > all namespace IDs (in the form of a nsfs device number and inode number
> > tuple) in a new auxilliary record AUDIT_CONTAINER with a qualifying
> > op=$action field.
> 
> What kind of requirement is there on the first tid/pid registering
> the container ID? What if the 8th tid/pid does the registration?
> Would that mean that the first process of the container did not
> register? It seems like you are suggesting that the registration
> by the 8th tid/pid causes a cascading registration progress,
> registering all tid/pids in the same grouping? Is that true?

Ah, good question, I forgot to address that fact.  The intent is that
either threaded processes after initiating threading will not have
permission to execute this, or all the processes in the thread group
will be forced into the same container.  I don't have a strong opinion
on whether or not it must be the lead thread process that must be the
one to receive that registration, but I suspect that would be wise.

> > Issue a new auxilliary record AUDIT_CONTAINER_INFO for each valid
> > container ID present on an auditable action or event.
> > 
> > Forked and cloned processes inherit their parent's container ID,
> > referenced in the process' audit_context struct.
> 
> So a cloned process with CLONE_NEWNS has the came container ID
> as the parent process that called clone, at least until the clone
> has time to change to a new container ID?

Yes.

> Do you forsee any case where someone might need a semantic that is
> slightly different? For example wanting to set the container ID on
> clone?

I could envision that situation and I think that might be workable but
for the synchronicity of having one initiated by a specific syscall and
the other initiated by a /proc write.

> > Log the creation of every namespace, inheriting/adding its spawning
> > process' containerID(s), if applicable.  Include the spawning and
> > spawned namespace IDs (device and inode number tuples).
> > [AUDIT_NS_CREATE, AUDIT_NS_DESTROY] [clone(2), unshare(2), setns(2)]
> > Note: At this point it appears only network namespaces may need to track
> > container IDs apart from processes since incoming packets may cause an
> > auditable event before being associated with a process.
> 
> OK.
> 
> > Log the destruction of every namespace when it is no longer used by any
> > process, include the namespace IDs (device and inode number tuples).
> > [AUDIT_NS_DESTROY] [process exit, unshare(2), setns(2)]
> > 
> > Issue a new auxilliary record AUDIT_NS_CHANGE listing (opt: op=$action)
> > the parent and child namespace IDs for any changes to a process'
> > namespaces. [setns(2)]
> > Note: It may be possible to combine AUDIT_NS_* record formats and
> > distinguish them with an op=$action field depending on the fields
> > required for each message type.
> > 
> > A process can be moved from one container to another by using the
> > container assignment method outlined above a second time.
> 
> OK.
> 
> > When a container ceases to exist because the last process in that
> > container has exited and hence the last namespace has been destroyed and
> > its refcount dropping to zero, log the fact.
> > (This latter is likely needed for certification accountability.)  A
> > container object may need a list of processes and/or namespaces.
> 
> OK.
> 
> > A namespace cannot directly migrate from one container to another but
> > could be assigned to a newly spawned container.  A namespace can be
> > moved from one container to another indirectly by having that namespace
> > used in a second process in another container and then ending all the
> > processes in the first container.
> 
> OK.
> 
> > Feedback please.

Thank you sir!

> Carlos.

- RGB

--
Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sr. S/W Engineer, Kernel Security, Base Operating Systems
Remote, Ottawa, Red Hat Canada
IRC: rgb, SunRaycer
Voice: +1.647.777.2635, Internal: (81) 32635
