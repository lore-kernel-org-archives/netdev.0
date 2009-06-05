From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH v2 00/19] virtual-bus
Date: Thu, 4 Jun 2009 22:30:10 -0700
Message-ID: <20090605053010.GD7125@linux.vnet.ibm.com>
References: <20090409155200.32740.19358.stgit@dev.haskins.net> <49E0C93E.5030205@redhat.com> <4A28172D.6010906@gmail.com> <200906051425.02924.rusty@rustcorp.com.au>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gregory Haskins <gregory.haskins@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, Avi Kivity <avi@redhat.com>,
	Gregory Haskins <ghaskins@novell.com>,
	linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	bhutchings@solarflare.com, andi@firstfloor.org, gregkh@suse.de,
	herber@gondor.apana.org.au, chrisw@sous-sol.org,
	shemminger@vyatta.com
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200906051425.02924.rusty@rustcorp.com.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 05, 2009 at 02:25:01PM +0930, Rusty Russell wrote:
> On Fri, 5 Jun 2009 04:19:17 am Gregory Haskins wrote:
> > Avi Kivity wrote:
> > > Gregory Haskins wrote:
> > > One idea is similar to signalfd() or eventfd()
> >
> > And thus the "kvm-eventfd" (irqfd/iosignalfd) interface project was born.
> > ;)
> 
> The lguest patch queue already has such an interface :)  And I have a
> partially complete in-kernel virtio_pci patch with the same trick.
> 
> I switched from "kernel created eventfd" to "userspace passes in eventfd"
> after a while though; it lets you connect multiple virtqueues to a single fd
> if you want.
> 
> Combined with a minor change to allow any process with access to the lguest fd
> to queue interrupts, this allowed lguest to move to a thread-per-virtqueue
> model which was a significant speedup as well as nice code reduction.
> 
> Here's the relevant kernel patch for reading.
> 
> Thanks!
> Rusty.
> 
> lguest: use eventfds for device notification
> 
> Currently, when a Guest wants to perform I/O it calls LHCALL_NOTIFY with
> an address: the main Launcher process returns with this address, and figures
> out what device to run.
> 
> A far nicer model is to let processes bind an eventfd to an address: if we
> find one, we simply signal the eventfd.

A couple of (probably misguided) RCU questions/suggestions interspersed.

> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Davide Libenzi <davidel@xmailserver.org>
> ---
>  drivers/lguest/Kconfig          |    2 -
>  drivers/lguest/core.c           |    8 ++--
>  drivers/lguest/lg.h             |    9 ++++
>  drivers/lguest/lguest_user.c    |   73 ++++++++++++++++++++++++++++++++++++++++
>  include/linux/lguest_launcher.h |    1 
>  5 files changed, 89 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/lguest/Kconfig b/drivers/lguest/Kconfig
> --- a/drivers/lguest/Kconfig
> +++ b/drivers/lguest/Kconfig
> @@ -1,6 +1,6 @@
>  config LGUEST
>  	tristate "Linux hypervisor example code"
> -	depends on X86_32 && EXPERIMENTAL && !X86_PAE && FUTEX
> +	depends on X86_32 && EXPERIMENTAL && !X86_PAE && EVENTFD
>  	select HVC_DRIVER
>  	---help---
>  	  This is a very simple module which allows you to run
> diff --git a/drivers/lguest/core.c b/drivers/lguest/core.c
> --- a/drivers/lguest/core.c
> +++ b/drivers/lguest/core.c
> @@ -198,9 +198,11 @@ int run_guest(struct lg_cpu *cpu, unsign
>  		/* It's possible the Guest did a NOTIFY hypercall to the
>  		 * Launcher, in which case we return from the read() now. */
>  		if (cpu->pending_notify) {
> -			if (put_user(cpu->pending_notify, user))
> -				return -EFAULT;
> -			return sizeof(cpu->pending_notify);
> +			if (!send_notify_to_eventfd(cpu)) {
> +				if (put_user(cpu->pending_notify, user))
> +					return -EFAULT;
> +				return sizeof(cpu->pending_notify);
> +			}
>  		}
> 
>  		/* Check for signals */
> diff --git a/drivers/lguest/lg.h b/drivers/lguest/lg.h
> --- a/drivers/lguest/lg.h
> +++ b/drivers/lguest/lg.h
> @@ -82,6 +82,11 @@ struct lg_cpu {
>  	struct lg_cpu_arch arch;
>  };
> 
> +struct lg_eventfds {
> +	unsigned long addr;
> +	struct file *event;
> +};
> +
>  /* The private info the thread maintains about the guest. */
>  struct lguest
>  {
> @@ -102,6 +107,9 @@ struct lguest
>  	unsigned int stack_pages;
>  	u32 tsc_khz;
> 
> +	unsigned int num_eventfds;
> +	struct lg_eventfds *eventfds;
> +
>  	/* Dead? */
>  	const char *dead;
>  };
> @@ -152,6 +160,7 @@ void setup_default_idt_entries(struct lg
>  void copy_traps(const struct lg_cpu *cpu, struct desc_struct *idt,
>  		const unsigned long *def);
>  void guest_set_clockevent(struct lg_cpu *cpu, unsigned long delta);
> +bool send_notify_to_eventfd(struct lg_cpu *cpu);
>  void init_clockdev(struct lg_cpu *cpu);
>  bool check_syscall_vector(struct lguest *lg);
>  int init_interrupts(void);
> diff --git a/drivers/lguest/lguest_user.c b/drivers/lguest/lguest_user.c
> --- a/drivers/lguest/lguest_user.c
> +++ b/drivers/lguest/lguest_user.c
> @@ -7,6 +7,8 @@
>  #include <linux/miscdevice.h>
>  #include <linux/fs.h>
>  #include <linux/sched.h>
> +#include <linux/eventfd.h>
> +#include <linux/file.h>
>  #include "lg.h"
> 
>  /*L:055 When something happens, the Waker process needs a way to stop the
> @@ -35,6 +37,70 @@ static int break_guest_out(struct lg_cpu
>  	}
>  }
> 
> +bool send_notify_to_eventfd(struct lg_cpu *cpu)
> +{
> +	unsigned int i;
> +
> +	/* lg->eventfds is RCU-protected */
> +	preempt_disable();

Suggest changing to rcu_read_lock() to match the synchronize_rcu().

> +	for (i = 0; i < cpu->lg->num_eventfds; i++) {
> +		if (cpu->lg->eventfds[i].addr == cpu->pending_notify) {
> +			eventfd_signal(cpu->lg->eventfds[i].event, 1);

Shouldn't this be something like the following?

		p = rcu_dereference(cpu->lg->eventfds);
		if (p[i].addr == cpu->pending_notify) {
			eventfd_signal(p[i].event, 1);

> +			cpu->pending_notify = 0;
> +			break;
> +		}
> +	}
> +	preempt_enable();

And of course, rcu_read_unlock() here.

> +	return cpu->pending_notify == 0;
> +}
> +
> +static int add_eventfd(struct lguest *lg, unsigned long addr, int fd)
> +{
> +	struct lg_eventfds *new, *old;
> +
> +	if (!addr)
> +		return -EINVAL;
> +
> +	/* Replace the old array with the new one, carefully: others can
> +	 * be accessing it at the same time */
> +	new = kmalloc(sizeof(*new) * (lg->num_eventfds + 1), GFP_KERNEL);
> +	if (!new)
> +		return -ENOMEM;
> +
> +	memcpy(new, lg->eventfds, sizeof(*new) * lg->num_eventfds);
> +	old = lg->eventfds;
> +	lg->eventfds = new;
> +	synchronize_rcu();
> +	kfree(old);
> +
> +	lg->eventfds[lg->num_eventfds].addr = addr;
> +	lg->eventfds[lg->num_eventfds].event = eventfd_fget(fd);
> +	if (IS_ERR(lg->eventfds[lg->num_eventfds].event))
> +		return PTR_ERR(lg->eventfds[lg->num_eventfds].event);
> +
> +	wmb();
> +	lg->num_eventfds++;

Doesn't the synchronize_rcu() need to be synchronize_sched() to match the
preempt_disable() in send_notify_to_eventfd()?  Or, alternatively, use
rcu_read_lock() instead of preempt_disable() in send_notify_to_eventfd().
This last is preferred.

Although you have the wmb() above, there is no ordering in
send_notify_to_eventfd().  Would the following work?

	old = lg->eventfds;
	lg->eventfds = new;

	lg->eventfds[lg->num_eventfds].addr = addr;
	lg->eventfds[lg->num_eventfds].event = eventfd_fget(fd);
	if (IS_ERR(lg->eventfds[lg->num_eventfds].event))
		return PTR_ERR(lg->eventfds[lg->num_eventfds].event);

	synchronize_rcu();
	kfree(old);
	lg->num_eventfds++;

Here, synchronize_rcu() is doing two things:

1.	ensuring that old readers who might be referencing "old" are
	done before the kfree(), and

2.	wait for the completion of all old readers who might (a) be
	referencing the short "old" array and (b) be unaware of the
	initialization of the new element.

Or do we also need to wait for anyone who might still be using the
old value of lg->num_eventfds?  If so, the usual trick is to put
this value behind the same pointer that references the array, so
that any given rcu_dereference() is guaranteed to see matching
array and size.

> +	return 0;
> +}
> +
> +static int attach_eventfd(struct lguest *lg, const unsigned long __user *input)
> +{
> +	unsigned long addr, fd;
> +	int err;
> +
> +	if (get_user(addr, input) != 0)
> +		return -EFAULT;
> +	input++;
> +	if (get_user(fd, input) != 0)
> +		return -EFAULT;
> +
> +	mutex_lock(&lguest_lock);
> +	err = add_eventfd(lg, addr, fd);
> +	mutex_unlock(&lguest_lock);
> +
> +	return 0;
> +}
> +
>  /*L:050 Sending an interrupt is done by writing LHREQ_IRQ and an interrupt
>   * number to /dev/lguest. */
>  static int user_send_irq(struct lg_cpu *cpu, const unsigned long __user *input)
> @@ -260,6 +326,8 @@ static ssize_t write(struct file *file, 
>  		return user_send_irq(cpu, input);
>  	case LHREQ_BREAK:
>  		return break_guest_out(cpu, input);
> +	case LHREQ_EVENTFD:
> +		return attach_eventfd(lg, input);
>  	default:
>  		return -EINVAL;
>  	}
> @@ -297,6 +365,11 @@ static int close(struct inode *inode, st
>  		 * the Launcher's memory management structure. */
>  		mmput(lg->cpus[i].mm);
>  	}
> +
> +	/* Release any eventfds they registered. */
> +	for (i = 0; i < lg->num_eventfds; i++)
> +		fput(lg->eventfds[i].event);
> +
>  	/* If lg->dead doesn't contain an error code it will be NULL or a
>  	 * kmalloc()ed string, either of which is ok to hand to kfree(). */
>  	if (!IS_ERR(lg->dead))
> diff --git a/include/linux/lguest_launcher.h b/include/linux/lguest_launcher.h
> --- a/include/linux/lguest_launcher.h
> +++ b/include/linux/lguest_launcher.h
> @@ -58,6 +58,7 @@ enum lguest_req
>  	LHREQ_GETDMA, /* No longer used */
>  	LHREQ_IRQ, /* + irq */
>  	LHREQ_BREAK, /* + on/off flag (on blocks until someone does off) */
> +	LHREQ_EVENTFD, /* + address, fd. */
>  };
> 
>  /* The alignment to use between consumer and producer parts of vring.
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
