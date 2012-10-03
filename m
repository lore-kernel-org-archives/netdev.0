From: anish singh <anish198519851985@gmail.com>
Subject: Re: [PATCHv4 1/4] modem_shm: Add Modem Access Framework
Date: Wed, 3 Oct 2012 09:47:07 +0530
Message-ID: <CAK7N6vqpHvi0R4eY0NPJ90Yu1_sVXOri-qOU5FPhp_5XcY3z0w@mail.gmail.com>
References: <1348819504-1303-1-git-send-email-arun.murthy@stericsson.com>
	<1348819504-1303-2-git-send-email-arun.murthy@stericsson.com>
	<20120928160045.GD2625@kroah.com>
	<F45880696056844FA6A73F415B568C695B6962C153@EXDCVYMBSTM006.EQ1STM.local>
	<20121001155940.GA1957@kroah.com>
	<F45880696056844FA6A73F415B568C695B6962CC8C@EXDCVYMBSTM006.EQ1STM.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Greg KH <gregkh@linuxfoundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"alan@lxorguk.ukuu.org.uk" <alan@lxorguk.ukuu.org.uk>
To: Arun MURTHY <arun.murthy@stericsson.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <F45880696056844FA6A73F415B568C695B6962CC8C@EXDCVYMBSTM006.EQ1STM.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 3, 2012 at 9:24 AM, Arun MURTHY <arun.murthy@stericsson.com> wrote:
>> On Mon, Oct 01, 2012 at 07:30:38AM +0200, Arun MURTHY wrote:
>> > > On Fri, Sep 28, 2012 at 01:35:01PM +0530, Arun Murthy wrote:
>> > > > +#include <linux/module.h>
>> > > > +#include <linux/slab.h>
>> > > > +#include <linux/err.h>
>> > > > +#include <linux/printk.h>
>> > > > +#include <linux/modem_shm/modem.h>
>> > > > +
>> > > > +static struct class *modem_class;
>> > >
>> > > What's wrong with a bus_type instead?
>> >
>> > Can I know the advantage of using bus_type over class?
>>
>> You have devices living on a bus, and it's much more descriptive than a class
>> (which we are going to eventually get rid of one of these days...).
>>
>> Might I ask why you choose a class over a bus_type?
>
> Basically my requirement is to create a central entity for accessing and releasing
> modem from APE. Since this is done by different clients the central entity should
> be able to handle the request and play safely, since this has more affect in
> system suspend and deep sleep. Using class helps me in achieving this and
> also create an entry to user space which can be used in the later parts. Moreover
You can have that same mechanism work for bus_type as well.
> this not something like a bus or so, so I didn't use bus instead went with a
> simple class approach.
>
>>
>> > > > +int modem_release(struct modem_desc *mdesc) {
>> > > > +       if (!mdesc->release)
>> > > > +               return -EFAULT;
>> > > > +
>> > > > +       if (modem_is_requested(mdesc)) {
>> > > > +               atomic_dec(&mdesc->mclients->cnt);
>> > > > +               if (atomic_read(&mdesc->use_cnt) == 1) {
>> > > > +                       mdesc->release(mdesc);
>> > > > +                       atomic_dec(&mdesc->use_cnt);
>> > > > +               }
>> > >
>> > > Eeek, why aren't you using the built-in reference counting that the
>> > > struct device provided to you, and instead are rolling your own?
>> > > This happens in many places, why?
>> >
>> > My usage of counters over here is for each modem there are many clients.
>> > Each of the clients will have a ref to modem_desc. Each of them use
>> > this for requesting and releasing the modem. One counter for tracking
>> > the request and release for each client which is done by variable 'cnt' in
>> struct clients.
>> > The counter use_cnt is used for tracking the modem request/release
>> > irrespective of the clients and counter cli_cnt is used for
>> > restricting the modem_get to the no of clients defined in no_clients.
>> >
>> > So totally 3 counter one for restricting the usage of modem_get by
>> > clients, second for restricting modem request/release at top level,
>> > and 3rd for restricting modem release/request for per client per modem
>> basis.
>> >
>> > Can you let me know if the same can be achieved by using built-in ref
>> > counting?
>>
>> Yes, because you don't need all of those different levels, just stick with one
>> and you should be fine. :)
>>
>
> No, checks at all these levels are required, I have briefed out the need also.
> This will have effect on system power management, i.e suspend and deep
> sleep.
> We restrict that the drivers should request modem only once and release
> only once, but we cannot rely on the clients hence a check for the same has
> to be done in the MAF. Also the no of clients should be defined and hence a
> check for the same is done in MAF. Apart from all these the requests coming
> from all the clients is to be accumulated and based on that modem release
> or access should be performed, hence so.
I think best way to deal with this is:
Define a new bus type and have your clients call the bus exposed functionality
when ever they need a service.So in your case it would be request and release
only AND when all of your clients have released the bus then you can do the
cleanup i.e. switch off the modem and on added advantage of making it a bus_type
would be that you can do the reference counting in your bus driver.

Designing is not my forte but I feel this way you can solve the problem at hand.
Please feel free to correct me.I would really appreciate it.
>
> Thanks and Regards,
> Arun R Murthy
> -------------------
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
