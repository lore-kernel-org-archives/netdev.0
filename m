From: Christian Lamparter <chunkeey@googlemail.com>
Subject: Re: [PATCH 3/7] ath9k: Add support for reading the EEPROM data using the nvmem API
Date: Tue, 14 Mar 2017 00:53:55 +0100
Message-ID: <1609202.bQK0rlNN3Y@debian64>
References: <1489439116-4233-1-git-send-email-albeu@free.fr> <1489439116-4233-3-git-send-email-albeu@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
        John Crispin <john@phrozen.org>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, chrisrblake93@gmail.com
To: Alban <albeu@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:35941 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750929AbdCMXx7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 19:53:59 -0400
In-Reply-To: <1489439116-4233-3-git-send-email-albeu@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, March 13, 2017 10:05:11 PM CET Alban wrote:
> Currently SoC platforms use a firmware request to get the EEPROM data.
> This is mostly a hack and rely on using a user-helper scripts which is
> deprecated. A nicer alternative is to use the nvmem API which was
> designed for this kind of task.
> 
> Furthermore we let CONFIG_ATH9K_AHB select CONFIG_NVMEM as such
> devices will generally use this method for loading the EEPROM data.
> 
> Signed-off-by: Alban <albeu@free.fr>
> ---
> @@ -654,6 +656,25 @@ static int ath9k_init_softc(u16 devid, struct ath_softc *sc,
>  	if (ret)
>  		return ret;
>  
> +	/* If the EEPROM hasn't been retrieved via firmware request
> +	 * use the nvmem API insted.
> +	 */
> +	if (!ah->eeprom_blob) {
> +		struct nvmem_cell *eeprom_cell;
> +
> +		eeprom_cell = nvmem_cell_get(ah->dev, "eeprom");
> +		if (!IS_ERR(eeprom_cell)) {
> +			ah->eeprom_data = nvmem_cell_read(
> +				eeprom_cell, &ah->eeprom_size);
> +			nvmem_cell_put(eeprom_cell);
> +
> +			if (IS_ERR(ah->eeprom_data)) {
> +				dev_err(ah->dev, "failed to read eeprom");
> +				return PTR_ERR(ah->eeprom_data);
> +			}
> +		}
> +	}
> +
>  	if (ath9k_led_active_high != -1)
>  		ah->config.led_active_high = ath9k_led_active_high == 1;
>  
Are you sure this works with AR93XX SoCs that have the calibration data
in the OTP?

I've added Chris to the CC, since he has a HiveAP 121 that has this
configuration, so he can test, whenever this is a problem or not.

But from what I can tell, devices with the calibration data in the
OTP would fail now. This is because the OTP is done by ath9k_hw_init()
which hasn't run yet (it's a bit further down the road in the same
function though). 

Note: the OTP doesn't store the whole caldata. Just a few parts.
A temporary "eeprom" gets constructed with the help of the 
ar9300_eep_templates in ar9003_eeprom.c's
ar9300_eeprom_restore_internal(). But from what I don't think, 
that the eeprom_blob is constructed/set by the functions in
ar9003_eeprom.

I think this will require an additional property like
qca,calibration-in-otp. What's your opinion?

Thanks,
Christian
