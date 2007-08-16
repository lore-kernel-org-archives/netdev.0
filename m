From: Brandon Philips <bphilips@suse.de>
Subject: Re: [patch 4/4] Update e1000 driver to use devres.
Date: Thu, 16 Aug 2007 10:05:22 -0700
Message-ID: <20070816170522.GA4226@ifup.org>
References: <20070815190014.GE7294@ifup.org>
	<D5C1322C3E673F459512FB59E0DDC329036D21B5@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	teheo@suse.de
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC329036D21B5@orsmsx414.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 01:38 Thu 16 Aug 2007, Waskiewicz Jr, Peter P wrote:
> > -	err = -ENOMEM;
> > -	netdev = alloc_etherdev(sizeof(struct e1000_adapter));
> > +	netdev = devm_alloc_etherdev(&pdev->dev, sizeof(struct 
> > +e1000_adapter));
> >  	if (!netdev)
> > -		goto err_alloc_etherdev;
> > +		return -ENOMEM;
> 
> I'm a bit confused why you removed the goto's, and then removed all the
> target unwinding code at the bottom of e1000_probe().   Those labels
> clean up resources if something fails, like the err_sw_init label.  I
> don't see anything in the devres code that jumps out at me that explains
> why we can do away with these cleanup routines.  Thoughts?

Have you read Documentation/driver-model/devres.txt?  That has a good
explanation.  Here is a practical explanation on how it works too.

This is the output from a normal modprobe then rmmod of e1000 with
devres debugging on.

# modprobe
DEVRES ADD f7fd6cc0 pcim_release (8 bytes)
DEVRES ADD f7a80fe0 devm_free_netdev (4 bytes) # netdev **p for free_netdev
DEVRES ADD f7dbe780 pcim_iomap_release (24 bytes) # adapter->hw.hw_addr
DEVRES ADD f7dbe9c0 devm_kzalloc_release (40 bytes) # adapter->tx_ring
DEVRES ADD f7dbe8c0 devm_kzalloc_release (44 bytes) # adapter->rx_ring

# rmmod
DEVRES REL f7dbe8c0 devm_kzalloc_release (44 bytes) # adapter->tx_ring
DEVRES REL f7dbe9c0 devm_kzalloc_release (40 bytes) # adapter->rx_ring
DEVRES REL f7dbe780 pcim_iomap_release (24 bytes) # adapter->hw.hw_addr
DEVRES REL f7a80fe0 devm_free_netdev (4 bytes) # called free_netdev
DEVRES REL f7fd6cc0 pcim_release (8 bytes)

Now if I insert a return -ENOMEM right after allocating tx_ring:
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1356,6 +1356,8 @@ e1000_alloc_queues(struct e1000_adapter *adapter)
 {
        adapter->tx_ring = kcalloc(adapter->num_tx_queues,
                                   sizeof(struct e1000_tx_ring),
GFP_KERNEL);
+
+       return -ENOMEM;
        if (!adapter->tx_ring)
                return -ENOMEM;

#insmod
DEVRES ADD f7a80e80 pcim_release (8 bytes)
DEVRES ADD f7a80ca0 devm_free_netdev (4 bytes)
DEVRES ADD eb7f0080 pcim_iomap_release (24 bytes)
DEVRES ADD eb7f0000 devm_kzalloc_release (40 bytes)
e1000_sw_init: Unable to allocate memory for queues 
DEVRES REL eb7f0000 devm_kzalloc_release (40 bytes)
DEVRES REL eb7f0080 pcim_iomap_release (24 bytes)
DEVRES REL f7a80ca0 devm_free_netdev (4 bytes)
DEVRES REL f7a80e80 pcim_release (8 bytes)
ACPI: PCI interrupt for device 0000:02:00.0 disabled
e1000: probe of 0000:02:00.0 failed with error -12

Since we are returning an error from probe the driver core calls
devres_release_all(dev) which releases all of the resources in the right
order.  See really_probe() in drivers/base/dd.c.

SIDE NOTE
---------
I ran into a possible e1000 bug with the little -ENOMEM patch above both
with and without the devres patches.  The driver seems to leave the
EEPROM in a bad state on error because I get this error after trying to
insert the module again: 

e1000_probe: The EEPROM Checksum Is Not Valid 

A power cycle but not a reboot fixes it.

Thanks,

	Brandon

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
