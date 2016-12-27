From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: stmmac: synchronize stmmac_open and stmmac_dvr_probe
Date: Mon, 26 Dec 2016 21:13:57 -0800
Message-ID: <6df6425b-bb0c-1e74-b5e1-a221447b761f@gmail.com>
References: <1482839100-20612-1-git-send-email-hock.leong.kweh@intel.com>
 <461cd45a-70a5-1f08-816d-3c210d694083@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Alexandre TORGUE <alexandre.torgue@gmail.com>,
        Joachim Eastwood <manabian@gmail.com>,
        Niklas Cassel <niklas.cassel@axis.com>,
        Johan Hovold <johan@kernel.org>, pavel@ucw.cz,
        Ong Boon Leong <boon.leong.ong@intel.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, weifeng.voon@intel.com,
        Lars Persson <lars.persson@axis.com>
To: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>,
        "David S. Miller" <davem@davemloft.net>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        seraphin.bonnaffe@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <461cd45a-70a5-1f08-816d-3c210d694083@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 12/26/2016 09:10 PM, Florian Fainelli wrote:
> 
> 
> On 12/27/2016 03:44 AM, Kweh, Hock Leong wrote:
>> From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
>>
>> If kernel module stmmac driver being loaded after OS booted, there is a
>> race condition between stmmac_open() and stmmac_mdio_register(), which is
>> invoked inside stmmac_dvr_probe(), and the error is showed in dmesg log as
>> PHY not found and stmmac_open() failed:
>> [  473.919358] stmmaceth 0000:01:00.0 (unnamed net_device) (uninitialized):
>> 		stmmac_dvr_probe: warning: cannot get CSR clock
>> [  473.919382] stmmaceth 0000:01:00.0: no reset control found
>> [  473.919412] stmmac - user ID: 0x10, Synopsys ID: 0x42
>> [  473.919429] stmmaceth 0000:01:00.0: DMA HW capability register supported
>> [  473.919436] stmmaceth 0000:01:00.0: RX Checksum Offload Engine supported
>> [  473.919443] stmmaceth 0000:01:00.0: TX Checksum insertion supported
>> [  473.919451] stmmaceth 0000:01:00.0 (unnamed net_device) (uninitialized):
>> 		Enable RX Mitigation via HW Watchdog Timer
>> [  473.921395] libphy: PHY stmmac-1:00 not found
>> [  473.921417] stmmaceth 0000:01:00.0 eth0: Could not attach to PHY
>> [  473.921427] stmmaceth 0000:01:00.0 eth0: stmmac_open: Cannot attach to
>> 		PHY (error: -19)
>> [  473.959710] libphy: stmmac: probed
>> [  473.959724] stmmaceth 0000:01:00.0 eth0: PHY ID 01410cc2 at 0 IRQ POLL
>> 		(stmmac-1:00) active
>> [  473.959728] stmmaceth 0000:01:00.0 eth0: PHY ID 01410cc2 at 1 IRQ POLL
>> 		(stmmac-1:01)
>> [  473.959731] stmmaceth 0000:01:00.0 eth0: PHY ID 01410cc2 at 2 IRQ POLL
>> 		(stmmac-1:02)
>> [  473.959734] stmmaceth 0000:01:00.0 eth0: PHY ID 01410cc2 at 3 IRQ POLL
>> 		(stmmac-1:03)
>>
>> The resolution used wait_for_completion_interruptible() to synchronize
>> stmmac_open() and stmmac_dvr_probe() to prevent the race condition
>> happening.
> 
> The proper fix for this would be to have register_netdev() be the last
> thing done in stmmac_drv_probe(), whereas right now, the last thing done
> is stmmac_mdio_register(), leading the window you are seeing here, where
> the network interface can be open prior to all resources being set up,
> including, but not limited to MDIO devices.

Something like the following untested patch should plug this race:

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index bb40382e205d..5910ea51f8f6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -3339,13 +3339,6 @@ int stmmac_dvr_probe(struct device *device,

        spin_lock_init(&priv->lock);

-       ret = register_netdev(ndev);
-       if (ret) {
-               netdev_err(priv->dev, "%s: ERROR %i registering the
device\n",
-                          __func__, ret);
-               goto error_netdev_register;
-       }
-
        /* If a specific clk_csr value is passed from the platform
         * this means that the CSR Clock Range selection cannot be
         * changed at run-time and it is fixed. Viceversa the driver'll
try to
@@ -3372,11 +3365,14 @@ int stmmac_dvr_probe(struct device *device,
                }
        }

-       return 0;
+       ret = register_netdev(ndev);
+       if (ret)
+               netdev_err(priv->dev, "%s: ERROR %i registering the
device\n",
+                          __func__, ret);
+
+       return ret;

 error_mdio_register:
-       unregister_netdev(ndev);
-error_netdev_register:
        netif_napi_del(&priv->napi);
 error_hw_init:
        clk_disable_unprepare(priv->pclk);

-- 
Florian
