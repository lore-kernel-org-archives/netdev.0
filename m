From: Jason Wang <jasowang@redhat.com>
Subject: Re: [RFC PATCH 2/2] tun: fix LSM/SELinux labeling of tun/tap devices
Date: Wed, 05 Dec 2012 21:45:29 +0800
Message-ID: <1521770.V1vlQSxGxZ@jason-thinkpad-t430s>
References: <20121129215724.30020.69464.stgit@sifl> <50BEE6FA.1080507@redhat.com> <20121205114339.GA26649@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Paul Moore <pmoore@redhat.com>, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20121205114339.GA26649@redhat.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, December 05, 2012 01:43:39 PM Michael S. Tsirkin wrote:
> On Wed, Dec 05, 2012 at 02:17:30PM +0800, Jason Wang wrote:
> > On 12/04/2012 11:24 PM, Michael S. Tsirkin wrote:
> > > On Tue, Dec 04, 2012 at 09:24:43PM +0800, Jason Wang wrote:
> > >> On Monday, December 03, 2012 11:22:29 AM Paul Moore wrote:
> > >>> On Monday, December 03, 2012 06:15:42 PM Jason Wang wrote:
> > >>>> On 11/30/2012 06:06 AM, Paul Moore wrote:
> > >>>>> This patch corrects some problems with LSM/SELinux that were
> > >>>>> introduced
> > >>>>> with the multiqueue patchset.  The problem stems from the fact that
> > >>>>> the
> > >>>>> multiqueue work changed the relationship between the tun device and
> > >>>>> its
> > >>>>> associated socket; before the socket persisted for the life of the
> > >>>>> device, however after the multiqueue changes the socket only
> > >>>>> persisted
> > >>>>> for the life of the userspace connection (fd open).  For
> > >>>>> non-persistent
> > >>>>> devices this is not an issue, but for persistent devices this can
> > >>>>> cause
> > >>>>> the tun device to lose its SELinux label.
> > >>>>> 
> > >>>>> We correct this problem by adding an opaque LSM security blob to the
> > >>>>> tun device struct which allows us to have the LSM security state,
> > >>>>> e.g.
> > >>>>> SELinux labeling information, persist for the lifetime of the tun
> > >>>>> device.
> > >>> 
> > >>> ...
> > >>> 
> > >>>>> -static int selinux_tun_dev_attach(struct sock *sk)
> > >>>>> +static int selinux_tun_dev_attach(struct sock *sk, void *security)
> > >>>>> 
> > >>>>>  {
> > >>>>> 
> > >>>>> +	struct tun_security_struct *tunsec = security;
> > >>>>> 
> > >>>>>  	struct sk_security_struct *sksec = sk->sk_security;
> > >>>>>  	u32 sid = current_sid();
> > >>>>>  	int err;
> > >>>>> 
> > >>>>> +	/* we don't currently perform any NetLabel based labeling here ...
> > >>>>> 
> > >>>>>  	err = avc_has_perm(sid, sksec->sid, SECCLASS_TUN_SOCKET,
> > >>>>>  	
> > >>>>>  			   TUN_SOCKET__RELABELFROM, NULL);
> > >>>>>  	
> > >>>>>  	if (err)
> > >>>>>  	
> > >>>>>  		return err;
> > >>>>> 
> > >>>>> -	err = avc_has_perm(sid, sid, SECCLASS_TUN_SOCKET,
> > >>>>> +	err = avc_has_perm(sid, tunsec->sid, SECCLASS_TUN_SOCKET,
> > >>>>> 
> > >>>>>  			   TUN_SOCKET__RELABELTO, NULL);
> > >>>>>  	
> > >>>>>  	if (err)
> > >>>>>  	
> > >>>>>  		return err;
> > >>>>> 
> > >>>>> -	sksec->sid = sid;
> > >>>>> +	sksec->sid = tunsec->sid;
> > >>>>> +	sksec->sclass = SECCLASS_TUN_SOCKET;
> > >>>> 
> > >>>> I'm not sure whether this is correct, looks like we need to differ
> > >>>> between
> > >>>> TUNSETQUEUE and TUNSETIFF. When userspace call TUNSETIFF for
> > >>>> persistent
> > >>>> device, looks like we need change the sid of tunsec like in the past.
> > >>> 
> > >>> It may be that I'm misunderstanding TUNSETQUEUE and/or TUNSETIFF.  Can
> > >>> you
> > >>> elaborate as to why they should be different?
> > >> 
> > >> If I understand correctly, before multiqueue patchset, TUNSETIFF is
> > >> used to:
> > >> 
> > >> 1) Create the tun/tap network device
> > >> 2) For persistent device, re-attach the fd to the network device /
> > >> socket. In this case, we call selinux_tun_dev_attch() to relabel the
> > >> socket sid (in fact also the device's since the socket were persistent
> > >> also) to the sid of process that calls TUNSETIFF.
> > >> 
> > >> So, after the changes of multiqueue, we need try to preserve those
> > >> policy. The interesting part is the introducing of TUNSETQUEUE, it's
> > >> used to attach more file descriptors/sockets to a tun/tap device after
> > >> at least one file descriptor were attached to the tun/tap device
> > >> through TUNSETIFF. So I think maybe we need differ those two ioctls.
> > >> This patch looks fine for TUNSETQUEUE, but for TUNSETIFF, we need
> > >> relabel the tunsec to the process that calling TUNSETIFF for
> > >> persistent device?
> > > 
> > > Basically, it looks like currently once you get a tun fd,
> > > you can attach it to any device even if normally
> > > selinux would prevent you from accessing it.
> > 
> > Yes some checking during TUNSETQUEUE is missed.
> > 
> > > If we reuse selinux_tun_dev_attach, we won't need to
> > > change selinux policy, with a new capability we will need to change it
> > > to allow libvirt to do TUNSETQUEUE.
> > 
> > Also needed for qemu too since it may call TUNSETQUEUE when guest wants
> > to change the number of queues.
> 
> Hmm that's nasty. If you allow qemu to do TUNSETQUEUE then how
> do you prevent it from attaching to some other tun?

Currently, we do the uid & gid check in tun_not_capable() also for 
TUNSETQUEUE. So the fd can't be attach to the device if current process is not 
the owner. And if it's the owner, is it harm to allow the fd to be attached to 
another device?

There's no state information of the tun stored in the tun_file, and it was 
something like after you open a fd of tun, you can call TUNSETIFF to any tun 
if the owner is current process.
> Maybe we can extend TUNSETQUEUE or add another ioctl to
> mark a queue active/inactive? Probably control transmit
> and receive being active separately as well.

It's better to extend current TUNSETQUEUE if needed, for controling 
transmitting and receiving, we can add more parameters to this ioctl (e.g. 
IFF_TX_ENABLE, IFF_TX_DISABLE)
> 
> > >> btw. Current code does allow calling TUNSETQUEUE to a persistent
> > >> tun/tap
> > >> device with no file attached. It should be a bug and need to be fixed.
> > > 
> > > Is this a problem? You can always
> > > attach
> > > set queue
> > > detach
> > > 
> > > and it would be hard to prevent this ...
> > 
> > Currently, the following steps is allowed:
> > 
> > 1. fd1 = open("/dev/net/tun");
> > 2. tunsetiff(fd1, "tap0");
> > 3. tunsetpersistent("tap0");
> > 4. close(fd1);
> > 5. fd2 = open("/dev/net/tun");
> > 6. tunsetqueue(fd2, "tap0);
> 
> Allowed for libvirt, right? Not for qemu.

But what if step 1-4 is done by one process, step 5-6 is done by another? The 
issuse only existed for persistent device with no fd attached. 

I agree we can add checks and let TUNSETQUEUE and let it to differ those 
conditions. But for simplicity, I suggest is to let userspace call TUNSETIFF 
first just like what we did when only single queue is supported in tun, and 
relabel the security of tun_struct there. And we can use different check (e.g. 
selinux for TUNSETQUEUE and TUNSETIFF) to enable the qemu to does TUNSETQUEUE 
itself.

> 
> > Looks like step 6 should be forbidden since:
> > 
> > - no fd/sockets were attached to the device, we need use TUNSETIFF
> > instead to keep the API as we used do in single queue tun
> > - we need update the security information in tun_struct just like what
> > we discussed in this mail
> > - it may also miss checks in TUNSETIFF
> 
> We need to fix the checks anyway. Basically if you allow
> a queue to be the only fd that is attached
> (and I don't see how you can prevent this since
> userspace does not expect close to fail),
> I don't see why one way to get to this state
> should be legal and another illegal.

Well, we can return -EPERM when userspace call TUNSETQUEUE to a tun_struct 
with zero fd/queues.
> 
> The rest is implementation detail.
> 
> > >>> One thing that I think we probably should change is the relabelto/from
> > >>> permissions in the function above (selinux_tun_dev_attach()); in the
> > >>> case
> > >>> where the socket does not yet have a label, e.g. 'sksec->sid == 0', we
> > >>> should probably skip the relabel permissions since we want to assign
> > >>> the
> > >>> TUN device label regardless in this case.
> > >> 
> > >> I'm not familiar with the selinux, have a quick glance of the code,
> > >> looks like the label has been initialized to SECINITSID_KERNEL in
> > >> selinux_socket_post_create().
> > >> 
> > >> Thanks
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
