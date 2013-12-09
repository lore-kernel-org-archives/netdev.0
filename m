From: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Subject: Re: [PATCH 01/10] net: stmmac: Enable stmmac main clock
 when probing hardware
Date: Mon, 9 Dec 2013 10:43:29 +0800
Message-ID: <CAGb2v65YOSq_BMWSzSHX8w_hbo+0vwquBT2pnLuwNVZkWRfLvA@mail.gmail.com>
References: <1386350983-13281-1-git-send-email-wens@csie.org>
 <1386350983-13281-2-git-send-email-wens@csie.org> <20131207103335.GL24519@lukather>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>, devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-sunxi <linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
	Srinivas Kandagatla <srinivas.kandagatla-qxv4g6HH51o@public.gmane.org>
To: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Return-path: <linux-sunxi+bncBCMILY6JWQBBBZ64SSKQKGQEXIFCPJA-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <20131207103335.GL24519@lukather>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

Hi,

On Sat, Dec 7, 2013 at 6:33 PM, Maxime Ripard
<maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org> wrote:
> Hi,
>
> On Sat, Dec 07, 2013 at 01:29:34AM +0800, Chen-Yu Tsai wrote:
>> Signed-off-by: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
>> ---
>>
>> Guiseppe previously stated that the "stmmaceth" clock is the
>> main clock that drives the IP. The stmmac driver does not
>> enable this clock during the probe phase. When the driver is
>> built in to the kernel, this is fine because the clock maybe
>> on by default, or the boot loader had enabled it.
>>
>> If stmmac is built as a module, when the module is loaded,
>> the clock may be found unused and disabled by the kernel.
>
> This should be your commit log.
>
> And this is actually not related to the fact that we are building it
> as a module or not. You'd face the same issue with a statically built
> kernel if the bootloader didn't enable it.

Noted. Will revise commit log.

>
>>
>>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 24 +++++++++++++----------
>>  1 file changed, 14 insertions(+), 10 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> index 8d4ccd3..7da71ed 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> @@ -2688,10 +2688,17 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
>>       if ((phyaddr >= 0) && (phyaddr <= 31))
>>               priv->plat->phy_addr = phyaddr;
>>
>> +     priv->stmmac_clk = clk_get(priv->device, STMMAC_RESOURCE_NAME);
>
> You can probably use devm_clk_get to make the exit path smaller.

As it stands, the driver does not call clk_put in the exit path.
Using devm_clk_get here would be a good fix.

>
>> +     if (IS_ERR(priv->stmmac_clk)) {
>> +             pr_warn("%s: warning: cannot get CSR clock\n", __func__);
>
> And dev_warn here.
>
>> +             goto error_clk_get;
>> +     }
>> +     clk_prepare_enable(priv->stmmac_clk);
>> +
>>       /* Init MAC and get the capabilities */
>>       ret = stmmac_hw_init(priv);
>>       if (ret)
>> -             goto error_free_netdev;
>> +             goto error_hw_init;
>>       ndev->netdev_ops = &stmmac_netdev_ops;
>>
>> @@ -2729,12 +2736,6 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
>>               goto error_netdev_register;
>>       }
>>
>> -     priv->stmmac_clk = clk_get(priv->device, STMMAC_RESOURCE_NAME);
>> -     if (IS_ERR(priv->stmmac_clk)) {
>> -             pr_warn("%s: warning: cannot get CSR clock\n", __func__);
>> -             goto error_clk_get;
>> -     }
>> -
>>       /* If a specific clk_csr value is passed from the platform
>>        * this means that the CSR Clock Range selection cannot be
>>        * changed at run-time and it is fixed. Viceversa the driver'll try to
>> @@ -2759,15 +2760,18 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
>>               }
>>       }
>>
>> +     clk_disable_unprepare(priv->stmmac_clk);
>> +
>
> Hu? Why do you disable the clock? don't you need it afterwards?

The clock is enabled in *_open (when the network interface is used),
and disabled in *_close.
