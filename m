From: Jon D Mason <jonmason@us.ibm.com>
Subject: e1000 module unloadable during boot
Date: Fri, 9 Apr 2004 16:38:42 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF4598EDC9.B96321B1-ON87256E71.006E26F7-86256E71.0076B7C7@us.ibm.com>
References: <20040328011052.GQ27747@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Brian M Rzycki <rzycki1@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040328011052.GQ27747@krispykreme>
To: scott.feldman@intel.com, Ganesh.Venkatesan@intel.com,
        john.ronciak@intel.com, netdev@oss.sgi.com, netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hey guys,
We are experiencing a problem where the e1000 driver will fail module 
loading during boot.  We did some debugging and found that the cause of 
this is the driver attempting to pci_alloc_consistent a transmit and 
receive descriptor ring size of zero.  This occurs because there is a 
timing issue in the driver.  The driver does not set the user definable 
attributes (defined in e1000_param.c), until after it registers the device 
with the kernel.  This allows the possibility of the driver being opened 
before it can read these parameters (which is what is happening in this 
error).  The fix is to move the reading of the user tunable parameters to 
before the registering of the device. 

--- e1000_main.c.orig   2004-04-08 13:51:34.967879752 -0500
+++ e1000_main.c        2004-04-08 14:34:48.113661672 -0500
@@ -536,6 +536,9 @@ e1000_probe(struct pci_dev *pdev,
        INIT_WORK(&adapter->tx_timeout_task,
                (void (*)(void *))e1000_tx_timeout_task, netdev);
 
+       e1000_check_options(adapter);
+ 
        if((err = register_netdev(netdev)))
                goto err_register;
 
@@ -544,9 +547,6 @@ e1000_probe(struct pci_dev *pdev,
        netif_carrier_off(netdev);
        netif_stop_queue(netdev);
 
        DPRINTK(PROBE, INFO, "Intel(R) PRO/1000 Network Connection\n");
-       e1000_check_options(adapter);
-
        /* Initial Wake on LAN setting
         * If APM wake is enabled in the EEPROM,
         * enable the ACPI Magic Packet filter


Jon Mason                jonmason@us.ibm.com
Software Engineer        Phone:(512)838.4162
Linux eServer I/O        Fax:  (512)838.3509
