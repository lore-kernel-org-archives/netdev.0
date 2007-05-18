From: Kieran Mansley <kmansley@solarflare.com>
Subject: [PATCH 0/4] [Net] Support Xen accelerated network
	plugin modules
Date: Fri, 18 May 2007 14:15:48 +0100
Message-ID: <1179494148.14376.7.camel@moonstone.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-nuAlVhN23GAGBcwmNmf/"
Cc: muli@il.ibm.com, netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: xen-devel@lists.xensource.com
Return-path: <xen-devel-bounces@lists.xensource.com>
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org


--=-nuAlVhN23GAGBcwmNmf/
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

This is a repost of some earlier patches to the xen-devel mailing list,
with a number of changes thanks to some useful suggestions from others.
Apologies for the short delay in getting this next version ready.

I've also CC'd netdev@vger.kernel.org as some of the files being patched
may be merged into upstream linux soon, and so folks there may have
opinions too.

This set of patches provides the hooks and support necessary for
accelerated network plugin modules to attach to Xen's netback and
netfront.  These modules provide a fast path for network traffic where
there is hardware support available for the netfront driver to send and
receive packets directly to a NIC (such as those available from
Solarflare).

As there are currently no available plugins, I've attached a couple of
dummy ones to illustrate how the hooks could be used.  These are
incomplete (and clearly wouldn't even compile) in that they only include
code to show the interface between the accelerated module and
netfront/netback.  A lot of the comments hint at what code should go
where.  They don't show any interface between the accelerated frontend
and accelerated backend, or hardware access, for example, as those would
both be specific to the implementation.  I hope they help illustrate
this, but if you have any questions I'm happy to provide more
information.

A brief overview of the operation of the plugins:  When the accelerated
modules are loaded, a VI is created by the accelerated backend to allow
the accelerated frontend to safely access portions of the NIC.  For RX,
when packets are received by the accelerated backend, it will examine
them and if appropriate insert filters into the NIC to deliver future
packets on that address directly to the accelerated frontend's VI.  For
TX, netfront gives each accelerated frontend the option of sending each
packet, which it can accept (if it wants to send it directly to the
hardware) or decline (if it thinks this is more appropriate to send via
the normal network path).

We have tried to ensure that the hooks are hardware-agnostic, i.e. would
be relevant to hardware other than our own, without providing all
possible ways of doing each task (but if others need to extend it, that
would be welcomed).

We have found that using this approach to accelerating network traffic,
domU to domU connections (across the network) can achieve close to the
performance of dom0 to dom0 connections on a 10Gbps ethernet.  This is
roughly double the bandwidth seen with unmodified Xen. 

Kieran

--=-nuAlVhN23GAGBcwmNmf/
Content-Disposition: attachment; filename=dummy_accel_backend.c
Content-Type: text/x-csrc; name=dummy_accel_backend.c; charset=UTF-8
Content-Transfer-Encoding: 7bit

/***************************************************************************/
/*! \file dumm_accel_backend.c Dummy accelerated plugin module

Copyright 2006 Solarflare Communications Inc,
               9501 Jeronimo Road, Suite 250,
               Irvine, CA 92618, USA

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License version 2 as published by the Free
Software Foundation, incorporated herein by reference.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

*/
/***************************************************************************/

static struct netback_accel_hooks accel_hooks = {
        &netback_accel_probe,
        &netback_accel_remove
};

static const char *frontend_name = "dummynetaccel";

static int netback_accel_init(void)
{
        /* Initialise the rest of the module... */

        /* Tell the netback that we're here */
        netback_connect_accelerator(0, frontend_name, &accel_hooks);
}
module_init(netback_accel_init);


static void __exit netback_accel_exit(void)
{
        netback_disconnect_accelerator(0, frontend_name);

        /* ...and take down the rest of the module */
}
module_exit(netback_accel_exit);




int netback_accel_probe(struct xenbus_device *dev)
{
        struct backend_info *binfo;

        /* Setup per-device internal state */

        /* Store internal state for future access */
        binfo = (struct backend_info *) dev->dev.driver_data;
        binfo->netback_accel_priv = my_internal_state;

        /* Setup watch on accel-state, so we know when frontend
           acceleration plugin is loaded */
        setup_domu_accel_watch(dev, my_internal_state);
}


int netback_accel_remove(struct xenbus_device *dev)
{
        /* Cleanup as the device is going away */
}


void netback_accel_frontend_changed(struct xenbus_device *dev,
                                    XenbusState frontend_state)
{
        switch(frontend_state) {
        case XenbusStateConnected:
                /* Frontend has loaded and is ready to go */
                /* Initialise ourselves */
                setup_accel_backend();
                netback_accel_update_state(dev, XenbusStateConnected);
        }
}


void netback_accel_update_state(struct xenbus_device *dev, int state)
{
        struct xenbus_transaction tr;
        int err;

        if(xenbus_exists(XBT_NIL, dev->nodename, "")) {
        again:
                err = xenbus_transaction_start(&tr);
                if (err == 0)
                        err = xenbus_printf(tr, dev->nodename, "accelstate", "%d", 
                                            state);
                if (err != 0)
                        xenbus_transaction_end(tr, 1);
                else {
                        err = xenbus_transaction_end(tr, 0);
                        if(err == -EAGAIN)
                                goto again;
                }
        }
}

--=-nuAlVhN23GAGBcwmNmf/
Content-Disposition: attachment; filename=dummy_accel_frontend.c
Content-Type: text/x-csrc; name=dummy_accel_frontend.c; charset=UTF-8
Content-Transfer-Encoding: 7bit

/***************************************************************************/
/*! \file dumm_accel_frontend.c Dummy accelerated plugin module

Copyright 2006 Solarflare Communications Inc,
               9501 Jeronimo Road, Suite 250,
               Irvine, CA 92618, USA

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License version 2 as published by the Free
Software Foundation, incorporated herein by reference.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

*/
/***************************************************************************/

#include <linux/stddef.h>
#include <linux/errno.h>
#include <linux/skbuff.h>
#include <linux/netdevice.h>

#include <xen/xenbus.h>
#include <xen/evtchn.h>
#include <xen/gnttab.h>

/* drivers/xen/netfront/netfront.h */
#include "netfront.h"

static const char *frontend_name = "dummynetaccel";

static struct netfront_accel_hooks accel_hooks = {
        .new_device            = &netfront_accel_probe,
        .suspend               = &netfront_accel_xenbus_suspend,
        .resume                = &netfront_accel_xenbus_resume,
        .remove                = &netfront_accel_xenbus_remove,
        .backend_changed       = &netfront_accel_backend_changed,
        .netdev_poll           = &netfront_accel_netdev_poll,
        .start_xmit            = &netfront_accel_netdev_start_xmit,
        .start_napi_interrupts = &netfront_accel_start_napi_interrupts,
        .stop_napi_interrupts  = &netfront_accel_stop_napi_interrupts
};

static int netfront_accel_init(void)
{
        /* Initialise internal state to module... */

        /* Hook into normal netfront */
        netfront_accelerator_loaded(frontend_name, &accel_hooks);

        /* Should now get a probe if netfront has any vifs interested
           in our acceleration */

        return 0;
}
module_init(netfront_accel_init);

static void netfront_accel_exit(void)
{
        /* Unhook from normal netfront */
        netfront_accelerator_unloaded(frontend_name);

        /* ...and rest of module cleanup */
}
module_exit(netfront_accel_exit);


/* The frontend calls this function to ask this plugin to support a
   new network interface */
int netfront_accel_probe(struct net_device *net_dev, struct xenbus_device *dev)
{
        unsigned flags;

        /* Setup per-device internal state */

        /* Store internal state handle for access from the xenbus_device */
        ((struct netfront_info *)dev->dev.driver_data)->accel_priv 
                = my_internal_state;

        /* Create shared pages, grants, irqs etc for communication
           with accelerated backend plugin module */

        /* Kick off contact with the backend */
        netfront_accel_update_state(dev, XenbusStateConnected);

        /* Enable interrupts */
        local_irq_save(flags);
        if(netfront_accel_enable_interrupts()) {
                /* Something to do already */
                netif_rx_schedule(net_dev);
        }
        local_irq_restore(flags);

        return 0;
}

/* Called on xenbus_suspend callback, allows plugin to remove
   accelerated path */
int netfront_accel_xenbus_suspend(struct xenbus_device *dev)
{
        /* Disconnect the accelerated plugin */
        netfront_accelerator_unloaded(frontend_name);
        
        /* Tell the accelerated backend that we're going */
        net_accel_update_state(dev, XenbusStateClosing);

        return 0;
}

/* Called on xenbus_resume callback, allows plugin to restore
   accelerated path */
int netfront_accel_xenbus_resume(struct xenbus_device *dev)
{
        /* Reconnect to the frontend module */
        netfront_accelerator_loaded(frontend_name, &accel_hooks);

        /* Should now get a probe if netfront has any vifs interested
           in our acceleration */

        return 0;
}

/* Called on xenbus_remove callback, allows plugin to remove internal
   state */
int netfront_accel_xenbus_remove(struct xenbus_device *dev)
{
        /* Remove the link to accelerated private state */
        ((struct netfront_info *)dev->dev.driver_data)->accel_priv = NULL;
        
        return 0;
}


/* Function to deal with Xenbus state change in backend */
void netfront_accel_backend_changed(struct xenbus_device *dev,
                                    XenbusState frontend_state)
{
        /* Not interested in changes of the normal netfront/netback
           state machine at the moment.  Others may be */
}


/* Function to deal with Xenbus accelstate change in backend */
void netfront_accel_backend_accel_changed(struct xenbus_device *dev,
                                          XenbusState backend_state)
{
        /* This is called off a watch set up by the accelerated
           plugin */

        /* Take appropriate internal action based on accelerated state
           changing - allows the accelerated plugins to go through a
           seperate but similar state machine cycle to the normal
           netfront/netback drivers */
        switch(backend_state) {
        case XenbusStateUnknown:
                /* ...etc */ 
        case XenbusStateConnected:
                /* We're now ready for action, notify frontend to
                   start using us for this device */
                netfront_accelerator_ready(frontend_name, dev)
        }
}

/* The net_device is being polled, check the accelerated hardware for
   any pending packets */
int netfront_accel_netdev_poll(struct net_device *net_dev, int *budget)
{
        int rx_done, rx_allowed = *budget;
        struct netfront_info *np = netdev_priv(net_dev);
        my_internal_state = np->accel_priv;

        /* Probe the fast path accelerated hardware to see if there
           have been any packets delivered direct to this frontend
           plugin.  This will call netif_receive_skb() on any received
           packets to pass to stack */
        rx_done = probe_my_event_queue(my_internal_state, rx_allowed);

        *budget -= rx_done;

        /* Done all we want to ? */
        if(rx_done < rx_allowed)
                return 0;
        
        /* More to do */
        return 1;
}

/* start_xmit: Used to give the accelerated plugin the option of
   sending a packet.  Returns non-zero if has done so, or zero to
   decline and force the packet onto normal send path */
int netfront_accel_netdev_start_xmit(struct sk_buff *skb,
                                     struct net_device *net_dev)
{
        int handled;
        struct netfront_info *np = netdev_priv(net_dev);
        my_internal_state = np->accel_priv;

        /* Have a look at this packet and see if it is one to send on
           the fast path */
        handled = netfront_accel_xmit(my_internal_state, skb);

        if(handled == BUSY) {
                /* We'd like to take it, but busy at the moment */
                netif_stop_queue(net_dev);

                /* netif_wake_queue() will be called when no longer
                   busy and this packet has been sent */
        }
        
        if(handled == CANT)
                /* We can't send this on the fast path, force onto
                   normal slow path by returning zero */
                return 0;
        else
                return 1;
}

/* Process request from netfront to start napi interrupt
   mode. (i.e. enable interrupts as it's finished polling) */
int netfront_accel_start_napi_interrupts(struct net_device *dev) 
{
        struct netfront_info *np = netdev_priv(dev);
        my_internal_state = np->accel_priv;

        
        if(!netfront_accel_enable_interrupts(my_internal_state)) {
                /* There was something there already, tell caller we
                   had something to do. */
                return 1;
        }

        return 0;
}

/* Process request from netfront to stop napi interrupt
   mode. (i.e. disable interrupts as it's starting to poll */
void netfront_accel_stop_napi_interrupts(struct net_device *dev) 
{
        struct netfront_info *np = netdev_priv(dev);
        my_internal_state = np->accel_priv;

        netfront_accel_disable_interrupts(my_internal_state);
}



void netfront_accel_update_state(struct xenbus_device *dev, int state)
{
        struct xenbus_transaction tr;
        int err;

        if(xenbus_exists(XBT_NIL, dev->nodename, "")) {
        again:
                err = xenbus_transaction_start(&tr);
                if (err == 0)
                        err = xenbus_printf(tr, dev->nodename, "accelstate", "%d", 
                                            state);
                if (err != 0)
                        xenbus_transaction_end(tr, 1);
                else {
                        err = xenbus_transaction_end(tr, 0);
                        if(err == -EAGAIN)
                                goto again;
                }
        }
}

--=-nuAlVhN23GAGBcwmNmf/
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Xen-devel mailing list
Xen-devel@lists.xensource.com
http://lists.xensource.com/xen-devel

--=-nuAlVhN23GAGBcwmNmf/--
