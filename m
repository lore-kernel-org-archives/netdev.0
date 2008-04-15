From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [RFC] Patch to option HSO driver to the kernel
Date: Tue, 15 Apr 2008 06:30:55 +0200
Message-ID: <48042F7F.8030608@hartkopp.net>
References: <20080414213238.GB28833@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Filip Aben <f.aben@option.com>,
	Paulius Zaleckas <paulius.zaleckas@teltonika.lt>,
	ajb@spheresystems.co.uk
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:42724 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475AbYDOEbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 00:31:33 -0400
In-Reply-To: <20080414213238.GB28833@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just some obvious things to reduce the source code hopping for the
review and to reduce the source code size.

Regards,
Oliver

> +
> +#define DRIVER_VERSION			"1.2"
> +#define MOD_AUTHOR			"Option Wireless"
> +#define MOD_DESCRIPTION			"USB High Speed Option driver"
> +#define MOD_LICENSE			"GPL"
> +
>   

Please move the MODULE_OWNER(), MODULE_LICENSE(), etc. macros from the
end of this file directly to this point.


> +/*****************************************************************************/
> +/* Prototypes                                                                */
> +/*****************************************************************************/
> +/* Network interface functions */
> +static int hso_net_open(struct net_device *net);
> +static int hso_net_close(struct net_device *net);
> +static int hso_net_start_xmit(struct sk_buff *skb, struct net_device *net);
> +static int hso_net_ioctl(struct net_device *net, struct ifreq *rq, int cmd);
> +static struct net_device_stats *hso_net_get_stats(struct net_device *net);
> +static void hso_net_tx_timeout(struct net_device *net);
> +static void hso_net_set_multicast(struct net_device *net);
> +static void read_bulk_callback(struct urb *urb);
> +static void packetizeRx(struct hso_net *odev, unsigned char *ip_pkt,
> +			unsigned int count, unsigned char is_eop);
> +static void write_bulk_callback(struct urb *urb);
> +/* Serial driver functions */
> +static int hso_serial_tiocmset(struct tty_struct *tty, struct file *file,
> +			       unsigned int set, unsigned int clear);
> +static void ctrl_callback(struct urb *urb);
> +static void put_rxbuf_data(struct urb *urb, struct hso_serial *serial);
> +static void hso_std_serial_read_bulk_callback(struct urb *urb);
> +static void hso_std_serial_write_bulk_callback(struct urb *urb);
> +static void _hso_serial_set_termios(struct tty_struct *tty,
> +				    struct ktermios *old);
> +static void hso_kick_transmit(struct hso_serial *serial);
> +/* Base driver functions */
> +static int hso_probe(struct usb_interface *interface,
> +		     const struct usb_device_id *id);
> +static void hso_disconnect(struct usb_interface *interface);
> +/* Helper functions */
> +static int hso_mux_submit_intr_urb(struct hso_shared_int *mux_int,
> +				   struct usb_device *usb, gfp_t gfp);
> +static void hso_net_init(struct net_device *net);
> +static void set_ethernet_addr(struct hso_net *odev);
> +static struct hso_serial *get_serial_by_index(unsigned index);
> +static struct hso_serial *get_serial_by_shared_int_and_type(
> +					struct hso_shared_int *shared_int,
> +					int mux);
> +static int get_free_serial_index(void);
> +static void set_serial_by_index(unsigned index, struct hso_serial *serial);
> +static int remove_net_device(struct hso_device *hso_dev);
> +static int add_net_device(struct hso_device *hso_dev);
> +static void log_usb_status(int status, const char *function);
> +static struct usb_endpoint_descriptor *hso_get_ep(struct usb_interface *intf,
> +						  int type, int dir);
> +static int hso_get_mux_ports(struct usb_interface *intf, unsigned char *ports);
> +static void hso_free_interface(struct usb_interface *intf);
> +static int hso_start_serial_device(struct hso_device *hso_dev);
> +static int hso_stop_serial_device(struct hso_device *hso_dev);
> +static int hso_start_net_device(struct hso_device *hso_dev);
> +static void hso_free_shared_int(struct hso_shared_int *shared_int);
> +static int hso_stop_net_device(struct hso_device *hso_dev);
> +static void hso_serial_ref_free(struct kref *ref);
> +static int hso_suspend(struct usb_interface *iface, pm_message_t message);
> +static int hso_resume(struct usb_interface *iface);
> +static void async_get_intf(struct work_struct *data);
> +static void async_put_intf(struct work_struct *data);
> +static int hso_put_activity(struct hso_device *hso_dev);
> +static int hso_get_activity(struct hso_device *hso_dev);
> +
>   

This is a real forward declaration hell. Please try to reorder the
functions in the code to make this as obsolte as possible.

> +/*****************************************************************************/
> +/* Helping functions                                                         */
> +/*****************************************************************************/
> +
> +/* convert a character representing a hex value to a number */
> +static unsigned char hex2dec(unsigned char digit)
> +{
> +
> +	if ((digit >= '0') && (digit <= '9'))
> +		return (digit - '0');
> +	/* Map all characters to 0-15 */
> +	if ((digit >= 'a') && (digit <= 'z'))
> +		return (digit - 'a' + 10) % 16;
> +	if ((digit >= 'A') && (digit <= 'Z'))
> +		return (digit - 'A' + 10) % 16;
> +	return 16;
> +}
> +
>   

Shouldn't this already be somewhere else in the kernel?

> +
> +/* module parameters */
> +static int debug;
> +static int procfs = 1;
> +static int tty_major;
> +static int disable_net;
> +static int enable_autopm;
> +
>   

please move the module_param() stuff and MODULE_PARM_DESC() from the end
of the file right to this place.

> +static int hso_proc_port_info(char *buf, char **start, off_t offset, int count,
> +			      int *eof, void *data)
> +{
> +	int len = 0;
> +	struct hso_device *hso_dev = (struct hso_device *)data;
> +	char *port_name = NULL;
> +
> +	D1("count: %d", count);
>   

This debug macro looks like it is from the very beginning of the
implementation. Remove it.

> +
> +static void hso_serial_throttle(struct tty_struct *tty)
> +{
> +	D1(" ");
> +}
> +
> +static void hso_serial_unthrottle(struct tty_struct *tty)
> +{
> +	D1(" ");
> +}
> +
> +static void hso_serial_break(struct tty_struct *tty, int break_state)
> +{
> +	D1(" ");
> +}
> +
> +static int hso_serial_read_proc(char *page, char **start, off_t off, int count,
> +				int *eof, void *data)
> +{
> +	return 0;
> +}
> +
>   

???
> +static void hso_serial_hangup(struct tty_struct *tty)
> +{
> +	D1("hang up");
> +}
> +
>
>   

Should all these functions be removed (and therefor not set in
hso_serial_ops) ??

> +
> +/* Base driver functions */
> +
> +/* operations setup of the serial interface */
> +static struct tty_operations hso_serial_ops = {
> +	.open = hso_serial_open,
> +	.close = hso_serial_close,
> +	.write = hso_serial_write,
> +	.write_room = hso_serial_write_room,
> +	.ioctl = hso_serial_ioctl,
> +	.set_termios = hso_serial_set_termios,
> +	.throttle = hso_serial_throttle,
> +	.unthrottle = hso_serial_unthrottle,
> +	.break_ctl = hso_serial_break,
> +	.chars_in_buffer = hso_serial_chars_in_buffer,
> +	.read_proc = hso_serial_read_proc,
> +	.hangup = hso_serial_hangup,
> +	.tiocmget = hso_serial_tiocmget,
> +	.tiocmset = hso_serial_tiocmset,
> +};
> +
>   



