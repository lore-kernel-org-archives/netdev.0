From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH 2/2] tun: fix LSM/SELinux labeling of tun/tap devices
Date: Tue, 4 Dec 2012 17:24:20 +0200
Message-ID: <20121204152420.GJ7499@redhat.com>
References: <20121129215724.30020.69464.stgit@sifl>
 <50BC7BCE.7000502@redhat.com>
 <2549856.XZ72FtkyJK@sifl>
 <7659411.O2Or69Bf6n@jason-thinkpad-t430s>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Moore <pmoore@redhat.com>, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <7659411.O2Or69Bf6n@jason-thinkpad-t430s>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 04, 2012 at 09:24:43PM +0800, Jason Wang wrote:
> On Monday, December 03, 2012 11:22:29 AM Paul Moore wrote:
> > On Monday, December 03, 2012 06:15:42 PM Jason Wang wrote:
> > > On 11/30/2012 06:06 AM, Paul Moore wrote:
> > > > This patch corrects some problems with LSM/SELinux that were introduced
> > > > with the multiqueue patchset.  The problem stems from the fact that the
> > > > multiqueue work changed the relationship between the tun device and its
> > > > associated socket; before the socket persisted for the life of the
> > > > device, however after the multiqueue changes the socket only persisted
> > > > for the life of the userspace connection (fd open).  For non-persistent
> > > > devices this is not an issue, but for persistent devices this can cause
> > > > the tun device to lose its SELinux label.
> > > > 
> > > > We correct this problem by adding an opaque LSM security blob to the
> > > > tun device struct which allows us to have the LSM security state, e.g.
> > > > SELinux labeling information, persist for the lifetime of the tun
> > > > device.
> > 
> > ...
> > 
> > > > -static int selinux_tun_dev_attach(struct sock *sk)
> > > > +static int selinux_tun_dev_attach(struct sock *sk, void *security)
> > > > 
> > > >  {
> > > > 
> > > > +	struct tun_security_struct *tunsec = security;
> > > > 
> > > >  	struct sk_security_struct *sksec = sk->sk_security;
> > > >  	u32 sid = current_sid();
> > > >  	int err;
> > > > 
> > > > +	/* we don't currently perform any NetLabel based labeling here ...
> > > > 
> > > >  	err = avc_has_perm(sid, sksec->sid, SECCLASS_TUN_SOCKET,
> > > >  	
> > > >  			   TUN_SOCKET__RELABELFROM, NULL);
> > > >  	
> > > >  	if (err)
> > > >  	
> > > >  		return err;
> > > > 
> > > > -	err = avc_has_perm(sid, sid, SECCLASS_TUN_SOCKET,
> > > > +	err = avc_has_perm(sid, tunsec->sid, SECCLASS_TUN_SOCKET,
> > > > 
> > > >  			   TUN_SOCKET__RELABELTO, NULL);
> > > >  	
> > > >  	if (err)
> > > >  	
> > > >  		return err;
> > > > 
> > > > -	sksec->sid = sid;
> > > > +	sksec->sid = tunsec->sid;
> > > > +	sksec->sclass = SECCLASS_TUN_SOCKET;
> > > 
> > > I'm not sure whether this is correct, looks like we need to differ between
> > > TUNSETQUEUE and TUNSETIFF. When userspace call TUNSETIFF for persistent
> > > device, looks like we need change the sid of tunsec like in the past.
> > 
> > It may be that I'm misunderstanding TUNSETQUEUE and/or TUNSETIFF.  Can you
> > elaborate as to why they should be different?
> 
> If I understand correctly, before multiqueue patchset, TUNSETIFF is used to:
> 
> 1) Create the tun/tap network device
> 2) For persistent device, re-attach the fd to the network device / socket. In 
> this case, we call selinux_tun_dev_attch() to relabel the socket sid (in fact 
> also the device's since the socket were persistent also) to the sid of process 
> that calls TUNSETIFF.
> 
> So, after the changes of multiqueue, we need try to preserve those policy. The 
> interesting part is the introducing of TUNSETQUEUE, it's used to attach more 
> file descriptors/sockets to a tun/tap device after at least one file descriptor 
> were attached to the tun/tap device through TUNSETIFF. So I think maybe we 
> need differ those two ioctls. This patch looks fine for TUNSETQUEUE, but for 
> TUNSETIFF, we need relabel the tunsec to the process that calling TUNSETIFF 
> for persistent device?

Basically, it looks like currently once you get a tun fd,
you can attach it to any device even if normally
selinux would prevent you from accessing it.

If we reuse selinux_tun_dev_attach, we won't need to
change selinux policy, with a new capability we will need to change it
to allow libvirt to do TUNSETQUEUE.


> 
> btw. Current code does allow calling TUNSETQUEUE to a persistent tun/tap 
> device with no file attached. It should be a bug and need to be fixed.

Is this a problem? You can always
attach
set queue
detach

and it would be hard to prevent this ...

> > 
> > One thing that I think we probably should change is the relabelto/from
> > permissions in the function above (selinux_tun_dev_attach()); in the case
> > where the socket does not yet have a label, e.g. 'sksec->sid == 0', we
> > should probably skip the relabel permissions since we want to assign the
> > TUN device label regardless in this case.
> 
> I'm not familiar with the selinux, have a quick glance of the code, looks like 
> the label has been initialized to SECINITSID_KERNEL in 
> selinux_socket_post_create().
> 
> Thanks
