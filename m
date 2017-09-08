From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 3/5] Add KSZ8795 switch driver
Date: Fri, 8 Sep 2017 20:32:27 +0200
Message-ID: <20170908183227.GJ25219@lunn.ch>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121A87@CHN-SV-EXMX02.mchp-main.com>
 <20170908091856.GB17738@amd>
 <93AF473E2DA327428DE3D46B72B1E9FD41121E3D@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pavel@ucw.cz, muvarov@gmail.com, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Woojung.Huh@microchip.com
To: Tristram.Ha@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:33511 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756210AbdIHScc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 8 Sep 2017 14:32:32 -0400
Content-Disposition: inline
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD41121E3D@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > > @@ -0,0 +1,2066 @@
> > > +/*
> > > + * Microchip KSZ8795 switch driver
> > > + *
> > > + * Copyright (C) 2017 Microchip Technology Inc.
> > > + *	Tristram Ha <Tristram.Ha@microchip.com>
> > > + *
> > > + * Permission to use, copy, modify, and/or distribute this software for any
> > > + * purpose with or without fee is hereby granted, provided that the above
> > > + * copyright notice and this permission notice appear in all copies.
> > > + *
> > > + * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
> > WARRANTIES
> > > + * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES
> > OF
> > > + * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE
> > LIABLE FOR
> > > + * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY
> > DAMAGES
> > > + * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER
> > IN AN
> > > + * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,
> > ARISING OUT OF
> > > + * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
> > > + */
> > 
> > This is not exactly GPL, right? But tagging below says it is
> > GPL. Please fix one.
> > 
> 
> This boilerplate paragraph was copied from the KSZ9477 driver, although I did
> wonder why this was used.

Hi Tristram

Please can you talk to your legal people and see if this can be
replaced with the standard GPL text?

> > > +	for (timeout = 1; timeout > 0; timeout--) {
> > > +		ksz_read8(dev, REG_IND_MIB_CHECK, &check);
> > > +
> > > +		if (check & MIB_COUNTER_VALID) {
> > > +			ksz_read32(dev, REG_IND_DATA_LO, &data);
> > > +			if (addr < 2) {
> > > +				u64 total;
> > > +
> > > +				total = check & MIB_TOTAL_BYTES_H;
> > > +				total <<= 32;
> > > +				*cnt += total;
> > > +				*cnt += data;
> > > +				if (check & MIB_COUNTER_OVERFLOW) {
> > > +					total = MIB_TOTAL_BYTES_H + 1;
> > > +					total <<= 32;
> > > +					*cnt += total;
> > > +				}
> > > +			} else {
> > > +				if (check & MIB_COUNTER_OVERFLOW)
> > > +					*cnt += MIB_PACKET_DROPPED + 1;
> > > +				*cnt += data & MIB_PACKET_DROPPED;
> > > +			}
> > > +			break;
> > > +		}
> > > +	}
> > 
> > Why do you need a loop here? This is quite strange code. (And you have
> > similar strangeness elsewhere. Please fix.)
> > 
> 
> The MIB_COUNTER_VALID bit may be invalid on first read, although in slow
> SPI speed it never happens.  The timeout value should be increased to 2.

Maybe timeout is the wrong name? There is nothing to do with time
here.
 
> > > +static int valid_dyn_entry(struct ksz_device *dev, u8 *data)
> > > +{
> > > +	int timeout = 100;
> > > +
> > > +	do {
> > > +		ksz_read8(dev, REG_IND_DATA_CHECK, data);
> > > +		timeout--;
> > > +	} while ((*data & DYNAMIC_MAC_TABLE_NOT_READY) && timeout);
> > > +
> > > +	/* Entry is not ready for accessing. */
> > > +	if (*data & DYNAMIC_MAC_TABLE_NOT_READY) {
> > > +		return 1;
> > > +	/* Entry is ready for accessing. */
> > > +	} else {
> > > +		ksz_read8(dev, REG_IND_DATA_8, data);
> > > +
> > > +		/* There is no valid entry in the table. */
> > > +		if (*data & DYNAMIC_MAC_TABLE_MAC_EMPTY)
> > > +			return 2;
> > > +	}
> > > +	return 0;
> > > +}
> > 
> > Normal calling convention is 0 / -ERROR, not 0,1,2.
> >
> 
> This is an internal function that is not returning any error.  It just reports
> different conditions so the calling function decides what to do.

Still, best practice is to use standard error codes.
  
    Andrew
