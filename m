From: "David S. Miller" <davem@redhat.com>
Subject: Re: dev->destructor
Date: Thu, 01 May 2003 00:00:58 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030501.000058.39187964.davem@redhat.com>
References: <20030429.232631.68131803.davem@redhat.com>
	<200305010110.FAA08689@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com, acme@conectiva.com.br,
   rusty@rustcorp.com.au
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200305010110.FAA08689@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: kuznet@ms2.inr.ac.ru
   Date: Thu, 1 May 2003 05:10:33 +0400 (MSD)

[ Rusty, just skip down to "Ok ok ok!", it's something we've
  discussed before.  Some of these problems are becomming so
  widespread that we need to implement a fix, I'll probably be
  the one to end up doing it... ]

   > 1) dev_get() gets module reference and dev_put() puts is.
   >    Ugly, as this means dev_get() can fail, but this does
   >    cover all the possible cases.
   
   Seems, you eventually _really_ understood why I histerically moan
   about bogosity of modules and maybe ready to recongnize that it is
   not just histerical moaning in some part. :-)
   
Yes, I know, and we can talk about this until the cows come
home... :-)
   
   > 2) Make unregister_netdev() wait for refcount to reach 1
   >    regardless of whether dev->destructor is NULL or not.
   > 
   > I don't like #1.  Do you see some holes in #2?
   
   It is deadlock.
   
What exactly is this deadlock?  Let me think...

None of destructors kill reference to device object, and I mean none
of them.  It is why I thought the idea works.

Also, holding RTNL semaphore does not block potential holders
of device reference.  Or does it?
   
   > As Stephen brought up, this also means we should do something
   > about that NETDEV_UNREGISTER code in dst_dev_event() :-(
   
   It is just one and the simplest subcase of general situation.
   Module must not be unloaded while device is held, that's all.

Ok ok ok!!!  Let us depict how it might work in your idealized
module scheme ok?

Your idea, as I understand it, is to add callback to module that
freezes module then at some time in the future makes indication
that module is clean and may be unloaded safely.

The logic is that module knows about reference, internal attributes,
etc. and thus can check for unloadability better than any simple
refcounting system can.

The best argument for this are things like ipv6 which are enormously
complicated to load/unload safely.  If we were to use the module
refcounting system to make ipv6 unloading work cleanly, every other
line of the ipv6 code would be some module get/put. :-)

So the unload sequence is something like:

	/* Shutdown the module, so that no new references may
	 * be created.
	 */
	rc = module->shutdown(module);
	if (rc)
		goto out_err;

	wait_event(&module->unload_waitq, module->unloadable);
	module->exit();

Then, using netdevice as an example, register_netdevice() would
do something like:

	module_add_instance(dev->owner);

which is simply:

void module_add_instance(struct module *module)
{
	if (module)
		atomic_inc(&module->instances);
}

The net device drivers add:

module_shutdown(netdev_module_shutdown);

And then netdev_module_shutdown() would go:

int netdev_module_shutdown(struct module *module)
{
	struct net_device *d, *d_next;

	rtnl_lock();
	d_next = NULL;
	for (d = dev_base; d != NULL; d = d_next) {
		d_next = d->next;
		if (d->owner == module) {
			if (unregister_netdevice(d))
				BUG();

			/* Keep traversing, this module may drive
			 * multiple device instances.
			 */
		}
	}
	rtnl_unlock();

	return 0;
}

And, at final dev_put(), netdev_finish_unregister() is invoked,
and we change it to look something like this:

int netdev_finish_unregister(struct net_device *dev)
{
        BUG_TRAP(!dev->ip_ptr);
        BUG_TRAP(!dev->ip6_ptr);
        BUG_TRAP(!dev->dn_ptr);

        if (!dev->deadbeaf) {
                printk(KERN_ERR "Freeing alive device %p, %s\n",
                       dev, dev->name);
                return 0;
        }
#ifdef NET_REFCNT_DEBUG
        printk(KERN_DEBUG "netdev_finish_unregister: %s%s.\n",
                dev->name,
               (dev->destructor != NULL)?"":", old style");
#endif
        if (dev->destructor)
                dev->destructor(dev);

	module_dec_instance(dev->owner);

        return 0;
}

We implement module_dev_instance as:

void module_dec_instance(struct module *module)
{
	if (module && atomic_dec_and_test(&module->instances))
		module_is_unloadable(module);
}

Finally, we implement module_is_unloadable() which is simply:

void module_is_unloadable(struct module *module)
{
	if (module) {
		module->unloadable = 1;
		wake_up(&module->unload_waitq);
	}
}

Next, let us make socket example for "simple protocol".

static int __init simple_proto_init(void)
{
	int rc;

	rc = sock_register(&simple_proto_ops);
	if (rc)
		return rc;

	return 0;
}

static int __exit simple_proto_shutdown(struct module *module)
{
	int rc;

	rc = sock_unregister(AF_SIMPLE);
	if (rc)
		return rc;

	return 0;
}

module_init(simple_proto_init);
module_shutdown(simple_proto_shutdown);

Now, where to place the code to mark module as unloadable?
We could maintain state internally using:

static atomic_t nr_simple_sockets;

And as sockets are created/destroyed, we inc/dec this thing.
When it is decreamented to zero, we can say

	module_is_unloadable(THIS_MODULE);

Question is, where to make this?  It cannot be in the module
itself of course, that would create race condition similar to
one which exists today making this exercise quite pointless :-)

Alexey and I had some private conversations about this with Rusty,
he agreed with our sentiments mostly, but he was concerned about
unload semantics and some unfortunate side effects of two-stage
unload.  Specifically, consider:

int example_module_shutdown(struct module *module)
{
	int rc;

	rc = unregister_foo(&foo);
	if (rc)
		return rc;

	rc = unregister_bar(&bar);
	if (rc) {
		register_foo(&foo);
		return rc;
	}

	return 0;
}

Note the problem.  If between the unregister_foo() and re-register of
foo in the failure path, someone asks to open a "foo" it will fail.
Those semantics absolutely stink.

Rusty went on to describe that this is one of the reasons for the
current "enable refcounts" scheme with try_module_get().  A single
binary state enables all of the interfaces to start to succeed.
ie. opening an object created by the module does not succeed until
module->init() finishes successfully and thus try_module_get()
starts to return success.

I think he was trying to hint to us that some analogue needs to
occur for shutdown as well.  Ie. to rewrite my shutdown logic
above:

	rc = stop_refcounts(mod);
	if (rc)
		goto out_err;

	if (mod->shutdown) {
		/* Shutdown the module, so that no new references may
		 * be created.
		 */
		rc = mod->shutdown(mod);
		if (rc) {
			restart_refcounts(mod);
			goto out_err;
		}

		wait_event(&mod->unload_waitq, mod->unloadable);
		if (module_refcount(mod) != 0)
			BUG();
	}
	restart_refcounts(mod);

	/* ... put here all the existing code in sys_delete_module()
	 * ... dealing O_NONBLOCK etc. etc.
	 */		

	module->exit();
	module_free(mod);

I am not even sure this is right.  It's quite a tricky area and
requires real brains to solve.
