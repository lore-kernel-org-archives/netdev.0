From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH v2 3/3] tun: fix LSM/SELinux labeling of tun/tap
 devices
Date: Wed, 12 Dec 2012 11:10:22 +0200
Message-ID: <20121212091022.GA4354@redhat.com>
References: <20121205202144.18626.61966.stgit@localhost>
 <3124654.2UMIXvF0vN@sifl>
 <20121210175035.GA31856@redhat.com>
 <1963349.P9uq3yvlyR@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov, jasowang@redhat.com
To: Paul Moore <pmoore@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56800 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751899Ab2LLJHO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2012 04:07:14 -0500
Content-Disposition: inline
In-Reply-To: <1963349.P9uq3yvlyR@sifl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 10, 2012 at 05:43:49PM -0500, Paul Moore wrote:
> On Monday, December 10, 2012 07:50:35 PM Michael S. Tsirkin wrote:
> > On Mon, Dec 10, 2012 at 12:33:49PM -0500, Paul Moore wrote:
> > > On Monday, December 10, 2012 07:26:56 PM Michael S. Tsirkin wrote:
> > > > On Mon, Dec 10, 2012 at 12:04:35PM -0500, Paul Moore wrote:
> > > > > On Friday, December 07, 2012 02:25:16 PM Michael S. Tsirkin wrote:
> > > > > > On Thu, Dec 06, 2012 at 04:09:51PM -0500, Paul Moore wrote:
> > > > > > > On Thursday, December 06, 2012 10:57:16 PM Michael S. Tsirkin 
> wrote:
> > > > > > > > On Thu, Dec 06, 2012 at 11:56:45AM -0500, Paul Moore wrote:
> > > > > > > > > The SETQUEUE/tun_socket:create_queue permissions do not yet
> > > > > > > > > exist
> > > > > > > > > in any released SELinux policy as we are just now adding them
> > > > > > > > > with
> > > > > > > > > this patchset. With current policies loaded into a kernel with
> > > > > > > > > this patchset applied the SETQUEUE/tun_socket:create_queue
> > > > > > > > > permission would be treated according to the policy's unknown
> > > > > > > > > permission setting.
> > > > > > > > 
> > > > > > > > OK I think we need to rethink what we are doing here: what you
> > > > > > > > sent
> > > > > > > > addresses the problem as stated but I think we mis-stated it. 
> > > > > > > > Let
> > > > > > > > me try to restate the problem: it is not just selinux problem.
> > > > > > > > Let's
> > > > > > > > assume qemu wants to use tun, I (libvirt) don't want to run it
> > > > > > > > as
> > > > > > > > root.
> > > > > > > > 
> > > > > > > > 1. TUNSETIFF: I can open tun, attach an fd and pass it to qemu.
> > > > > > > > Now, qemu does not invoke TUNSETIFF so it can run without
> > > > > > > > kernel priveledges.
> > > > > > > 
> > > > > > > Correct me if I'm wrong, but I believe libvirt does this while
> > > > > > > running
> > > > > > > as root.  Assuming that is the case, why not simply
> > > > > > > setuid()/setgid()
> > > > > > > to the same credentials as the QEMU instance before creating the
> > > > > > > TUN
> > > > > > > device? You can always (re)configure the device afterwards while
> > > > > > > running as root/CAP_NET_ADMIN.
> > > > > > 
> > > > > > We want isolation between qemu instances.
> > > > > 
> > > > > Understood, I agree.
> > > > > 
> > > > > Achieving separation via SELinux is easily done, with libvirt/sVirt
> > > > > already doing this for us automatically in most cases; the only thing
> > > > > we
> > > > > will want to do is make sure the SELinux policy is aware of the new
> > > > > permission.
> > > > > 
> > > > > Achieving separation via DAC should also be easily done, simply run
> > > > > each
> > > > > QEMU instance with a separate UID and/or GID.
> > > > > 
> > > > > > Giving qemu right to open tun and SETIFF would give it rights
> > > > > > to access any tun device.
> > > > > 
> > > > > I'm quickly looked at tun_chr_open() again and I don't see any special
> > > > > rights/privileges required, the same for tun_chr_ioctl() and
> > > > > __tun_chr_ioctl().  Looking at tun_set_queue() I see we call
> > > > > tun_not_capable() which does a simple DAC check; it must have the same
> > > > > UID/GID or have CAP_NET_ADMIN.
> > > > > 
> > > > > I'm having a hard time seeing the problem you are describing; help me
> > > > > understand.
> > > > 
> > > > The issue is guest controls the number of queues in use.
> > > > So qemu would be required to be allowed to call tun_set_queue.
> > > > If we allow this we have a problem as one qemu will be
> > > > able to access any tun.
> > > 
> > > QEMU can call tun_set_queue() as long as it satisfies tun_not_capable(),
> > > which from a practical point of view means that the TUN device was
> > > created with the same UID/GID as the QEMU instance.  If you want TUN
> > > device separation between QEMU instances using DAC you need to run each
> > > QEMU instance with a different UID/GID (which you should be doing anyway
> > > if you want DAC enforced general separation).
> > > 
> > > I believe I've stated this point several times now and I don't feel you've
> > > addressed it properly.
> > 
> > Look at how it works at the moment:
> > a priveledged libvirt server calls tun_set_iff
> > and passes the fd to qemu which is not priveledged.
> > 
> > The result is isolation between qemu instances without
> > need to create uid per qemu instance.
> 
> Okay, good.  That is my understanding.
>  
> > How do we create multiple queues? It makes sense to
> > follow this model and pass in fds for individual queues.
> 
> Okay.
> 
> > However they need to be disabled initially
> > so libvirt can not do tun_set_queue for us.
> 
> Unrelated question: why do the queues need to be disabled initially?  Is this 
> to prevent traffic from being queued up?  Some other reason?  I'm just curious 
> as to the reason ...

Yes.
Basically because old guests only use a single queue.
If a guest comes along and declares multiqueue support
we can queue up traffic on new queues but if we
do this with a legacy guest it will not be able to
consume it.



> > can't utilize multiqueue.
> 
> I still don't understand why in the multiqueue case libvirt doesn't just 
> change it's effective UID/GID when creating the TUN device, or just use the 
> TUNSETOWNER/TUNSETGROUP commands. This would solve the problem you describe 
> above and - at least to me - seems like a better solution conceptually.
> 
> Help me understand why you believe that will not work.
> 
> Do you not want to give ownership of the TUN device to QEMU?  That would be 
> the only reason I can think of, but all of your comments that I can recall 
> have been about isolation between QEMU instances and not access control 
> between a QEMU instance and its assigned TUN device.

I think I might have confused things more than clarified them.
Let me comment on specific lines in patch that worry me
that will make it clear I hope.

> > My solution is an unpriveledged variant
> > of tun_set_queue that only enables/disables
> > a queue without attach/detach.
> 
> -- 
> paul moore
> security and virtualization @ redhat
