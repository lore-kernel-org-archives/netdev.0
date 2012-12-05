From: Jason Wang <jasowang@redhat.com>
Subject: Re: [RFC PATCH 2/2] tun: fix LSM/SELinux labeling of tun/tap devices
Date: Wed, 05 Dec 2012 13:44:04 +0800
Message-ID: <2256083.NQQl9hT3YU@jason-thinkpad-t430s>
References: <20121129215724.30020.69464.stgit@sifl> <7659411.O2Or69Bf6n@jason-thinkpad-t430s> <8577392.82G063LYx2@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov, mst@redhat.com
To: Paul Moore <pmoore@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <8577392.82G063LYx2@sifl>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday, December 04, 2012 11:18:57 AM Paul Moore wrote:
> On Tuesday, December 04, 2012 09:24:43 PM Jason Wang wrote:
> > On Monday, December 03, 2012 11:22:29 AM Paul Moore wrote:
> > > It may be that I'm misunderstanding TUNSETQUEUE and/or TUNSETIFF.  Can
> > > you
> > > elaborate as to why they should be different?
> > 
> > If I understand correctly, before multiqueue patchset, TUNSETIFF is used
> > to:
> > 
> > 1) Create the tun/tap network device
> > 2) For persistent device, re-attach the fd to the network device / socket.
> > In this case, we call selinux_tun_dev_attch() to relabel the socket sid
> > (in
> > fact also the device's since the socket were persistent also) to the sid
> > of
> > process that calls TUNSETIFF.
> > 
> > So, after the changes of multiqueue, we need try to preserve those policy.
> > The interesting part is the introducing of TUNSETQUEUE, it's used to
> > attach
> > more file descriptors/sockets to a tun/tap device after at least one file
> > descriptor were attached to the tun/tap device through TUNSETIFF. So I
> > think maybe we need differ those two ioctls. This patch looks fine for
> > TUNSETQUEUE, but for TUNSETIFF, we need relabel the tunsec to the process
> > that calling TUNSETIFF for persistent device?
> 
> Okay, based on your explanation of TUNSETQUEUE, the steps below are what I
> believe we need to do ... if you disagree speak up quickly please.
> 
> A. TUNSETIFF (new, non-persistent device)
> 
> [Allocate and initialize the tun_struct LSM state based on the calling
> process, use this state to label the TUN socket.]
> 
> 1. Call security_tun_dev_create() which authorizes the action.
> 2. Call security_tun_dev_alloc_security() which allocates the tun_struct LSM
> blob and SELinux sets some internal blob state to record the label of the
> calling process.
> 3. Call security_tun_dev_attach() which sets the label of the TUN socket to
> match the label stored in the tun_struct LSM blob during A2.  No
> authorization is done at this point since the socket is new/unlabeled.
> 
> B. TUNSETIFF (existing, persistent device)
> 
> [Relabel the existing tun_struct LSM state based on the calling process, use
> this state to label the TUN socket.]
> 
> 1. Attempt to relabel/reset the tun_struct LSM blob from the currently
> stored value, set during A2, to the label of the current calling process.
> *** THIS IS NOT CURRENTLY DONE IN THE RFC PATCH ***
> 2. Call security_tun_dev_attach() which sets the label of the TUN socket to
> match the label stored in the tun_struct LSM blob during B1. No
> authorization is done at this point since the socket is new/unlabeled.
> 
> C. TUNSETQUEUE
> 
> [Use the existing tun_struct LSM state to label the new TUN socket.]
> 
> 1. Call security_tun_dev_attach() which sets the label of the TUN socket to
> match the label stored in the tun_struct LSM blob set during either A2 or
> B1. No authorization is done at this point since the socket is
> new/unlabeled.

This looks fine to me.
> > btw. Current code does allow calling TUNSETQUEUE to a persistent tun/tap
> > device with no file attached. It should be a bug and need to be fixed.
> 
> Since you wrote that code will you be submitting a patch to fix that
> problem?

Yes, I will fix it.
> > > One thing that I think we probably should change is the relabelto/from
> > > permissions in the function above (selinux_tun_dev_attach()); in the
> > > case
> > > where the socket does not yet have a label, e.g. 'sksec->sid == 0', we
> > > should probably skip the relabel permissions since we want to assign the
> > > TUN device label regardless in this case.
> > 
> > I'm not familiar with the selinux, have a quick glance of the code, looks
> > like the label has been initialized to SECINITSID_KERNEL in
> > selinux_socket_post_create().
> 
> Unless I've missed something in your changes, the multiqueue code never
> calls any socket code which ends up calling
> {security,selinux}_socket_post_create(); I believe you only call sk_alloc()
> which ends up calling
> {security,selinux}_sk_alloc() which sets SECINITSID_UNLABELED (I mistakenly
> wrote 0 instead in my earlier email which is techincally SECSID_NULL). 
> Either way, I still think the logic I originally described above is
> correct.

Yes, I was wrong. Thanks for the checking.


