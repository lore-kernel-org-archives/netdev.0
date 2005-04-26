From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/1] connector/CBUS: new messaging subsystem. Revision number
 next.
Date: Tue, 26 Apr 2005 22:48:33 +0400
Message-ID: <20050426224833.3b6a0792@zanzibar.2ka.mipt.ru>
References: <20050411125932.GA19538@uganda.factory.vocord.ru>
	<d120d5000504260857cb5f99e@mail.gmail.com>
	<20050426202437.234e7d45@zanzibar.2ka.mipt.ru>
	<20050426203023.378e4831@zanzibar.2ka.mipt.ru>
	<d120d50005042610342368cd72@mail.gmail.com>
	<20050426220713.7915e036@zanzibar.2ka.mipt.ru>
	<d120d50005042611203ce29dd8@mail.gmail.com>
	<20050426223126.37b7aea1@zanzibar.2ka.mipt.ru>
	<d120d50005042611426ec326e9@mail.gmail.com>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dmitry.torokhov@gmail.com, netdev@oss.sgi.com,
	Greg KH <greg@kroah.com>, Jamal Hadi Salim <hadi@cyberus.ca>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	James Morris <jmorris@redhat.com>,
	Guillaume Thouvenin <guillaume.thouvenin@bull.net>,
	linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>,
	Thomas Graf <tgraf@suug.ch>, Jay Lan <jlan@engr.sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261725AbVDZStz@vger.kernel.org>
To: dtor_core@ameritech.net
In-Reply-To: <d120d50005042611426ec326e9@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 26 Apr 2005 13:42:10 -0500
Dmitry Torokhov <dmitry.torokhov@gmail.com> wrote:

> On 4/26/05, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> > On Tue, 26 Apr 2005 13:20:08 -0500
> > Dmitry Torokhov <dmitry.torokhov@gmail.com> wrote:
> > 
> > > On 4/26/05, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> > > > Yes, I found it too.
> > > > Following patch should be the solution:
> > > >
> > > > --- orig/drivers/connector/connector.c
> > > > +++ mod/drivers/connector/connector.c
> > > > @@ -146,13 +146,16 @@
> > > >        spin_lock_bh(&dev->cbdev->queue_lock);
> > > >        list_for_each_entry(__cbq, &dev->cbdev->queue_list, callback_entry) {
> > > >                if (cn_cb_equal(&__cbq->cb->id, &msg->id)) {
> > > > -                       __cbq->cb->priv = msg;
> > > > +
> > > > +                       if (!test_bit(0, &work->pending)) {
> > > > +                               __cbq->cb->priv = msg;
> > > >
> > > > -                       __cbq->ddata = data;
> > > > -                       __cbq->destruct_data = destruct_data;
> > > > +                               __cbq->ddata = data;
> > > > +                               __cbq->destruct_data = destruct_data;
> > > >
> > >
> > > Still not good enough - work->pending bit gets cleared when work has
> > > been scheduled, but before executing payload. You still have the race.
> > 
> > Data pointer is copied before bit is set,
> > but I forget that it is not data, but another pointer
> > which may be overwritten.
> > 
> > I think we may finish it by setting skb as data,
> > and call kfree_skb() as destructor.
> > 
> 
> Yes, that woudl work, although I would urge you to implement a message
> queue for callbacks (probably limit it to 1000 messages or so) to
> allow bursting.

It already exist, btw, but not exactly in that way - 
we have skb queue, which can not be filled from userspace 
if pressure is so strong so work queue can not be scheduled. 
It is of course different and is influenced by other things 
but it handles bursts quite well - it was tested on both 
SMP and UP machines with continuous flows of forks with
shape addon of new running tasks [both fith fork bomb and not],
so I think it can be called real bursty test.
 
> -- 
> Dmitry


	Evgeniy Polyakov

Only failure makes us experts. -- Theo de Raadt
