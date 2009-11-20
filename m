From: Dan Williams <dcbw@redhat.com>
Subject: Re: [RFC] p54: software hot-swap eeprom image
Date: Fri, 20 Nov 2009 11:53:06 -0800
Message-ID: <1258746786.26965.83.camel@localhost.localdomain>
References: <200911202027.13284.chunkeey@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Christian Lamparter <chunkeey@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61132 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751986AbZKTTws (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Nov 2009 14:52:48 -0500
In-Reply-To: <200911202027.13284.chunkeey@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-11-20 at 20:27 +0100, Christian Lamparter wrote:
> This (aggregated) patch adds a new sysfs file "eeprom_overwrite"
> which can be used to upload an customized eeprom image to the
> driver during normal operation.
> 
> The old wlanX device will quickly vanish. And if the new EEPROM
> image passes all sanity checks the device will reappear.
> 
> Hopefully, this proves to be an adequate solution for everyone
> with a bad/missing EEPROM data/chip.

Honestly I wonder if this would be better done with ethtool.  There's
already ethtool --eeprom-dump, would it be so hard to do an ethtool
--eeprom-load ?

I can see a number of devices doing this, so in my mind it makes sense
to have a generic facility for this sort of thing.  But then again it's
not so common an operation and its fraught with danger :)  Libertas
could potentially use this, but libertas has *two* EEPROM images that it
might need to update.  So if ethtool did grow --eeprom-load we may want
to account for more than one eeprom image.

What do people think?

Dan

> ---
> there are plenty of bugs left!
> 
> would be nice to hear from p54spi & p54pci folks!
> 
> Regards,
> 	Chr
> ---
> diff --git a/drivers/net/wireless/p54/eeprom.c b/drivers/net/wireless/p54/eeprom.c
> index 8e3818f..e5c94d9 100644
> --- a/drivers/net/wireless/p54/eeprom.c
> +++ b/drivers/net/wireless/p54/eeprom.c
> @@ -121,25 +121,20 @@ static int p54_generate_band(struct ieee80211_hw *dev,
>  			     enum ieee80211_band band)
>  {
>  	struct p54_common *priv = dev->priv;
> -	struct ieee80211_supported_band *tmp, *old;
> +	struct ieee80211_supported_band *old_band, *new_band;
> +	struct ieee80211_channel *tmp, *old_chan, *new_chan;
>  	unsigned int i, j;
> -	int ret = -ENOMEM;
> +	int old_chan_num, ret = 0;
>  
>  	if ((!list->entries) || (!list->band_channel_num[band]))
>  		return -EINVAL;
>  
> -	tmp = kzalloc(sizeof(*tmp), GFP_KERNEL);
> -	if (!tmp)
> -		goto err_out;
> -
> -	tmp->channels = kzalloc(sizeof(struct ieee80211_channel) *
> -				list->band_channel_num[band], GFP_KERNEL);
> -	if (!tmp->channels)
> -		goto err_out;
> -
> -	ret = p54_fill_band_bitrates(dev, tmp, band);
> -	if (ret)
> -		goto err_out;
> +	tmp = kzalloc(sizeof(struct ieee80211_channel) *
> +		list->band_channel_num[band], GFP_KERNEL);
> +	if (!tmp) {
> +		ret = -ENOMEM;
> +		goto out;
> +	}
>  
>  	for (i = 0, j = 0; (j < list->band_channel_num[band]) &&
>  			   (i < list->entries); i++) {
> @@ -161,8 +156,8 @@ static int p54_generate_band(struct ieee80211_hw *dev,
>  			continue;
>  		}
>  
> -		tmp->channels[j].band = list->channels[i].band;
> -		tmp->channels[j].center_freq = list->channels[i].freq;
> +		tmp[j].band = list->channels[i].band;
> +		tmp[j].center_freq = list->channels[i].freq;
>  		j++;
>  	}
>  
> @@ -172,25 +167,60 @@ static int p54_generate_band(struct ieee80211_hw *dev,
>  		       "2 GHz" : "5 GHz");
>  
>  		ret = -ENODATA;
> -		goto err_out;
> +		goto out;
>  	}
>  
> -	tmp->n_channels = j;
> -	old = priv->band_table[band];
> -	priv->band_table[band] = tmp;
> -	if (old) {
> -		kfree(old->channels);
> -		kfree(old);
> +	old_band = priv->band_table[band];
> +	if (old_band) {
> +		old_chan_num = old_band->n_channels;
> +		old_chan = old_band->channels;
> +		old_band->n_channels = 0;
> +		old_band->n_bitrates = 0;
> +	} else {
> +		old_chan_num = 0;
> +		old_chan = NULL;
>  	}
>  
> -	return 0;
> +	if (j < old_chan_num) {
> +		printk(KERN_ERR "%s: Channel list can only be extended.\n",
> +		       wiphy_name(dev->wiphy));
> +		goto out;
> +	}
> +
> +	new_band = krealloc(old_band, sizeof(*new_band), GFP_KERNEL);
> +	if (!new_band) {
> +		printk(KERN_ERR "%s: Unable to modify band table.\n",
> +		       wiphy_name(dev->wiphy));
> +
> +		goto out;
> +	}
> +
> +	new_band->band = band;
> +	new_band->ht_cap.ht_supported = false;
>  
> -err_out:
> -	if (tmp) {
> -		kfree(tmp->channels);
> -		kfree(tmp);
> +	new_chan = krealloc(old_chan, j * sizeof(struct ieee80211_channel),
> +			    GFP_KERNEL);
> +
> +	if (!new_chan) {
> +		printk(KERN_ERR "%s: Unable to modify band channel table.\n",
> +		       wiphy_name(dev->wiphy));
> +
> +		goto out;
>  	}
>  
> +	memcpy(new_chan, tmp, j * sizeof(struct ieee80211_channel));
> +
> +	new_band->channels = new_chan;
> +	new_band->n_channels = j;
> +
> +	ret = p54_fill_band_bitrates(dev, new_band, band);
> +	if (ret)
> +		goto out;
> +
> +	priv->band_table[band] = new_band;
> +
> +out:
> +	kfree(tmp);
>  	return ret;
>  }
>  
> @@ -533,7 +563,19 @@ static struct p54_cal_database *p54_convert_db(struct pda_custom_wrapper *src,
>  	return dst;
>  }
>  
> -int p54_parse_eeprom(struct ieee80211_hw *dev, void *eeprom, int len)
> +static void p54_reset_phydata(struct p54_common *priv)
> +{
> +	memset(&priv->rssical_db, 0, sizeof(priv->rssical_db));
> +	priv->iq_autocal_len = 0;
> +	kfree(priv->output_limit);
> +	kfree(priv->curve_data);
> +	kfree(priv->iq_autocal);
> +	priv->output_limit = NULL;
> +	priv->curve_data = NULL;
> +	priv->iq_autocal = NULL;
> +}
> +
> +int p54_parse_eeprom(struct ieee80211_hw *dev, const void *eeprom, int len)
>  {
>  	struct p54_common *priv = dev->priv;
>  	struct eeprom_pda_wrap *wrap;
> @@ -543,10 +585,14 @@ int p54_parse_eeprom(struct ieee80211_hw *dev, void *eeprom, int len)
>  	int err;
>  	u8 *end = (u8 *)eeprom + len;
>  	u16 synth = 0;
> +	bool has_rssical = false, has_mac = false, has_country = false;
>  
>  	wrap = (struct eeprom_pda_wrap *) eeprom;
>  	entry = (void *)wrap->data + le16_to_cpu(wrap->len);
>  
> +	mutex_lock(&priv->conf_mutex);
> +	p54_reset_phydata(priv);
> +
>  	/* verify that at least the entry length/code fits */
>  	while ((u8 *)entry <= end - sizeof(*entry)) {
>  		entry_len = le16_to_cpu(entry->len);
> @@ -558,21 +604,34 @@ int p54_parse_eeprom(struct ieee80211_hw *dev, void *eeprom, int len)
>  
>  		switch (le16_to_cpu(entry->code)) {
>  		case PDR_MAC_ADDRESS:
> +			if (has_mac)
> +				break;
> +
> +			has_mac = true;
> +
>  			if (data_len != ETH_ALEN)
>  				break;
> +
>  			SET_IEEE80211_PERM_ADDR(dev, entry->data);
>  			break;
> +
>  		case PDR_PRISM_PA_CAL_OUTPUT_POWER_LIMITS:
>  			if (priv->output_limit)
>  				break;
> +
>  			err = p54_convert_output_limits(dev, entry->data,
>  							data_len);
>  			if (err)
>  				goto err;
>  			break;
> +
>  		case PDR_PRISM_PA_CAL_CURVE_DATA: {
>  			struct pda_pa_curve_data *curve_data =
>  				(struct pda_pa_curve_data *)entry->data;
> +
> +			if (priv->curve_data)
> +				break;
> +
>  			if (data_len < sizeof(*curve_data)) {
>  				err = -EINVAL;
>  				goto err;
> @@ -597,7 +656,11 @@ int p54_parse_eeprom(struct ieee80211_hw *dev, void *eeprom, int len)
>  				goto err;
>  			}
>  			break;
> +
>  		case PDR_PRISM_ZIF_TX_IQ_CALIBRATION:
> +			if (priv->iq_autocal)
> +				break;
> +
>  			priv->iq_autocal = kmalloc(data_len, GFP_KERNEL);
>  			if (!priv->iq_autocal) {
>  				err = -ENOMEM;
> @@ -607,11 +670,22 @@ int p54_parse_eeprom(struct ieee80211_hw *dev, void *eeprom, int len)
>  			memcpy(priv->iq_autocal, entry->data, data_len);
>  			priv->iq_autocal_len = data_len / sizeof(struct pda_iq_autocal_entry);
>  			break;
> +
>  		case PDR_DEFAULT_COUNTRY:
> +			if (has_country)
> +				break;
> +
> +			has_country = true;
> +
>  			p54_parse_default_country(dev, entry->data, data_len);
>  			break;
> +
>  		case PDR_INTERFACE_LIST:
>  			tmp = entry->data;
> +
> +			if (synth)
> +				break;
> +
>  			while ((u8 *)tmp < entry->data + data_len) {
>  				struct exp_if *exp_if = tmp;
>  				if (exp_if->if_id == cpu_to_le16(IF_ID_ISL39000))
> @@ -619,22 +693,38 @@ int p54_parse_eeprom(struct ieee80211_hw *dev, void *eeprom, int len)
>  				tmp += sizeof(*exp_if);
>  			}
>  			break;
> +
>  		case PDR_HARDWARE_PLATFORM_COMPONENT_ID:
> +			if (priv->version)
> +				break;
> +
>  			if (data_len < 2)
>  				break;
>  			priv->version = *(u8 *)(entry->data + 1);
>  			break;
> +
>  		case PDR_RSSI_LINEAR_APPROXIMATION:
>  		case PDR_RSSI_LINEAR_APPROXIMATION_DUAL_BAND:
>  		case PDR_RSSI_LINEAR_APPROXIMATION_EXTENDED:
> +			if (has_rssical)
> +				break;
> +
> +			has_rssical = true;
> +
>  			p54_parse_rssical(dev, entry->data, data_len,
>  					  le16_to_cpu(entry->code));
>  			break;
> +
>  		case PDR_RSSI_LINEAR_APPROXIMATION_CUSTOM: {
>  			__le16 *src = (void *) entry->data;
>  			s16 *dst = (void *) &priv->rssical_db;
>  			int i;
>  
> +			if (has_rssical)
> +				break;
> +
> +			has_rssical = true;
> +
>  			if (data_len != sizeof(priv->rssical_db)) {
>  				err = -EINVAL;
>  				goto err;
> @@ -644,24 +734,30 @@ int p54_parse_eeprom(struct ieee80211_hw *dev, void *eeprom, int len)
>  				*(dst++) = (s16) le16_to_cpu(*(src++));
>  			}
>  			break;
> +
>  		case PDR_PRISM_PA_CAL_OUTPUT_POWER_LIMITS_CUSTOM: {
>  			struct pda_custom_wrapper *pda = (void *) entry->data;
>  			if (priv->output_limit || data_len < sizeof(*pda))
>  				break;
> +
>  			priv->output_limit = p54_convert_db(pda, data_len);
>  			}
>  			break;
> +
>  		case PDR_PRISM_PA_CAL_CURVE_DATA_CUSTOM: {
>  			struct pda_custom_wrapper *pda = (void *) entry->data;
>  			if (priv->curve_data || data_len < sizeof(*pda))
>  				break;
> +
>  			priv->curve_data = p54_convert_db(pda, data_len);
>  			}
>  			break;
> +
>  		case PDR_END:
>  			/* make it overrun */
>  			entry_len = len;
>  			break;
> +
>  		default:
>  			break;
>  		}
> @@ -670,7 +766,11 @@ int p54_parse_eeprom(struct ieee80211_hw *dev, void *eeprom, int len)
>  	}
>  
>  	if (!synth || !priv->iq_autocal || !priv->output_limit ||
> -	    !priv->curve_data) {
> +	    !priv->curve_data || !has_rssical) {
> +		printk(KERN_INFO "%d %p %p %p %d\n",
> +			synth, priv->iq_autocal, priv->output_limit,
> +			priv->curve_data, has_rssical);
> +
>  		printk(KERN_ERR "%s: not all required entries found in eeprom!\n",
>  			wiphy_name(dev->wiphy));
>  		err = -EINVAL;
> @@ -708,18 +808,18 @@ int p54_parse_eeprom(struct ieee80211_hw *dev, void *eeprom, int len)
>  		wiphy_name(dev->wiphy),	dev->wiphy->perm_addr, priv->version,
>  		p54_rf_chips[priv->rxhw]);
>  
> +	mutex_unlock(&priv->conf_mutex);
> +
>  	return 0;
>  
>  err:
> -	kfree(priv->iq_autocal);
> -	kfree(priv->output_limit);
> -	kfree(priv->curve_data);
> -	priv->iq_autocal = NULL;
> -	priv->output_limit = NULL;
> -	priv->curve_data = NULL;
> +	p54_reset_phydata(priv);
>  
>  	printk(KERN_ERR "%s: eeprom parse failed!\n",
>  		wiphy_name(dev->wiphy));
> +
> +	mutex_unlock(&priv->conf_mutex);
> +
>  	return err;
>  }
>  EXPORT_SYMBOL_GPL(p54_parse_eeprom);
> @@ -753,8 +853,39 @@ int p54_read_eeprom(struct ieee80211_hw *dev)
>  	}
>  
>  	ret = p54_parse_eeprom(dev, eeprom, offset);
> +
>  free:
>  	kfree(eeprom);
>  	return ret;
>  }
>  EXPORT_SYMBOL_GPL(p54_read_eeprom);
> +
> +ssize_t p54_overwrite_eeprom(struct ieee80211_hw *dev,
> +			     const char *buf, size_t len)
> +{
> +	struct p54_common *priv = dev->priv;
> +	int err;
> +
> +	if (len < 64 || len > 0x2020)
> +		return -EINVAL;
> +
> +	mutex_lock(&priv->sysfs_mutex);
> +	p54_unregister_common(dev);
> +
> +	err = p54_parse_eeprom(dev, buf, len);
> +	if (err)
> +		goto out;
> +
> +	err = p54_register_common(dev, priv->pdev);
> +	if (err)
> +		goto out;
> +
> +out:
> +
> +	if (err)
> +		dev_err(priv->pdev, "failed to (re)-register device.\n");
> +
> +	mutex_unlock(&priv->sysfs_mutex);
> +	return (err) ? err : len;
> +}
> +EXPORT_SYMBOL_GPL(p54_overwrite_eeprom);
> diff --git a/drivers/net/wireless/p54/main.c b/drivers/net/wireless/p54/main.c
> index 18012db..e1395d4 100644
> --- a/drivers/net/wireless/p54/main.c
> +++ b/drivers/net/wireless/p54/main.c
> @@ -582,6 +582,7 @@ struct ieee80211_hw *p54_init_common(size_t priv_data_len)
>  	dev->wiphy->flags &= ~WIPHY_FLAG_PS_ON_BY_DEFAULT;
>  
>  	mutex_init(&priv->conf_mutex);
> +	mutex_init(&priv->sysfs_mutex);
>  	mutex_init(&priv->eeprom_mutex);
>  	init_completion(&priv->eeprom_comp);
>  	init_completion(&priv->beacon_comp);
> @@ -596,6 +597,9 @@ int p54_register_common(struct ieee80211_hw *dev, struct device *pdev)
>  	struct p54_common *priv = dev->priv;
>  	int err;
>  
> +	if (priv->registered)
> +		return -EBUSY;
> +
>  	err = ieee80211_register_hw(dev);
>  	if (err) {
>  		dev_err(pdev, "Cannot register device (%d).\n", err);
> @@ -607,8 +611,9 @@ int p54_register_common(struct ieee80211_hw *dev, struct device *pdev)
>  	if (err)
>  		return err;
>  #endif /* CONFIG_P54_LEDS */
> -
> +	priv->pdev = pdev;
>  	dev_info(pdev, "is registered as '%s'\n", wiphy_name(dev->wiphy));
> +	priv->registered = true;
>  	return 0;
>  }
>  EXPORT_SYMBOL_GPL(p54_register_common);
> @@ -618,6 +623,11 @@ void p54_free_common(struct ieee80211_hw *dev)
>  	struct p54_common *priv = dev->priv;
>  	unsigned int i;
>  
> +	BUG_ON(priv->registered);
> +
> +	mutex_destroy(&priv->conf_mutex);
> +	mutex_destroy(&priv->eeprom_mutex);
> +
>  	for (i = 0; i < IEEE80211_NUM_BANDS; i++)
>  		kfree(priv->band_table[i]);
>  
> @@ -637,12 +647,14 @@ void p54_unregister_common(struct ieee80211_hw *dev)
>  {
>  	struct p54_common *priv = dev->priv;
>  
> +	if (!priv->registered)
> +		return ;
> +
>  #ifdef CONFIG_P54_LEDS
>  	p54_unregister_leds(priv);
>  #endif /* CONFIG_P54_LEDS */
>  
> -	ieee80211_unregister_hw(dev);
> -	mutex_destroy(&priv->conf_mutex);
> -	mutex_destroy(&priv->eeprom_mutex);
> +	ieee80211_unregister_hw(priv->hw);
> +	priv->registered = false;
>  }
>  EXPORT_SYMBOL_GPL(p54_unregister_common);
> diff --git a/drivers/net/wireless/p54/p54.h b/drivers/net/wireless/p54/p54.h
> index 1afc394..3e097e0 100644
> --- a/drivers/net/wireless/p54/p54.h
> +++ b/drivers/net/wireless/p54/p54.h
> @@ -159,6 +159,7 @@ struct p54_led_dev {
>  
>  struct p54_common {
>  	struct ieee80211_hw *hw;
> +	struct device *pdev;
>  	struct ieee80211_vif *vif;
>  	void (*tx)(struct ieee80211_hw *dev, struct sk_buff *skb);
>  	int (*open)(struct ieee80211_hw *dev);
> @@ -166,6 +167,7 @@ struct p54_common {
>  	struct sk_buff_head tx_pending;
>  	struct sk_buff_head tx_queue;
>  	struct mutex conf_mutex;
> +	bool registered;
>  
>  	/* memory management (as seen by the firmware) */
>  	u32 rx_start;
> @@ -233,14 +235,17 @@ struct p54_common {
>  	void *eeprom;
>  	struct completion eeprom_comp;
>  	struct mutex eeprom_mutex;
> +	struct mutex sysfs_mutex;
>  };
>  
>  /* interfaces for the drivers */
>  int p54_rx(struct ieee80211_hw *dev, struct sk_buff *skb);
>  void p54_free_skb(struct ieee80211_hw *dev, struct sk_buff *skb);
>  int p54_parse_firmware(struct ieee80211_hw *dev, const struct firmware *fw);
> -int p54_parse_eeprom(struct ieee80211_hw *dev, void *eeprom, int len);
> +int p54_parse_eeprom(struct ieee80211_hw *dev, const void *eeprom, int len);
>  int p54_read_eeprom(struct ieee80211_hw *dev);
> +ssize_t p54_overwrite_eeprom(struct ieee80211_hw *dev,
> +			    const char *eeprom, size_t len);
>  
>  struct ieee80211_hw *p54_init_common(size_t priv_data_len);
>  int p54_register_common(struct ieee80211_hw *dev, struct device *pdev);
> diff --git a/drivers/net/wireless/p54/p54pci.c b/drivers/net/wireless/p54/p54pci.c
> index e3a4c90..b8040e4 100644
> --- a/drivers/net/wireless/p54/p54pci.c
> +++ b/drivers/net/wireless/p54/p54pci.c
> @@ -466,6 +466,18 @@ static int p54p_open(struct ieee80211_hw *dev)
>  	return 0;
>  }
>  
> +static ssize_t p54p_sysfs_overwrite_eeprom(struct device *dev,
> +					   struct device_attribute *attr,
> +					   const char *buf, size_t count)
> +{
> +	struct p54p_priv *priv = dev_get_drvdata(dev);
> +
> +	return p54_overwrite_eeprom(priv->common.hw, buf, count);
> +}
> +
> +static DEVICE_ATTR(eeprom_overwrite, S_IWUSR,
> +		   NULL, p54p_sysfs_overwrite_eeprom);
> +
>  static int __devinit p54p_probe(struct pci_dev *pdev,
>  				const struct pci_device_id *id)
>  {
> @@ -561,6 +573,13 @@ static int __devinit p54p_probe(struct pci_dev *pdev,
>  	if (err)
>  		goto err_free_common;
>  
> +	err = device_create_file(&pdev->dev, &dev_attr_eeprom_overwrite);
> +	if (err < 0) {
> +		dev_err(&pdev->dev, "failed to create sysfs file "
> +				    "eeprom_overwrite.\n");
> +		goto err_free_common;
> +	}
> +
>  	return 0;
>  
>   err_free_common:
> @@ -591,6 +610,8 @@ static void __devexit p54p_remove(struct pci_dev *pdev)
>  		return;
>  
>  	p54_unregister_common(dev);
> +	device_remove_file(&pdev->dev, &dev_attr_eeprom_overwrite);
> +
>  	priv = dev->priv;
>  	release_firmware(priv->firmware);
>  	pci_free_consistent(pdev, sizeof(*priv->ring_control),
> diff --git a/drivers/net/wireless/p54/p54spi.c b/drivers/net/wireless/p54/p54spi.c
> index afd26bf..6fb0863 100644
> --- a/drivers/net/wireless/p54/p54spi.c
> +++ b/drivers/net/wireless/p54/p54spi.c
> @@ -592,6 +592,18 @@ static void p54spi_op_stop(struct ieee80211_hw *dev)
>  	mutex_unlock(&priv->mutex);
>  }
>  
> +static ssize_t p54s_sysfs_overwrite_eeprom(struct device *dev,
> +					   struct device_attribute *attr,
> +					   const char *buf, size_t count)
> +{
> +	struct p54s_priv *priv = dev_get_drvdata(dev);
> +
> +	return p54_overwrite_eeprom(priv->common.hw, buf, count);
> +}
> +
> +static DEVICE_ATTR(eeprom_overwrite, S_IWUSR,
> +		   NULL, p54s_sysfs_overwrite_eeprom);
> +
>  static int __devinit p54spi_probe(struct spi_device *spi)
>  {
>  	struct p54s_priv *priv = NULL;
> @@ -667,7 +679,9 @@ static int __devinit p54spi_probe(struct spi_device *spi)
>  	if (ret)
>  		goto err_free_common;
>  
> -	return 0;
> +        ret = device_create_file(&spi->dev, &dev_attr_eeprom_overwrite);
> +
> +	return ret;
>  
>  err_free_common:
>  	p54_free_common(priv->hw);
> @@ -680,6 +694,9 @@ static int __devexit p54spi_remove(struct spi_device *spi)
>  
>  	p54_unregister_common(priv->hw);
>  
> +	device_remove_file(&spi->dev, &dev_attr_eeprom_overwrite);
> +	dev_set_drvdata(&spi->dev, NULL);
> +
>  	free_irq(gpio_to_irq(p54spi_gpio_irq), spi);
>  
>  	gpio_free(p54spi_gpio_power);
> diff --git a/drivers/net/wireless/p54/p54usb.c b/drivers/net/wireless/p54/p54usb.c
> index 92af9b9..be699d6 100644
> --- a/drivers/net/wireless/p54/p54usb.c
> +++ b/drivers/net/wireless/p54/p54usb.c
> @@ -874,6 +874,19 @@ static void p54u_stop(struct ieee80211_hw *dev)
>  	return;
>  }
>  
> +static ssize_t p54u_sysfs_overwrite_eeprom(struct device *dev,
> +					   struct device_attribute *attr,
> +					   const char *buf, size_t count)
> +{
> +        struct ieee80211_hw *hw = (struct ieee80211_hw *)
> +                usb_get_intfdata(to_usb_interface(dev));
> +
> +	return p54_overwrite_eeprom(hw, buf, count);
> +}
> +
> +static DEVICE_ATTR(eeprom_overwrite, S_IWUSR,
> +                   NULL, p54u_sysfs_overwrite_eeprom);
> +
>  static int __devinit p54u_probe(struct usb_interface *intf,
>  				const struct usb_device_id *id)
>  {
> @@ -959,7 +972,9 @@ static int __devinit p54u_probe(struct usb_interface *intf,
>  	if (err)
>  		goto err_free_fw;
>  
> -	return 0;
> +	err = device_create_file(&intf->dev, &dev_attr_eeprom_overwrite);
> +
> +	return err;
>  
>  err_free_fw:
>  	release_firmware(priv->fw);
> @@ -982,6 +997,9 @@ static void __devexit p54u_disconnect(struct usb_interface *intf)
>  	p54_unregister_common(dev);
>  
>  	priv = dev->priv;
> +	device_remove_file(&intf->dev, &dev_attr_eeprom_overwrite); 
> +
> +	usb_set_intfdata(intf, NULL);
>  	usb_put_dev(interface_to_usbdev(intf));
>  	release_firmware(priv->fw);
>  	p54_free_common(dev);
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

