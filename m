From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [04/04] USB: HSO: minor fixes due to code review
Date: Thu, 14 Aug 2008 04:45:18 -0400
Message-ID: <48A3F09E.7070308@pobox.com>
References: <20080808190023.GA2953@kroah.com> <20080808190257.GE2953@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Jari Tenhunen <jari.tenhunen@iki.fi>,
	Olivier Blin <blino@mandriva.com>,
	Andrew Bird <ajb@spheresystems.co.uk>,
	Paul Rolland <rol@witbe.net>,
	Arjan van de Ven <arjan@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36271 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758147AbYHNIpV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2008 04:45:21 -0400
In-Reply-To: <20080808190257.GE2953@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg KH wrote:
> From: Greg Kroah-Hartman <gregkh@suse.de>
> 
> Fix up problems in hso.c driver as pointed out by Andrew.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
> 
> ---
>  drivers/net/usb/hso.c |   43 ++++++++++++++++++++++++-------------------
>  1 file changed, 24 insertions(+), 19 deletions(-)
> 
> --- a/drivers/net/usb/hso.c
> +++ b/drivers/net/usb/hso.c
> @@ -102,8 +102,12 @@
>  
>  #define MAX_RX_URBS			2
>  
> -#define get_serial_by_tty(x)	\
> -	(x ? (struct hso_serial *)x->driver_data : NULL)
> +static inline struct hso_serial *get_serial_by_tty(struct tty_struct *tty)
> +{
> +	if (tty)
> +		return tty->driver_data;
> +	return NULL;
> +}
>  
>  /*****************************************************************************/
>  /* Debugging functions                                                       */
> @@ -294,24 +298,25 @@ static int hso_get_activity(struct hso_d
>  
>  /* #define DEBUG */
>  
> -#define dev2net(x) (x->port_data.dev_net)
> -#define dev2ser(x) (x->port_data.dev_serial)
> +static inline struct hso_net *dev2net(struct hso_device *hso_dev)
> +{
> +	return hso_dev->port_data.dev_net;
> +}
> +
> +static inline struct hso_serial *dev2ser(struct hso_device *hso_dev)
> +{
> +	return hso_dev->port_data.dev_serial;
> +}
>  
>  /* Debugging functions */
>  #ifdef DEBUG
>  static void dbg_dump(int line_count, const char *func_name, unsigned char *buf,
>  		     unsigned int len)
>  {
> -	u8 i = 0;
> -
> -	printk(KERN_DEBUG "[%d:%s]: len %d", line_count, func_name, len);
> +	static char name[255];
>  
> -	for (i = 0; i < len; i++) {
> -		if (!(i % 16))
> -			printk("\n    0x%03x:  ", i);
> -		printk("%02x ", (unsigned char)buf[i]);
> -	}
> -	printk("\n");
> +	sprintf(name, "hso[%d:%s]", line_count, func_name);
> +	print_hex_dump_bytes(name, DUMP_PREFIX_NONE, buf, len);
>  }
>  
>  #define DUMP(buf_, len_)	\
> @@ -528,13 +533,12 @@ static struct hso_serial *get_serial_by_
>  
>  static struct hso_serial *get_serial_by_index(unsigned index)
>  {
> -	struct hso_serial *serial;
> +	struct hso_serial *serial = NULL;
>  	unsigned long flags;
>  
> -	if (!serial_table[index])
> -		return NULL;
>  	spin_lock_irqsave(&serial_table_lock, flags);
> -	serial = dev2ser(serial_table[index]);
> +	if (serial_table[index])
> +		serial = dev2ser(serial_table[index]);
>  	spin_unlock_irqrestore(&serial_table_lock, flags);
>  
>  	return serial;
> @@ -561,6 +565,7 @@ static int get_free_serial_index(void)
>  static void set_serial_by_index(unsigned index, struct hso_serial *serial)
>  {
>  	unsigned long flags;
> +
>  	spin_lock_irqsave(&serial_table_lock, flags);
>  	if (serial)
>  		serial_table[index] = serial->parent;
> @@ -569,7 +574,7 @@ static void set_serial_by_index(unsigned
>  	spin_unlock_irqrestore(&serial_table_lock, flags);
>  }
>  
> -/* log a meaningfull explanation of an USB status */
> +/* log a meaningful explanation of an USB status */
>  static void log_usb_status(int status, const char *function)
>  {
>  	char *explanation;
> @@ -2654,7 +2659,7 @@ static void hso_free_interface(struct us
>  			hso_stop_net_device(network_table[i]);
>  			cancel_work_sync(&network_table[i]->async_put_intf);
>  			cancel_work_sync(&network_table[i]->async_get_intf);
> -			if(rfk)
> +			if (rfk)
>  				rfkill_unregister(rfk);

applied 1-4

