From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 08/13] net/stmmac: Remove conditional compilation of clk
 code
Date: Tue, 24 Apr 2012 07:57:38 +0200
Message-ID: <4F9640D2.5080303@st.com>
References: <cover.1335008617.git.viresh.kumar@st.com>
 <03d5825c44251e6cbbdb3c3d8e67208f0fd4619d.1335008617.git.viresh.kumar@st.com>
 <4F964099.7030401@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mturquette@linaro.org, sshtylyov@mvista.com,
 ML netdev <netdev@vger.kernel.org>, spear-devel@list.st.com,
 linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
 akpm@linux-foundation.org, jgarzik@redhat.com,
 linux-arm-kernel@lists.infradead.org
To: Viresh Kumar <viresh.linux@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <4F964099.7030401@st.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

+ netdev

On 4/24/2012 7:56 AM, Giuseppe CAVALLARO wrote:
> Hello Viresh.
> 
> On 4/21/2012 1:47 PM, Viresh Kumar wrote:
>> With addition of dummy clk_*() calls for non CONFIG_HAVE_CLK cases in clk.h,
>> there is no need to have clk code enclosed in #ifdef CONFIG_HAVE_CLK, #endif
>> macros.
> 
> I like this patch also because reduces ifdef in the code :-)
> 
> Anyway this patch doesn't apply fine either in net-next and in net.git.
> Also I wonder if you had already tested the driver build on arch w/o
> HAVE_CLK ... just to avoid kernel build failures on other platforms.
> 
> Let me know if I can help you on that.
> 
> Peppe
>>
>> Signed-off-by: Viresh Kumar <viresh.kumar@st.com>
>> Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
>> Cc: David S. Miller <davem@davemloft.net>
>> ---
>>  drivers/net/ethernet/stmicro/stmmac/stmmac.h      |   40 ---------------------
>>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   34 +++++++++++-------
>>  2 files changed, 21 insertions(+), 53 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
>> index 9f2435c..7f85895 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
>> @@ -81,9 +81,7 @@ struct stmmac_priv {
>>  	struct stmmac_counters mmc;
>>  	struct dma_features dma_cap;
>>  	int hw_cap_support;
>> -#ifdef CONFIG_HAVE_CLK
>>  	struct clk *stmmac_clk;
>> -#endif
>>  	int clk_csr;
>>  };
>>  
>> @@ -103,41 +101,3 @@ int stmmac_dvr_remove(struct net_device *ndev);
>>  struct stmmac_priv *stmmac_dvr_probe(struct device *device,
>>  				     struct plat_stmmacenet_data *plat_dat,
>>  				     void __iomem *addr);
>> -
>> -#ifdef CONFIG_HAVE_CLK
>> -static inline int stmmac_clk_enable(struct stmmac_priv *priv)
>> -{
>> -	if (priv->stmmac_clk)
>> -		return clk_enable(priv->stmmac_clk);
>> -
>> -	return 0;
>> -}
>> -
>> -static inline void stmmac_clk_disable(struct stmmac_priv *priv)
>> -{
>> -	if (priv->stmmac_clk)
>> -		clk_disable(priv->stmmac_clk);
>> -}
>> -static inline int stmmac_clk_get(struct stmmac_priv *priv)
>> -{
>> -	priv->stmmac_clk = clk_get(priv->device, NULL);
>> -
>> -	if (IS_ERR(priv->stmmac_clk)) {
>> -		pr_err("%s: ERROR clk_get failed\n", __func__);
>> -		return PTR_ERR(priv->stmmac_clk);
>> -	}
>> -	return 0;
>> -}
>> -#else
>> -static inline int stmmac_clk_enable(struct stmmac_priv *priv)
>> -{
>> -	return 0;
>> -}
>> -static inline void stmmac_clk_disable(struct stmmac_priv *priv)
>> -{
>> -}
>> -static inline int stmmac_clk_get(struct stmmac_priv *priv)
>> -{
>> -	return 0;
>> -}
>> -#endif /* CONFIG_HAVE_CLK */
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> index a64f0d4..28b8f30 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> @@ -28,6 +28,7 @@
>>  	https://bugzilla.stlinux.com/
>>  *******************************************************************************/
>>  
>> +#include <linux/clk.h>
>>  #include <linux/kernel.h>
>>  #include <linux/interrupt.h>
>>  #include <linux/ip.h>
>> @@ -165,7 +166,6 @@ static void stmmac_verify_args(void)
>>  
>>  static void stmmac_clk_csr_set(struct stmmac_priv *priv)
>>  {
>> -#ifdef CONFIG_HAVE_CLK
>>  	u32 clk_rate;
>>  
>>  	clk_rate = clk_get_rate(priv->stmmac_clk);
>> @@ -189,7 +189,6 @@ static void stmmac_clk_csr_set(struct stmmac_priv *priv)
>>  	   * we can not estimate the proper divider as it is not known
>>  	   * the frequency of clk_csr_i. So we do not change the default
>>  	   * divider. */
>> -#endif
>>  }
>>  
>>  #if defined(STMMAC_XMIT_DEBUG) || defined(STMMAC_RX_DEBUG)
>> @@ -933,7 +932,8 @@ static int stmmac_open(struct net_device *dev)
>>  	struct stmmac_priv *priv = netdev_priv(dev);
>>  	int ret;
>>  
>> -	stmmac_clk_enable(priv);
>> +	if (!IS_ERR(priv->stmmac_clk))
>> +		clk_enable(priv->stmmac_clk);
>>  
>>  	stmmac_check_ether_addr(priv);
>>  
>> @@ -1068,7 +1068,9 @@ open_error:
>>  		phy_disconnect(priv->phydev);
>>  
>>  open_clk_dis:
>> -	stmmac_clk_disable(priv);
>> +	if (!IS_ERR(priv->stmmac_clk))
>> +		clk_disable(priv->stmmac_clk);
>> +
>>  	return ret;
>>  }
>>  
>> @@ -1121,7 +1123,9 @@ static int stmmac_release(struct net_device *dev)
>>  	stmmac_exit_fs();
>>  #endif
>>  	stmmac_mdio_unregister(dev);
>> -	stmmac_clk_disable(priv);
>> +
>> +	if (!IS_ERR(priv->stmmac_clk))
>> +		clk_disable(priv->stmmac_clk);
>>  
>>  	return 0;
>>  }
>> @@ -1918,8 +1922,9 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
>>  		goto error;
>>  	}
>>  
>> -	if (stmmac_clk_get(priv))
>> -		goto error;
>> +	priv->stmmac_clk = clk_get(priv->device, NULL);
>> +	if (IS_ERR(priv->stmmac_clk))
>> +		pr_err("%s: No clock found\n", __func__);
>>  
>>  	/* If a specific clk_csr value is passed from the platform
>>  	 * this means that the CSR Clock Range selection cannot be
>> @@ -1927,10 +1932,12 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
>>  	 * set the MDC clock dynamically according to the csr actual
>>  	 * clock input.
>>  	 */
>> -	if (!priv->plat->clk_csr)
>> -		stmmac_clk_csr_set(priv);
>> -	else
>> +	if (!priv->plat->clk_csr) {
>> +		if (!IS_ERR(priv->stmmac_clk))
>> +			stmmac_clk_csr_set(priv);
>> +	} else {
>>  		priv->clk_csr = priv->plat->clk_csr;
>> +	}
>>  
>>  	return priv;
>>  
>> @@ -2004,7 +2011,8 @@ int stmmac_suspend(struct net_device *ndev)
>>  	else {
>>  		stmmac_set_mac(priv->ioaddr, false);
>>  		/* Disable clock in case of PWM is off */
>> -		stmmac_clk_disable(priv);
>> +		if (!IS_ERR(priv->stmmac_clk))
>> +			clk_disable(priv->stmmac_clk);
>>  	}
>>  	spin_unlock(&priv->lock);
>>  	return 0;
>> @@ -2026,9 +2034,9 @@ int stmmac_resume(struct net_device *ndev)
>>  	 * from another devices (e.g. serial console). */
>>  	if (device_may_wakeup(priv->device))
>>  		priv->hw->mac->pmt(priv->ioaddr, 0);
>> -	else
>> +	else if (!IS_ERR(priv->stmmac_clk))
>>  		/* enable the clk prevously disabled */
>> -		stmmac_clk_enable(priv);
>> +			clk_enable(priv->stmmac_clk);
>>  
>>  	netif_device_attach(ndev);
>>  
> 
