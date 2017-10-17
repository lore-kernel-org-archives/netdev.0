From: Richard Guy Briggs <rgb@redhat.com>
Subject: Re: RFC(v2): Audit Kernel Container IDs
Date: Mon, 16 Oct 2017 20:33:40 -0400
Message-ID: <20171017003340.whjdkqmkw4lydwy7@madcap2.tricolour.ca>
References: <20171012141359.saqdtnodwmbz33b2@madcap2.tricolour.ca>
 <75b7d6a6-42ba-2dff-1836-1091c7c024e7@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cgroups@vger.kernel.org,
        Linux Containers <containers@lists.linux-foundation.org>,
        Linux API <linux-api@vger.kernel.org>,
        Linux Audit <linux-audit@redhat.com>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        Linux Network Development <netdev@vger.kernel.org>,
        mszeredi@redhat.com, Andy Lutomirski <luto@kernel.org>,
        jlayton@redhat.com, Carlos O'Donell <carlos@redhat.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        David Howells <dhowells@redhat.com>,
        Simo Sorce <simo@redhat.com>, trondmy@primarydata.com,
        Eric Paris <eparis@parisplace.org>,
        "Serge E. Hallyn" <serge@hallyn.com>,
        "Eric W. Biederman" <ebiederm@xmission.com>
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <75b7d6a6-42ba-2dff-1836-1091c7c024e7@schaufler-ca.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2017-10-12 16:33, Casey Schaufler wrote:
> On 10/12/2017 7:14 AM, Richard Guy Briggs wrote:
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
> >
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
> Hang on. If containers are a user space concept, how can
> you want CAP_CONTAINER_ANYTHING? If there's not such thing as
> a container, how can you be asking for a capability to manage
> them?

There is such a thing, but the kernel doesn't know about it yet.  This
same situation exists for loginuid and sessionid which are userspace
concepts that the kernel tracks for the convenience of userspace.  As
for its name, I'm not particularly picky, so if you don't like
CAP_CONTAINER_* then I'm fine with CAP_AUDIT_CONTAINERID.  It really
needs to be distinct from CAP_AUDIT_WRITE and CAP_AUDIT_CONTROL since we
don't want to give the ability to set a containerID to any process that
is able to do audit logging (such as vsftpd) and similarly we don't want
to give the orchestrator the ability to control the setup of the audit
daemon.
> 
> >   At that time, record the target container's user-supplied
> > container identifier along with the target container's first process
> > (which may become the target container's "init" process) process ID
> > (referenced from the initial PID namespace), all namespace IDs (in the
> > form of a nsfs device number and inode number tuple) in a new auxilliary
> > record AUDIT_CONTAINER with a qualifying op=$action field.
> >
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
> >
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
> >
> > (v2)
> > - switch from u64 to u128 UUID
> > - switch from "signal" and "trigger" to "register"
> > - restrict registration to single process or force all threads and children into same container
> >
> > - RGB

- RGB

--
Richard Guy Briggs <rgb@redhat.com>
Sr. S/W Engineer, Kernel Security, Base Operating Systems
Remote, Ottawa, Red Hat Canada
IRC: rgb, SunRaycer
Voice: +1.647.777.2635, Internal: (81) 32635
