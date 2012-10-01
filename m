From: anish singh <anish198519851985@gmail.com>
Subject: Re: [PATCHv4 1/4] modem_shm: Add Modem Access Framework
Date: Mon, 1 Oct 2012 14:27:21 +0530
Message-ID: <CAK7N6vqpokVk19-KPPggZRynKJVjoa04n_0g4nnb1CN836s5pA@mail.gmail.com>
References: <1348819504-1303-1-git-send-email-arun.murthy@stericsson.com>
	<1348819504-1303-2-git-send-email-arun.murthy@stericsson.com>
	<20120928160045.GD2625@kroah.com>
	<F45880696056844FA6A73F415B568C695B6962C153@EXDCVYMBSTM006.EQ1STM.local>
	<CAK7N6vpXfhb0KhMfqxbcSQqT=qPcMS06OdaG9kNsWMqiiepLTQ@mail.gmail.com>
	<F45880696056844FA6A73F415B568C695B6962C1CD@EXDCVYMBSTM006.EQ1STM.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg KH <gregkh@linuxfoundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"alan@lxorguk.ukuu.org.uk" <alan@lxorguk.ukuu.org.uk>
To: Arun MURTHY <arun.murthy@stericsson.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <F45880696056844FA6A73F415B568C695B6962C1CD@EXDCVYMBSTM006.EQ1STM.local>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 1, 2012 at 12:27 PM, Arun MURTHY <arun.murthy@stericsson.co=
m> wrote:
>> On Mon, Oct 1, 2012 at 11:00 AM, Arun MURTHY
>> <arun.murthy@stericsson.com> wrote:
>> >> On Fri, Sep 28, 2012 at 01:35:01PM +0530, Arun Murthy wrote:
>> >> > +#include <linux/module.h>
>> >> > +#include <linux/slab.h>
>> >> > +#include <linux/err.h>
>> >> > +#include <linux/printk.h>
>> >> > +#include <linux/modem_shm/modem.h>
>> >> > +
>> >> > +static struct class *modem_class;
>> >>
>> >> What's wrong with a bus_type instead?
>> >
>> > Can I know the advantage of using bus_type over class?
>> >
>> >>
>> >> > +static int __modem_is_requested(struct device *dev, void *data=
) {
>> >> > +   struct modem_desc *mdesc =3D (struct modem_desc *)data;
>> >> > +
>> >> > +   if (!mdesc->mclients) {
>> >> > +           printk(KERN_ERR "modem_access: modem description is
>> >> NULL\n");
>> >> > +           return 0;
>> >> > +   }
>> >> > +   return atomic_read(&mdesc->mclients->cnt);
>> >> > +}
>> >> > +
>> >> > +int modem_is_requested(struct modem_desc *mdesc) {
>> >> > +   return class_for_each_device(modem_class, NULL, (void *)mde=
sc,
>> >> > +__modem_is_requested); }
>> >>
>> >> Where is the documentation for your public api functions like thi=
s?
>> >
>> > Sure will include this in the next patchset.
>> >
>> >>
>> >> > +
>> >> > +int modem_release(struct modem_desc *mdesc) {
>> >> > +   if (!mdesc->release)
>> >> > +           return -EFAULT;
>> >> > +
>> >> > +   if (modem_is_requested(mdesc)) {
>> >> > +           atomic_dec(&mdesc->mclients->cnt);
>> >> > +           if (atomic_read(&mdesc->use_cnt) =3D=3D 1) {
>> >> > +                   mdesc->release(mdesc);
>> >> > +                   atomic_dec(&mdesc->use_cnt);
>> >> > +           }
>> >>
>> >> Eeek, why aren't you using the built-in reference counting that t=
he
>> >> struct device provided to you, and instead are rolling your own?
>> >> This happens in many places, why?
>> >
>> > My usage of counters over here is for each modem there are many cl=
ients.
>> > Each of the clients will have a ref to modem_desc. Each of them us=
e
>> > this for requesting and releasing the modem. One counter for track=
ing
>> > the request and release for each client which is done by variable =
'cnt' in
>> struct clients.
>> > The counter use_cnt is used for tracking the modem request/release
>> > irrespective of the clients and counter cli_cnt is used for
>> > restricting the modem_get to the no of clients defined in no_clien=
ts.
>> >
>> > So totally 3 counter one for restricting the usage of modem_get by
>> > clients, second for restricting modem request/release at top level=
,
>> > and 3rd for restricting modem release/request for per client per m=
odem
>> basis.
>> >
>> > Can you let me know if the same can be achieved by using built-in =
ref
>> > counting?
>> Is this your model:
>> You have a modem device which can be requested by many clients.This
>> clients can register for a particular service which this modem provi=
des and
>> then after that if it client doesn't need this service then it will =
call un-register.
>
> Let me correct a bit over here:
> There are many clients, yes correct but the operations performed are =
only two,
> i.e modem request and modem release. This is something like waking up=
 the
> modem and let modem to sleep.
> The traffic of this request and release is too high.
>
> So irrespective of the requests/releases made to the MAF framework, t=
he MAF
> should perform the operation request/release only once.
>
> So each and every time handling list consumes time.
> Let me brief the context, this is a single chip modem and ape, basica=
lly used in
> mobile, tablets etc. So the traffic in ape-modem communication is too=
 high and
> also time critical. If it bound to exceed the time, or delay might en=
d up in buffer
> full. That=E2=80=99s the reason I have made it as simple as possible.

So let me put it this way:
           Modem                 Client1     Client2    Client3    Clie=
nt4
State  turn-on                   request
State  no-state-change                     request
State  no-state-change                                   request
State  no-state-change
request
State  no-state-change      release
State  no-state-change                     release
State  no-state-change                                   release
State   turn-off
      release

So eventhough all the clients have requested the modem it is being
turned on only once and when all of them have released then it will be
turned-off.

In this case it makes sense to use the atomic variables to track the re=
quests
and release but what will happen to sysfs incase the device is released=
 when the
last call to release has come from client4?Won't it lead to kernel pani=
c or some
unwanted behaviour?

>
> Thanks and Regards,
> Arun R Murthy
> ------------------
