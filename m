From: Paul Moore <pmoore@redhat.com>
Subject: Re: [RFC PATCH 2/2] tun: fix LSM/SELinux labeling of tun/tap devices
Date: Mon, 03 Dec 2012 11:22:29 -0500
Message-ID: <2549856.XZ72FtkyJK@sifl>
References: <20121129215724.30020.69464.stgit@sifl> <20121129220637.30020.9980.stgit@sifl> <50BC7BCE.7000502@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <50BC7BCE.7000502@redhat.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, December 03, 2012 06:15:42 PM Jason Wang wrote:
> On 11/30/2012 06:06 AM, Paul Moore wrote:
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
> > device.

...

> > -static int selinux_tun_dev_attach(struct sock *sk)
> > +static int selinux_tun_dev_attach(struct sock *sk, void *security)
> > 
> >  {
> > 
> > +	struct tun_security_struct *tunsec = security;
> > 
> >  	struct sk_security_struct *sksec = sk->sk_security;
> >  	u32 sid = current_sid();
> >  	int err;
> > 
> > +	/* we don't currently perform any NetLabel based labeling here ...
> >
> >  	err = avc_has_perm(sid, sksec->sid, SECCLASS_TUN_SOCKET,
> >  	
> >  			   TUN_SOCKET__RELABELFROM, NULL);
> >  	
> >  	if (err)
> >  	
> >  		return err;
> > 
> > -	err = avc_has_perm(sid, sid, SECCLASS_TUN_SOCKET,
> > +	err = avc_has_perm(sid, tunsec->sid, SECCLASS_TUN_SOCKET,
> > 
> >  			   TUN_SOCKET__RELABELTO, NULL);
> >  	
> >  	if (err)
> >  	
> >  		return err;
> > 
> > -	sksec->sid = sid;
> > +	sksec->sid = tunsec->sid;
> > +	sksec->sclass = SECCLASS_TUN_SOCKET;
> 
> I'm not sure whether this is correct, looks like we need to differ between
> TUNSETQUEUE and TUNSETIFF. When userspace call TUNSETIFF for persistent
> device, looks like we need change the sid of tunsec like in the past.

It may be that I'm misunderstanding TUNSETQUEUE and/or TUNSETIFF.  Can you 
elaborate as to why they should be different?

One thing that I think we probably should change is the relabelto/from 
permissions in the function above (selinux_tun_dev_attach()); in the case 
where the socket does not yet have a label, e.g. 'sksec->sid == 0', we should 
probably skip the relabel permissions since we want to assign the TUN device 
label regardless in this case.

-- 
paul moore
security and virtualization @ redhat

