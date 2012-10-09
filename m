From: Arun MURTHY <arun.murthy@stericsson.com>
Subject: RE: [PATCHv4 1/4] modem_shm: Add Modem Access Framework
Date: Tue, 9 Oct 2012 07:37:02 +0200
Message-ID: <F45880696056844FA6A73F415B568C695B697CB0C9@EXDCVYMBSTM006.EQ1STM.local>
References: <1348819504-1303-1-git-send-email-arun.murthy@stericsson.com>
 <1348819504-1303-2-git-send-email-arun.murthy@stericsson.com>
 <20120928160045.GD2625@kroah.com>
 <F45880696056844FA6A73F415B568C695B6962C153@EXDCVYMBSTM006.EQ1STM.local>
 <20121001155940.GA1957@kroah.com>
 <F45880696056844FA6A73F415B568C695B6962CC8C@EXDCVYMBSTM006.EQ1STM.local>
 <20121003151748.GA5745@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"alan@lxorguk.ukuu.org.uk" <alan@lxorguk.ukuu.org.uk>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > On Wed, Oct 03, 2012 at 05:54:08AM +0200, Arun MURTHY wrote:
> > > > On Mon, Oct 01, 2012 at 07:30:38AM +0200, Arun MURTHY wrote:
> > > > > > On Fri, Sep 28, 2012 at 01:35:01PM +0530, Arun Murthy wrote:
> > > > > > > +#include <linux/module.h>
> > > > > > > +#include <linux/slab.h>
> > > > > > > +#include <linux/err.h>
> > > > > > > +#include <linux/printk.h>
> > > > > > > +#include <linux/modem_shm/modem.h>
> > > > > > > +
> > > > > > > +static struct class *modem_class;
> > > > > >
> > > > > > What's wrong with a bus_type instead?
> > > > >
> > > > > Can I know the advantage of using bus_type over class?
> > > >
> > > > You have devices living on a bus, and it's much more descriptive
> > > > than a class (which we are going to eventually get rid of one of
> > > > these
> > days...).
> > > >
> > > > Might I ask why you choose a class over a bus_type?
> > >
> > > Basically my requirement is to create a central entity for accessing
> > > and releasing modem from APE.
> >
> > What is an "APE"?
> >
> > And what do you mean by "accessing" and "releasing"?
> 
> APE - Application Processor Engine
> There are two processors but on a single chip, one being the APE and other is
> the modem. So 'accessing' means requesting access or waking-up the co-
> processor and releasing means allowing the co-processor to sleep.
> 
> 
> >
> > > Since this is done by different clients the central entity should be
> > > able to handle the request and play safely, since this has more
> > > affect in system suspend and deep sleep. Using class helps me in
> > > achieving this and also create an entry to user space which can be
> > > used in the later parts. Moreover this not something like a bus or
> > > so, so I didn't use bus instead went with a simple class approach.
> >
> > But as you have devices that are "binding" to this "controller", a bus
> > might make more sense, right?
> 
> Have explained above regarding the platform, the concept of bus doesn't
> come into picture at all. Here its just waking-up the modem and allowing it to
> go to sleep.
> 
> >
> > I don't see how a class helps out for you here more than anything
> > else, what are you expecting from the class interface?  You aren't
> > using the reference counting logic it provides, so why use it at all?
> 
> I am using the reference counting logic in class such as
> class_for_each_device.
> 
> >
> > Actually, why use the driver core at all in the first place if you
> > aren't needing the devices to show up in sysfs (as you don't have a
> > device, you are just a mediator)?
> 
> Yes I am something like a mediator, but since this is associated with many
> clients, there should be some central entity to take inputs from all the clients
> and act accordingly. This MAF does that. Sysfs will also be created for this
> MAF in the coming versions.
> 
> >
> > > > > > > +int modem_release(struct modem_desc *mdesc) {
> > > > > > > +	if (!mdesc->release)
> > > > > > > +		return -EFAULT;
> > > > > > > +
> > > > > > > +	if (modem_is_requested(mdesc)) {
> > > > > > > +		atomic_dec(&mdesc->mclients->cnt);
> > > > > > > +		if (atomic_read(&mdesc->use_cnt) == 1) {
> > > > > > > +			mdesc->release(mdesc);
> > > > > > > +			atomic_dec(&mdesc->use_cnt);
> > > > > > > +		}
> > > > > >
> > > > > > Eeek, why aren't you using the built-in reference counting
> > > > > > that the struct device provided to you, and instead are rolling your
> own?
> > > > > > This happens in many places, why?
> > > > >
> > > > > My usage of counters over here is for each modem there are many
> > clients.
> > > > > Each of the clients will have a ref to modem_desc. Each of them
> > > > > use this for requesting and releasing the modem. One counter for
> > > > > tracking the request and release for each client which is done
> > > > > by variable 'cnt' in
> > > > struct clients.
> > > > > The counter use_cnt is used for tracking the modem
> > > > > request/release irrespective of the clients and counter cli_cnt
> > > > > is used for restricting the modem_get to the no of clients defined in
> no_clients.
> > > > >
> > > > > So totally 3 counter one for restricting the usage of modem_get
> > > > > by clients, second for restricting modem request/release at top
> > > > > level, and 3rd for restricting modem release/request for per
> > > > > client per modem
> > > > basis.
> > > > >
> > > > > Can you let me know if the same can be achieved by using
> > > > > built-in ref counting?
> > > >
> > > > Yes, because you don't need all of those different levels, just
> > > > stick with one and you should be fine. :)
> > > >
> > >
> > > No, checks at all these levels are required, I have briefed out the need
> also.
> >
> > I still don't understand, sorry.
> 
> The pictorial view by Anish should help in understanding.
>            Modem                 Client1     Client2    Client3    Client4
> State  turn-on                   request
> State  no-state-change                     request
> State  no-state-change                                   request
> State  no-state-change				request
> State  no-state-change      release
> State  no-state-change                                   release
> State  no-state-change                     release
> State   turn-off					release
> 
> This is just a simple straight forward example.
> 
> >
> > > This will have effect on system power management, i.e suspend and
> > > deep sleep.
> >
> > How does power management matter?  If you tie into the driver model
> > properly, power management comes "for free" so you don't have to do
> > anything special about it.  Why not use that logic instead of trying
> > to roll your own?
> 
> As said there are two processors on a single chip playing over here. One
> being the APE(Application Processor Engine) and other is Modem. Since they
> are on a single chip but for APE entering into deep sleep modem should be
> released.
> 
> >
> > > We restrict that the drivers should request modem only once and
> > > release only once, but we cannot rely on the clients hence a check
> > > for the same has to be done in the MAF.
> >
> > You can't rely on the clients to do what?  And why can't you rely on them?
> > What is going to happen?  Who is a "client" here?  Other kernel code?
> 
> Yes, let me take my driver itself as an example. Here the clients are the
> shared memory driver, sim driver, security etc. Shared memory driver is the
> communicating media between the APE and Modem and hence needs to
> wake-up the modem and after completion should allow modem to enter
> sleep.
> Similarly it's the same for sim driver also.
> We define that the clients such as shared memory driver and the sim driver
> should request for modem only one and then release only once and also
> since this is a MAF shouldn't it take care of checking the same?
> 
> >
> > I really don't understand your model at all as to what you are trying
> > to mediate and manage here, sorry.  I suggest writing it all up as
> > your first patch (documentation is good), so that we can properly
> > review your implementation and not argue about how to implement
> > something that I honestly don't understand.
> 
> Sorry for that. Actually my 4th patch in this patchset includes the
> documentation.
> Since it's the kernel doc I have made it as the last patch in this patchset, else
> kernel doc compilation will fail.
> Please feel free to refer the 4th patch for the documentation part and if still
> not clear I can provide more explanation on this.
> 
> >
> > > Also the no of clients should be defined and hence a check for the
> > > same is done in MAF.
> >
> > Defined where?  What is "MAF"?
> 
> This driver is MAF(Modem Access Framework).
> 


Any further comments?

Thanks and Regards,
Arun R Murthy
------------------
