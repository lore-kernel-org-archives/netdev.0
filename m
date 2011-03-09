From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Bug inkvm_set_irq
Date: Wed, 9 Mar 2011 15:00:01 +0200
Message-ID: <20110309130000.GA30297@redhat.com>
References: <20110301070333.GA5972@redhat.com>
 <4D6D0510.4060300@univ-nantes.fr>
 <20110303144715.GA12400@redhat.com>
 <4D6FB313.1010400@univ-nantes.fr>
 <20110303155533.GA13310@redhat.com>
 <4D70AF3B.5080007@univ-nantes.fr>
 <20110304093500.GA31844@redhat.com>
 <4D70B339.3080001@univ-nantes.fr>
 <20110308111320.GA8002@redhat.com>
 <4D77727B.2000207@univ-nantes.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Jean-Philippe Menil <jean-philippe.menil@univ-nantes.fr>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4D77727B.2000207@univ-nantes.fr>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 09, 2011 at 01:28:43PM +0100, Jean-Philippe Menil wrote:
> Le 08/03/2011 12:13, Michael S. Tsirkin a =C3=A9crit :
> >On Fri, Mar 04, 2011 at 10:39:05AM +0100, Jean-Philippe Menil wrote:
> >>Yes, it's a 2.6.37.2 kernel.
> >OK, here's a debugging patch.
> >Please run with slab debugging as previously until you see
> >'eventfd bug detected!' in dmesg or until there is a crash.
> >It might be also useful to enable timestampts on printk with
> >  Symbol: PRINTK_TIME [=3Dy]
> >   =E2=94=82 Type  : boolean
> >   =E2=94=82 Prompt: Show timing information on printks
> >
> >once you see the error, please upload the
> >full dmesg output somewhere to we can track what
> >goes on.
> >
> >Hopefully there won't be an oops this time which
> >should make it easier for you to test (no need to
> >reboot).
> >
> >
> >diff --git a/virt/kvm/eventfd.c b/virt/kvm/eventfd.c
> >index c1f1e3c..3cb679b 100644
> >--- a/virt/kvm/eventfd.c
> >+++ b/virt/kvm/eventfd.c
> >@@ -32,6 +32,7 @@
> >  #include<linux/eventfd.h>
> >  #include<linux/kernel.h>
> >  #include<linux/slab.h>
> >+#include<linux/nmi.h>
> >
> >  #include "iodev.h"
> >
> >@@ -43,6 +44,8 @@
> >   * ---------------------------------------------------------------=
-----
> >   */
> >
> >+#define KVM_BAD_PTR ((void*)(long)(0x6b6b6b6b6b6b6b6bull))
> >+
> >  struct _irqfd {
> >  	struct kvm               *kvm;
> >  	struct eventfd_ctx       *eventfd;
> >@@ -61,6 +64,13 @@ irqfd_inject(struct work_struct *work)
> >  {
> >  	struct _irqfd *irqfd =3D container_of(work, struct _irqfd, inject=
);
> >  	struct kvm *kvm =3D irqfd->kvm;
> >+	if (kvm =3D=3D KVM_BAD_PTR) {
> >+		printk(KERN_ERR "Eventfd bug detected!\n");
> >+		printk(KERN_ERR "%s(work=3D%p,irqfd=3D%p,kvm=3D%p,gsi=3D%d)\n", _=
_func__,
> >+			work, irqfd, kvm, irqfd->gsi);
> >+		trigger_all_cpu_backtrace();
> >+		return;
> >+	}
> >
> >  	kvm_set_irq(kvm, KVM_USERSPACE_IRQ_SOURCE_ID, irqfd->gsi, 1);
> >  	kvm_set_irq(kvm, KVM_USERSPACE_IRQ_SOURCE_ID, irqfd->gsi, 0);
> >@@ -75,6 +85,8 @@ irqfd_shutdown(struct work_struct *work)
> >  	struct _irqfd *irqfd =3D container_of(work, struct _irqfd, shutdo=
wn);
> >  	u64 cnt;
> >
> >+	printk(KERN_ERR "%s(work=3D%p,irqfd=3D%p,kvm=3D%p, gsi=3D%d)\n", _=
_func__,
> >+	       work, irqfd, irqfd->kvm, irqfd->gsi);
> >  	/*
> >  	 * Synchronize with the wait-queue and unhook ourselves to preven=
t
> >  	 * further events.
> >@@ -91,6 +103,8 @@ irqfd_shutdown(struct work_struct *work)
> >  	 * It is now safe to release the object's resources
> >  	 */
> >  	eventfd_ctx_put(irqfd->eventfd);
> >+	printk(KERN_ERR "kfree at %s(work=3D%p,irqfd=3D%p)\n", __func__,
> >+	       work, irqfd);
> >  	kfree(irqfd);
> >  }
> >
> >@@ -111,6 +125,8 @@ static void
> >  irqfd_deactivate(struct _irqfd *irqfd)
> >  {
> >  	BUG_ON(!irqfd_is_active(irqfd));
> >+	printk(KERN_ERR "%s(irqfd=3D%p,kvm=3D%p, gsi=3D%d)\n", __func__,
> >+	       irqfd, irqfd->kvm, irqfd->gsi);
> >
> >  	list_del_init(&irqfd->list);
> >
> >@@ -178,6 +194,8 @@ kvm_irqfd_assign(struct kvm *kvm, int fd, int gs=
i)
> >
> >  	irqfd->kvm =3D kvm;
> >  	irqfd->gsi =3D gsi;
> >+	printk(KERN_ERR "%s(irqfd=3D%p,kvm=3D%p, gsi=3D%d)\n", __func__,
> >+	       irqfd, kvm, gsi);
> >  	INIT_LIST_HEAD(&irqfd->list);
> >  	INIT_WORK(&irqfd->inject, irqfd_inject);
> >  	INIT_WORK(&irqfd->shutdown, irqfd_shutdown);
> >@@ -264,6 +282,8 @@ kvm_irqfd_deassign(struct kvm *kvm, int fd, int =
gsi)
> >  	struct _irqfd *irqfd, *tmp;
> >  	struct eventfd_ctx *eventfd;
> >
> >+	printk(KERN_ERR "%s(kvm=3D%p, gsi=3D%d)\n", __func__,
> >+	       kvm, gsi);
> >  	eventfd =3D eventfd_ctx_fdget(fd);
> >  	if (IS_ERR(eventfd))
> >  		return PTR_ERR(eventfd);
> >@@ -305,6 +325,7 @@ void
> >  kvm_irqfd_release(struct kvm *kvm)
> >  {
> >  	struct _irqfd *irqfd, *tmp;
> >+	printk(KERN_ERR "%s(kvm=3D%p)\n", __func__, kvm);
> >
> >  	spin_lock_irq(&kvm->irqfds.lock);
> >
> >--
> >To unsubscribe from this list: send the line "unsubscribe netdev" in
> >the body of a message to majordomo@vger.kernel.org
> >More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Hi,
>=20
> I boot the host with the patched kernel yesterday.
> No crach until now, but two "Eventfd bug detected!" in the log at
> "Mar  9 02:04:31" and "Mar  9 02:15:17"
> You can find part of the log at the following adress:
> http://filex.univ-nantes.fr/get?k=3DjL4Fe7yfSMN57toAH7V
>=20
> It a split file of the kern.log (1,4G), so if you need another part
> of the log, let me know.
>=20
> Thanks for all.
>=20
> Regards.

Downloading, it's big :)
What about some 1000 lines before and after Eventfd bug detected! line?
