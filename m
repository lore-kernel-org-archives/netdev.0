From: Richard Guy Briggs <rgb@redhat.com>
Subject: Re: RFC(v2): Audit Kernel Container IDs
Date: Thu, 19 Oct 2017 15:57:47 -0400
Message-ID: <20171019195747.4ssujtaj3f5ipsoh@madcap2.tricolour.ca>
References: <20171012141359.saqdtnodwmbz33b2@madcap2.tricolour.ca>
 <2307769.VGpzlLa4Dp@x2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cgroups@vger.kernel.org,
        Linux Containers <containers@lists.linux-foundation.org>,
        Linux API <linux-api@vger.kernel.org>,
        Linux Audit <linux-audit@redhat.com>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        Linux Network Development <netdev@vger.kernel.org>,
        Simo Sorce <simo@redhat.com>,
        Carlos O'Donell <carlos@redhat.com>,
        Aristeu Rozanski <arozansk@redhat.com>,
        David Howells <dhowells@redhat.com>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Eric Paris <eparis@parisplace.org>, jlayton@redhat.com,
        Andy Lutomirski <luto@kernel.org>, mszeredi@redhat.com,
        Paul Moore <pmoore@redhat.com>,
        "Serge E. Hallyn" <serge@hallyn.com>, trondmy@primarydata.com,
        Al Viro <viro@zeniv.linux.org.uk>
To: Steve Grubb <sgrubb@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33136 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753515AbdJST6j (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Oct 2017 15:58:39 -0400
Content-Disposition: inline
In-Reply-To: <2307769.VGpzlLa4Dp@x2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-10-12 15:45, Steve Grubb wrote:
> On Thursday, October 12, 2017 10:14:00 AM EDT Richard Guy Briggs wrote:
> > Containers are a userspace concept.  The kernel knows nothing of them.
> > 
> > The Linux audit system needs a way to be able to track the container
> > provenance of events and actions.  Audit needs the kernel's help to do
> > this.
> > 
> > Since the concept of a container is entirely a userspace concept, a
> > registration from the userspace container orchestration system initiates
> > this.  This will define a point in time and a set of resources
> > associated with a particular container with an audit container ID.
> 
> The requirements for common criteria around containers should be very closely 
> modeled on the requirements for virtualization. It would be the container 
> manager that is responsible for logging the resource assignment events.

I suspect we are in violent agreement here.

> > The registration is a pseudo filesystem (proc, since PID tree already
> > exists) write of a u8[16] UUID representing the container ID to a file
> > representing a process that will become the first process in a new
> > container.  This write might place restrictions on mount namespaces
> > required to define a container, or at least careful checking of
> > namespaces in the kernel to verify permissions of the orchestrator so it
> > can't change its own container ID.  A bind mount of nsfs may be
> > necessary in the container orchestrator's mntNS.
> > Note: Use a 128-bit scalar rather than a string to make compares faster
> > and simpler.
> > 
> > Require a new CAP_CONTAINER_ADMIN to be able to carry out the
> > registration.
> 
> Wouldn't CAP_AUDIT_WRITE be sufficient? After all, this is for auditing.

No, because then any process with that capability (vsftpd) could change
its own container ID.  This is discussed more in other parts of the
thread...

> > At that time, record the target container's user-supplied
> > container identifier along with the target container's first process
> > (which may become the target container's "init" process) process ID
> > (referenced from the initial PID namespace), all namespace IDs (in the
> > form of a nsfs device number and inode number tuple) in a new auxilliary
> > record AUDIT_CONTAINER with a qualifying op=$action field.
> 
> This would be in addition to the normal audit fields.

It was intended that this be an auxilliary record, but this issue is
being debated in threads about other upstream issues currently so I
won't cover that here.

> > Issue a new auxilliary record AUDIT_CONTAINER_INFO for each valid
> > container ID present on an auditable action or event.
> > 
> > Forked and cloned processes inherit their parent's container ID,
> > referenced in the process' task_struct.
> > 
> > Mimic setns(2) and return an error if the process has already initiated
> > threading or forked since this registration should happen before the
> > process execution is started by the orchestrator and hence should not
> > yet have any threads or children.  If this is deemed overly restrictive,
> > switch all threads and children to the new containerID.
> > 
> > Trust the orchestrator to judiciously use and restrict CAP_CONTAINER_ADMIN.
> > 
> > Log the creation of every namespace, inheriting/adding its spawning
> > process' containerID(s), if applicable.  Include the spawning and
> > spawned namespace IDs (device and inode number tuples).
> > [AUDIT_NS_CREATE, AUDIT_NS_DESTROY] [clone(2), unshare(2), setns(2)]
> > Note: At this point it appears only network namespaces may need to track
> > container IDs apart from processes since incoming packets may cause an
> > auditable event before being associated with a process.
> > 
> > Log the destruction of every namespace when it is no longer used by any
> > process, include the namespace IDs (device and inode number tuples).
> > [AUDIT_NS_DESTROY] [process exit, unshare(2), setns(2)]
> 
> In the virtualization requirements, we only log removal of resources when 
> something is removed by intention. If the VM shuts down, the manager issues a 
> VIRT_CONTROL stop event and the user space utilities knows this means all 
> resources have been unassigned.

Ok, this assumes the orchestrator is waiting on that child process (and
that it is in turn waiting on all its children) so it knows when that
job has exited naturally or errored out.  I don't know if there is any
consensus or best practice with orchestrators out there now.  The kernel
should know, so it seemed reasonable to report what was known.  Besides,
in this case, I was talking specifically about namespace creation and
destruction rather than containers.

> > Issue a new auxilliary record AUDIT_NS_CHANGE listing (opt: op=$action)
> > the parent and child namespace IDs for any changes to a process'
> > namespaces. [setns(2)]
> > Note: It may be possible to combine AUDIT_NS_* record formats and
> > distinguish them with an op=$action field depending on the fields
> > required for each message type.
> > 
> > When a container ceases to exist because the last process in that
> > container has exited and hence the last namespace has been destroyed and
> > its refcount dropping to zero, log the fact.
> > (This latter is likely needed for certification accountability.)  A
> > container object may need a list of processes and/or namespaces.
> > 
> > A namespace cannot directly migrate from one container to another but
> > could be assigned to a newly spawned container.  A namespace can be
> > moved from one container to another indirectly by having that namespace
> > used in a second process in another container and then ending all the
> > processes in the first container.
> 
> I'm thinking that there needs to be a clear delineation between what the 
> container manager is responsible for and what the kernel needs to do. The 
> kernel needs the registration system and to associate an identifier with 
> events inside the container.

Agreed this needs to be defined much better than it is.

> But would the container manager be mostly responsible for auditing the events 
> described here:
> 
> https://github.com/linux-audit/audit-documentation/wiki/SPEC-Virtualization-Manager-Guest-Lifecycle-Events

I'm having trouble fitting all these events into the container model,
but recognize its importance in continuing to try to do so or to be able
to justify deviations from this SPEC.

> Also, we can already audit exit, unshare, setns, and clone. If the kernel just 
> sticks the identifier on them, isn't that sufficient?

I think this last one is incomplete without a way to identify the
namespaces involved.

> -Steve
> 
> > (v2)
> > - switch from u64 to u128 UUID
> > - switch from "signal" and "trigger" to "register"
> > - restrict registration to single process or force all threads and children
> > into same container
> > 
> > - RGB

- RGB
