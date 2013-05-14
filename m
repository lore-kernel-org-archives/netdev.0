From: Hein Tibosch <hein_tibosch@yahoo.es>
Subject: Re: [PATCH] net/macb: fix ISR clear-on-write behavior only for some
 SoC
Date: Tue, 14 May 2013 08:58:11 +0800
Message-ID: <51918C23.7040106@yahoo.es>
References: <1368461105-23128-1-git-send-email-nicolas.ferre@atmel.com> <FE065E51-1EAA-47ED-8C7B-0F2E6418F349@jcrosoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: michal.simek@xilinx.com,
	Ludovic Desroches <ludovic.desroches@atmel.com>,
	s.trumtrar@pengutronix.de, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <FE065E51-1EAA-47ED-8C7B-0F2E6418F349@jcrosoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/14/2013 12:05 AM, Jean-Christophe PLAGNIOL-VILLARD wrote:
> On May 14, 2013, at 12:05 AM, Nicolas Ferre <nicolas.ferre@atmel.com> wrote:
>
>> Commit 749a2b6 (net/macb: clear tx/rx completion flags in ISR)
>> introduces clear-on-write on ISR register. This behavior is not always
>> implemented when using Cadence MACB/GEM and is breaking other platforms.
>> We are using a new Device Tree compatibility string and a capability
>> property to actually activate this clear-on-write behavior on ISR.
>>
>> Reported-by: Hein Tibosch <hein_tibosch@yahoo.es>
>> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
> can we detect it via the IP?

This was my first proposal, have it based on the value of MACB's
register 'MID' (offset 0x00fc, lower 16 bits).
On avr32 it reads: 0x0000010D, on Zynq it reports 0x00000119

So for the moment, CAPS_ISR_CLEAR_ON_WRITE could be set if the revision
equals to 0x00000119?

>> ---
>> Documentation/devicetree/bindings/net/macb.txt |  2 ++
>> drivers/net/ethernet/cadence/macb.c            | 15 +++++++++++++--
>> drivers/net/ethernet/cadence/macb.h            |  5 +++++
>> 3 files changed, 20 insertions(+), 2 deletions(-)
>>
>> diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Documentation/devicetree/bindings/net/macb.txt
>> index 44afa0e..13ec4f6 100644
>>
>> <snip>
>>
>> @@ -1474,6 +1476,10 @@ static const struct of_device_id macb_dt_ids[] = {
>> 	{ .compatible = "cdns,macb" },
>> 	{ .compatible = "cdns,pc302-gem" },
>> 	{ .compatible = "cdns,gem" },
>> +	{
>> +		.compatible = "cdns,zynq-7000-gem",
>> +		.data = (void *)MACB_CAPS_ISR_CLEAR_ON_WRITE,
>> +	},
>> 	{ /* sentinel */ }
>> };
>> MODULE_DEVICE_TABLE(of, macb_dt_ids);
>> @@ -1484,6 +1490,7 @@ static int __init macb_probe(struct platform_device *pdev)
>> 	struct macb_platform_data *pdata;
>> 	struct resource *regs;
>> 	struct net_device *dev;
>> +	const struct of_device_id *dev_id;
>> 	struct macb *bp;
>> 	struct phy_device *phydev;
>> 	u32 config;
>> @@ -1558,6 +1565,10 @@ static int __init macb_probe(struct platform_device *pdev)
>>
>> 	dev->base_addr = regs->start;
>>
>> +	dev_id = of_match_device(macb_dt_ids, &pdev->dev);
As avr32 doesn't yet define CONFIG_OF:
    macb.c:1601: error:  'macb_dt_ids' undeclared

Hein
