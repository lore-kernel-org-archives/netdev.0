From: Marcelo Tosatti <marcelo@kvack.org>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)
Date: Sat, 10 Feb 2007 12:05:29 -0200
Message-ID: <20070210140529.GA3814@dmt.wfacil.com.br>
References: <20070116185524.GA5681@dmt> <200701270253.08320.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcelo Tosatti <marcelo@kvack.org>,
	netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	"John W. Linville" <linville@redhat.com>,
	Dan Williams <dcbw@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:34426 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932169AbXBJOJe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Feb 2007 09:09:34 -0500
Content-Disposition: inline
In-Reply-To: <200701270253.08320.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 27, 2007 at 02:53:07AM +0100, Arnd Bergmann wrote:
> > +/** Command Processing States and Options */
> > +#define HostCmd_STATE_IDLE                    0x0000
> > +#define HostCmd_STATE_IN_USE_BY_HOST          0x0001
> > +#define HostCmd_STATE_IN_USE_BY_MINIPORT      0x0002
> > +#define HostCmd_STATE_FINISHED                0x000f
> 
> No SilLYcAps please

Done.

> Most of these are unused as well, I guess it would be good
> to go through the whole list and see what can be removed.

Done.

> > +/**  
> > + *  @brief This function reads of the packet into the upload buff, 
> > + *  wake up the main thread and initialise the Rx callack.
> > + *  
> > + *  @param urb		pointer to struct urb
> > + *  @return 	   	N/A
> > + */
> > +static void if_usb_receive(struct urb *urb)
> > +{
> 
> This function is a little long, there is a switch() statement in it
> that can probably be converted into one function per case.

Moved processing of CMD_TYPE_REQUEST and CMD_TYPE_DATA to inline 
functions.

> > +/** 
> > + *  @brief Given a usb_card_rec return its wlan_private
> > + *  @param card		pointer to a usb_card_rec
> > + *  @return 	   	pointer to wlan_private
> > + */
> > +wlan_private *libertas_sbi_get_priv(void *card)
> > +{
> > +	struct usb_card_rec *cardp = (struct usb_card_rec *)card;
> > +	return (wlan_private *)cardp->priv;
> > +}
> 
> Don't do explicit casts of void* pointers.

Fixed.

> > +	data = *((int *)(wrq->u.name + SUBCMD_OFFSET));
> 
> You use this weird line in many places, it would be good to make it
> a helper function.

Converted to a macro.

> > +static u8 Is_Command_Allowed_In_PS(u16 Command)
> > +{
> > +	int count = sizeof(Commands_Allowed_In_PS)
> > +	    / sizeof(Commands_Allowed_In_PS[0]);
> > +	int i;
> > +
> > +	for (i = 0; i < count; i++) {
> > +		if (Command == cpu_to_le16(Commands_Allowed_In_PS[i]))
> > +			return 1;
> > +	}
> > +
> > +	return 0;
> > +}
> 
> In places where you use variables that are strictly little-endian,
> it would be nice to use the __le32/__le16 types instead of u32/u16.
> 
> > +/** 
> > + *  @brief This function handles the command response
> > + *  
> > + *  @param priv    A pointer to wlan_private structure
> > + *  @return 	   WLAN_STATUS_SUCCESS or WLAN_STATUS_FAILURE
> > + */
> > +int libertas_process_rx_command(wlan_private * priv)
> > +{
> 
> This function is incredibly long, to the point where it gets
> unreadable.

Moved the switch() to an inline function, that should make it much more
readable.

> > +static struct dentry *libertas_dir = NULL;
> > +static const int big_buffer_len = 4096;
> > +static char big_buffer[4096];
> > +static DECLARE_MUTEX(big_buffer_sem);
> 
> This seems to provide a generalized interface for buffering debugfs
> files. Have you considered using the existing simple_attribute
> and seq_file interfaces instead?
> 
> Even if they don't work for this, I would consider it cleaner to
> use get_zeroed_page/free_page instead of the global buffer here.

Borrowed the idea from bcm43xx, but yeah, I agree that using
get_zeroed_page/free_page is cleaner and safer.

Done.

> > +static struct file_operations libertas_devinfo_fops = { 
> > +	.owner = THIS_MODULE,
> > +	.open = open_file_generic,
> > +	.write = write_file_dummy,
> > +	.read = libertas_dev_info,
> > +};
> > +
> > +static struct file_operations libertas_getscantable_fops = { 
> > +	.owner = THIS_MODULE,
> > +	.open = open_file_generic,
> > +	.write = write_file_dummy,
> > +	.read = libertas_getscantable,
> > +};
> > +
> > +static struct file_operations libertas_sleepparams_fops = { 
> > +	.owner = THIS_MODULE,
> > +	.open = open_file_generic,
> > +	.write = libertas_sleepparams_write,
> > +	.read = libertas_sleepparams_read,
> > +};
> 
> I would guess you can better express this with some array, like
> 
> #define FOPS(read, write) { \
> 	.owner = THIS_MODULE, \
> 	.open = open_file_generic, \
> 	.read = (read), \
> 	.write = (write), \
> }
> 
> struct libertas_debugfs_files {
> 	char *name;
> 	int perm;
> 	struct file_operations fops;
> } debugfs_files = {
> 	{ "devinfo", 0444, FOPS(libertas_dev_info, NULL), },
> 	{ "getscantable", 0444, FOPS(libertas_getscantable, NULL), },
> 	{ "sleepparams", 0644, FOPS(libertas_sleepparams_read,
> 					libertas_sleepparams_write), },
> 	...
> };
> 
> > +void libertas_debugfs_init_one(wlan_private *priv, struct net_device *dev)
> > +{
> > +	if (!libertas_dir)
> > +		goto exit;
> > +
> > +	priv->debugfs_dir = debugfs_create_dir(dev->name, libertas_dir);
> > +	if (!priv->debugfs_dir)
> > +		goto exit;
> > +
> > +	priv->debugfs_devinfo = debugfs_create_file("info", 0444,
> > +						    priv->debugfs_dir,
> > +						    priv,
> > +						    &libertas_devinfo_fops);
> 
> And then here do a loop over that array.

Done.

