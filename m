From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: Re: [PATCH 1/1] net: nps_enet: Disable interrupts before napi
 reschedule
Date: Thu, 26 May 2016 17:53:29 +0000
Message-ID: <1464285174.4578.36.camel@synopsys.com>
References: <1464264006-26627-1-git-send-email-eladkan@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-7"
Content-Transfer-Encoding: 8BIT
Cc: "linux-snps-arc@lists.infradead.org"
	<linux-snps-arc@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"noamca@mellanox.com" <noamca@mellanox.com>,
	Anton Kolesov <Anton.Kolesov@synopsys.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "eladkan@mellanox.com" <eladkan@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464264006-26627-1-git-send-email-eladkan@mellanox.com>
Content-Language: en-US
Content-ID: <AD1ADBA841901E40B07A0F934243F1B5@internal.synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Elad,

On Thu, 2016-05-26 at 15:00 +-0300, Elad Kanfi wrote:
+AD4- From: Elad Kanfi +ADw-eladkan+AEA-mellanox.com+AD4-
+AD4- 
+AD4- Since NAPI works by shutting down event interrupts when theres
+AD4- work and turning them on when theres none, the net driver must
+AD4- make sure that interrupts are disabled when it reschedules polling.
+AD4- By calling napi+AF8-reschedule, the driver switches to polling mode,
+AD4- therefor there should be no interrupt interference.
+AD4- Any received packets will be handled in nps+AF8-enet+AF8-poll by polling the HW
+AD4- indication of received packet until all packets are handled.
+AD4- 
+AD4- Signed-off-by: Elad Kanfi +ADw-eladkan+AEA-mellanox.com+AD4-
+AD4- Acked-by: Noam Camus +ADw-noamca+AEA-mellanox.com+AD4-
+AD4- ---
+AD4- +AKA-drivers/net/ethernet/ezchip/nps+AF8-enet.c +AHwAoACgAKAAoA-4 +-+-+--
+AD4- +AKA-1 files changed, 3 insertions(+-), 1 deletions(-)
+AD4- 
+AD4- diff --git a/drivers/net/ethernet/ezchip/nps+AF8-enet.c b/drivers/net/ethernet/ezchip/nps+AF8-enet.c
+AD4- index 085f912..06f0317 100644
+AD4- --- a/drivers/net/ethernet/ezchip/nps+AF8-enet.c
+AD4- +-+-+- b/drivers/net/ethernet/ezchip/nps+AF8-enet.c
+AD4- +AEAAQA- -205,8 +-205,10 +AEAAQA- static int nps+AF8-enet+AF8-poll(struct napi+AF8-struct +ACo-napi, int budget)
+AD4- +AKA-		+AKAAKg- re-adding ourselves to the poll list.
+AD4- +AKA-		+AKAAKg-/
+AD4- +AKA-
+AD4- -		if (priv-+AD4-tx+AF8-skb +ACYAJg- +ACE-tx+AF8-ctrl+AF8-ct)
+AD4- +-		if (priv-+AD4-tx+AF8-skb +ACYAJg- +ACE-tx+AF8-ctrl+AF8-ct) +AHs-
+AD4- +-			nps+AF8-enet+AF8-reg+AF8-set(priv, NPS+AF8-ENET+AF8-REG+AF8-BUF+AF8-INT+AF8-ENABLE, 0)+ADs-
+AD4- +AKA-			napi+AF8-reschedule(napi)+ADs-
+AD4- +-		+AH0-
+AD4- +AKA-	+AH0-
+AD4- +AKA-
+AD4- +AKA-	return work+AF8-done+ADs-

We just bumped into the same problem (data exchange hangs on the very first +ACI-ping+ACI-)
with released Linux v4.6 and linux-next on our nSIM OSCI virtual platform.

I believe it was commit+AKA-05c00d82f4d1 (+ACI-net: nps+AF8-enet: bug fix - handle lost tx interrupts+ACI-)
that introduced the problem. At least reverting it I got networking working.

And indeed that patch fixes mentioned issue.
In other words...

Tested-by: Alexey Brodkin +ADw-abrodkin+AEA-synopsys.com+AD4-

P.S. Given my observation is correct please add following to your commit
message if you ever do a respin:
------------------+AD4-8---------------
Fixes: 05c00d82f4d1 (+ACI-net: nps+AF8-enet: bug fix - handle lost tx interrupts+ACI-)

Cc: +ADw-stable+AEA-vger.kernel.org+AD4- +ACM- 4.6.x
------------------+AD4-8---------------
