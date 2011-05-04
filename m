From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 2/2] libertas: Use netdev_<level> or dev_<level> where
 possible
Date: Wed, 04 May 2011 17:15:37 -0500
Message-ID: <1304547338.4379.1.camel@dcbw.foobar.com>
References: <cover.1304379925.git.joe@perches.com>
	 <b4b100451cb09b60065f2cf87b893b8d42759aaf.1304379925.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b4b100451cb09b60065f2cf87b893b8d42759aaf.1304379925.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-05-02 at 16:49 -0700, Joe Perches wrote:
> Using the more descriptive logging styles gives a bit
> more information about the device being operated on.
> 
> Makes the object trivially smaller too.
> 
> $ size drivers/net/wireless/libertas/built-in.o.*
>  187730	   2973	  38488	 229191	  37f47	drivers/net/wireless/libertas/built-in.o.new
>  188195	   2973	  38488	 229656	  38118	drivers/net/wireless/libertas/built-in.o.old
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Acked-by: Dan Williams <dcbw@redhat.com>

> ---
>  drivers/net/wireless/libertas/cfg.c     |    9 +++--
>  drivers/net/wireless/libertas/cmd.c     |   42 +++++++++++++----------
>  drivers/net/wireless/libertas/cmdresp.c |   32 +++++++++---------
>  drivers/net/wireless/libertas/debugfs.c |    7 ++--
>  drivers/net/wireless/libertas/if_cs.c   |   15 +++++---
>  drivers/net/wireless/libertas/if_sdio.c |   19 +++++-----
>  drivers/net/wireless/libertas/if_spi.c  |   57 ++++++++++++++++++++-----------
>  drivers/net/wireless/libertas/if_usb.c  |   11 ++++--
>  drivers/net/wireless/libertas/main.c    |   27 +++++++++------
>  drivers/net/wireless/libertas/mesh.c    |    4 +-
>  drivers/net/wireless/libertas/rx.c      |    2 +-
>  11 files changed, 131 insertions(+), 94 deletions(-)
> 
> diff --git a/drivers/net/wireless/libertas/cfg.c b/drivers/net/wireless/libertas/cfg.c
> index d6e0656..47b7f17 100644
> --- a/drivers/net/wireless/libertas/cfg.c
> +++ b/drivers/net/wireless/libertas/cfg.c
> @@ -1316,7 +1316,8 @@ static int lbs_cfg_connect(struct wiphy *wiphy, struct net_device *dev,
>  		sme->ssid, sme->ssid_len,
>  		WLAN_CAPABILITY_ESS, WLAN_CAPABILITY_ESS);
>  	if (!bss) {
> -		pr_err("assoc: bss %pM not in scan results\n", sme->bssid);
> +		wiphy_err(wiphy, "assoc: bss %pM not in scan results\n",
> +			  sme->bssid);
>  		ret = -ENOENT;
>  		goto done;
>  	}
> @@ -1373,8 +1374,8 @@ static int lbs_cfg_connect(struct wiphy *wiphy, struct net_device *dev,
>  		lbs_enable_rsn(priv, sme->crypto.cipher_group != 0);
>  		break;
>  	default:
> -		pr_err("unsupported cipher group 0x%x\n",
> -		       sme->crypto.cipher_group);
> +		wiphy_err(wiphy, "unsupported cipher group 0x%x\n",
> +			  sme->crypto.cipher_group);
>  		ret = -ENOTSUPP;
>  		goto done;
>  	}
> @@ -1492,7 +1493,7 @@ static int lbs_cfg_add_key(struct wiphy *wiphy, struct net_device *netdev,
>  				     params->key, params->key_len);
>  		break;
>  	default:
> -		pr_err("unhandled cipher 0x%x\n", params->cipher);
> +		wiphy_err(wiphy, "unhandled cipher 0x%x\n", params->cipher);
>  		ret = -ENOTSUPP;
>  		break;
>  	}
> diff --git a/drivers/net/wireless/libertas/cmd.c b/drivers/net/wireless/libertas/cmd.c
> index 10ca485..f11c656 100644
> --- a/drivers/net/wireless/libertas/cmd.c
> +++ b/drivers/net/wireless/libertas/cmd.c
> @@ -3,8 +3,6 @@
>    * It prepares command and sends it to firmware when it is ready.
>    */
>  
> -#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> -
>  #include <linux/kfifo.h>
>  #include <linux/sched.h>
>  #include <linux/slab.h>
> @@ -110,7 +108,7 @@ int lbs_update_hw_spec(struct lbs_private *priv)
>  	 * CF card    firmware 5.0.16p0:   cap 0x00000303
>  	 * USB dongle firmware 5.110.17p2: cap 0x00000303
>  	 */
> -	pr_info("%pM, fw %u.%u.%up%u, cap 0x%08x\n",
> +	netdev_info(priv->dev, "%pM, fw %u.%u.%up%u, cap 0x%08x\n",
>  		cmd.permanentaddr,
>  		priv->fwrelease >> 24 & 0xff,
>  		priv->fwrelease >> 16 & 0xff,
> @@ -141,7 +139,8 @@ int lbs_update_hw_spec(struct lbs_private *priv)
>  	/* if it's unidentified region code, use the default (USA) */
>  	if (i >= MRVDRV_MAX_REGION_CODE) {
>  		priv->regioncode = 0x10;
> -		pr_info("unidentified region code; using the default (USA)\n");
> +		netdev_info(priv->dev,
> +			    "unidentified region code; using the default (USA)\n");
>  	}
>  
>  	if (priv->current_addr[0] == 0xff)
> @@ -211,7 +210,7 @@ int lbs_host_sleep_cfg(struct lbs_private *priv, uint32_t criteria,
>  					(uint8_t *)&cmd_config.wol_conf,
>  					sizeof(struct wol_config));
>  	} else {
> -		pr_info("HOST_SLEEP_CFG failed %d\n", ret);
> +		netdev_info(priv->dev, "HOST_SLEEP_CFG failed %d\n", ret);
>  	}
>  
>  	return ret;
> @@ -314,7 +313,7 @@ static int lbs_wait_for_ds_awake(struct lbs_private *priv)
>  	if (priv->is_deep_sleep) {
>  		if (!wait_event_interruptible_timeout(priv->ds_awake_q,
>  					!priv->is_deep_sleep, (10 * HZ))) {
> -			pr_err("ds_awake_q: timer expired\n");
> +			netdev_err(priv->dev, "ds_awake_q: timer expired\n");
>  			ret = -1;
>  		}
>  	}
> @@ -339,7 +338,7 @@ int lbs_set_deep_sleep(struct lbs_private *priv, int deep_sleep)
>  				netif_carrier_off(priv->dev);
>  			}
>  		} else {
> -			pr_err("deep sleep: already enabled\n");
> +			netdev_err(priv->dev, "deep sleep: already enabled\n");
>  		}
>  	} else {
>  		if (priv->is_deep_sleep) {
> @@ -349,7 +348,8 @@ int lbs_set_deep_sleep(struct lbs_private *priv, int deep_sleep)
>  			if (!ret) {
>  				ret = lbs_wait_for_ds_awake(priv);
>  				if (ret)
> -					pr_err("deep sleep: wakeup failed\n");
> +					netdev_err(priv->dev,
> +						   "deep sleep: wakeup failed\n");
>  			}
>  		}
>  	}
> @@ -383,8 +383,9 @@ int lbs_set_host_sleep(struct lbs_private *priv, int host_sleep)
>  			ret = lbs_host_sleep_cfg(priv, priv->wol_criteria,
>  					(struct wol_config *)NULL);
>  			if (ret) {
> -				pr_info("Host sleep configuration failed: %d\n",
> -					ret);
> +				netdev_info(priv->dev,
> +					    "Host sleep configuration failed: %d\n",
> +					    ret);
>  				return ret;
>  			}
>  			if (priv->psstate == PS_STATE_FULL_POWER) {
> @@ -394,19 +395,21 @@ int lbs_set_host_sleep(struct lbs_private *priv, int host_sleep)
>  						sizeof(cmd),
>  						lbs_ret_host_sleep_activate, 0);
>  				if (ret)
> -					pr_info("HOST_SLEEP_ACTIVATE failed: %d\n",
> -						ret);
> +					netdev_info(priv->dev,
> +						    "HOST_SLEEP_ACTIVATE failed: %d\n",
> +						    ret);
>  			}
>  
>  			if (!wait_event_interruptible_timeout(
>  						priv->host_sleep_q,
>  						priv->is_host_sleep_activated,
>  						(10 * HZ))) {
> -				pr_err("host_sleep_q: timer expired\n");
> +				netdev_err(priv->dev,
> +					   "host_sleep_q: timer expired\n");
>  				ret = -1;
>  			}
>  		} else {
> -			pr_err("host sleep: already enabled\n");
> +			netdev_err(priv->dev, "host sleep: already enabled\n");
>  		}
>  	} else {
>  		if (priv->is_host_sleep_activated)
> @@ -1003,7 +1006,8 @@ static void lbs_submit_command(struct lbs_private *priv,
>  	ret = priv->hw_host_to_card(priv, MVMS_CMD, (u8 *) cmd, cmdsize);
>  
>  	if (ret) {
> -		pr_info("DNLD_CMD: hw_host_to_card failed: %d\n", ret);
> +		netdev_info(priv->dev, "DNLD_CMD: hw_host_to_card failed: %d\n",
> +			    ret);
>  		/* Let the timer kick in and retry, and potentially reset
>  		   the whole thing if the condition persists */
>  		timeo = HZ/4;
> @@ -1268,7 +1272,8 @@ int lbs_execute_next_command(struct lbs_private *priv)
>  	spin_lock_irqsave(&priv->driver_lock, flags);
>  
>  	if (priv->cur_cmd) {
> -		pr_alert( "EXEC_NEXT_CMD: already processing command!\n");
> +		netdev_alert(priv->dev,
> +			     "EXEC_NEXT_CMD: already processing command!\n");
>  		spin_unlock_irqrestore(&priv->driver_lock, flags);
>  		ret = -1;
>  		goto done;
> @@ -1430,7 +1435,7 @@ static void lbs_send_confirmsleep(struct lbs_private *priv)
>  	ret = priv->hw_host_to_card(priv, MVMS_CMD, (u8 *) &confirm_sleep,
>  		sizeof(confirm_sleep));
>  	if (ret) {
> -		pr_alert("confirm_sleep failed\n");
> +		netdev_alert(priv->dev, "confirm_sleep failed\n");
>  		goto out;
>  	}
>  
> @@ -1656,7 +1661,8 @@ int __lbs_cmd(struct lbs_private *priv, uint16_t command,
>  	spin_lock_irqsave(&priv->driver_lock, flags);
>  	ret = cmdnode->result;
>  	if (ret)
> -		pr_info("PREP_CMD: command 0x%04x failed: %d\n", command, ret);
> +		netdev_info(priv->dev, "PREP_CMD: command 0x%04x failed: %d\n",
> +			    command, ret);
>  
>  	__lbs_cleanup_and_insert_cmd(priv, cmdnode);
>  	spin_unlock_irqrestore(&priv->driver_lock, flags);
> diff --git a/drivers/net/wireless/libertas/cmdresp.c b/drivers/net/wireless/libertas/cmdresp.c
> index 2cb6f5f..4352e92 100644
> --- a/drivers/net/wireless/libertas/cmdresp.c
> +++ b/drivers/net/wireless/libertas/cmdresp.c
> @@ -3,8 +3,6 @@
>    * responses as well as events generated by firmware.
>    */
>  
> -#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> -
>  #include <linux/slab.h>
>  #include <linux/delay.h>
>  #include <linux/sched.h>
> @@ -87,17 +85,18 @@ int lbs_process_command_response(struct lbs_private *priv, u8 *data, u32 len)
>  	lbs_deb_hex(LBS_DEB_CMD, "CMD_RESP", (void *) resp, len);
>  
>  	if (resp->seqnum != priv->cur_cmd->cmdbuf->seqnum) {
> -		pr_info("Received CMD_RESP with invalid sequence %d (expected %d)\n",
> -			le16_to_cpu(resp->seqnum),
> -			le16_to_cpu(priv->cur_cmd->cmdbuf->seqnum));
> +		netdev_info(priv->dev,
> +			    "Received CMD_RESP with invalid sequence %d (expected %d)\n",
> +			    le16_to_cpu(resp->seqnum),
> +			    le16_to_cpu(priv->cur_cmd->cmdbuf->seqnum));
>  		spin_unlock_irqrestore(&priv->driver_lock, flags);
>  		ret = -1;
>  		goto done;
>  	}
>  	if (respcmd != CMD_RET(curcmd) &&
>  	    respcmd != CMD_RET_802_11_ASSOCIATE && curcmd != CMD_802_11_ASSOCIATE) {
> -		pr_info("Invalid CMD_RESP %x to command %x!\n",
> -			respcmd, curcmd);
> +		netdev_info(priv->dev, "Invalid CMD_RESP %x to command %x!\n",
> +			    respcmd, curcmd);
>  		spin_unlock_irqrestore(&priv->driver_lock, flags);
>  		ret = -1;
>  		goto done;
> @@ -106,8 +105,9 @@ int lbs_process_command_response(struct lbs_private *priv, u8 *data, u32 len)
>  	if (resp->result == cpu_to_le16(0x0004)) {
>  		/* 0x0004 means -EAGAIN. Drop the response, let it time out
>  		   and be resubmitted */
> -		pr_info("Firmware returns DEFER to command %x. Will let it time out...\n",
> -			le16_to_cpu(resp->command));
> +		netdev_info(priv->dev,
> +			    "Firmware returns DEFER to command %x. Will let it time out...\n",
> +			    le16_to_cpu(resp->command));
>  		spin_unlock_irqrestore(&priv->driver_lock, flags);
>  		ret = -1;
>  		goto done;
> @@ -318,28 +318,28 @@ int lbs_process_event(struct lbs_private *priv, u32 event)
>  		lbs_deb_cmd("EVENT: ADHOC beacon lost\n");
>  		break;
>  	case MACREG_INT_CODE_RSSI_LOW:
> -		pr_alert("EVENT: rssi low\n");
> +		netdev_alert(priv->dev, "EVENT: rssi low\n");
>  		break;
>  	case MACREG_INT_CODE_SNR_LOW:
> -		pr_alert("EVENT: snr low\n");
> +		netdev_alert(priv->dev, "EVENT: snr low\n");
>  		break;
>  	case MACREG_INT_CODE_MAX_FAIL:
> -		pr_alert("EVENT: max fail\n");
> +		netdev_alert(priv->dev, "EVENT: max fail\n");
>  		break;
>  	case MACREG_INT_CODE_RSSI_HIGH:
> -		pr_alert("EVENT: rssi high\n");
> +		netdev_alert(priv->dev, "EVENT: rssi high\n");
>  		break;
>  	case MACREG_INT_CODE_SNR_HIGH:
> -		pr_alert("EVENT: snr high\n");
> +		netdev_alert(priv->dev, "EVENT: snr high\n");
>  		break;
>  
>  	case MACREG_INT_CODE_MESH_AUTO_STARTED:
>  		/* Ignore spurious autostart events */
> -		pr_info("EVENT: MESH_AUTO_STARTED (ignoring)\n");
> +		netdev_info(priv->dev, "EVENT: MESH_AUTO_STARTED (ignoring)\n");
>  		break;
>  
>  	default:
> -		pr_alert("EVENT: unknown event id %d\n", event);
> +		netdev_alert(priv->dev, "EVENT: unknown event id %d\n", event);
>  		break;
>  	}
>  
> diff --git a/drivers/net/wireless/libertas/debugfs.c b/drivers/net/wireless/libertas/debugfs.c
> index c179094..f2f65bc 100644
> --- a/drivers/net/wireless/libertas/debugfs.c
> +++ b/drivers/net/wireless/libertas/debugfs.c
> @@ -1,5 +1,3 @@
> -#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> -
>  #include <linux/dcache.h>
>  #include <linux/debugfs.h>
>  #include <linux/delay.h>
> @@ -153,13 +151,14 @@ static ssize_t lbs_host_sleep_write(struct file *file,
>  		ret = lbs_set_host_sleep(priv, 0);
>  	else if (host_sleep == 1) {
>  		if (priv->wol_criteria == EHS_REMOVE_WAKEUP) {
> -			pr_info("wake parameters not configured\n");
> +			netdev_info(priv->dev,
> +				    "wake parameters not configured\n");
>  			ret = -EINVAL;
>  			goto out_unlock;
>  		}
>  		ret = lbs_set_host_sleep(priv, 1);
>  	} else {
> -		pr_err("invalid option\n");
> +		netdev_err(priv->dev, "invalid option\n");
>  		ret = -EINVAL;
>  	}
>  
> diff --git a/drivers/net/wireless/libertas/if_cs.c b/drivers/net/wireless/libertas/if_cs.c
> index eb88d9a..d6f757e 100644
> --- a/drivers/net/wireless/libertas/if_cs.c
> +++ b/drivers/net/wireless/libertas/if_cs.c
> @@ -363,7 +363,7 @@ static int if_cs_send_cmd(struct lbs_private *priv, u8 *buf, u16 nb)
>  		if (status & IF_CS_BIT_COMMAND)
>  			break;
>  		if (++loops > 100) {
> -			pr_err("card not ready for commands\n");
> +			netdev_err(priv->dev, "card not ready for commands\n");
>  			goto done;
>  		}
>  		mdelay(1);
> @@ -433,14 +433,16 @@ static int if_cs_receive_cmdres(struct lbs_private *priv, u8 *data, u32 *len)
>  	/* is hardware ready? */
>  	status = if_cs_read16(priv->card, IF_CS_CARD_STATUS);
>  	if ((status & IF_CS_BIT_RESP) == 0) {
> -		pr_err("no cmd response in card\n");
> +		netdev_err(priv->dev, "no cmd response in card\n");
>  		*len = 0;
>  		goto out;
>  	}
>  
>  	*len = if_cs_read16(priv->card, IF_CS_RESP_LEN);
>  	if ((*len == 0) || (*len > LBS_CMD_BUFFER_SIZE)) {
> -		pr_err("card cmd buffer has invalid # of bytes (%d)\n", *len);
> +		netdev_err(priv->dev,
> +			   "card cmd buffer has invalid # of bytes (%d)\n",
> +			   *len);
>  		goto out;
>  	}
>  
> @@ -474,7 +476,9 @@ static struct sk_buff *if_cs_receive_data(struct lbs_private *priv)
>  
>  	len = if_cs_read16(priv->card, IF_CS_READ_LEN);
>  	if (len == 0 || len > MRVDRV_ETH_RX_PACKET_BUFFER_SIZE) {
> -		pr_err("card data buffer has invalid # of bytes (%d)\n", len);
> +		netdev_err(priv->dev,
> +			   "card data buffer has invalid # of bytes (%d)\n",
> +			   len);
>  		priv->dev->stats.rx_dropped++;
>  		goto dat_err;
>  	}
> @@ -752,7 +756,8 @@ static int if_cs_host_to_card(struct lbs_private *priv,
>  		ret = if_cs_send_cmd(priv, buf, nb);
>  		break;
>  	default:
> -		pr_err("%s: unsupported type %d\n", __func__, type);
> +		netdev_err(priv->dev, "%s: unsupported type %d\n",
> +			   __func__, type);
>  	}
>  
>  	lbs_deb_leave_args(LBS_DEB_CS, "ret %d", ret);
> diff --git a/drivers/net/wireless/libertas/if_sdio.c b/drivers/net/wireless/libertas/if_sdio.c
> index ab86779..a7b5cb0 100644
> --- a/drivers/net/wireless/libertas/if_sdio.c
> +++ b/drivers/net/wireless/libertas/if_sdio.c
> @@ -851,7 +851,7 @@ static int if_sdio_enter_deep_sleep(struct lbs_private *priv)
>  	ret = __lbs_cmd(priv, CMD_802_11_DEEP_SLEEP, &cmd, sizeof(cmd),
>  			lbs_cmd_copyback, (unsigned long) &cmd);
>  	if (ret)
> -		pr_err("DEEP_SLEEP cmd failed\n");
> +		netdev_err(priv->dev, "DEEP_SLEEP cmd failed\n");
>  
>  	mdelay(200);
>  	return ret;
> @@ -867,7 +867,7 @@ static int if_sdio_exit_deep_sleep(struct lbs_private *priv)
>  
>  	sdio_writeb(card->func, HOST_POWER_UP, CONFIGURATION_REG, &ret);
>  	if (ret)
> -		pr_err("sdio_writeb failed!\n");
> +		netdev_err(priv->dev, "sdio_writeb failed!\n");
>  
>  	sdio_release_host(card->func);
>  	lbs_deb_leave_args(LBS_DEB_SDIO, "ret %d", ret);
> @@ -884,7 +884,7 @@ static int if_sdio_reset_deep_sleep_wakeup(struct lbs_private *priv)
>  
>  	sdio_writeb(card->func, 0, CONFIGURATION_REG, &ret);
>  	if (ret)
> -		pr_err("sdio_writeb failed!\n");
> +		netdev_err(priv->dev, "sdio_writeb failed!\n");
>  
>  	sdio_release_host(card->func);
>  	lbs_deb_leave_args(LBS_DEB_SDIO, "ret %d", ret);
> @@ -1103,7 +1103,7 @@ static int if_sdio_probe(struct sdio_func *func,
>  		lbs_deb_sdio("send function INIT command\n");
>  		if (__lbs_cmd(priv, CMD_FUNC_INIT, &cmd, sizeof(cmd),
>  				lbs_cmd_copyback, (unsigned long) &cmd))
> -			pr_alert("CMD_FUNC_INIT cmd failed\n");
> +			netdev_alert(priv->dev, "CMD_FUNC_INIT cmd failed\n");
>  	}
>  
>  	ret = lbs_start_card(priv);
> @@ -1204,19 +1204,20 @@ static int if_sdio_suspend(struct device *dev)
>  
>  	mmc_pm_flag_t flags = sdio_get_host_pm_caps(func);
>  
> -	pr_info("%s: suspend: PM flags = 0x%x\n", sdio_func_id(func), flags);
> +	dev_info(dev, "%s: suspend: PM flags = 0x%x\n",
> +		 sdio_func_id(func), flags);
>  
>  	/* If we aren't being asked to wake on anything, we should bail out
>  	 * and let the SD stack power down the card.
>  	 */
>  	if (card->priv->wol_criteria == EHS_REMOVE_WAKEUP) {
> -		pr_info("Suspend without wake params -- powering down card\n");
> +		dev_info(dev, "Suspend without wake params -- powering down card\n");
>  		return -ENOSYS;
>  	}
>  
>  	if (!(flags & MMC_PM_KEEP_POWER)) {
> -		pr_err("%s: cannot remain alive while host is suspended\n",
> -		       sdio_func_id(func));
> +		dev_err(dev, "%s: cannot remain alive while host is suspended\n",
> +			sdio_func_id(func));
>  		return -ENOSYS;
>  	}
>  
> @@ -1237,7 +1238,7 @@ static int if_sdio_resume(struct device *dev)
>  	struct if_sdio_card *card = sdio_get_drvdata(func);
>  	int ret;
>  
> -	pr_info("%s: resume: we're back\n", sdio_func_id(func));
> +	dev_info(dev, "%s: resume: we're back\n", sdio_func_id(func));
>  
>  	ret = lbs_resume(card->priv);
>  
> diff --git a/drivers/net/wireless/libertas/if_spi.c b/drivers/net/wireless/libertas/if_spi.c
> index bebd9f0..30f21b1 100644
> --- a/drivers/net/wireless/libertas/if_spi.c
> +++ b/drivers/net/wireless/libertas/if_spi.c
> @@ -559,6 +559,7 @@ static int if_spi_prog_main_firmware_check_len(struct if_spi_card *card,
>  static int if_spi_prog_main_firmware(struct if_spi_card *card,
>  					const struct firmware *firmware)
>  {
> +	struct lbs_private *priv = card->priv;
>  	int len, prev_len;
>  	int bytes, crc_err = 0, err = 0;
>  	const u8 *fw;
> @@ -572,8 +573,9 @@ static int if_spi_prog_main_firmware(struct if_spi_card *card,
>  
>  	err = spu_wait_for_u16(card, IF_SPI_SCRATCH_1_REG, 0, 0);
>  	if (err) {
> -		pr_err("%s: timed out waiting for initial scratch reg = 0\n",
> -		       __func__);
> +		netdev_err(priv->dev,
> +			   "%s: timed out waiting for initial scratch reg = 0\n",
> +			   __func__);
>  		goto out;
>  	}
>  
> @@ -589,7 +591,8 @@ static int if_spi_prog_main_firmware(struct if_spi_card *card,
>  		if (bytes < 0) {
>  			/* If there are no more bytes left, we would normally
>  			 * expect to have terminated with len = 0 */
> -			pr_err("Firmware load wants more bytes than we have to offer\n");
> +			netdev_err(priv->dev,
> +				   "Firmware load wants more bytes than we have to offer\n");
>  			break;
>  		}
>  		if (crc_err) {
> @@ -674,12 +677,14 @@ static int if_spi_c2h_cmd(struct if_spi_card *card)
>  	if (err)
>  		goto out;
>  	if (!len) {
> -		pr_err("%s: error: card has no data for host\n", __func__);
> +		netdev_err(priv->dev, "%s: error: card has no data for host\n",
> +			   __func__);
>  		err = -EINVAL;
>  		goto out;
>  	} else if (len > IF_SPI_CMD_BUF_SIZE) {
> -		pr_err("%s: error: response packet too large: %d bytes, but maximum is %d\n",
> -		       __func__, len, IF_SPI_CMD_BUF_SIZE);
> +		netdev_err(priv->dev,
> +			   "%s: error: response packet too large: %d bytes, but maximum is %d\n",
> +			   __func__, len, IF_SPI_CMD_BUF_SIZE);
>  		err = -EINVAL;
>  		goto out;
>  	}
> @@ -700,7 +705,7 @@ static int if_spi_c2h_cmd(struct if_spi_card *card)
>  
>  out:
>  	if (err)
> -		pr_err("%s: err=%d\n", __func__, err);
> +		netdev_err(priv->dev, "%s: err=%d\n", __func__, err);
>  	lbs_deb_leave(LBS_DEB_SPI);
>  	return err;
>  }
> @@ -708,6 +713,7 @@ out:
>  /* Move data from the card to the host */
>  static int if_spi_c2h_data(struct if_spi_card *card)
>  {
> +	struct lbs_private *priv = card->priv;
>  	struct sk_buff *skb;
>  	char *data;
>  	u16 len;
> @@ -720,12 +726,14 @@ static int if_spi_c2h_data(struct if_spi_card *card)
>  	if (err)
>  		goto out;
>  	if (!len) {
> -		pr_err("%s: error: card has no data for host\n", __func__);
> +		netdev_err(priv->dev, "%s: error: card has no data for host\n",
> +			   __func__);
>  		err = -EINVAL;
>  		goto out;
>  	} else if (len > MRVDRV_ETH_RX_PACKET_BUFFER_SIZE) {
> -		pr_err("%s: error: card has %d bytes of data, but our maximum skb size is %zu\n",
> -		       __func__, len, MRVDRV_ETH_RX_PACKET_BUFFER_SIZE);
> +		netdev_err(priv->dev,
> +			   "%s: error: card has %d bytes of data, but our maximum skb size is %zu\n",
> +			   __func__, len, MRVDRV_ETH_RX_PACKET_BUFFER_SIZE);
>  		err = -EINVAL;
>  		goto out;
>  	}
> @@ -756,7 +764,7 @@ free_skb:
>  	dev_kfree_skb(skb);
>  out:
>  	if (err)
> -		pr_err("%s: err=%d\n", __func__, err);
> +		netdev_err(priv->dev, "%s: err=%d\n", __func__, err);
>  	lbs_deb_leave(LBS_DEB_SPI);
>  	return err;
>  }
> @@ -765,6 +773,7 @@ out:
>  static void if_spi_h2c(struct if_spi_card *card,
>  			struct if_spi_packet *packet, int type)
>  {
> +	struct lbs_private *priv = card->priv;
>  	int err = 0;
>  	u16 int_type, port_reg;
>  
> @@ -778,7 +787,8 @@ static void if_spi_h2c(struct if_spi_card *card,
>  		port_reg = IF_SPI_CMD_RDWRPORT_REG;
>  		break;
>  	default:
> -		pr_err("can't transfer buffer of type %d\n", type);
> +		netdev_err(priv->dev, "can't transfer buffer of type %d\n",
> +			   type);
>  		err = -EINVAL;
>  		goto out;
>  	}
> @@ -792,7 +802,7 @@ out:
>  	kfree(packet);
>  
>  	if (err)
> -		pr_err("%s: error %d\n", __func__, err);
> +		netdev_err(priv->dev, "%s: error %d\n", __func__, err);
>  }
>  
>  /* Inform the host about a card event */
> @@ -816,7 +826,7 @@ static void if_spi_e2h(struct if_spi_card *card)
>  	lbs_queue_event(priv, cause & 0xff);
>  out:
>  	if (err)
> -		pr_err("%s: error %d\n", __func__, err);
> +		netdev_err(priv->dev, "%s: error %d\n", __func__, err);
>  }
>  
>  static void if_spi_host_to_card_worker(struct work_struct *work)
> @@ -826,8 +836,10 @@ static void if_spi_host_to_card_worker(struct work_struct *work)
>  	u16 hiStatus;
>  	unsigned long flags;
>  	struct if_spi_packet *packet;
> +	struct lbs_private *priv;
>  
>  	card = container_of(work, struct if_spi_card, packet_work);
> +	priv = card->priv;
>  
>  	lbs_deb_enter(LBS_DEB_SPI);
>  
> @@ -836,7 +848,7 @@ static void if_spi_host_to_card_worker(struct work_struct *work)
>  	err = spu_read_u16(card, IF_SPI_HOST_INT_STATUS_REG,
>  				&hiStatus);
>  	if (err) {
> -		pr_err("I/O error\n");
> +		netdev_err(priv->dev, "I/O error\n");
>  		goto err;
>  	}
>  
> @@ -898,7 +910,7 @@ static void if_spi_host_to_card_worker(struct work_struct *work)
>  
>  err:
>  	if (err)
> -		pr_err("%s: got error %d\n", __func__, err);
> +		netdev_err(priv->dev, "%s: got error %d\n", __func__, err);
>  
>  	lbs_deb_leave(LBS_DEB_SPI);
>  }
> @@ -920,7 +932,8 @@ static int if_spi_host_to_card(struct lbs_private *priv,
>  	lbs_deb_enter_args(LBS_DEB_SPI, "type %d, bytes %d", type, nb);
>  
>  	if (nb == 0) {
> -		pr_err("%s: invalid size requested: %d\n", __func__, nb);
> +		netdev_err(priv->dev, "%s: invalid size requested: %d\n",
> +			   __func__, nb);
>  		err = -EINVAL;
>  		goto out;
>  	}
> @@ -948,7 +961,8 @@ static int if_spi_host_to_card(struct lbs_private *priv,
>  		spin_unlock_irqrestore(&card->buffer_lock, flags);
>  		break;
>  	default:
> -		pr_err("can't transfer buffer of type %d\n", type);
> +		netdev_err(priv->dev, "can't transfer buffer of type %d\n",
> +			   type);
>  		err = -EINVAL;
>  		break;
>  	}
> @@ -981,6 +995,7 @@ static irqreturn_t if_spi_host_interrupt(int irq, void *dev_id)
>  
>  static int if_spi_init_card(struct if_spi_card *card)
>  {
> +	struct lbs_private *priv = card->priv;
>  	struct spi_device *spi = card->spi;
>  	int err, i;
>  	u32 scratch;
> @@ -1009,7 +1024,8 @@ static int if_spi_init_card(struct if_spi_card *card)
>  				break;
>  		}
>  		if (i == ARRAY_SIZE(fw_table)) {
> -			pr_err("Unsupported chip_id: 0x%02x\n", card->card_id);
> +			netdev_err(priv->dev, "Unsupported chip_id: 0x%02x\n",
> +				   card->card_id);
>  			err = -ENODEV;
>  			goto out;
>  		}
> @@ -1018,7 +1034,8 @@ static int if_spi_init_card(struct if_spi_card *card)
>  					card->card_id, &fw_table[0], &helper,
>  					&mainfw);
>  		if (err) {
> -			pr_err("failed to find firmware (%d)\n", err);
> +			netdev_err(priv->dev, "failed to find firmware (%d)\n",
> +				   err);
>  			goto out;
>  		}
>  
> diff --git a/drivers/net/wireless/libertas/if_usb.c b/drivers/net/wireless/libertas/if_usb.c
> index 7260791..63e7e2c 100644
> --- a/drivers/net/wireless/libertas/if_usb.c
> +++ b/drivers/net/wireless/libertas/if_usb.c
> @@ -198,7 +198,7 @@ static void if_usb_setup_firmware(struct lbs_private *priv)
>  	wake_method.hdr.size = cpu_to_le16(sizeof(wake_method));
>  	wake_method.action = cpu_to_le16(CMD_ACT_GET);
>  	if (lbs_cmd_with_response(priv, CMD_802_11_FW_WAKE_METHOD, &wake_method)) {
> -		pr_info("Firmware does not seem to support PS mode\n");
> +		netdev_info(priv->dev, "Firmware does not seem to support PS mode\n");
>  		priv->fwcapinfo &= ~FW_CAPINFO_PS;
>  	} else {
>  		if (le16_to_cpu(wake_method.method) == CMD_WAKE_METHOD_COMMAND_INT) {
> @@ -207,7 +207,8 @@ static void if_usb_setup_firmware(struct lbs_private *priv)
>  			/* The versions which boot up this way don't seem to
>  			   work even if we set it to the command interrupt */
>  			priv->fwcapinfo &= ~FW_CAPINFO_PS;
> -			pr_info("Firmware doesn't wake via command interrupt; disabling PS mode\n");
> +			netdev_info(priv->dev,
> +				    "Firmware doesn't wake via command interrupt; disabling PS mode\n");
>  		}
>  	}
>  }
> @@ -343,10 +344,12 @@ static int if_usb_probe(struct usb_interface *intf,
>  	usb_set_intfdata(intf, cardp);
>  
>  	if (device_create_file(&priv->dev->dev, &dev_attr_lbs_flash_fw))
> -		pr_err("cannot register lbs_flash_fw attribute\n");
> +		netdev_err(priv->dev,
> +			   "cannot register lbs_flash_fw attribute\n");
>  
>  	if (device_create_file(&priv->dev->dev, &dev_attr_lbs_flash_boot2))
> -		pr_err("cannot register lbs_flash_boot2 attribute\n");
> +		netdev_err(priv->dev,
> +			   "cannot register lbs_flash_boot2 attribute\n");
>  
>  	/*
>  	 * EHS_REMOVE_WAKEUP is not supported on all versions of the firmware.
> diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
> index 639461b..84ffafe 100644
> --- a/drivers/net/wireless/libertas/main.c
> +++ b/drivers/net/wireless/libertas/main.c
> @@ -155,7 +155,7 @@ static void lbs_tx_timeout(struct net_device *dev)
>  
>  	lbs_deb_enter(LBS_DEB_TX);
>  
> -	pr_err("tx watch dog timeout\n");
> +	netdev_err(dev, "tx watch dog timeout\n");
>  
>  	dev->trans_start = jiffies; /* prevent tx timeout */
>  
> @@ -464,8 +464,8 @@ static int lbs_thread(void *data)
>  		if (priv->cmd_timed_out && priv->cur_cmd) {
>  			struct cmd_ctrl_node *cmdnode = priv->cur_cmd;
>  
> -			pr_info("Timeout submitting command 0x%04x\n",
> -				le16_to_cpu(cmdnode->cmdbuf->command));
> +			netdev_info(dev, "Timeout submitting command 0x%04x\n",
> +				    le16_to_cpu(cmdnode->cmdbuf->command));
>  			lbs_complete_command(priv, cmdnode, -ETIMEDOUT);
>  			if (priv->reset_card)
>  				priv->reset_card(priv);
> @@ -492,7 +492,8 @@ static int lbs_thread(void *data)
>  				 * after firmware fixes it
>  				 */
>  				priv->psstate = PS_STATE_AWAKE;
> -				pr_alert("ignore PS_SleepConfirm in non-connected state\n");
> +				netdev_alert(dev,
> +					     "ignore PS_SleepConfirm in non-connected state\n");
>  			}
>  		}
>  
> @@ -586,7 +587,8 @@ int lbs_suspend(struct lbs_private *priv)
>  	if (priv->is_deep_sleep) {
>  		ret = lbs_set_deep_sleep(priv, 0);
>  		if (ret) {
> -			pr_err("deep sleep cancellation failed: %d\n", ret);
> +			netdev_err(priv->dev,
> +				   "deep sleep cancellation failed: %d\n", ret);
>  			return ret;
>  		}
>  		priv->deep_sleep_required = 1;
> @@ -619,7 +621,8 @@ int lbs_resume(struct lbs_private *priv)
>  		priv->deep_sleep_required = 0;
>  		ret = lbs_set_deep_sleep(priv, 1);
>  		if (ret)
> -			pr_err("deep sleep activation failed: %d\n", ret);
> +			netdev_err(priv->dev,
> +				   "deep sleep activation failed: %d\n", ret);
>  	}
>  
>  	if (priv->setup_fw_on_resume)
> @@ -645,8 +648,8 @@ static void lbs_cmd_timeout_handler(unsigned long data)
>  	if (!priv->cur_cmd)
>  		goto out;
>  
> -	pr_info("command 0x%04x timed out\n",
> -		le16_to_cpu(priv->cur_cmd->cmdbuf->command));
> +	netdev_info(priv->dev, "command 0x%04x timed out\n",
> +		    le16_to_cpu(priv->cur_cmd->cmdbuf->command));
>  
>  	priv->cmd_timed_out = 1;
>  	wake_up_interruptible(&priv->waitq);
> @@ -961,7 +964,7 @@ int lbs_start_card(struct lbs_private *priv)
>  
>  	lbs_debugfs_init_one(priv, dev);
>  
> -	pr_info("%s: Marvell WLAN 802.11 adapter\n", dev->name);
> +	netdev_info(dev, "Marvell WLAN 802.11 adapter\n");
>  
>  	ret = 0;
>  
> @@ -1088,14 +1091,16 @@ int lbs_get_firmware(struct device *dev, const char *user_helper,
>  	if (user_helper) {
>  		ret = request_firmware(helper, user_helper, dev);
>  		if (ret) {
> -			pr_err("couldn't find helper firmware %s", user_helper);
> +			dev_err(dev, "couldn't find helper firmware %s\n",
> +				user_helper);
>  			goto fail;
>  		}
>  	}
>  	if (user_mainfw) {
>  		ret = request_firmware(mainfw, user_mainfw, dev);
>  		if (ret) {
> -			pr_err("couldn't find main firmware %s", user_mainfw);
> +			dev_err(dev, "couldn't find main firmware %s\n",
> +				user_mainfw);
>  			goto fail;
>  		}
>  	}
> diff --git a/drivers/net/wireless/libertas/mesh.c b/drivers/net/wireless/libertas/mesh.c
> index f7c51cb..f4c4f1c 100644
> --- a/drivers/net/wireless/libertas/mesh.c
> +++ b/drivers/net/wireless/libertas/mesh.c
> @@ -248,7 +248,7 @@ int lbs_init_mesh(struct lbs_private *priv)
>  		lbs_add_mesh(priv);
>  
>  		if (device_create_file(&dev->dev, &dev_attr_lbs_mesh))
> -			pr_err("cannot register lbs_mesh attribute\n");
> +			netdev_err(dev, "cannot register lbs_mesh attribute\n");
>  
>  		ret = 1;
>  	}
> @@ -928,7 +928,7 @@ static ssize_t mesh_id_get(struct device *dev, struct device_attribute *attr,
>  		return ret;
>  
>  	if (defs.meshie.val.mesh_id_len > IEEE80211_MAX_SSID_LEN) {
> -		pr_err("inconsistent mesh ID length\n");
> +		dev_err(dev, "inconsistent mesh ID length\n");
>  		defs.meshie.val.mesh_id_len = IEEE80211_MAX_SSID_LEN;
>  	}
>  
> diff --git a/drivers/net/wireless/libertas/rx.c b/drivers/net/wireless/libertas/rx.c
> index fd045aa..f2ef0ae 100644
> --- a/drivers/net/wireless/libertas/rx.c
> +++ b/drivers/net/wireless/libertas/rx.c
> @@ -251,7 +251,7 @@ static int process_rxed_802_11_packet(struct lbs_private *priv,
>  	/* add space for the new radio header */
>  	if ((skb_headroom(skb) < sizeof(struct rx_radiotap_hdr)) &&
>  	    pskb_expand_head(skb, sizeof(struct rx_radiotap_hdr), 0, GFP_ATOMIC)) {
> -		pr_alert("%s: couldn't pskb_expand_head\n", __func__);
> +		netdev_alert(dev, "%s: couldn't pskb_expand_head\n", __func__);
>  		ret = -ENOMEM;
>  		kfree_skb(skb);
>  		goto done;
