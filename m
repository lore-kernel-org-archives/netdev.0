From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: Re: [PATCH] NET: Add ezchip ethernet driver
Date: Tue, 9 Jun 2015 14:11:05 +0000
Message-ID: <1433859065.3732.43.camel@synopsys.com>
References: <1433853863-6704-1-git-send-email-noamc@ezchip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-7"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"cmetcalf@ezchip.com" <cmetcalf@ezchip.com>,
	"Vineet.Gupta1@synopsys.com" <Vineet.Gupta1@synopsys.com>,
	"talz@ezchip.com" <talz@ezchip.com>,
	"giladb@ezchip.com" <giladb@ezchip.com>
To: "noamc@ezchip.com" <noamc@ezchip.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1433853863-6704-1-git-send-email-noamc@ezchip.com>
Content-Language: en-US
Content-ID: <E790A9B164EEC647A20E40BE44E462A2@internal.synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Noam, Tal,

On Tue, 2015-06-09 at 15:44 +-0300, Noam Camus wrote:
+AD4- From: Tal Zilcer +ADw-talz+AEA-ezchip.com+AD4-
+AD4- 
+AD4- Simple LAN device without multicast support.
+AD4- Device performance is not high and may be used for
+AD4- debug or management purposes.
+AD4- Device supports interrupts for RX and TX end.
+AD4- Device does not support NAPI and also does not support DMA.
+AD4- It is used in EZchip NPS devices.
+AD4- 
+AD4- Signed-off-by: Noam Camus +ADw-noamc+AEA-ezchip.com+AD4-

Probably it's good to add Tal in +ACI-Signed-off-by+ACI- here as well.

+AFs-snip+AF0-

+AD4- +-static void nps+AF8-enet+AF8-read+AF8-rx+AF8-fifo(struct net+AF8-device +ACo-netdev,
+AD4- +-                               unsigned char +ACo-dst, int length)
+AD4- +-+AHs-
+AD4- +-     struct nps+AF8-enet+AF8-priv +ACo-net+AF8-priv +AD0- netdev+AF8-priv(netdev)+ADs-
+AD4- +-     int i, len +AD0- (length +AD4APg- 2)+ADs-

I'd say brackets are not really required here, why not just +ACI-int i, len
+AD0- length +AD4APg- 2+ADsAIg-?

+AD4- +-     int last +AD0- length +ACY- 3+ADs-

Shouldn't it be +ACI-int last +AD0- length +ACY- (sizeof(int) - 1)+ADsAIg-? Well,
assuming we're talking 4-byte words here.

+AD4- +-     unsigned int +ACo-reg +AD0- (unsigned int +ACo-)dst+ADs-
+AD4- +-     bool dst+AF8-is+AF8-align +AD0- +ACE-((unsigned int)dst +ACY- 0x3)+ADs-
+AD4- +-
+AD4- +-     /+ACo- In case dst is not aligned we need an intermediate buffer 
+AD4- +ACo-/
+AD4- +-     if (dst+AF8-is+AF8-align)
+AD4- +-             for (i +AD0- 0+ADs- i +ADw- len+ADs- i+-+-, reg+-+-)
+AD4- +-                     +ACo-reg +AD0- nps+AF8-enet+AF8-reg+AF8-get(net+AF8-priv, 
+AD4- NPS+AF8-ENET+AF8-REG+AF8-RX+AF8-BUF)+ADs-
+AD4- +-     else +AHs- /+ACo- +ACE-dst+AF8-is+AF8-align +ACo-/
+AD4- +-             unsigned int buf+ADs-
+AD4- +-
+AD4- +-             for (i +AD0- 0+ADs- i +ADw- len+ADs- i+-+-, reg+-+-) +AHs-

I would move definition of +ACI-buf+ACI- right here in the +ACI-for+ACI- loop because
it is not used outside this +ACI-for+ACI-, right?

+AD4- +-                     buf +AD0- nps+AF8-enet+AF8-reg+AF8-get(net+AF8-priv, 
+AD4- NPS+AF8-ENET+AF8-REG+AF8-RX+AF8-BUF)+ADs-
+AD4- +-                     memcpy(reg, +ACY-buf, sizeof(buf))+ADs-

Here I think it might be useful to add a comment saying why memcpy() is
used here, like to accommodate word-unaligned address of +ACI-reg+ACI- we have
to do memcpy() instead of simple +ACIAPQAi-.

+AD4- +-             +AH0-
+AD4- +-     +AH0-
+AD4- +-
+AD4- +-     /+ACo- copy last bytes (if any) +ACo-/
+AD4- +-     if (last) +AHs-
+AD4- +-             unsigned int buf+ADs-
+AD4- +-
+AD4- +-             buf +AD0- nps+AF8-enet+AF8-reg+AF8-get(net+AF8-priv, 
+AD4- NPS+AF8-ENET+AF8-REG+AF8-RX+AF8-BUF)+ADs-

Here as well no need for separate lines for +ACI-buf+ACI- declaration and real
usage, let's have more compact +ACI-unsigned int buf +AD0-
nps+AF8-enet+AF8-reg+AF8-get(net+AF8-priv, NPS+AF8-ENET+AF8-REG+AF8-RX+AF8-BUF)+ADsAIg-.

Also what might be good is to make +ACI-buf+ACI- of explicit storage type. Now
it's just +ACI-int+ACI- but once you move to 64-bit CPU core length of +ACI-int+ACI-
will change. So +ACI-u32+ACI- IMHO is a better option here - that's actually
applicable through all the driver, so please re-visit this topic.

+AD4- +-             memcpy(reg, +ACY-buf, last)+ADs-

BTW it might also be nice to add a check for +ACI-last+ACI- value so it never
gets larger than both +ACI-reg+ACI- and +ACI-buf+ACI- size.

+AD4- +-     +AH0-
+AD4- +-+AH0-
+AD4- +-
+AD4- +-static void nps+AF8-enet+AF8-rx+AF8-irq+AF8-handler(struct net+AF8-device +ACo-netdev,
+AD4- +-                                 struct nps+AF8-enet+AF8-rx+AF8-ctl rx+AF8-ctrl)
+AD4- +-+AHs-
+AD4- +-     struct nps+AF8-enet+AF8-priv +ACo-net+AF8-priv +AD0- netdev+AF8-priv(netdev)+ADs-
+AD4- +-     struct sk+AF8-buff +ACo-skb+ADs-
+AD4- +-     int frame+AF8-len +AD0- rx+AF8-ctrl.nr+ADs-
+AD4- +-
+AD4- +-     /+ACo- Check Rx error +ACo-/
+AD4- +-     if (rx+AF8-ctrl.er) +AHs-
+AD4- +-             netdev-+AD4-stats.rx+AF8-errors+-+-+ADs-
+AD4- +-             goto rx+AF8-irq+AF8-clean+ADs-

Why do you go straight to +ACI-rx+AF8-irq+AF8-clean+ACI- here and in branches below?
Isn't it possible to have simultaneously set following flags
+ACI-rx+AF8-ctrl.er+ACI-, +ACI-rx+AF8-ctrl.crc+ACI- plus +ACI-frame+AF8-len +ADw- ETH+AF8-ZLEN+ACI- etc?

+AD4- +-     +AH0-
+AD4- +-
+AD4- +-     /+ACo- Check Rx CRC error +ACo-/
+AD4- +-     if (rx+AF8-ctrl.crc) +AHs-
+AD4- +-             netdev-+AD4-stats.rx+AF8-crc+AF8-errors+-+-+ADs-
+AD4- +-             netdev-+AD4-stats.rx+AF8-dropped+-+-+ADs-
+AD4- +-             goto rx+AF8-irq+AF8-clean+ADs-
+AD4- +-     +AH0-

+AFs-snip+AF0-

+AD4- +-/+ACoAKg-
+AD4- +- +ACo- nps+AF8-enet+AF8-irq+AF8-handler - Global interrupt handler for ENET.
+AD4- +- +ACo- +AEA-irq:                irq number.
+AD4- +- +ACo- +AEA-dev+AF8-instance:       device instance.
+AD4- +- +ACo-
+AD4- +- +ACo- returns: IRQ+AF8-HANDLED for all cases.
+AD4- +- +ACo-
+AD4- +- +ACo- EZchip ENET has 2 interrupt causes, and depending on bits raised 
+AD4- in
+AD4- +- +ACo- CTRL register we may tell what is a reason for interrupt to fire.
+AD4- +- +ACo- We got one for RX and the other for TX (end).
+AD4- +- +ACo-/
+AD4- +-static irqreturn+AF8-t nps+AF8-enet+AF8-irq+AF8-handler(int irq, void +ACo-dev+AF8-instance)
+AD4- +-+AHs-
+AD4- +-     struct net+AF8-device +ACo-netdev +AD0- dev+AF8-instance+ADs-
+AD4- +-     struct nps+AF8-enet+AF8-priv +ACo-net+AF8-priv +AD0- netdev+AF8-priv(netdev)+ADs-
+AD4- +-     struct nps+AF8-enet+AF8-rx+AF8-ctl rx+AF8-ctrl+ADs-
+AD4- +-     struct nps+AF8-enet+AF8-tx+AF8-ctl tx+AF8-ctrl+ADs-

Both +ACI-rx+AF8-ctrl+ACI- and +ACI-tx+AF8-ctrl+ACI- could be put in one line.

+AFs-snip+AF0-

+AD4- +-static void nps+AF8-enet+AF8-hw+AF8-reset(struct net+AF8-device +ACo-netdev)
+AD4- +-+AHs-
+AD4- +-     struct nps+AF8-enet+AF8-priv +ACo-net+AF8-priv +AD0- netdev+AF8-priv(netdev)+ADs-
+AD4- +-     struct nps+AF8-enet+AF8-ge+AF8-rst ge+AF8-rst +AD0- +AHs-.value +AD0- 0+AH0AOw-
+AD4- +-     struct nps+AF8-enet+AF8-phase+AF8-fifo+AF8-ctl phase+AF8-fifo+AF8-ctl +AD0- +AHs-.value +AD0- 
+AD4- 0+AH0AOw-
+AD4- +-
+AD4- +-     /+ACo- Pcs reset sequence+ACo-/
+AD4- +-     ge+AF8-rst.gmac+AF8-0 +AD0- NPS+AF8-ENET+AF8-ENABLE+ADs-
+AD4- +-     nps+AF8-enet+AF8-reg+AF8-set(net+AF8-priv, NPS+AF8-ENET+AF8-REG+AF8-GE+AF8-RST, 
+AD4- ge+AF8-rst.value)+ADs-
+AD4- +-     usleep+AF8-range(10, 20)+ADs-

I'm wondering if there's a possibility to read back for example the
same bit we set and once it gets reset by hardware we then know for
sure that hardware exited reset state? If there's such a possibility we
may just busywait for it... well probably with known timeout to report
a problem if hardware still in reset state.

Otherwise you cannot be sure hardware is ready to operate really.

Probably I'm nitpicking here but in general driver looks good to me so
feel free to add:

Acked-by: Alexey Brodkin +ADw-abrodkin+AEA-synopsys.com+AD4-

-Alexey