From: Rask Ingemann Lambertsen <rask@sygehus.dk>
Subject: Re: de2104x problems (and perhaps a clue as to why)
Date: Tue, 9 Dec 2003 16:20:03 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031209162003.E1345@sygehus.dk>
References: <20031126134140.A7327@sygehus.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20031126134140.A7327@sygehus.dk>; from rask@sygehus.dk on Wed, Nov 26, 2003 at 01:41:40PM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Nov 26, 2003 at 01:41:40PM +0100, Rask Ingemann Lambertsen wrote:
[snip]
> lspci dug up something interesting:
> $ modprobe -k de2104x
> $ ethtool -s eth0 port bnc
> $ ifconfig eth0 up
> $ ifconfig eth0 down
> $ ifconfig eth0 up
> $ lspci -vvv
> [...]
> 00:0e.0 Ethernet controller: Digital Equipment Corporation DECchip 21041 [Tulip Pass 3] (rev 11)
> 	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
> 	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> 	Interrupt: pin A routed to IRQ 11
> 	Region 0: I/O ports at 2080 [size=128]
> 	Region 1: Memory at 42200000 (32-bit, non-prefetchable) [size=128]
> 	Expansion ROM at <unassigned> [disabled] [size=256K]
> [...]
> 
> Say what? It says "BusMaster-", which means busmaster DMA is disabled,
> right? Then of course it won't work. Is this because de_close() calls
> pci_disable_device() and de_open() doesn't not reenable the device?

Indeed pci_disable_device() disables busmaster DMA, so this needs to be
reenabled by dev->open(). This patch seems to fix the problem by reenabling
the device and busmaster DMA in de_init_hw():

--- linux-2.6.0-test8/drivers/net/tulip/de2104x.c~	Wed Nov 26 13:37:17 2003
+++ linux-2.6.0-test8/drivers/net/tulip/de2104x.c	Wed Nov 26 13:37:17 2003
@@ -1253,6 +1253,10 @@ static int de_init_hw (struct de_private
 	struct net_device *dev = de->dev;
 	int rc;
 
+	rc = pci_enable_device(de->pdev);
+	if (rc)
+		return (rc);
+	pci_set_master(de->pdev);
 	de_adapter_wake(de);
 	
 	de->macmode = dr32(MacMode) & ~MacModeClear;

But this causes pci_enable_device() and pci_set_busmaster() to be called
twice when the interface is brought up for the first time after loading the
module. The documentation does not say that doing so is OK. Perhaps we should
simply remove the pci_disable_device() call from dev->close()? de2104x is a
bit unusual in calling pci_disable_device() from dev-close(). Jeff?

-- 
Regards,
Rask Ingemann Lambertsen
