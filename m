From: Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: Re: [PATCH 3/7] ath9k: Add support for reading the EEPROM data using the nvmem API
Date: Fri, 24 Mar 2017 17:24:38 +0100
Message-ID: <4828897.dR6pcKhMJ3@debian64>
References: <1489439116-4233-1-git-send-email-albeu@free.fr> <1609202.bQK0rlNN3Y@debian64> <20170323154328.4bb5db44@avionic-0020>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: QCA ath9k Development <ath9k-devel-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
        John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, chrisrblake93-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Alban <albeu-GANU6spQydw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170323154328.4bb5db44@avionic-0020>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday, March 23, 2017 3:43:28 PM CET Alban wrote:
> On Tue, 14 Mar 2017 00:53:55 +0100
> Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org> wrote:
> 
> > On Monday, March 13, 2017 10:05:11 PM CET Alban wrote:
> > > Currently SoC platforms use a firmware request to get the EEPROM data.
> > > This is mostly a hack and rely on using a user-helper scripts which is
> > > deprecated. A nicer alternative is to use the nvmem API which was
> > > designed for this kind of task.
> > > 
> > > Furthermore we let CONFIG_ATH9K_AHB select CONFIG_NVMEM as such
> > > devices will generally use this method for loading the EEPROM data.
> > > 
> > > Signed-off-by: Alban <albeu-GANU6spQydw@public.gmane.org>
> > > ---
> > > @@ -654,6 +656,25 @@ static int ath9k_init_softc(u16 devid, struct ath_softc *sc,
> > >  	if (ret)
> > >  		return ret;
> > >  
> > > +	/* If the EEPROM hasn't been retrieved via firmware request
> > > +	 * use the nvmem API insted.
> > > +	 */
> > > +	if (!ah->eeprom_blob) {
> > > +		struct nvmem_cell *eeprom_cell;
> > > +
> > > +		eeprom_cell = nvmem_cell_get(ah->dev, "eeprom");
> > > +		if (!IS_ERR(eeprom_cell)) {
> > > +			ah->eeprom_data = nvmem_cell_read(
> > > +				eeprom_cell, &ah->eeprom_size);
> > > +			nvmem_cell_put(eeprom_cell);
> > > +
> > > +			if (IS_ERR(ah->eeprom_data)) {
> > > +				dev_err(ah->dev, "failed to read eeprom");
> > > +				return PTR_ERR(ah->eeprom_data);
> > > +			}
> > > +		}
> > > +	}
> > > +
> > >  	if (ath9k_led_active_high != -1)
> > >  		ah->config.led_active_high = ath9k_led_active_high == 1;
> > >    
> > Are you sure this works with AR93XX SoCs that have the calibration data
> > in the OTP?
> 
> I only tested this on an ar9132 platform, so it might well be that a
> few things are missing for the newer SoC. However this shouldn't break
> anything existing as a platform needs to define an nvmem cell on the
> athk9 device for this code to be used a all.

Yes, I looked at it.
+		eeprom_cell = nvmem_cell_get(ah->dev, "eeprom");
+		if (!IS_ERR(eeprom_cell)) {
+			...
+		}
So if there's a error with the "eeprom" nvmem property,
(i.e.: it's not present) the driver should works as before.

Thanks,
Christian
