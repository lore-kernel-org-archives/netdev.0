From: Paul Moore <pmoore@redhat.com>
Subject: Re: [RFC PATCH v2 3/3] tun: fix LSM/SELinux labeling of tun/tap devices
Date: Wed, 12 Dec 2012 13:49:35 -0500
Message-ID: <5382266.0cxDERT5g8@sifl>
References: <20121205202144.18626.61966.stgit@localhost> <20121205202619.18626.98778.stgit@localhost> <20121212092236.GB4354@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov, jasowang@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20121212092236.GB4354@redhat.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, December 12, 2012 11:22:36 AM Michael S. Tsirkin wrote:
> On Wed, Dec 05, 2012 at 03:26:19PM -0500, Paul Moore wrote:
> > This patch corrects some problems with LSM/SELinux that were introduced
> > with the multiqueue patchset.  The problem stems from the fact that the
> > multiqueue work changed the relationship between the tun device and its
> > associated socket; before the socket persisted for the life of the
> > device, however after the multiqueue changes the socket only persisted
> > for the life of the userspace connection (fd open).  For non-persistent
> > devices this is not an issue, but for persistent devices this can cause
> > the tun device to lose its SELinux label.
> > 
> > We correct this problem by adding an opaque LSM security blob to the
> > tun device struct which allows us to have the LSM security state, e.g.
> > SELinux labeling information, persist for the lifetime of the tun
> > device.  In the process we tweak the LSM hooks to work with this new
> > approach to TUN device/socket labeling and introduce a new LSM hook,
> > security_tun_dev_create_queue(), to approve requests to create a new
> > TUN queue via TUNSETQUEUE.
> > 
> > The SELinux code has been adjusted to match the new LSM hooks, the
> > other LSMs do not make use of the LSM TUN controls.  This patch makes
> > use of the recently added "tun_socket:create_queue" permission to
> > restrict access to the TUNSETQUEUE operation.  On older SELinux
> > policies which do not define the "tun_socket:create_queue" permission
> > the access control decision for TUNSETQUEUE will be handled according
> > to the SELinux policy's unknown permission setting.

...

> > @@ -465,6 +466,10 @@ static int tun_attach(struct tun_struct *tun, struct
> > file *file)> 
> >  	struct tun_file *tfile = file->private_data;
> >  	int err;
> > 
> > +	err = security_tun_dev_attach(tfile->socket.sk, tun->security);
> > +	if (err < 0)
> > +		goto out;
> > +
> > 
> >  	err = -EINVAL;
> >  	if (rcu_dereference_protected(tfile->tun, lockdep_rtnl_is_held()))
> >  	
> >  		goto out;
> 
> This hook triggers with both set_queue and set_iff,
> and it also seems to trigger when attaching to a
> persistent device and when creating a new one. But I
> believe we might want to be able to allow one but not the other.
> 
> For example:
> 	- we might want to allow qemu to do set_queue but not set_iff
> 	- we might want to configure presistent devices and
> 	  prevent a user from adding new ones

Please look at the rest of the patch and see what the hook actually does.  It 
does not perform any access control under SELinux, all it does is ensure that 
the socket is labeled based on the associated TUN device.

> > - * @tun_dev_post_create:
> > - *	This hook allows a module to update or allocate a per-socket security
> > - *	structure.
> > - *	@sk contains the newly created sock structure.
> 
> I worry that removing a hook hurt users that use it in their
> security policy.

We need to change the hooks because there was a significant change to the 
implementation of a TUN device.

However, even when changing the LSM hooks, we have preserved the SELinux 
access controls for standard, e.g. single queue, TUN devices such that 
existing SELinux policies will work for existing TUN users.  The new SELinux 
access control we added only comes into play when TUN users want to enable 
multiple queues.

-- 
paul moore
security and virtualization @ redhat

