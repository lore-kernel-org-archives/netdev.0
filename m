From: Anton Blanchard <anton@samba.org>
Subject: Network device driver probe issues
Date: Thu, 15 Jul 2004 23:52:44 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040715135244.GD27715@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cramerj@intel.com, john.ronciak@intel.com, ganesh.venkatesan@intel.com,
        jonmason@us.ibm.com, jkenisto@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,

With the advent of hotplug and udev we see network device driver opens
called as soon as possible, ie after register_netdev. In a lot of cases
drivers currently call register_netdev too early, before they are ready
to handle an open. I think the e1000 had this problem (which has since
been fixed), and the s2io appears to have this same issue.

Once the register_netdev call is delayed until late in probe (it really
should be the last thing the probe call does) we have an issue with
device printks. One of the reasons register_netdev is often early in the
probe routine of network drivers is that it provides a device name to
append to printks.

The e1000 gets around this by replicating register_netdev:

        rtnl_lock();
        /* we need to set the name early since the DPRINTK macro needs it set */
        if (dev_alloc_name(netdev, netdev->name) < 0)
                goto err_free_unlock;

...

        /* since we are holding the rtnl lock already, call the no-lock version */
        if((err = register_netdevice(netdev)))
                goto err_register;

        cards_found++;
        rtnl_unlock();

The problem I have with this method has to do with how failures appear
to the user. If you have two network cards and the first one fails
during probe you will see:

eth0: Intel(R) PRO/1000 Network Connection
eth0: The EEPROM Checksum Is Not Valid
eth0: Intel(R) PRO/1000 Network Connection

This makes debugging the issue difficult. Where is the card that failed?
We have machines with 100s of interfaces and there it becomes a real
pain.

We should instead use something stable to attach to printks during
probe. pci_name() is the obvious choice, perhaps using dev_printk().
The failure then becomes:

0000:01:01.0 Intel(R) PRO/1000 Network Connection
0000:01:01.0 The EEPROM Checksum Is Not Valid
0000:02:01.0 Intel(R) PRO/1000 Network Connection

Also it would be useful if somewhere during probe the network driver
associated the network name with the pci id, eg:

0000:02:01.0 Intel(R) PRO/1000 Network Connection (eth0)

I know we can get at it via other means but it would be nice to be able
to look through the dmesg and work out what names were given to the
cards.

Anton
