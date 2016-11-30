From: Dave Gerlach <d-gerlach@ti.com>
Subject: Re: [PATCH] net: ethernet: ti: cpsw: fix ASSERT_RTNL() warning during
 resume
Date: Wed, 30 Nov 2016 10:03:40 -0600
Message-ID: <573b4b9d-190a-c374-d047-5a971653f766@ti.com>
References: <20161129222703.10908-1-grygorii.strashko@ti.com>
 <20161130001857.GB18604@khorivan>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161130001857.GB18604@khorivan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/29/2016 06:18 PM, Ivan Khoronzhuk wrote:
> On Tue, Nov 29, 2016 at 04:27:03PM -0600, Grygorii Strashko wrote:
>> netif_set_real_num_tx/rx_queues() are required to be called with rtnl_lock
>> taken, otherwise ASSERT_RTNL() warning will be triggered - which happens
>> now during System resume from suspend:
>> cpsw_resume()
>> |- cpsw_ndo_open()
>>   |- netif_set_real_num_tx/rx_queues()
>>      |- ASSERT_RTNL();
>>
>> Hence, fix it by surrounding cpsw_ndo_open() by rtnl_lock/unlock() calls.
>>
>> Cc: Dave Gerlach <d-gerlach@ti.com>
>> Cc: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
>> Fixes: commit e05107e6b747 ("net: ethernet: ti: cpsw: add multi queue support")
>> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
> Reviewed-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
>

Tested-by: Dave Gerlach <d-gerlach@ti.com>

>> ---
>>  drivers/net/ethernet/ti/cpsw.c | 4 ++++
>>  1 file changed, 4 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
>> index ae1ec6a..fd6c03b 100644
>> --- a/drivers/net/ethernet/ti/cpsw.c
>> +++ b/drivers/net/ethernet/ti/cpsw.c
>> @@ -2944,6 +2944,8 @@ static int cpsw_resume(struct device *dev)
>>  	/* Select default pin state */
>>  	pinctrl_pm_select_default_state(dev);
>>
>> +	/* shut up ASSERT_RTNL() warning in netif_set_real_num_tx/rx_queues */
>> +	rtnl_lock();
>>  	if (cpsw->data.dual_emac) {
>>  		int i;
>>
>> @@ -2955,6 +2957,8 @@ static int cpsw_resume(struct device *dev)
>>  		if (netif_running(ndev))
>>  			cpsw_ndo_open(ndev);
>>  	}
>> +	rtnl_unlock();
>> +
>>  	return 0;
>>  }
>>  #endif
>> --
>> 2.10.1
>>
