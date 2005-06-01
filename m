From: Andy Fleming <afleming@freescale.com>
Subject: Re: RFC: PHY Abstraction Layer II
Date: Wed, 1 Jun 2005 17:36:54 -0500
Message-ID: <9A2D608A-D818-455B-96F4-ED42413556C0@freescale.com>
References: <1107b64b01fb8e9a6c84359bb56881a6@freescale.com>
	<20050531105939.7486e071@dxpl.pdx.osdl.net>
	<92F1428A-0B26-428B-8C06-35C7E5B9EEE3@freescale.com>
	<20050601144123.2bc11c06@dxpl.pdx.osdl.net>
Mime-Version: 1.0 (Apple Message framework v730)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>,
	Embedded PPC Linux list <linuxppc-embedded@ozlabs.org>
Return-path: <linuxppc-embedded-bounces@ozlabs.org>
In-Reply-To: <20050601144123.2bc11c06@dxpl.pdx.osdl.net>
To: Stephen Hemminger <shemminger@osdl.org>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-embedded>
List-Post: <mailto:linuxppc-embedded@ozlabs.org>
List-Help: <mailto:linuxppc-embedded-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-embedded-bounces@ozlabs.org
Errors-To: linuxppc-embedded-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org


On Jun 1, 2005, at 16:41, Stephen Hemminger wrote:

> On Wed, 1 Jun 2005 15:45:26 -0500
> Andy Fleming <afleming@freescale.com> wrote:
>>
>>>     * get rid of bus read may sleep implication in comment.
>>>       since you are holding phy spin lock it better not!!
>>>
>>
>>
>
> On a different note, I am not sure that using sysfs/kobject bus object
> is the right thing for this object.  Isn't the phy instance really  
> just
> an kobject whose parent is the network device?  I can't see a 1 to N
> relationship between phy bus and phy objects existing.

Well, the MII Management bus is, in fact, a bus.  When a network  
driver wants to modify a PHY, it must access that bus.  Many ethernet  
controllers have a 1 to 1 relationship, since a typical NIC is a PCI  
card with 1 ethernet port (meaning one controller, and one PHY).   
However, many systems have multiple ethernet controllers attached to  
one bus, which configures multiple PHYs.  Currently, these systems  
have been relying on luck to prevent multiple accesses to the same bus.

This tends to work because all of the PHY support is contained within  
the ethernet driver, so it is easy for such drivers to ensure that  
only one PHY transaction is done at a time.  This system begins to  
fall apart, though, when the PHY drivers start operating more  
independently to react to changing PHY state.  It really begins to  
fall apart if you have multiple drivers trying to access a shared  
bus.  For instance, the 8560 ADS board has 2 gigabit ethernet ports  
controlled by the gianfar driver, and 2 10/100 ports in the CPM  
subsystem, controlled by the fcc_enet driver.

These two drivers each have an access point for the bus, which use  
different mechanisms (one is a bit bang interface, and one is  
register based).  Using the new abstraction, it is possible for the  
FCC driver to use the gianfar driver's bus, thus saving code, and  
reducing complexity.

>
> The main use I can see for being a driver object is to catch  
> suspend/resume,
> and wouldn't you want that to be tied to the network device.

It would be quite easy for the network driver to suspend or resume  
the PHY and bus objects under the new abstraction.  However, if eth0  
is suspended, should it suspend the whole bus, and all the PHYs on  
it?  By making the MII bus an independent entity, eth0 can be  
suspended, and it can choose to suspend its PHY, but eth1 can  
continue to access its PHY over the bus, since those aren't suspended.
