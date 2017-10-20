From: Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: RFC(v2): Audit Kernel Container IDs
Date: Thu, 19 Oct 2017 22:25:54 -0400
Message-ID: <2180320.n4TdndeGoA@x2>
References: <20171012141359.saqdtnodwmbz33b2@madcap2.tricolour.ca> <20171019195747.4ssujtaj3f5ipsoh@madcap2.tricolour.ca> <8f495870-dd6c-23b9-b82b-4228a441c729@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        trondmy-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org, Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Carlos O'Donell <carlos-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
        Paul Moore <pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>,
        Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
        David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Linux Audit <linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Simo Sorce <simo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Linux Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
To: Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <8f495870-dd6c-23b9-b82b-4228a441c729-l3A5Bk7waGM@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday, October 19, 2017 7:11:33 PM EDT Aleksa Sarai wrote:
> >>> The registration is a pseudo filesystem (proc, since PID tree already
> >>> exists) write of a u8[16] UUID representing the container ID to a file
> >>> representing a process that will become the first process in a new
> >>> container.  This write might place restrictions on mount namespaces
> >>> required to define a container, or at least careful checking of
> >>> namespaces in the kernel to verify permissions of the orchestrator so it
> >>> can't change its own container ID.  A bind mount of nsfs may be
> >>> necessary in the container orchestrator's mntNS.
> >>> Note: Use a 128-bit scalar rather than a string to make compares faster
> >>> and simpler.
> >>> 
> >>> Require a new CAP_CONTAINER_ADMIN to be able to carry out the
> >>> registration.
> >> 
> >> Wouldn't CAP_AUDIT_WRITE be sufficient? After all, this is for auditing.
> > 
> > No, because then any process with that capability (vsftpd) could change
> > its own container ID.  This is discussed more in other parts of the
> > thread...

For the record, I changed my mind. CAP_AUDIT_CONTROL is the correct 
capability. 

> Not if we make the container ID append-only (to support nesting), or
> write-once (the other idea thrown around). 

Well...I like to use lessons learned if they can be applied. In the normal 
world without containers we have uid, auid, and session_id. uid is who you are 
now, auid is how you got into the system, session_id distinguishes individual 
auids. We have a default auid of -1 for system objects and a real number for 
people.

I think there should be the equivalent of auid and session_id but tailored for 
containers. Loginuid == container id. It can be set, overridden, or appended 
to (we'll figure this out later) in very limited circumstances. 
Container_session == session which is tamper-proof. This way things can enter 
a container with the same ID but under a different session. And everything 
else gets to inherit the original ID. This way we can trace actions to 
something that entered the container rather than normal system activity in the 
container.

What a security officer wants to know is what did people do inside the 
system / container. The system objects we typically don't care about. Sure 
they might get hacked and then work on behalf of someone, but they would 
almost always pop a shell so that they can have freedom. That should set off 
an AVC or create other activity that gets picked up.

-Steve

> In that case, you can't move "out" from a particular container ID, you can
> only go "deeper". These semantics don't make sense for generic containers,
> but since the point of this facility is *specifically* for audit I imagine
> that not being able to move a process from a sub-container's ID is a
> benefit.
