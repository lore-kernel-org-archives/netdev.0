From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [BUG] drivers/net/ioc3_eth.c in 2.5
Date: Mon, 9 Jun 2003 10:10:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030609101018.0ca2e1f9.shemminger@osdl.org>
References: <20030606161658.1f01b8f9.shemminger@osdl.org>
	<20030607.013010.116359540.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ralf@oss.sgi.com, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030607.013010.116359540.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 07 Jun 2003 01:30:10 -0700 (PDT)
"David S. Miller" <davem@redhat.com> wrote:

>    From: Stephen Hemminger <shemminger@osdl.org>
>    Date: Fri, 6 Jun 2003 16:16:58 -0700
> 
>    This driver never calls unregister in it's module exit function:
>    
>    static void __exit ioc3_cleanup_module(void)
>    {
>    	pci_unregister_driver(&ioc3_driver);
>    }
>    
> pci_unregister_driver() invokes, for each PCI driver instance
> registered, the ->remove() method for that driver.
> 
> What is the problem?  tg3.c and many other drivers work exactly
> like this, using the PCI registry mechanism as a helper to do
> all the grunge work or device iteration.

pci_unregister_driver does the iteration but not the net device
cleanup.


The problem is the driver never calls unregister_netdev, it just free's
the device structure.  If this ever happens, the net device list would be corrupt.
Don't have the hardware to actually do this though.

Looks like the right fix is:
--- ioc3-eth.c.orig	2003-06-09 10:05:45.000000000 -0700
+++ ioc3-eth.c	2003-06-09 10:04:45.000000000 -0700
@@ -1614,6 +1614,7 @@ static void __devexit ioc3_remove_one (s
 	struct ioc3 *ioc3 = ip->regs;
 
 	iounmap(ioc3);
+	unregister_netdev(dev);
 	pci_release_regions(pdev);
 	kfree(dev);
 }
