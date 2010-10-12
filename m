From: James Hogan <james@albanarts.com>
Subject: Re: [PATCH] b44: fix resume, request_irq after hw reset
Date: Tue, 12 Oct 2010 09:40:20 +0100
Message-ID: <AANLkTimdasN2xF71DbueQyv0sWNQicu79==VfuW6BTKM@mail.gmail.com>
References: <201010120022.13171.james@albanarts.com>
	<20101011163440.072e0227.akpm@linux-foundation.org>
	<201010120808.05713.james@albanarts.com>
	<20101012002715.fd0e3371.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gary Zambrano <zambrano@broadcom.com>,
	Jiri Pirko <jpirko@redhat.com>,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101012002715.fd0e3371.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12 October 2010 08:27, Andrew Morton <akpm@linux-foundation.org> wro=
te:
> On Tue, 12 Oct 2010 08:08:05 +0100 James Hogan <james@albanarts.com> =
wrote:
>
>> > > @@ -2309,6 +2303,12 @@ static int b44_resume(struct ssb_device *=
sdev)
>> > >
>> > > =A0 netif_device_attach(bp->dev);
>> > > =A0 spin_unlock_irq(&bp->lock);
>> > >
>> > > + rc =3D request_irq(dev->irq, b44_interrupt, IRQF_SHARED, dev->=
name,
>> dev);
>> > > + if (rc) {
>> > > + =A0 =A0 =A0 =A0 netdev_err(dev, "request_irq failed\n");
>> > > + =A0 =A0 =A0 =A0 return rc;
>> > > + }
>> > > +
>> > >
>> > > =A0 b44_enable_ints(bp);
>> > > =A0 netif_wake_queue(dev);
>> >
>> > OK, running the interrupt handler before b44_init_hw() is presumab=
ly
>> > the problem here.
>> >
>> > The hardware surely won't be generating interrupts until we've run
>> > b44_init_hw() and b44_enable_ints(), so this patch really is only =
to
>> > keep CONFIG_DEBUG_SHIRQ happy.
>>
>> For me it's mainly to keep CONFIG_DEBUG_SHIRQ happy (Fedora has this=
 switched
>> on), but since it's a shared IRQ, there is still a chance it could b=
e
>> called before enabling it's own interrupts by a different device on =
the same
>> IRQ.
>
> ooh, yes, you're right, I forgot about that. =A0It's indeed a bug.
>
>> It makes sense to me why it's disabling the IRQ now, in case another=
 device
>> triggers it when it cannot handle it safely.
>
> What code are you referring to here? =A0There's no disable_irq() in t=
hat area?

Sorry, I meant freeing the irq (free_irq() in b44_suspend).

Thinking about it this should also go in stable too.

Cheers
James

>
>> I also tried calling the
>> interrupt directly before the free_irq in the suspend function to ch=
eck that
>> it wasn't being done too late, and it didn't fail, so possibly it is=
 the core
>> suspension that makes it start failing until it is brought back up p=
roperly.
>
