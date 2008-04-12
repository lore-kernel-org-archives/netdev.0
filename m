From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: Re: [PATCH RFC 1/5] vringfd syscall
Date: Sat, 12 Apr 2008 14:39:26 -0300
Message-ID: <20080412173926.GA29904@dmt>
References: <200804052202.09157.rusty@rustcorp.com.au> <20080412171820.GA29568@dmt>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Max Krasnyansky <maxk@qualcomm.com>,
	virtualization@lists.linux-foundation.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37294 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754480AbYDLRhX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Apr 2008 13:37:23 -0400
Content-Disposition: inline
In-Reply-To: <20080412171820.GA29568@dmt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 12, 2008 at 02:18:20PM -0300, Marcelo Tosatti wrote:

> > +		mask = POLLIN | POLLRDNORM;
> > +	else
> > +		mask = 0;
> > +
> > +poll_wait:
> > +	poll_wait(filp, &vr->poll_wait, poll);
> > +
> > +	return mask;
> > +}
> 
> I suppose you are doing data copy in ->poll instead of ->read to save
> a system call? This is weird, not conformant to what the interface is
> supposed to do.
> 
> This way select/poll syscalls might block in userspace datacopy. The
> application might have a higher priority fd in the fdset to be informed
> of, for example.
> 
> So why not change this to the common arrangement, with vring_poll adding
> the waitqueue with poll_wait() and vring_read doing the actual data copy ?
> 
> > +struct vring_info *vring_attach(int fd, const struct vring_ops *ops,
> > +				void *data, bool atomic_use)
> > +{
> > +	struct file *filp;
> > +	struct vring_info *vr;
> > +
> > +	/* Must be a valid fd, and must be one of ours. */
> > +	filp = fget(fd);
> > +	if (!filp) {
> > +		vr = ERR_PTR(-EBADF);
> > +		goto out;
> > +	}
> > +
> > +	if (filp->f_op != &vring_fops) {
> > +		vr = ERR_PTR(-EBADF);
> > +		goto fput;
> > +	}
> > +
> > +	/* Mutex simply protects against parallel vring_attach. */
> > +	mutex_lock(&vring_lock);
> > +	vr = filp->private_data;
> > +	if (vr->ops) {
> > +		vr = ERR_PTR(-EBUSY);
> > +		goto unlock;
> > +	}
> > +
> > +	/* If they want to use atomically, we have to map the page. */
> > +	if (atomic_use) {
> > +		if (get_user_pages(current, current->mm,
> > +				   (unsigned long)vr->ring.used, 1, 1, 1,
> > +				   &vr->used_page, NULL) != 1) {
> 
> Can't the same be achieved by the app mlocking the vring pages, which
> then goes through standard rlimit checking ?

Oh, this is a driver API to allow the copy to take place in atomic
contexes. You might want to add some sort of limit enforcement.

Also forgot mmap_sem there.

