From: Paul Moore <pmoore@redhat.com>
Subject: Re: [RFC PATCH v2 3/3] tun: fix LSM/SELinux labeling of tun/tap devices
Date: Mon, 10 Dec 2012 12:33:49 -0500
Message-ID: <3124654.2UMIXvF0vN@sifl>
References: <20121205202144.18626.61966.stgit@localhost> <5998443.squEvSxCG9@sifl> <20121210172656.GA30775@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov, jasowang@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34374 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752739Ab2LJRdx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Dec 2012 12:33:53 -0500
In-Reply-To: <20121210172656.GA30775@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, December 10, 2012 07:26:56 PM Michael S. Tsirkin wrote:
> On Mon, Dec 10, 2012 at 12:04:35PM -0500, Paul Moore wrote:
> > On Friday, December 07, 2012 02:25:16 PM Michael S. Tsirkin wrote:
> > > On Thu, Dec 06, 2012 at 04:09:51PM -0500, Paul Moore wrote:
> > > > On Thursday, December 06, 2012 10:57:16 PM Michael S. Tsirkin wrote:
> > > > > On Thu, Dec 06, 2012 at 11:56:45AM -0500, Paul Moore wrote:
> > > > > > The SETQUEUE/tun_socket:create_queue permissions do not yet exist
> > > > > > in any released SELinux policy as we are just now adding them with
> > > > > > this patchset. With current policies loaded into a kernel with
> > > > > > this patchset applied the SETQUEUE/tun_socket:create_queue
> > > > > > permission would be treated according to the policy's unknown
> > > > > > permission setting.
> > > > > 
> > > > > OK I think we need to rethink what we are doing here: what you sent
> > > > > addresses the problem as stated but I think we mis-stated it.  Let
> > > > > me try to restate the problem: it is not just selinux problem. Let's
> > > > > assume qemu wants to use tun, I (libvirt) don't want to run it as
> > > > > root.
> > > > > 
> > > > > 1. TUNSETIFF: I can open tun, attach an fd and pass it to qemu.
> > > > > Now, qemu does not invoke TUNSETIFF so it can run without
> > > > > kernel priveledges.
> > > > 
> > > > Correct me if I'm wrong, but I believe libvirt does this while running
> > > > as root.  Assuming that is the case, why not simply setuid()/setgid()
> > > > to the same credentials as the QEMU instance before creating the TUN
> > > > device? You can always (re)configure the device afterwards while
> > > > running as root/CAP_NET_ADMIN.
> > > 
> > > We want isolation between qemu instances.
> > 
> > Understood, I agree.
> > 
> > Achieving separation via SELinux is easily done, with libvirt/sVirt
> > already doing this for us automatically in most cases; the only thing we
> > will want to do is make sure the SELinux policy is aware of the new
> > permission.
> > 
> > Achieving separation via DAC should also be easily done, simply run each
> > QEMU instance with a separate UID and/or GID.
> > 
> > > Giving qemu right to open tun and SETIFF would give it rights
> > > to access any tun device.
> > 
> > I'm quickly looked at tun_chr_open() again and I don't see any special
> > rights/privileges required, the same for tun_chr_ioctl() and
> > __tun_chr_ioctl().  Looking at tun_set_queue() I see we call
> > tun_not_capable() which does a simple DAC check; it must have the same
> > UID/GID or have CAP_NET_ADMIN.
> > 
> > I'm having a hard time seeing the problem you are describing; help me
> > understand.
> 
> The issue is guest controls the number of queues in use.
> So qemu would be required to be allowed to call tun_set_queue.
> If we allow this we have a problem as one qemu will be
> able to access any tun.

QEMU can call tun_set_queue() as long as it satisfies tun_not_capable(), which 
from a practical point of view means that the TUN device was created with the 
same UID/GID as the QEMU instance.  If you want TUN device separation between 
QEMU instances using DAC you need to run each QEMU instance with a different 
UID/GID (which you should be doing anyway if you want DAC enforced general 
separation).

I believe I've stated this point several times now and I don't feel you've 
addressed it properly.

-- 
paul moore
security and virtualization @ redhat
