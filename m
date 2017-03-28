From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH RFC v4 06/10] net: qualcomm: make qca_common a separate
 kernel module
Date: Tue, 28 Mar 2017 12:18:57 -0500
Message-ID: <1490721537.4915.1.camel@redhat.com>
References: <1490621848-24828-1-git-send-email-stefan.wahren@i2se.com>
         <1490621848-24828-7-git-send-email-stefan.wahren@i2se.com>
         <1490629444.2719.3.camel@redhat.com>
         <d90f8e33-8b86-2cf7-145b-b15997e152a7@i2se.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>,
        Marcel Holtmann <marcel@holtmann.org>,
        Sebastian Reichel <sre@kernel.org>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-serial@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Stefan Wahren <stefan.wahren@i2se.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d90f8e33-8b86-2cf7-145b-b15997e152a7@i2se.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-03-28 at 18:24 +0200, Stefan Wahren wrote:
> Am 27.03.2017 um 17:44 schrieb Dan Williams:
> > On Mon, 2017-03-27 at 15:37 +0200, Stefan Wahren wrote:
> > > In order to share common functions between QCA7000 SPI and UART
> > > protocol
> > > driver the qca_common needs to be a separate kernel module.
> > 
> > Maybe "qca_eth_common"?  There are many things Qualcomm, slightly
> > fewer
> > things Qualcomm Atheros, and "qca_common" isn't very descriptive.
> 
> Since it is a Homeplug powerline chip which doesn't have any physical
> connection to Ethernet only on protocol level, i wouldn't use eth in
> the
> module name.
> 
> The code is very specific to the QCA7000, so how about
> "qca_7k_common"?

Sure; I just saw it was under drivers/net/ethernet, which kinda means
it's ethernet-related...  But 7k common is fine.

Dan

> > 
> > Dan
> > 
> > > Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
> > > ---
> > >  drivers/net/ethernet/qualcomm/Kconfig      |  8 +++++++-
> > >  drivers/net/ethernet/qualcomm/Makefile     |  5 +++--
> > >  drivers/net/ethernet/qualcomm/qca_common.c | 10 ++++++++++
> > >  3 files changed, 20 insertions(+), 3 deletions(-)
> > > 
> > > diff --git a/drivers/net/ethernet/qualcomm/Kconfig
> > > b/drivers/net/ethernet/qualcomm/Kconfig
> > > index d7720bf..b4c369d 100644
> > > --- a/drivers/net/ethernet/qualcomm/Kconfig
> > > +++ b/drivers/net/ethernet/qualcomm/Kconfig
> > > @@ -16,7 +16,13 @@ config NET_VENDOR_QUALCOMM
> > >  if NET_VENDOR_QUALCOMM
> > >  
> > >  config QCA7000
> > > -	tristate "Qualcomm Atheros QCA7000 support"
> > > +	tristate
> > > +	help
> > > +	  This enables support for the Qualcomm Atheros QCA7000.
> > > +
> > > +config QCA7000_SPI
> > > +	tristate "Qualcomm Atheros QCA7000 SPI support"
> > > +	select QCA7000
> > >  	depends on SPI_MASTER && OF
> > >  	---help---
> > >  	  This SPI protocol driver supports the Qualcomm Atheros
> > > QCA7000.
> > > diff --git a/drivers/net/ethernet/qualcomm/Makefile
> > > b/drivers/net/ethernet/qualcomm/Makefile
> > > index 8080570..00d8729 100644
> > > --- a/drivers/net/ethernet/qualcomm/Makefile
> > > +++ b/drivers/net/ethernet/qualcomm/Makefile
> > > @@ -2,7 +2,8 @@
> > >  # Makefile for the Qualcomm network device drivers.
> > >  #
> > >  
> > > -obj-$(CONFIG_QCA7000) += qcaspi.o
> > > -qcaspi-objs := qca_spi.o qca_common.o qca_7k.o qca_debug.o
> > > +obj-$(CONFIG_QCA7000) += qca_common.o
> > > +obj-$(CONFIG_QCA7000_SPI) += qcaspi.o
> > > +qcaspi-objs := qca_7k.o qca_debug.o qca_spi.o
> > >  
> > >  obj-y += emac/
> > > diff --git a/drivers/net/ethernet/qualcomm/qca_common.c
> > > b/drivers/net/ethernet/qualcomm/qca_common.c
> > > index d930524..f2c9e76 100644
> > > --- a/drivers/net/ethernet/qualcomm/qca_common.c
> > > +++ b/drivers/net/ethernet/qualcomm/qca_common.c
> > > @@ -21,7 +21,9 @@
> > >   *   by an atheros frame while transmitted over a serial
> > > channel;
> > >   */
> > >  
> > > +#include <linux/init.h>
> > >  #include <linux/kernel.h>
> > > +#include <linux/module.h>
> > >  
> > >  #include "qca_common.h"
> > >  
> > > @@ -46,6 +48,7 @@ qcafrm_create_header(u8 *buf, u16 length)
> > >  
> > >  	return QCAFRM_HEADER_LEN;
> > >  }
> > > +EXPORT_SYMBOL_GPL(qcafrm_create_header);
> > >  
> > >  u16
> > >  qcafrm_create_footer(u8 *buf)
> > > @@ -57,6 +60,7 @@ qcafrm_create_footer(u8 *buf)
> > >  	buf[1] = 0x55;
> > >  	return QCAFRM_FOOTER_LEN;
> > >  }
> > > +EXPORT_SYMBOL_GPL(qcafrm_create_footer);
> > >  
> > >  /*   Gather received bytes and try to extract a full ethernet
> > > frame
> > > by
> > >   *   following a simple state machine.
> > > @@ -154,3 +158,9 @@ qcafrm_fsm_decode(struct qcafrm_handle
> > > *handle,
> > > u8 *buf, u16 buf_len, u8 recv_by
> > >  
> > >  	return ret;
> > >  }
> > > +EXPORT_SYMBOL_GPL(qcafrm_fsm_decode);
> > > +
> > > +MODULE_DESCRIPTION("Qualcomm Atheros Common");
> > > +MODULE_AUTHOR("Qualcomm Atheros Communications");
> > > +MODULE_AUTHOR("Stefan Wahren <stefan.wahren@i2se.com>");
> > > +MODULE_LICENSE("Dual BSD/GPL");
> 
> 
> *** Diese E-Mail ist allein für den bezeichneten Adressaten bestimmt.
> Sie kann rechtlich vertrauliche Informationen enthalten. Wenn Sie
> diese E-Mail irrtümlich erhalten haben, informieren Sie bitte
> unverzüglich den Absender per E-Mail und löschen Sie diese E-Mail von
> Ihrem Computer, ohne Kopien anzufertigen.
> Vielen Dank. ***
> 
> *** This email is for the exclusive use of the addressee. It may
> contain legally privileged information. If you have received this
> message in error, please notify the sender by email immediately and
> delete the message from your computer without making any copies.
> Thank you. ***
> 
