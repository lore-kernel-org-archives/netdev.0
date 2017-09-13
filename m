From: Carlos O'Donell <carlos@redhat.com>
Subject: Re: RFC: Audit Kernel Container IDs
Date: Wed, 13 Sep 2017 14:33:52 -0500
Message-ID: <9043cc5a-e624-10c9-1906-f29010c5f57c@redhat.com>
References: <20170913171328.GP3405@madcap2.tricolour.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Aristeu Rozanski <arozansk@redhat.com>,
        David Howells <dhowells@redhat.com>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Eric Paris <eparis@parisplace.org>, jlayton@redhat.com,
        Andy Lutomirski <luto@kernel.org>, mszeredi@redhat.com,
        Paul Moore <pmoore@redhat.com>,
        "Serge E. Hallyn" <serge@hallyn.com>,
        Steve Grubb <sgrubb@redhat.com>, trondmy@primarydata.com,
        Al Viro <viro@zeniv.linux.org.uk>
To: Richard Guy Briggs <rgb@redhat.com>, cgroups@vger.kernel.org,
        Linux Containers <containers@lists.linux-foundation.org>,
        Linux API <linux-api@vger.kernel.org>,
        Linux Audit <linux-audit@redhat.com>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        Linux Network Development <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170913171328.GP3405@madcap2.tricolour.ca>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/13/2017 12:13 PM, Richard Guy Briggs wrote:
> Containers are a userspace concept.  The kernel knows nothing of them.

I am looking at this RFC from a userspace perspective, particularly from
the loader's point of view and the unshare syscall and the semantics that
arise from the use of it.

At a high level what you are doing is providing a way to group, without
hierarchy, processes and namespaces. The processes can move between
container's if they have CAP_CONTAINER_ADMIN and can open and write to
a special proc file.

* With unshare a thread may dissociate part of its execution context and
  therefore see a distinct mount namespace. When you say "process" in this
  particular RFC do you exclude the fact that a thread might be in a
  distinct container from the rest of the threads in the process?

> The Linux audit system needs a way to be able to track the container
> provenance of events and actions.  Audit needs the kernel's help to do
> this.

* Why does the Linux audit system need to tracker container provenance?

  - How does it help to provide better audit messages?

  - Is it be enough to list the namespace that a process occupies?

* Why does it need the kernel's help?

  - Is there a race condition that is only fixable with kernel support?

  - Or is it easier with kernel help but not required?

Providing background on these questions would help clarify the
design requirements.

> Since the concept of a container is entirely a userspace concept, a
> trigger signal from the userspace container orchestration system
> initiates this.  This will define a point in time and a set of resources
> associated with a particular container with an audit container ID.

Please don't use the word 'signal', I suggest 'register' since you are
writing to a filesystem.

> The trigger is a pseudo filesystem (proc, since PID tree already exists)
> write of a u64 representing the container ID to a file representing a
> process that will become the first process in a new container.
> This might place restrictions on mount namespaces required to define a
> container, or at least careful checking of namespaces in the kernel to
> verify permissions of the orchestrator so it can't change its own
> container ID.
> A bind mount of nsfs may be necessary in the container orchestrator's
> mntNS.
> 
> Require a new CAP_CONTAINER_ADMIN to be able to write to the pseudo
> filesystem to have this action permitted.  At that time, record the
> child container's user-supplied 64-bit container identifier along with

What is a "child container?" Containers don't have any hierarchy.

I assume that if you don't have CAP_CONTAINER_ADMIN, that nothing prevents
your continued operation as we have today?

> the child container's first process (which may become the container's
> "init" process) process ID (referenced from the initial PID namespace),
> all namespace IDs (in the form of a nsfs device number and inode number
> tuple) in a new auxilliary record AUDIT_CONTAINER with a qualifying
> op=$action field.

What kind of requirement is there on the first tid/pid registering
the container ID? What if the 8th tid/pid does the registration?
Would that mean that the first process of the container did not
register? It seems like you are suggesting that the registration
by the 8th tid/pid causes a cascading registration progress,
registering all tid/pids in the same grouping? Is that true?

> Issue a new auxilliary record AUDIT_CONTAINER_INFO for each valid
> container ID present on an auditable action or event.
> 
> Forked and cloned processes inherit their parent's container ID,
> referenced in the process' audit_context struct.

So a cloned process with CLONE_NEWNS has the came container ID
as the parent process that called clone, at least until the clone
has time to change to a new container ID?

Do you forsee any case where someone might need a semantic that is
slightly different? For example wanting to set the container ID on
clone?

> Log the creation of every namespace, inheriting/adding its spawning
> process' containerID(s), if applicable.  Include the spawning and
> spawned namespace IDs (device and inode number tuples).
> [AUDIT_NS_CREATE, AUDIT_NS_DESTROY] [clone(2), unshare(2), setns(2)]
> Note: At this point it appears only network namespaces may need to track
> container IDs apart from processes since incoming packets may cause an
> auditable event before being associated with a process.

OK.

> Log the destruction of every namespace when it is no longer used by any
> process, include the namespace IDs (device and inode number tuples).
> [AUDIT_NS_DESTROY] [process exit, unshare(2), setns(2)]
> 
> Issue a new auxilliary record AUDIT_NS_CHANGE listing (opt: op=$action)
> the parent and child namespace IDs for any changes to a process'
> namespaces. [setns(2)]
> Note: It may be possible to combine AUDIT_NS_* record formats and
> distinguish them with an op=$action field depending on the fields
> required for each message type.
> 
> A process can be moved from one container to another by using the
> container assignment method outlined above a second time.

OK.

> When a container ceases to exist because the last process in that
> container has exited and hence the last namespace has been destroyed and
> its refcount dropping to zero, log the fact.
> (This latter is likely needed for certification accountability.)  A
> container object may need a list of processes and/or namespaces.

OK.

> A namespace cannot directly migrate from one container to another but
> could be assigned to a newly spawned container.  A namespace can be
> moved from one container to another indirectly by having that namespace
> used in a second process in another container and then ending all the
> processes in the first container.

OK.

> Feedback please.

-- 
Cheers,
Carlos.
