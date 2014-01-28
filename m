From: Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>
Subject: Re: [PATCH V2 0/4] misc: xgene: Add support for APM X-Gene SoC Queue
 Manager/Traffic Manager
Date: Mon, 27 Jan 2014 16:58:26 -0800
Message-ID: <CAN1v_Ps9U=yjG-G40FK+L9SLaAQp7s8j9mg9DNoiGwqjMiGtiQ@mail.gmail.com>
References: <1387594651-25771-1-git-send-email-rapatel@apm.com>
	<201401122219.11593.arnd@arndb.de>
	<CAN1v_Pt9rOGn8zmf+u7MR6-GJPDPswBbuhXu6i=MJVa2mwqNtw@mail.gmail.com>
	<201401141615.55820.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, Loc Ho <lho-qTEPVZfXA3Y@public.gmane.org>,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	Jon Masters <jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"patches-qTEPVZfXA3Y@public.gmane.org" <patches-qTEPVZfXA3Y@public.gmane.org>,
	Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201401141615.55820.arnd-r2nGTMty4D4@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 14, 2014 at 7:15 AM, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> wrote:
> Now that I have a better understanding of what the driver is good for and
> how it's used, let's have a look at how we can make it fit into the Linux
> driver APIs and the DT bindings. We don't have anything exactly like this
> yet, but I think the "mailbox" framework is a close enough match that we
> can fit it in there, with some extensions. This framework is still in the
> process of being created (so far there is only a TI OMAP specific driver,
> and one for pl320), and I've not seen any mailboxes that support IRQ
> mitigation or multiple software interfaces per hardware mailbox, but those
> should be easy enough to add.

OK. We will put Queue Manager driver under drivers/mailbox directory along
with TI OMAP and pl320 drivers.

> For the DT binding, I would suggest using something along the lines of
> what we have for clocks, pinctrl and dmaengine. OMAP doesn't use this
> (yet), but now would be a good time to standardize it. The QMTM node
> should define a "#mailbox-cells" property that indicates how many
> 32-bit cells a qmtm needs to describe the connection between the
> controller and the slave. My best guess is that this would be hardcoded
> to <3>, using two cells for a 64-bit FIFO bus address, and a 32-bit cell
> for the slave-id signal number. All other parameters that you have in
> the big table in the qmtm driver at the moment can then get moved into
> the slave drivers, as they are constant per type of slave. This will
> simplify the QMTM driver.
>
> In the slave, you should have a "mailboxes" property with a phandle
> to the qmtm followed by the three cells to identify the actual
> queue. If it's possible that a device uses more than one rx and
> one tx queue, we also need a "mailbox-names" property to identify
> the individual queues.

We explored on DT bindings suggestion given by you. We have come
up with a sample DT binding for how it will look like. Herewith we have
provided the same. Would you please review and give us your
comments before we change our driver and DTS file to accomodate it?

Sample DTS node for QM:
                qmlite: qmtm@17030000 {
                        compatible = "apm,xgene-qmtm-lite";
                        reg = <0x0 0x17030000 0x0 0x10000>,
                              <0x0 0x10000000 0x0 0x400000>;
                        interrupts = <0x0 0x40 0x4>,
                                     <0x0 0x3c 0x4>;
                        status = "ok";
                        #clock-cells = <1>;
                        clocks = <&qmlclk 0>;
                        #mailbox-cells = <3>;
                };

Sample DTS node for Ethernet:
                menet: ethernet@17020000 {
                        compatible = "apm,xgene-enet";
                        status = "disabled";
                        reg = <0x0 0x17020000 0x0 0x30>,
                              <0x0 0x17020000 0x0 0x10000>,
                              <0x0 0x17020000 0x0 0x20>;
                        mailboxes = <&qmlite 0x0 0x1000002c 0x0000>,
                                            <&qmlite 0x0 0x10000052 0x0020>,
                                            <&qmlite 0x0 0x10000060 0x0f00>
                        mailbox-names = "mb-tx", "mb-fp", "mb-rx";
                        interrupts = <0x0 0x38 0x4>,
                                     <0x0 0x39 0x4>,
                                     <0x0 0x3a 0x4>;
                        #clock-cells = <1>;
                        clocks = <&eth8clk 0>;
                        local-mac-address = <0x0 0x11 0x3a 0x8a 0x5a 0x78>;
                        max-frame-size = <0x233a>;
                        phyid = <3>;
                        phy-mode = "rgmii";
                };

The mailbox node in DTS has following format:
mailbox = <&parent 'higher 32 bit bus address' 'lower 32 bit bus
address' 'signal id'>
Ethernet driver will call following function in platform_probe:
 mailbox_get(dev, "mb-tx");
mailbox_get API will return the the context of allocated and configured mailbox.
For now, mailbox_get API will be implemented in xgene QMTM driver.
Eventually when mailbox framework in Linux will be standardized, we
will use it instead.

> For the in-kernel interfaces, we should probably start a conversation
> with the owners of the mailbox drivers to get a common API, for now
> I'd suggest you just leave it as it is, and only adapt for the new
> binding.

Sure. For now we will put our driver mostly as is in the
drivers/mailbox. Can you please help us identify the owners of the
mailbox drivers? As you suggested, we can start conversation with them
to define common in kernel APIs.

Ravi

On Tue, Jan 14, 2014 at 7:15 AM, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> wrote:
> On Monday 13 January 2014, Ravi Patel wrote:
>> > Examples for local resource management (I had to think about this
>> > a long time, but probably some of these are wrong) would be
>> > * balancing between multiple non-busmaster devices connected to
>> >   a dma-engine
>> > * distributing incoming ethernet data to the available CPUs based on
>> >   a flow classifier in the MAC, e.g. by IOV MAC address, VLAN tag
>> >   or even individual TCP connection depending on the NIC's capabilities.
>> > * 802.1p flow control for incoming ethernet data based on the amount
>> >   of data queued up between the MAC and the driver
>> > * interrupt mitigation for both inbound data and outbound completion,
>> >   by delaying the IRQ to the OS until multiple messages have arrived
>> >   or a queue specific amount of time has passed.
>> > * controlling the amount of outbound buffer space per flow to minimize
>> >   buffer-bloat between an ethernet driver and the NIC hardware.
>> > * reordering data from outbound flows based on priority.
>> >
>> > This is basically my current interpretation, I hope I got at least
>> > some of it right this time ;-)
>>
>> You have got them right. Although we have taken Ethernet examples here,
>> most of the local resource management apply to other slave devices also.
>
> I'm very suprised I got all those right, it seems it's a quite sophisticated
> piece of hardware then. I guess most other slave devices only use a subset
> of the capabilities that ethernet wants.
>
> Now that I have a better understanding of what the driver is good for and
> how it's used, let's have a look at how we can make it fit into the Linux
> driver APIs and the DT bindings. We don't have anything exactly like this
> yet, but I think the "mailbox" framework is a close enough match that we
> can fit it in there, with some extensions. This framework is still in the
> process of being created (so far there is only a TI OMAP specific driver,
> and one for pl320), and I've not seen any mailboxes that support IRQ
> mitigation or multiple software interfaces per hardware mailbox, but those
> should be easy enough to add.
>
> For the DT binding, I would suggest using something along the lines of
> what we have for clocks, pinctrl and dmaengine. OMAP doesn't use this
> (yet), but now would be a good time to standardize it. The QMTM node
> should define a "#mailbox-cells" property that indicates how many
> 32-bit cells a qmtm needs to describe the connection between the
> controller and the slave. My best guess is that this would be hardcoded
> to <3>, using two cells for a 64-bit FIFO bus address, and a 32-bit cell
> for the slave-id signal number. All other parameters that you have in
> the big table in the qmtm driver at the moment can then get moved into
> the slave drivers, as they are constant per type of slave. This will
> simplify the QMTM driver.
>
> In the slave, you should have a "mailboxes" property with a phandle
> to the qmtm followed by the three cells to identify the actual
> queue. If it's possible that a device uses more than one rx and
> one tx queue, we also need a "mailbox-names" property to identify
> the individual queues.
>
> For the in-kernel interfaces, we should probably start a conversation
> with the owners of the mailbox drivers to get a common API, for now
> I'd suggest you just leave it as it is, and only adapt for the new
> binding.
>
>         Arnd
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
