From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH V2 0/4] misc: xgene: Add support for APM X-Gene SoC Queue
 Manager/Traffic Manager
Date: Tue, 14 Jan 2014 16:15:55 +0100
Message-ID: <201401141615.55820.arnd@arndb.de>
References: <1387594651-25771-1-git-send-email-rapatel@apm.com>
 <201401122219.11593.arnd@arndb.de>
 <CAN1v_Pt9rOGn8zmf+u7MR6-GJPDPswBbuhXu6i=MJVa2mwqNtw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
 Jon Masters <jcm@redhat.com>, Greg KH <gregkh@linuxfoundation.org>,
 "patches@apm.com" <patches@apm.com>, linux-kernel@vger.kernel.org,
 Loc Ho <lho@apm.com>, netdev@vger.kernel.org, Keyur Chudgar <kchudgar@apm.com>,
 davem@davemloft.net,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
To: Ravi Patel <rapatel@apm.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <CAN1v_Pt9rOGn8zmf+u7MR6-GJPDPswBbuhXu6i=MJVa2mwqNtw@mail.gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Monday 13 January 2014, Ravi Patel wrote:
> > Examples for local resource management (I had to think about this
> > a long time, but probably some of these are wrong) would be
> > * balancing between multiple non-busmaster devices connected to
> >   a dma-engine
> > * distributing incoming ethernet data to the available CPUs based on
> >   a flow classifier in the MAC, e.g. by IOV MAC address, VLAN tag
> >   or even individual TCP connection depending on the NIC's capabilities.
> > * 802.1p flow control for incoming ethernet data based on the amount
> >   of data queued up between the MAC and the driver
> > * interrupt mitigation for both inbound data and outbound completion,
> >   by delaying the IRQ to the OS until multiple messages have arrived
> >   or a queue specific amount of time has passed.
> > * controlling the amount of outbound buffer space per flow to minimize
> >   buffer-bloat between an ethernet driver and the NIC hardware.
> > * reordering data from outbound flows based on priority.
> >
> > This is basically my current interpretation, I hope I got at least
> > some of it right this time ;-)
> 
> You have got them right. Although we have taken Ethernet examples here,
> most of the local resource management apply to other slave devices also.

I'm very suprised I got all those right, it seems it's a quite sophisticated
piece of hardware then. I guess most other slave devices only use a subset
of the capabilities that ethernet wants.

Now that I have a better understanding of what the driver is good for and
how it's used, let's have a look at how we can make it fit into the Linux
driver APIs and the DT bindings. We don't have anything exactly like this
yet, but I think the "mailbox" framework is a close enough match that we
can fit it in there, with some extensions. This framework is still in the
process of being created (so far there is only a TI OMAP specific driver,
and one for pl320), and I've not seen any mailboxes that support IRQ
mitigation or multiple software interfaces per hardware mailbox, but those
should be easy enough to add.

For the DT binding, I would suggest using something along the lines of
what we have for clocks, pinctrl and dmaengine. OMAP doesn't use this
(yet), but now would be a good time to standardize it. The QMTM node
should define a "#mailbox-cells" property that indicates how many
32-bit cells a qmtm needs to describe the connection between the
controller and the slave. My best guess is that this would be hardcoded
to <3>, using two cells for a 64-bit FIFO bus address, and a 32-bit cell
for the slave-id signal number. All other parameters that you have in
the big table in the qmtm driver at the moment can then get moved into
the slave drivers, as they are constant per type of slave. This will
simplify the QMTM driver.

In the slave, you should have a "mailboxes" property with a phandle
to the qmtm followed by the three cells to identify the actual
queue. If it's possible that a device uses more than one rx and
one tx queue, we also need a "mailbox-names" property to identify
the individual queues.

For the in-kernel interfaces, we should probably start a conversation
with the owners of the mailbox drivers to get a common API, for now
I'd suggest you just leave it as it is, and only adapt for the new
binding.

	Arnd
