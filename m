From: Jean Delvare <jdelvare@suse.de>
Subject: Re: [PATCH 12/14] i2c-parport: return proper error values from
 attach
Date: Thu, 9 Apr 2015 11:33:42 +0200
Message-ID: <20150409113342.5621af83@endymion.delvare>
References: <1428492040-5581-1-git-send-email-sudipm.mukherjee@gmail.com>
	<1428492040-5581-13-git-send-email-sudipm.mukherjee@gmail.com>
	<20150409071307.GA1166@katana>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Sudip Mukherjee <sudipm.mukherjee@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Rodolfo Giometti <giometti@enneenne.com>,
	"James E.J. Bottomley" <JBottomley@parallels.com>,
	Mark Brown <broonie@kernel.org>,
	Willy Tarreau <willy@meta-x.org>,
	Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.de>,
	linux-kernel@vger.kernel.org, linux-i2c@vger.kernel.org,
	netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	linux-spi@vger.kernel.org, devel@driverdev.osuosl.org,
	alsa-devel@alsa-project.org
To: Wolfram Sang <wsa@the-dreams.de>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20150409071307.GA1166@katana>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 9 Apr 2015 09:13:07 +0200, Wolfram Sang wrote:
> On Wed, Apr 08, 2015 at 04:50:38PM +0530, Sudip Mukherjee wrote:
> > now that we are monitoring the return value from attach, make the
> > required changes to return proper value from its attach function.
> > 
> > Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
> > ---
> >  drivers/i2c/busses/i2c-parport.c | 7 ++++---
> >  1 file changed, 4 insertions(+), 3 deletions(-)
> > 
> > diff --git a/drivers/i2c/busses/i2c-parport.c b/drivers/i2c/busses/i2c-parport.c
> > index a1fac5a..761a775 100644
> > --- a/drivers/i2c/busses/i2c-parport.c
> > +++ b/drivers/i2c/busses/i2c-parport.c
> > @@ -160,14 +160,14 @@ static void i2c_parport_irq(void *data)
> >  			"SMBus alert received but no ARA client!\n");
> >  }
> >  
> > -static void i2c_parport_attach(struct parport *port)
> > +static int i2c_parport_attach(struct parport *port)
> >  {
> >  	struct i2c_par *adapter;
> >  
> >  	adapter = kzalloc(sizeof(struct i2c_par), GFP_KERNEL);
> >  	if (adapter == NULL) {
> >  		printk(KERN_ERR "i2c-parport: Failed to kzalloc\n");
> > -		return;
> > +		return -ENOMEM;
> 
> ENOMEM does not need printout. Please remove printk while we are here.
> 
> >  
> >  	pr_debug("i2c-parport: attaching to %s\n", port->name);
> > @@ -230,13 +230,14 @@ static void i2c_parport_attach(struct parport *port)
> >  	mutex_lock(&adapter_list_lock);
> >  	list_add_tail(&adapter->node, &adapter_list);
> >  	mutex_unlock(&adapter_list_lock);
> > -	return;
> > +	return 0;
> >  
> >   err_unregister:
> >  	parport_release(adapter->pdev);
> >  	parport_unregister_device(adapter->pdev);
> >   err_free:
> >  	kfree(adapter);
> > +	return -ENODEV;
> 
> Ideally, we would return different -Esomething for each failing case. We
> can leave that for someone who is acutally using the driver. However, I
> wonder if ENODEV is a proper catch-all case because the driver core will
> not report failures.

It doesn't really matter that the error codes are different, it matters
that they are meaningful. As much as possible you should pass error
codes from the lower layers. parport_claim_or_block() and
i2c_bit_add_bus() return proper error codes so you should record and
transmit them. Only parport_register_device() does not, so you have to
craft one and -ENODEV seems appropriate to me.

Note: I can test this driver.

-- 
Jean Delvare
SUSE L3 Support
