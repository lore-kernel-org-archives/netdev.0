From: Sekhar Nori <nsekhar@ti.com>
Subject: Re: [PATCH net-next 2/2] net/davinci_emac: use clk_{prepare|unprepare}
Date: Tue, 26 Mar 2013 15:35:43 +0530
Message-ID: <515172F7.3050600@ti.com>
References: <1364203547-2960-1-git-send-email-nsekhar@ti.com> <1364203547-2960-3-git-send-email-nsekhar@ti.com> <20130325161654.4014.68401@quantum>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<davinci-linux-open-source@linux.davincidsp.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Mike Turquette <mturquette@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:55852 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751742Ab3CZKF6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Mar 2013 06:05:58 -0400
In-Reply-To: <20130325161654.4014.68401@quantum>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 3/25/2013 9:46 PM, Mike Turquette wrote:
> Quoting Sekhar Nori (2013-03-25 02:25:47)
>> Use clk_prepare()/clk_unprepare() in the driver since common
>> clock framework needs these to be called before clock is enabled.
>>
>> This is in preparation of common clock framework migration
>> for DaVinci.
>>
>> Cc: Mike Turquette <mturquette@linaro.org>
>> Signed-off-by: Sekhar Nori <nsekhar@ti.com>
>> ---
>>  drivers/net/ethernet/ti/davinci_emac.c |   19 +++++++++++++++++--
>>  1 file changed, 17 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
>> index b1349b5..436296c 100644
>> --- a/drivers/net/ethernet/ti/davinci_emac.c
>> +++ b/drivers/net/ethernet/ti/davinci_emac.c
>> @@ -350,6 +350,7 @@ struct emac_priv {
>>         /*platform specific members*/
>>         void (*int_enable) (void);
>>         void (*int_disable) (void);
>> +       struct clk *clk;
>>  };
>>  
>>  /* EMAC TX Host Error description strings */
>> @@ -1870,19 +1871,29 @@ static int davinci_emac_probe(struct platform_device *pdev)
>>                 dev_err(&pdev->dev, "failed to get EMAC clock\n");
>>                 return -EBUSY;
>>         }
>> +
>> +       rc = clk_prepare(emac_clk);
>> +       if (rc) {
>> +               dev_err(&pdev->dev, "emac clock prepare failed.\n");
>> +               return rc;
>> +       }
>> +
> 
> Is clk_enable ever called for emac_clk here?  I don't see it in the
> diff.  clk_prepare and clk_enable should usually be paired, even if
> simply calling clk_prepare generates the clock signal that your device
> needs.

clk_enable() is called by pm_runtime framework. Without this patch, the 
clk_enable() call from pm_clk_resume() will result in a warning when 
using common clock framework. This issue can actually be fixed by patch
below which fixes this in drivers/base/power/clock_ops.c so 
individual drivers don't have to do this, but we need to careful since 
will break for callers who intend to use the pm_runtime apis from atomic 
context.

Anyway, its probably much better to fix this in pm_runtime framework so I will 
work with Rafael to see if I can come up with something acceptable.

This patch can then be dropped for now, but 1/2 can still be applied.
That one is pretty harmless!

Thanks,
Sekhar

diff --git a/drivers/base/power/clock_ops.c b/drivers/base/power/clock_ops.c
index 9d8fde7..60d389a 100644
--- a/drivers/base/power/clock_ops.c
+++ b/drivers/base/power/clock_ops.c
@@ -230,7 +230,7 @@ int pm_clk_suspend(struct device *dev)
        list_for_each_entry_reverse(ce, &psd->clock_list, node) {
                if (ce->status < PCE_STATUS_ERROR) {
                        if (ce->status == PCE_STATUS_ENABLED)
-                               clk_disable(ce->clk);
+                               clk_disable_unprepare(ce->clk);
                        ce->status = PCE_STATUS_ACQUIRED;
                }
        }
@@ -259,7 +259,7 @@ int pm_clk_resume(struct device *dev)

        list_for_each_entry(ce, &psd->clock_list, node) {
                if (ce->status < PCE_STATUS_ERROR) {
-                       clk_enable(ce->clk);
+                       clk_prepare_enable(ce->clk);
                        ce->status = PCE_STATUS_ENABLED;
                }
        }
