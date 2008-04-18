From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 2/5] /dev/vring: simple userspace-kernel ringbuffer
	interface.
Date: Sat, 19 Apr 2008 00:32:39 +1000
Message-ID: <200804190032.39626.rusty@rustcorp.com.au>
References: <200804181433.48488.rusty@rustcorp.com.au>
	<200804181439.49051.rusty@rustcorp.com.au>
	<20080418041846.db15150b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Max Krasnyansky <maxk@qualcomm.com>,
        virtualization@lists.linux-foundation.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20080418041846.db15150b.akpm@linux-foundation.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Friday 18 April 2008 21:18:46 Andrew Morton wrote:
> > +	/* Must be a power of two, and limit indices to a u16. */
> > +	if (!num_descs || (num_descs & (num_descs-1)) || num_descs > 65536)
>
> We have an is_power_of_2().

Thanks, fixed.

> > + * vring_get - check out a vring file descriptor
> > + * @filp: the file structure to attach to (eg. from fget()).
> > + *
> > + * Userspace opens /dev/vring and mmaps it, then hands that fd to the
> > + * kernel subsystem it wants to communicate with.  That subsystem uses
> > + * this routine and vring_set_ops() to attach to it.
> > + *
> > + * This simply checks that it really is a vring fd (otherwise it
> > + * returns NULL), the other routine checks that it's not already
> > + * attached.
> > + */
>
> hm, I don't understand the big picture here yet.
>
> Isn't this kinda-sorta like what a relayfs file does?  The oprofile
> buffers?  etc?  Nothing in common at all, no hope?

An excellent question, but I thought the modern kernel etiquette was to only 
comment on whitespace and formatting, and call it "review"? :)

Yes, kinda-sorta in that it's a ring buffer.  No, in that it's bidir and 
consumption can be out-of-order (kind of important for I/O buffers).

But the reason I'm not proposing it as a syscall is that I'm not convinced 
it's the One True Solution which everyone should be using.  Time will tell: 
it's clearly not tied to tun and it's been generically useful for virtual 
I/O, but history has not been kind to new userspace interfaces.

> > +	mutex_unlock(&vr->lock);
> > +	local_irq_enable();
>
> what's this doing here?

Snot from previous version.  Removed.

> > +void vring_unset_ops(struct vring_info *vr)
> > +{
> > +	BUG_ON(!vr->ops);
> > +	mutex_lock(&vr->lock);
> > +	vr->ops = NULL;
> > +	mutex_unlock(&vr->lock);
> > +}
> > +EXPORT_SYMBOL_GPL(vring_unset_ops);
>
> Isn't this just vring_set_ops(vr, NULL, NULL)?

Yes, except I like the clarity and the BUG_ON.

> ponders #include <copyright.h>

"#include <copyright-gpl2-plus>" for me, just to add more inclement weather to 
that teacup...

Thanks,
Rusty.
