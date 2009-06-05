From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH v2 00/19] virtual-bus
Date: Fri, 05 Jun 2009 07:56:48 -0400
Message-ID: <4A290800.1030803@novell.com>
References: <20090409155200.32740.19358.stgit@dev.haskins.net> <49E0C93E.5030205@redhat.com> <4A28172D.6010906@gmail.com> <200906051425.02924.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigEA73C36EB4BFD4A0F385B999"
Cc: Gregory Haskins <gregory.haskins@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, Avi Kivity <avi@redhat.com>,
	linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	bhutchings@solarflare.com, andi@firstfloor.org, gregkh@suse.de,
	herber@gondor.apana.org.au, chrisw@sous-sol.org,
	shemminger@vyatta.com
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:43728 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751088AbZFEL5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2009 07:57:07 -0400
In-Reply-To: <200906051425.02924.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigEA73C36EB4BFD4A0F385B999
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Hi Rusty,

Rusty Russell wrote:
> On Fri, 5 Jun 2009 04:19:17 am Gregory Haskins wrote:
>  =20
>> Avi Kivity wrote:
>>    =20
>>> Gregory Haskins wrote:
>>> One idea is similar to signalfd() or eventfd()
>>>      =20
>> And thus the "kvm-eventfd" (irqfd/iosignalfd) interface project was bo=
rn.
>> ;)
>>    =20
>
> The lguest patch queue already has such an interface :)

Cool!  Ultimately I think it will be easier if both lguest+kvm support
the same eventfd notion so this is good you are already moving in the
same direction.

> And I have a partially complete in-kernel virtio_pci patch with the sam=
e trick.
>  =20

I thought lguest didn't use pci?  Or do you just mean that you have an
in-kernel virtio-net for lguest?

As a follow up question, I wonder if we can easily port that to vbus so
that it will work in both lguest and kvm? (note to self: push a skeleton
example today)

> I switched from "kernel created eventfd" to "userspace passes in eventf=
d"
> after a while though; it lets you connect multiple virtqueues to a sing=
le fd
> if you want.
>  =20

Yeah, actually we switched that that model, too.  Aside from the
limitation you point out, there were some problems that Al Viro had
raised trying to do it in kernel w.r.t. fd abuse.

> Combined with a minor change to allow any process with access to the lg=
uest fd
> to queue interrupts, this allowed lguest to move to a thread-per-virtqu=
eue
> model which was a significant speedup as well as nice code reduction.
>  =20

Yep, that was one of my findings on venet as well so I was looking
forward to trying to get virtio-net to do the same.
> Here's the relevant kernel patch for reading.
>  =20

Thanks Rusty!  Will take a look.
> Thanks!
> Rusty.
>
> lguest: use eventfds for device notification
>
> Currently, when a Guest wants to perform I/O it calls LHCALL_NOTIFY wit=
h
> an address: the main Launcher process returns with this address, and fi=
gures
> out what device to run.
>
> A far nicer model is to let processes bind an eventfd to an address: if=
 we
> find one, we simply signal the eventfd.
>
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Davide Libenzi <davidel@xmailserver.org>
> ---
>  drivers/lguest/Kconfig          |    2 -
>  drivers/lguest/core.c           |    8 ++--
>  drivers/lguest/lg.h             |    9 ++++
>  drivers/lguest/lguest_user.c    |   73 +++++++++++++++++++++++++++++++=
+++++++++
>  include/linux/lguest_launcher.h |    1=20
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
>  =20

Note to self:  we probably need a similar line in KVM now.

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
> =20
>  		/* Check for signals */
> diff --git a/drivers/lguest/lg.h b/drivers/lguest/lg.h
> --- a/drivers/lguest/lg.h
> +++ b/drivers/lguest/lg.h
> @@ -82,6 +82,11 @@ struct lg_cpu {
>  	struct lg_cpu_arch arch;
>  };
> =20
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
> =20
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
> diff --git a/drivers/lguest/lguest_user.c b/drivers/lguest/lguest_user.=
c
> --- a/drivers/lguest/lguest_user.c
> +++ b/drivers/lguest/lguest_user.c
> @@ -7,6 +7,8 @@
>  #include <linux/miscdevice.h>
>  #include <linux/fs.h>
>  #include <linux/sched.h>
> +#include <linux/eventfd.h>
> +#include <linux/file.h>
>  #include "lg.h"
> =20
>  /*L:055 When something happens, the Waker process needs a way to stop =
the
> @@ -35,6 +37,70 @@ static int break_guest_out(struct lg_cpu
>  	}
>  }
> =20
> +bool send_notify_to_eventfd(struct lg_cpu *cpu)
> +{
> +	unsigned int i;
> +
> +	/* lg->eventfds is RCU-protected */
> +	preempt_disable();
> +	for (i =3D 0; i < cpu->lg->num_eventfds; i++) {
> +		if (cpu->lg->eventfds[i].addr =3D=3D cpu->pending_notify) {
> +			eventfd_signal(cpu->lg->eventfds[i].event, 1);
> +			cpu->pending_notify =3D 0;
> +			break;
> +		}
> +	}
> +	preempt_enable();
> +	return cpu->pending_notify =3D=3D 0;
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
> +	new =3D kmalloc(sizeof(*new) * (lg->num_eventfds + 1), GFP_KERNEL);
> +	if (!new)
> +		return -ENOMEM;
> +
> +	memcpy(new, lg->eventfds, sizeof(*new) * lg->num_eventfds);
> +	old =3D lg->eventfds;
> +	lg->eventfds =3D new;
> +	synchronize_rcu();
> +	kfree(old);
> +
> +	lg->eventfds[lg->num_eventfds].addr =3D addr;
> +	lg->eventfds[lg->num_eventfds].event =3D eventfd_fget(fd);
> +	if (IS_ERR(lg->eventfds[lg->num_eventfds].event))
> +		return PTR_ERR(lg->eventfds[lg->num_eventfds].event);
> +
> +	wmb();
> +	lg->num_eventfds++;
> +	return 0;
> +}
> +
> +static int attach_eventfd(struct lguest *lg, const unsigned long __use=
r *input)
> +{
> +	unsigned long addr, fd;
> +	int err;
> +
> +	if (get_user(addr, input) !=3D 0)
> +		return -EFAULT;
> +	input++;
> +	if (get_user(fd, input) !=3D 0)
> +		return -EFAULT;
> +
> +	mutex_lock(&lguest_lock);
> +	err =3D add_eventfd(lg, addr, fd);
> +	mutex_unlock(&lguest_lock);
> +
> +	return 0;
> +}
> +
>  /*L:050 Sending an interrupt is done by writing LHREQ_IRQ and an inter=
rupt
>   * number to /dev/lguest. */
>  static int user_send_irq(struct lg_cpu *cpu, const unsigned long __use=
r *input)
> @@ -260,6 +326,8 @@ static ssize_t write(struct file *file,=20
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
> +	for (i =3D 0; i < lg->num_eventfds; i++)
> +		fput(lg->eventfds[i].event);
> +
>  	/* If lg->dead doesn't contain an error code it will be NULL or a
>  	 * kmalloc()ed string, either of which is ok to hand to kfree(). */
>  	if (!IS_ERR(lg->dead))
> diff --git a/include/linux/lguest_launcher.h b/include/linux/lguest_lau=
ncher.h
> --- a/include/linux/lguest_launcher.h
> +++ b/include/linux/lguest_launcher.h
> @@ -58,6 +58,7 @@ enum lguest_req
>  	LHREQ_GETDMA, /* No longer used */
>  	LHREQ_IRQ, /* + irq */
>  	LHREQ_BREAK, /* + on/off flag (on blocks until someone does off) */
> +	LHREQ_EVENTFD, /* + address, fd. */
>  };
> =20
>  /* The alignment to use between consumer and producer parts of vring.
>
>
>
>  =20
Other than the potential rcu issues that Paul already addressed, looks
good.  FWIW: this looks like what we are calling "iosignalfd" on the kvm
land (unless I am misunderstanding).  Do you have the equivalent of
"irqfd" going the other way?

Thanks Rusty,
-Greg


--------------enigEA73C36EB4BFD4A0F385B999
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkopCAQACgkQlOSOBdgZUxkd8wCeKJky1JqLZQG+d0KD2UpnS2nj
11kAmwbmI7efXMWxjRSv1aXhhfjRvkl6
=8rUZ
-----END PGP SIGNATURE-----

--------------enigEA73C36EB4BFD4A0F385B999--
