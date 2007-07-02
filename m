From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] ixgbe: Introduce new 10GbE driver for Intel 82598 based
 PCI	Express adapters...
Date: Mon, 2 Jul 2007 14:09:58 -0700
Message-ID: <20070702140958.5ea6571a@freepuppy.localdomain.hemminger.net>
References: <4688F512.3030801@garzik.org>
	<E35F4F4D7F6C9E4E826FEC1F86CEF58304193063@orsmsx412.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jeff@garzik.org>, <netdev@vger.kernel.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	<arjan@linux.intel.com>, <akpm@linux-foundation.org>
To: "Veeraiyan, Ayyappan" <ayyappan.veeraiyan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:46068 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755358AbXGBVKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2007 17:10:20 -0400
In-Reply-To: <E35F4F4D7F6C9E4E826FEC1F86CEF58304193063@orsmsx412.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2 Jul 2007 12:00:29 -0700
"Veeraiyan, Ayyappan" <ayyappan.veeraiyan@intel.com> wrote:

> On 7/2/07, Jeff Garzik <jeff@garzik.org> wrote:
> > Ayyappan Veeraiyan wrote:
> > > +#define IXGBE_TX_FLAGS_VLAN_MASK     0xffff0000
> > > +#define IXGBE_TX_FLAGS_VLAN_SHIFT    16
> > 
> > defining bits using the form "(1 << n)" is preferred.  Makes it easier
> > to read, by eliminating the requirement of the human brain to decode
> hex
> > into bit numbers.
> > 
> > 
> 
> Ok.
> 
> > > +             struct net_device netdev;
> > > +     };
> > 
> > Embedded a struct net_device into your ring?  How can I put this?
> > 
> > Wrong, wrong.  Wrong, wrong, wrong.  Wrong.
> > 
> 
> Agreed. 
> Fake netdevs are needed for doing the multiple Rx queues in NAPI mode.
> We are thinking to solve in 2 ways. Having netdev pointer in ring
> structure or having an array of netdev pointers in ixgbe_adatper struct
> which would be visible to all rings.

Wait until Davem & I separate NAPI from network device.
The patch is close to ready for 2.6.24 when this driver will need to show up.

Since I know Intel will be forced to backport this to older distro's. You
would be best to have a single receive queue version when you have to make
it work on the older code.

> > > +
> > > +     char name[IFNAMSIZ + 5];
> > 
> > The interface name should not be stored by your ring structure
> >

Gag
 
> Yes, I agree and also (pointed out by someone before) this would break
> if the user changes the interface name..
> But, having the "cause" in the MSIX vector name really helps in
> debugging and helps the user also. 

If you need a unique token use ifindex

> 
> I think the below output is much better
> 
> [root@ayyapsz src]# cat /proc/interrupts | grep eth0
> 214:          0          0   PCI-MSI-edge      eth0-lsc
> 215:      11763          4   PCI-MSI-edge      eth0-rx7
> 216:          0          0   PCI-MSI-edge      eth0-rx6
> 217:      77324          0   PCI-MSI-edge      eth0-rx5
> 218:          0          0   PCI-MSI-edge      eth0-rx4
> 219:      52911          0   PCI-MSI-edge      eth0-rx3
> 220:      80271          0   PCI-MSI-edge      eth0-rx2
> 221:      80244          6   PCI-MSI-edge      eth0-rx1
> 222:         12          0   PCI-MSI-edge      eth0-rx0
> 223:     124870      28543   PCI-MSI-edge      eth0-tx0
> 
> Compared to 
> 
> [root@ayyapsz src]# cat /proc/interrupts | grep eth0
> 214:          0          0   PCI-MSI-edge      eth0
> 215:      11763          4   PCI-MSI-edge      eth0
> 216:          0          0   PCI-MSI-edge      eth0
> 217:      77324          0   PCI-MSI-edge      eth0
> 218:          0          0   PCI-MSI-edge      eth0
> 219:      52911          0   PCI-MSI-edge      eth0
> 220:      80271          0   PCI-MSI-edge      eth0
> 221:      80244          6   PCI-MSI-edge      eth0
> 222:         12          0   PCI-MSI-edge      eth0
> 223:     124900      28543   PCI-MSI-edge      eth0
> 
> Since we wanted to distinguish the various MSIX vectors in
> /proc/interrupts and since request_irq expects memory for name to be
> allocated somewhere, I added this part of the ring struct.

You only need to store the name for when you are doing request_irq, so
it can just be a stack temporary.  

> > 
> > Kill io_base and stop setting netdev->base_addr
> 
> In my latest internal version, I already removed the io_base member (and
> couple more from ixgbe_adapter) but still setting the netdev->base_addr.
> I will remove that also..
> 
> > > +     struct ixgbe_hw_stats stats;
> > > +     char lsc_name[IFNAMSIZ + 5];
> > 
> > delete lsc_name and use netdev name directly in request_irq()
> > 
> 
> Please see the response for the name member of ring structure.
>  
> > 
> > Will review more after you fix these problems.
> > 
> 
> Thanks for the feedback. I will post another version shortly (except the
> feature flags change and the ring struct name members) which fixes my
> previous TODO list and also most of Francois comments..
> 
> Ayyappan


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
