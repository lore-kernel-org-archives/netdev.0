From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: dev->destructor
Date: Tue, 06 May 2003 14:18:36 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030506075808.388332C07F@lists.samba.org>
References: <20030505130050.4b9868bb.shemminger@osdl.org>
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
   acme@conectiva.com.br
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-reply-to: Your message of "Mon, 05 May 2003 13:00:50 MST."
             <20030505130050.4b9868bb.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20030505130050.4b9868bb.shemminger@osdl.org> you write:
> As an experiment, tried acquiring module ref count every time network
> device is ref counted.

Brave man 8)

> The result is discovering that there are cases in the Ethernet
> module init path where there is a call to dev_hold() without a
> previous explicit ref count.

Well caught: this is in fact a false alarm.  Coming, as we do, out of
module_init(), we actually hold an implicit reference.

It's logically consistent to make it implicit, and cuts out some code
in the unload path.

How's this?
Rusty.
--
  Anyone who quotes me in their sig is an idiot. -- Rusty Russell.

Name: Hold Initial Reference To Module
Author: Rusty Russell
Status: Tested on 2.5.69

D: __module_get is theoretically allowed on module inside init, since
D: we already hold an implicit reference.  Currently this BUG()s: make
D: the reference count explicit, which also simplifies delete path.

diff -urpN --exclude TAGS -X /home/rusty/devel/kernel/kernel-patches/current-dontdiff --minimal linux-2.5.69/kernel/module.c working-2.5.69-module-init-ref/kernel/module.c
--- linux-2.5.69/kernel/module.c	2003-05-05 12:37:13.000000000 +1000
+++ working-2.5.69-module-init-ref/kernel/module.c	2003-05-06 12:11:18.000000000 +1000
@@ -214,6 +214,8 @@ static void module_unload_init(struct mo
 	INIT_LIST_HEAD(&mod->modules_which_use_me);
 	for (i = 0; i < NR_CPUS; i++)
 		atomic_set(&mod->ref[i].count, 0);
+	/* Hold reference count during initialization. */
+	atomic_set(&mod->ref[smp_processor_id()].count, 1);
 	/* Backwards compatibility macros put refcount during init. */
 	mod->waiter = current;
 }
@@ -500,16 +502,6 @@ sys_delete_module(const char __user *nam
 		goto out;
 	}
 
-	/* Coming up?  Allow force on stuck modules. */
-	if (mod->state == MODULE_STATE_COMING) {
-		forced = try_force(flags);
-		if (!forced) {
-			/* This module can't be removed */
-			ret = -EBUSY;
-			goto out;
-		}
-	}
-
 	/* If it has an init func, it must have an exit func to unload */
 	if ((mod->init != init_module && mod->exit == cleanup_module)
 	    || mod->unsafe) {
@@ -1448,6 +1440,7 @@ sys_init_module(void __user *umod,
 			printk(KERN_ERR "%s: module is now stuck!\n",
 			       mod->name);
 		else {
+			module_put(mod);
 			down(&module_mutex);
 			free_module(mod);
 			up(&module_mutex);
@@ -1463,6 +1456,9 @@ sys_init_module(void __user *umod,
 	mod->init_size = 0;
 	up(&module_mutex);
 
+	/* Drop initial reference. */
+	module_put(mod);
+
 	return 0;
 }
 
