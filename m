From: Arun MURTHY <arun.murthy@stericsson.com>
Subject: RE: [PATCHv4 1/4] modem_shm: Add Modem Access Framework
Date: Mon, 1 Oct 2012 07:30:38 +0200
Message-ID: <F45880696056844FA6A73F415B568C695B6962C153@EXDCVYMBSTM006.EQ1STM.local>
References: <1348819504-1303-1-git-send-email-arun.murthy@stericsson.com>
 <1348819504-1303-2-git-send-email-arun.murthy@stericsson.com>
 <20120928160045.GD2625@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"alan@lxorguk.ukuu.org.uk" <alan@lxorguk.ukuu.org.uk>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20120928160045.GD2625@kroah.com>
Content-Language: en-US
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Fri, Sep 28, 2012 at 01:35:01PM +0530, Arun Murthy wrote:
> > +#include <linux/module.h>
> > +#include <linux/slab.h>
> > +#include <linux/err.h>
> > +#include <linux/printk.h>
> > +#include <linux/modem_shm/modem.h>
> > +
> > +static struct class *modem_class;
> 
> What's wrong with a bus_type instead?

Can I know the advantage of using bus_type over class?

> 
> > +static int __modem_is_requested(struct device *dev, void *data) {
> > +	struct modem_desc *mdesc = (struct modem_desc *)data;
> > +
> > +	if (!mdesc->mclients) {
> > +		printk(KERN_ERR "modem_access: modem description is
> NULL\n");
> > +		return 0;
> > +	}
> > +	return atomic_read(&mdesc->mclients->cnt);
> > +}
> > +
> > +int modem_is_requested(struct modem_desc *mdesc) {
> > +	return class_for_each_device(modem_class, NULL, (void *)mdesc,
> > +__modem_is_requested); }
> 
> Where is the documentation for your public api functions like this?

Sure will include this in the next patchset.

> 
> > +
> > +int modem_release(struct modem_desc *mdesc) {
> > +	if (!mdesc->release)
> > +		return -EFAULT;
> > +
> > +	if (modem_is_requested(mdesc)) {
> > +		atomic_dec(&mdesc->mclients->cnt);
> > +		if (atomic_read(&mdesc->use_cnt) == 1) {
> > +			mdesc->release(mdesc);
> > +			atomic_dec(&mdesc->use_cnt);
> > +		}
> 
> Eeek, why aren't you using the built-in reference counting that the struct
> device provided to you, and instead are rolling your own?  This happens in
> many places, why?

My usage of counters over here is for each modem there are many clients.
Each of the clients will have a ref to modem_desc. Each of them use this for
requesting and releasing the modem. One counter for tracking the request
and release for each client which is done by variable 'cnt' in struct clients.
The counter use_cnt is used for tracking the modem request/release irrespective
of the clients and counter cli_cnt is used for restricting the modem_get to
the no of clients defined in no_clients.

So totally 3 counter one for restricting the usage of modem_get by clients,
second for restricting modem request/release at top level, and 3rd for
restricting modem release/request for per client per modem basis.

Can you let me know if the same can be achieved by using built-in ref
counting?

Thanks and Regards,
Arun R Murthy
------------------
