From: Casey Leedom <leedom@chelsio.com>
Subject: RE: Request for advice on where to put Root Complex "fix up" code
 for downstream device
Date: Thu, 28 May 2015 22:35:41 +0000
Message-ID: <4985EFDD773FCB459EF7915D2A3621ADBDE9A7@nice.asicdesigners.com>
References: <4985EFDD773FCB459EF7915D2A3621ADBC7408@nice.asicdesigners.com>,<20150507230426.GO24643@google.com>,<4985EFDD773FCB459EF7915D2A3621ADBC80D4@nice.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: Bjorn Helgaas <bhelgaas@google.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <4985EFDD773FCB459EF7915D2A3621ADBC80D4@nice.asicdesigners.com>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

| From: Casey Leedom [leedom@chelsio.com]
| Sent: Thursday, May 07, 2015 4:31 PM
| 
| | From: Bjorn Helgaas [bhelgaas@google.com]
| | Sent: Thursday, May 07, 2015 4:04 PM
| |
| | There are a lot of fixups in drivers/pci/quirks.c.  For things that have to
| | be worked around either before a driver claims the device or if there is no
| | driver at all, the fixup *has* to go in drivers/pci/quirks.c
| |
| | But for things like this, where the problem can only occur after a driver
| | claims the device, I think it makes more sense to put the fixup in the
| | driver itself.  The only wrinkle here is that the fixup has to be done on a
| | separate device, not the device claimed by the driver.  But I think it
| | probably still makes sense to put this fixup in the driver.
| ...
|   One complication to doing this in cxgb4 is that it attaches to Physical
| Function 4 of our T5 chip.  Meanwhile, a completely separate storage
| driver, csiostor, connections to PF5 and PF6 and there's no
| requirement at all that cxgb4 be loaded.  So if we go down the road of
| putting the fixup code in the cxgb4 driver, we'll also need to duplicate
| that code in the csiostor driver.

  I never heard back on this issue of needing to put the Root Complex "fixup" code in two different drivers -- cxgb4 and csiostor -- if we don't go down the path of using a PCI Quirk.  I'm happy doing either and have verified both solutions locally.  I'd just like to get a judgement call on this.

  It comes down to adding ~30 lines to

    drivers/net/eththernet/chelsio/cxgb4/cxgb4_main.c
    drivers/scsi/csiostor/csio_init.c

or ~30 lines to

    drivers/pci/quirks.c

| | Can you include a pointer to the relevant part of the spec?
| 
|   Sure:
| 
|     2.2.9. Completion Rules
|     ...
|     Completion headers must supply the same values for
|     the Attribute as were supplied in the 20 header of
|     the corresponding Request, except as explicitly
|     allowed when IDO is used (see Section 2.2.6.4).
|     ...
|     2.3.2. Completion Handling Rules
|     ...
|     If a received Completion matches the Transaction ID
|     of an outstanding Request, but in some other way
|     does not match the corresponding Request (e.g., a
|     problem with Attributes, Traffic Class, Byte Count,
|     Lower Address, etc), it is strongly recommended for
|     the Receiver to handle the Completion as a Malformed
|     TLP. However, if the Completion is otherwise properly
|     formed, it is permitted[22] for the Receiver to
|     handle the Completion as an Unexpected Completion.

| | Can you use pci_upstream_bridge() here?  There are a couple places where we
| | want to find the Root Port, so we might factor that out someday.  It'll be
| | easier to find all those places if they use with pci_upstream_bridge().
| 
| It looks like pci_upstream_bridge() just traverses one like upstream toward the
| Root Complex?  Or am I misunderstanding that function?
