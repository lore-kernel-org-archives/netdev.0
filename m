From: Jason Wang <jasowang@redhat.com>
Subject: Re: [RFC PATCH v2 3/3] tun: fix LSM/SELinux labeling of tun/tap devices
Date: Fri, 07 Dec 2012 13:41:54 +0800
Message-ID: <1576545.5OP3IuDm9I@jason-thinkpad-t430s>
References: <20121205202144.18626.61966.stgit@localhost> <6001427.qD54i2BbtH@sifl> <20121206205716.GA6576@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Paul Moore <pmoore@redhat.com>, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20121206205716.GA6576@redhat.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, December 06, 2012 10:57:16 PM Michael S. Tsirkin wrote:
> On Thu, Dec 06, 2012 at 11:56:45AM -0500, Paul Moore wrote:
> > The SETQUEUE/tun_socket:create_queue permissions do not yet exist in any
> > released SELinux policy as we are just now adding them with this patchset.
> > With current policies loaded into a kernel with this patchset applied the
> > SETQUEUE/tun_socket:create_queue permission would be treated according to
> > the policy's unknown permission setting.
> 
> OK I think we need to rethink what we are doing here: what you sent
> addresses the problem as stated but I think we mis-stated it.  Let me
> try to restate the problem: it is not just selinux problem.  Let's
> assume qemu wants to use tun, I (libvirt) don't want to run it as root.
> 
> 1. TUNSETIFF: I can open tun, attach an fd and pass it to qemu.
> Now, qemu does not invoke TUNSETIFF so it can run without
> kernel priveledges.
> 
> 2. TUNSETQUEUE - I can open tun and attach a queue but this
> is not what is needed since this automatically switches
> to multiqueue mode - we want to change number of queues
> on the fly.
> So qemu needs to be allowed to run TUNSETQUEUE.
> Since this checks tun_not_capable(tun) we would need
> to give qemu these priveledges, and we want to avoid this
> (I can go into why if it's not obvious).
> 
> How can we slove this?
> I don't see a way without extending the interface.
> Here's a simple way to extend it: pass a flag to TUNSETQUEUE
> that enables/disables TX on this queue.
> If TX is disabled, ignore this queue for flow steering decisions.
> Allow TUNSETQUEUE for a non priveledged user if it
> it already bound to the currect tun and only changes this flag.
> 
> 
> Now I open tun and SETQUEUE with TX disabled flag. Pass it to qemu.
> qemu calls SETQUEUE with TX enabled flag.

So the check of CAP_NET_ADMIN is bypassed in the situation.  And new selinux 
policy is then needed for this new flag.

The only concern with this is whether it could be treated as a kind of host 
network device configuration and need CAP_NET_ADMIN capability. (But it looks 
the only method that we could let qemu change the queue used by tun).
> 
> Jason? Want to try implementing and see what people think?

Sure, will draft a path based on this.
