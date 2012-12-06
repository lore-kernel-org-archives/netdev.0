From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH v2 3/3] tun: fix LSM/SELinux labeling of tun/tap
 devices
Date: Thu, 6 Dec 2012 22:57:16 +0200
Message-ID: <20121206205716.GA6576@redhat.com>
References: <20121205202144.18626.61966.stgit@localhost>
 <7448004.siKCIqQqTi@sifl>
 <20121206161200.GA4340@redhat.com>
 <6001427.qD54i2BbtH@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov, jasowang@redhat.com
To: Paul Moore <pmoore@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6001427.qD54i2BbtH@sifl>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 06, 2012 at 11:56:45AM -0500, Paul Moore wrote:
> The SETQUEUE/tun_socket:create_queue permissions do not yet exist in any 
> released SELinux policy as we are just now adding them with this patchset.  
> With current policies loaded into a kernel with this patchset applied the 
> SETQUEUE/tun_socket:create_queue permission would be treated according to the 
> policy's unknown permission setting.


OK I think we need to rethink what we are doing here: what you sent
addresses the problem as stated but I think we mis-stated it.  Let me
try to restate the problem: it is not just selinux problem.  Let's
assume qemu wants to use tun, I (libvirt) don't want to run it as root.

1. TUNSETIFF: I can open tun, attach an fd and pass it to qemu.
Now, qemu does not invoke TUNSETIFF so it can run without
kernel priveledges.

2. TUNSETQUEUE - I can open tun and attach a queue but this
is not what is needed since this automatically switches
to multiqueue mode - we want to change number of queues
on the fly.
So qemu needs to be allowed to run TUNSETQUEUE.
Since this checks tun_not_capable(tun) we would need
to give qemu these priveledges, and we want to avoid this
(I can go into why if it's not obvious).
 
How can we slove this?
I don't see a way without extending the interface.
Here's a simple way to extend it: pass a flag to TUNSETQUEUE
that enables/disables TX on this queue.
If TX is disabled, ignore this queue for flow steering decisions.
Allow TUNSETQUEUE for a non priveledged user if it
it already bound to the currect tun and only changes this flag.


Now I open tun and SETQUEUE with TX disabled flag. Pass it to qemu.
qemu calls SETQUEUE with TX enabled flag.

Jason? Want to try implementing and see what people think?

> -- 
> paul moore
> security and virtualization @ redhat
