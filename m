From: Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH V6 05/10] audit: log creation and deletion of namespace instances
Date: Thu, 14 May 2015 10:57:14 -0400
Message-ID: <2918460.dpKocsKt4o@x2>
References: <cover.1429252659.git.rgb@redhat.com> <2487286.y6vyJ9A3er@x2> <20150512195759.GA9832@madcap2.tricolour.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org, pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150512195759.GA9832-bcJWsdo4jJjeVoXN4CMphl7TgLCtbB0G@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tuesday, May 12, 2015 03:57:59 PM Richard Guy Briggs wrote:
> On 15/05/05, Steve Grubb wrote:
> > I think there needs to be some more discussion around this. It seems like
> > this is not exactly recording things that are useful for audit.
> 
> It seems to me that either audit has to assemble that information, or
> the kernel has to do so.  The kernel doesn't know about containers
> (yet?).

Auditing is something that has a lot of requirements imposed on it by security 
standards. There was no requirement to have an auid until audit came along and 
said that uid is not good enough to know who is issuing commands because of su 
or sudo. There was no requirement for sessionid until we had to track each 
action back to a login so we could see if the login came from the expected 
place. 

What I am saying is we have the same situation. Audit needs to track a 
container and we need an ID. The information that is being logged is not 
useful for auditing. Maybe someone wants that info in syslog, but I doubt it. 
The audit trail's purpose is to allow a security officer to reconstruct the 
events to determine what happened during some security incident.

What they would want to know is what resources were assigned; if two 
containers shared a resource, what resource and container was it shared with; 
if two containers can communicate, we need to see or control information flow 
when necessary; and we need to see termination and release of resources.

Also, if the host OS cannot make sense of the information being logged because 
the pid maps to another process name, or a uid maps to another user, or a file 
access maps to something not in the host's, then we need the container to do 
its own auditing and resolve these mappings and optionally pass these to an 
aggregation server.

Nothing else makes sense.


> > On Friday, April 17, 2015 03:35:52 AM Richard Guy Briggs wrote:
> > > Log the creation and deletion of namespace instances in all 6 types of
> > > namespaces.
> > > 
> > > Twelve new audit message types have been introduced:
> > > AUDIT_NS_INIT_MNT       1330    /* Record mount namespace instance
> > > creation
> > > */ AUDIT_NS_INIT_UTS       1331    /* Record UTS namespace instance
> > > creation */ AUDIT_NS_INIT_IPC       1332    /* Record IPC namespace
> > > instance creation */ AUDIT_NS_INIT_USER      1333    /* Record USER
> > > namespace instance creation */ AUDIT_NS_INIT_PID       1334    /* Record
> > > PID namespace instance creation */ AUDIT_NS_INIT_NET       1335    /*
> > > Record NET namespace instance creation */ AUDIT_NS_DEL_MNT        1336
> > > /* Record mount namespace instance deletion */ AUDIT_NS_DEL_UTS       
> > > 1337
> > > 
> > >    /* Record UTS namespace instance deletion */ AUDIT_NS_DEL_IPC
> > > 
> > > 1338    /* Record IPC namespace instance deletion */ AUDIT_NS_DEL_USER
> > > 
> > >  1339    /* Record USER namespace instance deletion */ AUDIT_NS_DEL_PID
> > >  
> > >    1340    /* Record PID namespace instance deletion */ AUDIT_NS_DEL_NET
> > >    
> > >     1341    /* Record NET namespace instance deletion */
> > 
> > The requirements for auditing of containers should be derived from VPP. In
> > it, it asks for selectable auditing, selective audit, and selective audit
> > review. What this means is that we need the container and all its
> > children to have one identifier that is inserted into all the events that
> > are associated with the container.
> 
> Is that requirement for the records that are sent from the kernel, or
> for the records stored by auditd, or by another facility that delivers
> those records to a final consumer?

A little of both. Selective audit means that you can set rules to include or 
exclude an event. This is done in the kernel. Selectable review means that the 
user space tools need to be able to skip past records not of interest to a 
specific line of inquiry. Also, logging everything and letting user space work 
it out later is also not a solution because the needle is harder to find in a 
larger haystack. Or, the logs may rotate and its gone forever because the 
partition is filled. 

 
> > With this, its possible to do a search for all events related to a
> > container. Its possible to exclude events from a container. Its possible
> > to not get any events.
> > 
> > The requirements also call out for the identification of the subject. This
> > means that the event should be bound to a syscall such as clone, setns, or
> > unshare.
> 
> Is it useful to have a reference of the init namespace set from which
> all others are spawned?

For things directly observable by the init name space, yes.

> If it isn't bound, I assume the subject should be added to the message
> format?  I'm thinking of messages without an audit_context such as audit
> user messages (such as AUDIT_NS_INFO and AUDIT_VIRT_CONTROL).

Making these events auxiliary records to a syscall is all that is needed. The 
same way that PATH is added to an open event. If someone wants to have 
container/namespace events, they add a rule on clone(2).


> For now, we should not need to log namespaces with AUDIT_FEATURE_CHANGE
> or AUDIT_CONFIG_CHANGE messages since only initial user namespace with
> initial pid namespace has permission to do so.  This will need to be
> addressed by having non-init config changes be limited to that container
> or set of namespaces and possibly its children.  The other possibility
> is to add the subject to the stand-alone message.
> 
> > Also, any user space events originating inside the container needs to have
> > the container ID added to the user space event - just like auid and
> > session id.
>
> This sounds like every task needs to record a container ID since that
> information is otherwise unknown by the kernel except by what might be
> provided by an audit user message such as AUDIT_VIRT_CONTROL or possibly
> the new AUDIT_NS_INFO request.

Right. The same as we record auid and ses on every event. We'll need a 
container ID logged with everything. -1 for unset, meaning init namespace.


> It could be stored in struct task_struct or in struct audit_context.  I
> don't have a suggestion on how to get that information securely into the
> kernel.

That is where I'd suggest. Its for audit subsystem needs.
 

> > Recording each instance of a name space is giving me something that I
> > cannot use to do queries required by the security target. Given these
> > events, how do I locate a web server event where it accesses a watched
> > file? That authentication failed? That an update within the container
> > failed?
> > 
> > The requirements are that we have to log the creation, suspension,
> > migration, and termination of a container. The requirements are not on
> > the individual name space.
> 
> Ok.  Do we have a robust definition of a container? 

We call the combination of name spaces, cgroups, and seccomp rules a 
container.

> Where is that definition managed?

In the thing that invokes a container.

> If it is a userspace concept, then I think either userspace should be
> assembling this information, or providing that information to the entity
> that will be expected to know about and provide it.

Well, uid is a userspace concept, too. But we record an auid and keep it 
immutable so that we can check enforcement of system security policy which is 
also a user space concept. These things need to be collected to a place that 
can be associated with events as needed. That place is the kernel.


> > Maybe I'm missing how these events give me that. But I'd like to hear how
> > I
> > would be able to meet requirements with these 12 events.
> 
> Adding the infrastructure to give each of those 12 events an audit
> context to be able to give meaningful subject fields in audit records
> appears to require adding a struct task_struct argument to calls to
> copy_mnt_ns(), copy_utsname(), copy_ipcs(), copy_pid_ns(),
> copy_net_ns(), create_user_ns() unless I use current.  I think we must
> use current since the userns is created before the spawned process is
> mature or has an audit context in the case of clone.

I think you are heading down the wrong path. We can tell from syscall flags 
what is being done. Try this:

## Optional - log container creation
-a always,exit -F arch=b32 -S clone -F a0&0x7C020000 -F key=container-create
-a always,exit -F arch=b64 -S clone -F a0&0x7C020000 -F key=container-create

## Optional - watch for containers that may change their configuration
-a always,exit -F arch=b32 -S unshare,setns -F key=container-config
-a always,exit -F arch=b64 -S unshare,setns -F key=container-config

Then muck with containers, then use ausearch --start recent -k container -i. I 
think you'll see that we know a bit about what's happening. What's needed is 
the breadcrumb trail to tie future events back to the container so that we can 
check for violations of host security policy.

> Either that, or I have mis-understood and I should be stashing this
> namespace ID information in an audit_aux_data structure or a more
> permanent part of struct audit_context to be printed when required on
> syscall exit.  I'm trying to think through if it is needed in any
> non-syscall audit messages.

I think this is what is required. But we also have the issue where an event's 
meaning can't be determined outside of a container. (For example, login, 
account creation, password change, uid change, file access, etc.) So, I think 
auditing needs to be local to the container for enrichment and ultimately 
forwarded to an aggregating server.

-Steve
