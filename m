From: Dongpo Li <lidongpo@hisilicon.com>
Subject: Re: [PATCH 2/4] net: hix5hd2_gmac: add reset control and clock
 signals
Date: Mon, 15 Aug 2016 15:07:47 +0800
Message-ID: <57B16A43.4090600@hisilicon.com>
References: <1470906115-155569-1-git-send-email-lidongpo@hisilicon.com>
 <1470906115-155569-3-git-send-email-lidongpo@hisilicon.com>
 <20160812184824.GA8959@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <mark.rutland@arm.com>, <mturquette@baylibre.com>,
	<sboyd@codeaurora.org>, <linux@armlinux.org.uk>,
	<zhangfei.gao@linaro.org>, <yisen.zhuang@huawei.com>,
	<salil.mehta@huawei.com>, <davem@davemloft.net>, <arnd@arndb.de>,
	<andrew@lunn.ch>, <xuejiancheng@hisilicon.com>,
	<benjamin.chenhao@hisilicon.com>, <howell.yang@hisilicon.com>,
	<netdev@vger.kernel.org>, <devicetree@vger.kernel.org>,
	<linux-clk@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Rob Herring <robh@kernel.org>
Return-path: <linux-clk-owner@vger.kernel.org>
In-Reply-To: <20160812184824.GA8959@rob-hp-laptop>
Sender: linux-clk-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Rob,

On 2016/8/13 2:48, Rob Herring wrote:
> On Thu, Aug 11, 2016 at 05:01:53PM +0800, Dongpo Li wrote:
>> From: Li Dongpo <lidongpo@hisilicon.com>
>>
>> Add three reset control signals, "mac_core_rst", "mac_ifc_rst" and
>> "phy_rst".
>> The following diagram explained how the reset signals work.
>>
>>                         SoC
>> |-----------------------------------------------------
>> |                               ------                |
>> |                               | cpu |               |
>> |                               ------                |
>> |                                  |                  |
>> |                              ------------ AMBA bus  |
>> |                         GMAC     |                  |
>> |                            ----------------------   |
>> | ------------- mac_core_rst | --------------      |  |
>> | |clock and   |-------------->|   mac core  |     |  |
>> | |reset       |             | --------------      |  |
>> | |generator   |----         |       |             |  |
>> | -------------     |        | ----------------    |  |
>> |          |        ---------->| mac interface |   |  |
>> |          |     mac_ifc_rst | ----------------    |  |
>> |          |                 |       |             |  |
>> |          |                 | ------------------  |  |
>> |          |phy_rst          | | RGMII interface | |  |
>> |          |                 | ------------------  |  |
>> |          |                 ----------------------   |
>> |----------|------------------------------------------|
>>            |                          |
>>            |                      ----------
>>            |--------------------- |PHY chip |
>>                                   ----------
>>
>> The "mac_core_rst" represents "mac core reset signal", it resets
>> the mac core including packet processing unit, descriptor processing unit,
>> tx engine, rx engine, control unit.
>> The "mac_ifc_rst" represents "mac interface reset signal", it resets
>> the mac interface. The mac interface unit connects mac core and
>> data interface like MII/RMII/RGMII. After we set a new value of
>> interface mode, we must reset mac interface to reload the new mode value.
>> The "phy_rst" represents "phy reset signal", it does a hardware reset
>> on the PHY chip. This reset signal is optinal if the PHY can work well
>> without the hardware reset.
>>
>> Add one more clock signal, the existing is MAC core clock,
>> and the new one is MAC interface clock.
>>
>> Signed-off-by: Dongpo Li <lidongpo@hisilicon.com>
>> ---
>>  .../bindings/net/hisilicon-hix5hd2-gmac.txt        |  16 ++-
>>  drivers/net/ethernet/hisilicon/hix5hd2_gmac.c      | 140 +++++++++++++++++++--
>>  2 files changed, 143 insertions(+), 13 deletions(-)
> 
> 
>>
>> @@ -807,16 +829,26 @@ static int hix5hd2_net_open(struct net_device *dev)
>>  	struct phy_device *phy;
>>  	int ret;
>>  
>> -	ret = clk_prepare_enable(priv->clk);
>> +	ret = clk_prepare_enable(priv->mac_core_clk);
>> +	if (ret < 0) {
>> +		netdev_err(dev, "failed to enable mac core clk %d\n", ret);
>> +		return ret;
>> +	}
>> +
>> +	ret = clk_prepare_enable(priv->mac_ifc_clk);
>>  	if (ret < 0) {
>> -		netdev_err(dev, "failed to enable clk %d\n", ret);
>> +		clk_disable_unprepare(priv->mac_core_clk);
>> +		netdev_err(dev, "failed to enable mac ifc clk %d\n", ret);
> 
> This change will break with existing DTs. The mac_ifc_clk should be 
> optional.
> 
The mac_ifc_clk has existed in the existing hix5hd2. It's not implemented in the MAC driver
because the CLOCK driver implements a "complex" ethernet clock type.
So [PATCH 3/4] and [PATCH 4/4] are following this patch to change the CLOCK driver and existing DTs
at the same time.

> Rob
> 
>>  		return ret;
>>  	}
> 
> .
> 


    Regards,
    Dongpo

.

