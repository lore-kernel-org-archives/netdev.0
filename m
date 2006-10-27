From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 2/9] NetEffect 10Gb RNIC Driver: main kernel driver c file
Date: Thu, 26 Oct 2006 17:19:17 -0700
Message-ID: <adaslha6262.fsf@cisco.com>
References: <5E701717F2B2ED4EA60F87C8AA57B7CC064C9EB6@venom2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <openib-general@openib.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:54052 "EHLO
	sj-iport-6.cisco.com") by vger.kernel.org with ESMTP
	id S1946053AbWJ0ATT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Oct 2006 20:19:19 -0400
To: <glenng@NetEffect.com>
In-Reply-To: <5E701717F2B2ED4EA60F87C8AA57B7CC064C9EB6@venom2> (Glenn Grundstrom's message of "Thu, 26 Oct 2006 18:54:18 -0500")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > +static int nes_device_event(struct notifier_block *notifier, unsigned
 > long event, void *ptr);
 > +static int nes_inetaddr_event(struct notifier_block *notifier, unsigned
 > long event, void *ptr);
 > +static void nes_print_macaddr(struct net_device *netdev);
 > +static irqreturn_t nes_interrupt(int, void *, struct pt_regs *);
 > +static int __devinit nes_probe(struct pci_dev *, const struct
 > pci_device_id *);
 > +static int nes_suspend(struct pci_dev *, pm_message_t);
 > +static int nes_resume(struct pci_dev *);
 > +static void __devexit nes_remove(struct pci_dev *);
 > +static int __init nes_init_module(void);
 > +static void __exit nes_exit_module(void);

Some of these declarations are already unneeded (eg at least
nes_init_module and nes_exit_module), and it would be good to
rearrange your code so that the rest can be removed too.

 > +// _the_ function interface handle to nes_tcpip module

We prefer /* */ style comments

 > +static struct notifier_block nes_dev_notifier = {
 > +	notifier_call:  nes_device_event
 > +};

Standard C syntax (rather than gcc extension is preferred), like:

static struct notifier_block nes_dev_notifier = {
	.notifier_call = nes_device_event
};

 > +/**
 > + * nes_device_event
 > + * 
 > + * @param notifier
 > + * @param event
 > + * @param ptr
 > + * 
 > + * @return int
 > + */

There's no point to comments like this.  I can read the function
declaration just fine, so save the screen real estate unless you have
something more to say.

 > +	unsigned long reg0_start, reg0_flags, reg0_len;
 > +	unsigned long reg1_start, reg1_flags, reg1_len;

PCI bars are type resource_size_t, which can be bigger than long...

 > +	assert(pcidev != NULL);
 > +	assert(ent != NULL);

BUG_ON() is more idiomatic.  But this looks kind of useless anyway --
you'll get a nice enough oops if they are NULL.

 > +	/* Enable PCI device */
 > +	ret = pci_enable_device(pcidev);

This isn't major, but comments like this just waste screen space.  I
mean, someone who can't guess what pci_enable_device() does is
probably not going to be helped by the comment either.

 > +	/* pci tweaks */
 > +	pci_write_config_word(pcidev, 0x000c, 0xfc10);
 > +	pci_write_config_dword(pcidev, 0x0048, 0x00480007);

Looks rather magic and fragile.  Register 0xc is the cacheline size
and latency, right?  Why are you tweaking that?

And I assume 0x48 is somewhere in a capability structure.  It's much
better to use pci_find_capability() in that case.  That way when the
hardware guys tell you they have to rearrange the PCI header in the
next rev of the chip, you don't have to touch the chip.  However this
tweaking probably needs to be justified too.

 > +/**
 > + * nes_suspend - power management
 > + */
 > +static int nes_suspend(struct pci_dev *pcidev, pm_message_t state)
 > +{
 > +	dprintk("pcidev=%p\n", pcidev);
 > +
 > +	return (0);
 > +}
 > 

Umm, just don't have suspend/resume methods if you don't support it.

 > +	nes_adapter_free(nesdev->nesadapter);
 > +	
 > +	dprintk("nes_remove: calling iounmap.\n");
 > +	/* Unmap adapter PA space */
 > +	iounmap(nesdev->regs);
 > +
 > +	/* Unregister with OpenFabrics */
 > +	if (nesdev->of_device_registered) {
 > +		dprintk("nes_remove: calling nes_unregister_device.\n");
 > +		nes_unregister_device(nesdev);
 > +	}

You can still have upper layers calling into you until
ib_unregister_device() returns, so it looks bogus to do things like
iounmap before then.  I think your cleanup needs to be reordered.

And I don't think you're unregistering with OpenFabrics -- you're just
unregistering with the RDMA midlayer.

 > +	return (pci_module_init(&nes_pci_driver));

Just use pci_register_driver().
 - R.
