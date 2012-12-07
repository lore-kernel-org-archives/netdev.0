From: Jason Wang <jasowang@redhat.com>
Subject: Re: [RFC PATCH v2 3/3] tun: fix LSM/SELinux labeling of tun/tap devices
Date: Fri, 07 Dec 2012 13:29:23 +0800
Message-ID: <1803499.1I7Vdk23bE@jason-thinkpad-t430s>
References: <20121205202144.18626.61966.stgit@localhost> <9040763.QsllgCP7TP@jason-thinkpad-t430s> <10346047.LWlqqejLmO@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov, mst@redhat.com
To: Paul Moore <pmoore@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12627 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932721Ab2LGF33 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Dec 2012 00:29:29 -0500
In-Reply-To: <10346047.LWlqqejLmO@sifl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, December 06, 2012 10:36:11 AM Paul Moore wrote:
> On Thursday, December 06, 2012 06:29:54 PM Jason Wang wrote:
> > On Wednesday, December 05, 2012 03:26:19 PM Paul Moore wrote:
> > > This patch corrects some problems with LSM/SELinux that were introduced
> > > with the multiqueue patchset.  The problem stems from the fact that the
> > > multiqueue work changed the relationship between the tun device and its
> > > associated socket; before the socket persisted for the life of the
> > > device, however after the multiqueue changes the socket only persisted
> > > for the life of the userspace connection (fd open).  For non-persistent
> > > devices this is not an issue, but for persistent devices this can cause
> > > the tun device to lose its SELinux label.
> > > 
> > > We correct this problem by adding an opaque LSM security blob to the
> > > tun device struct which allows us to have the LSM security state, e.g.
> > > SELinux labeling information, persist for the lifetime of the tun
> > > device.  In the process we tweak the LSM hooks to work with this new
> > > approach to TUN device/socket labeling and introduce a new LSM hook,
> > > security_tun_dev_create_queue(), to approve requests to create a new
> > > TUN queue via TUNSETQUEUE.
> > > 
> > > The SELinux code has been adjusted to match the new LSM hooks, the
> > > other LSMs do not make use of the LSM TUN controls.  This patch makes
> > > use of the recently added "tun_socket:create_queue" permission to
> > > restrict access to the TUNSETQUEUE operation.  On older SELinux
> > > policies which do not define the "tun_socket:create_queue" permission
> > > the access control decision for TUNSETQUEUE will be handled according
> > > to the SELinux policy's unknown permission setting.
> > > 
> > > Signed-off-by: Paul Moore <pmoore@redhat.com>
> 
> ...
> 
> > > @@ -4425,20 +4452,19 @@ static void selinux_tun_dev_post_create(struct
> > > sock
> > > *sk) * cause confusion to the TUN user that had no idea network labeling
> > > *
> > > protocols were being used */
> > > 
> > > -	/* see the comments in selinux_tun_dev_create() about why we ...
> > > -
> > > -	sksec->sid = current_sid();
> > > +	sksec->sid = tunsec->sid;
> > 
> > Since both tun_set_iff() and tun_set_queue() would call this. I wonder
> > when
> > it is called by tun_set_queue() we need some checking just like what we
> > done in v1, otherwise it's unconditionally in TUNSETQUEUE. Or we can add
> > them in selinux_tun_dev_create_queue()?
> 
> In all the cases that call tun_attach() we have a new socket which needs to
> be labeled based on the tun->security label, yes?  That is what the

Yes.
> security_tun_dev_attach() code does, there is no need for access control at
> this point as the operation has already been authorized by either
> security_tun_dev_create() (new device), security_tun_dev_create_queue() (new
> queue), or security_tun_dev_open() (opening persistent device).
> 
> I think we are all set, or am I missing something?
> 

Looks fine, thanks for the explanation.
> > >  	sksec->sclass = SECCLASS_TUN_SOCKET;
> > > 
> > > +
> > > +	return 0;
> > > 
> > >  }
