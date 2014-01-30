From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH V2 0/4] misc: xgene: Add support for APM X-Gene SoC Queue
 Manager/Traffic Manager
Date: Thu, 30 Jan 2014 15:35:10 +0100
Message-ID: <201401301535.10940.arnd@arndb.de>
References: <1387594651-25771-1-git-send-email-rapatel@apm.com>
 <201401141615.55820.arnd@arndb.de>
 <CAN1v_Ps9U=yjG-G40FK+L9SLaAQp7s8j9mg9DNoiGwqjMiGtiQ@mail.gmail.com>
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
In-Reply-To: <CAN1v_Ps9U=yjG-G40FK+L9SLaAQp7s8j9mg9DNoiGwqjMiGtiQ@mail.gmail.com>
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

On Tuesday 28 January 2014, Ravi Patel wrote:
> On Tue, Jan 14, 2014 at 7:15 AM, Arnd Bergmann <arnd@arndb.de> wrote:
-
> > For the DT binding, I would suggest using something along the lines of
> > what we have for clocks, pinctrl and dmaengine. OMAP doesn't use this
> > (yet), but now would be a good time to standardize it. The QMTM node
> > should define a "#mailbox-cells" property that indicates how many
> > 32-bit cells a qmtm needs to describe the connection between the
> > controller and the slave. My best guess is that this would be hardcoded
> > to <3>, using two cells for a 64-bit FIFO bus address, and a 32-bit cell
> > for the slave-id signal number. All other parameters that you have in
> > the big table in the qmtm driver at the moment can then get moved into
> > the slave drivers, as they are constant per type of slave. This will
> > simplify the QMTM driver.
> >
> > In the slave, you should have a "mailboxes" property with a phandle
> > to the qmtm followed by the three cells to identify the actual
> > queue. If it's possible that a device uses more than one rx and
> > one tx queue, we also need a "mailbox-names" property to identify
> > the individual queues.
> 
> We explored on DT bindings suggestion given by you. We have come
> up with a sample DT binding for how it will look like. Herewith we have
> provided the same. Would you please review and give us your
> comments before we change our driver and DTS file to accomodate it?
> 
> Sample DTS node for QM:
>                 qmlite: qmtm@17030000 {
>                         compatible = "apm,xgene-qmtm-lite";

I would use 'mailbox@17030000' as the node name, as the name part
is supposed to be descriptive of the function rather than the implemention.

>                         reg = <0x0 0x17030000 0x0 0x10000>,
>                               <0x0 0x10000000 0x0 0x400000>;
>                         interrupts = <0x0 0x40 0x4>,
>                                      <0x0 0x3c 0x4>;
>                         status = "ok";
>                         #clock-cells = <1>;
>                         clocks = <&qmlclk 0>;
>                         #mailbox-cells = <3>;
>                 };

The #clock-cells seems misplaced here, unless this is also a clock
provider, which I don't think it is.

> 
> Sample DTS node for Ethernet:
>                 menet: ethernet@17020000 {
>                         compatible = "apm,xgene-enet";
>                         status = "disabled";
>                         reg = <0x0 0x17020000 0x0 0x30>,
>                               <0x0 0x17020000 0x0 0x10000>,
>                               <0x0 0x17020000 0x0 0x20>;

Unrelated, but it seems strange to have three register sets of different
sizes at the same offset.

>                         mailboxes = <&qmlite 0x0 0x1000002c 0x0000>,
>                                             <&qmlite 0x0 0x10000052 0x0020>,
>                                             <&qmlite 0x0 0x10000060 0x0f00>
>                         mailbox-names = "mb-tx", "mb-fp", "mb-rx";

I would leave out the "mb-" part of the strings and just document them
as "tx", "rx" and "fp".

>                         interrupts = <0x0 0x38 0x4>,
>                                      <0x0 0x39 0x4>,
>                                      <0x0 0x3a 0x4>;
>                         #clock-cells = <1>;

Same comment about #clock-cells here.

>                         clocks = <&eth8clk 0>;
>                         local-mac-address = <0x0 0x11 0x3a 0x8a 0x5a 0x78>;
>                         max-frame-size = <0x233a>;
>                         phyid = <3>;
>                         phy-mode = "rgmii";
>                 };
> 
> The mailbox node in DTS has following format:
> mailbox = <&parent 'higher 32 bit bus address' 'lower 32 bit bus
> address' 'signal id'>

sounds good.

> Ethernet driver will call following function in platform_probe:
>  mailbox_get(dev, "mb-tx");
> mailbox_get API will return the the context of allocated and configured mailbox.
> For now, mailbox_get API will be implemented in xgene QMTM driver.
> Eventually when mailbox framework in Linux will be standardized, we
> will use it instead.

Ok.

> > For the in-kernel interfaces, we should probably start a conversation
> > with the owners of the mailbox drivers to get a common API, for now
> > I'd suggest you just leave it as it is, and only adapt for the new
> > binding.
> 
> Sure. For now we will put our driver mostly as is in the
> drivers/mailbox. Can you please help us identify the owners of the
> mailbox drivers? As you suggested, we can start conversation with them
> to define common in kernel APIs.
 
Please talk to "Suman Anna" <s-anna@ti.com> for the TI part and Rob
Herring <robh@kernel.org> for pl320. The pl320 driver was written
by Mark Langsdorf for Calxeda, but I don't have an updated email
address for him and assume that the calxeda address is no longer
functional.

	Arnd
