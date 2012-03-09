From: Johan Hovold <jhovold@gmail.com>
Subject: Re: [PATCH 1/2] bluetooth: hci_ldisc: fix NULL-pointer dereference
 on tty_close
Date: Fri, 9 Mar 2012 16:15:27 +0100
Message-ID: <20120309151527.GH4497@localhost>
References: <1331136120-27075-1-git-send-email-jhovold@gmail.com>
 <1331136120-27075-2-git-send-email-jhovold@gmail.com>
 <CANq1E4Sd45FtZN6NXs7TZ1k6VrFkbcAZug-1UQwW-XPB0e5Aag@mail.gmail.com>
 <20120309142939.GD4497@localhost>
 <CANq1E4TzcQCuKomPv1bNTdkJ7LDTYjKiMqUwV8ZaoYG6FJO9Qw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Marcel Holtmann <marcel@holtmann.org>,
	"Gustavo F. Padovan" <padovan@profusion.mobi>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, stable <stable@vger.kernel.org>
To: David Herrmann <dh.herrmann@googlemail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CANq1E4TzcQCuKomPv1bNTdkJ7LDTYjKiMqUwV8ZaoYG6FJO9Qw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 09, 2012 at 03:35:46PM +0100, David Herrmann wrote:
> On Fri, Mar 9, 2012 at 3:29 PM, Johan Hovold <jhovold@gmail.com> wrot=
e:
> > On Fri, Mar 09, 2012 at 02:44:30PM +0100, David Herrmann wrote:
> >> On Wed, Mar 7, 2012 at 5:01 PM, Johan Hovold <jhovold@gmail.com> w=
rote:
> >> > Do not close protocol driver until device has been unregistered.
> >> >
> >> > This fixes a race between tty_close and hci_dev_open which can r=
esult in
> >> > a NULL-pointer dereference.
> >> >
> >> > The line discipline closes the protocol driver while we may stil=
l have
> >> > hci_dev_open sleeping on the req_lock mutex resulting in a NULL-=
pointer
> >> > dereference when lock is acquired and hci_init_req called.
> >
> > [...]
> >
> >> > diff --git a/drivers/bluetooth/hci_ldisc.c b/drivers/bluetooth/h=
ci_ldisc.c
> >> > index 0711448..6946081 100644
> >> > --- a/drivers/bluetooth/hci_ldisc.c
> >> > +++ b/drivers/bluetooth/hci_ldisc.c
> >> > @@ -310,11 +310,11 @@ static void hci_uart_tty_close(struct tty_=
struct *tty)
> >> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0hci_uart_close(hd=
ev);
> >> >
> >> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (test_and_clear_bit(HCI_UART_P=
ROTO_SET, &hu->flags)) {
> >> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hu->proto->close(h=
u);
> >> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (hdev) {
> >> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0h=
ci_unregister_dev(hdev);
> >> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0h=
ci_free_dev(hdev);
> >> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> >> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hu->proto->close(h=
u);
> >> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> >> > =A0 =A0 =A0 =A0}
> >> > =A0}
> >>
> >> I can confirm this. hci_uart_set_proto() opens the proto before it
> >> registers the hci device. Hence, we should also unregister the hci
> >> device before closing the proto. I also looked whether this introd=
uces
> >> other race conditions but no proto-callback can be called here as =
they
> >> are all protected by the tty-layer which synchronizes all
> >> tty-callbacks. Therefore, I think this is the correct fix.
> >>
> >> We can apply this to stable even without the "destruct"-fixes from=
 me
> >> as hu->proto->$cb$() doesn't care whether hdev is valid or not. I
> >> don't think the destruct-fixes are important enough to send them t=
o
> >> stable.
> >
> > Unfortunately hu is is not valid once hci_unregister returns as it =
will
> > call the destruct callback. So my patch depends on changing this
> > behaviour first. (I could also store a pointer to the protocol befo=
re
> > calling unregister in my patch.)
>=20
> Right, I missed that, sorry.
>=20
> > Secondly, I must disagree with you regarding whether the memory lea=
k you
> > found is critical enough to be added to the stable trees. We're lea=
king
> > kernel memory in a deterministic and easily triggered way which cou=
ld be
> > exploited by a malicious user.
>=20
> Are you planning on sending a patch to stable-ML or should I do so? H=
ow about
> my proposal in the other mail? Could you include this fix when resend=
ing this?

This needs to go in through the bluetooth/networking trees (or their
maintainers at least) so that it gets in to 3.3, otherwise stable will
not pick it up for earlier trees.

I'll post a revised series which includes the minimal fix to the memory
leak so that all three patches can go to Linus and hopefully make it in
before 3.3 is out.=20

Sounds good?

Thanks,
Johan
