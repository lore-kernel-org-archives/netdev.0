From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] (5/6) ibmtr -- probe2
Date: Fri, 17 Oct 2003 15:49:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031017154921.7afa10f0.shemminger@osdl.org>
References: <OF5D2BA91F.A6EBFE7D-ON84256DC2.004A9DE9-84256DC2.004ADCCD@urscorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mike_Phillips@URSCorp.com
In-Reply-To: <OF5D2BA91F.A6EBFE7D-ON84256DC2.004A9DE9-84256DC2.004ADCCD@urscorp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 17 Oct 2003 10:37:41 -0300
Mike_Phillips@URSCorp.com wrote:

> 
> In ibmtr_cs.c:
> 
> >+static int ibmtr_init(struct net_device *dev)
> >+{
> >+    extern int ibmtr_probe1(struct net_device *, int);
> >+
> >+    return ibmtr_probe1(dev, dev->base_addr);
> >+}
> >+
> > /*======================================================================
> 
> >     ibmtr_attach() creates an "instance" of the driver, allocating
> >@@ -194,7 +200,8 @@
> 
> >     link->irq.Instance = info->dev = dev;
> >
> >-    dev->init = &ibmtr_probe;
> >+    dev->init = ibmtr_init;
> >+
> 
> This changes dev->init from calling ibmtr_probe to ibmtr_probe1. The probe
> routines are specifically split into two because of ibmtr_cs. It doesn't
> need to do second probe routing because all the memory spaces get allocated
> by the pcmcia driver. Trying to allocate the same IO mem area will fail
> because its already been allocated by ibmtr_cs.

The probe routine interface needs to change to return the device structure,
and the interface that ibmtr_cs needs is one where the structure is allocated.
If you look at the details,  the new probe1 does pretty much the same thing
the old probe did.  Doesn't the PCMCIA infrastructure give the correct memory
address and set it during the config routine. 

The problem with the structures was a BUG in the existing code!
The PCMCIA code was setting dev->priv to a structure:
	
struct ibmtr_dev_t {
    dev_link_t		link;
    struct net_device	*dev;
    dev_node_t          node;
    window_handle_t     sram_win_handle;
    struct tok_info	ti;
}

and then later when registered, the dev->init callback goes to ibmtr_probe and
then ibmtr_probe1 which expects dev->priv to point to 'struct tok_info'

The code is broken in 2.6.0-test7.
	 
