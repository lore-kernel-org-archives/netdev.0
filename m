From: Johan Hovold <jhovold-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/2 v2] bluetooth: hci_core: fix NULL-pointer dereference
 at unregister
Date: Fri, 9 Mar 2012 15:48:04 +0100
Message-ID: <20120309144804.GF4497@localhost>
References: <1331228606.14217.5.camel@aeonflux>
 <1331297594-13332-1-git-send-email-jhovold@gmail.com>
 <CANq1E4Rt0ctZ5cpXipJE--YmkR4OjKBXLBQkeTKWP3+Q-q37Yw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	"Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Herrmann <dh.herrmann-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CANq1E4Rt0ctZ5cpXipJE--YmkR4OjKBXLBQkeTKWP3+Q-q37Yw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi David,

On Fri, Mar 09, 2012 at 03:04:11PM +0100, David Herrmann wrote:
> On Fri, Mar 9, 2012 at 1:53 PM, Johan Hovold <jhovold-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrot=
e:
> > Make sure hci_dev_open returns immediately if hci_dev_unregister ha=
s
> > been called.
> >
> > This fixes a race between hci_dev_open and hci_dev_unregister which=
 can
> > lead to a NULL-pointer dereference.
> >
> > Bug is 100% reproducible using hciattach and a disconnected serial =
port:
> >
> > 0. # hciattach -n /dev/ttyO1 any noflow
> >
> > 1. hci_dev_open called from hci_power_on grabs req lock
> > 2. hci_init_req executes but device fails to initialise (times out
> > =A0 eventually)
> > 3. hci_dev_open is called from hci_sock_ioctl and sleeps on req loc=
k
> > 4. hci_uart_tty_close calls hci_dev_unregister and sleeps on req lo=
ck in
> > =A0 hci_dev_do_close
> > 5. hci_dev_open (1) releases req lock
> > 6. hci_dev_do_close grabs req lock and returns as device is not up
> > 7. hci_dev_unregister sleeps in destroy_workqueue
> > 8. hci_dev_open (3) grabs req lock, calls hci_init_req and eventual=
ly sleeps
> > 9. hci_dev_unregister finishes, while hci_dev_open is still running=
=2E..

[...]

> > diff --git a/include/net/bluetooth/hci.h b/include/net/bluetooth/hc=
i.h
> > index 00596e8..e8879b9 100644
> > --- a/include/net/bluetooth/hci.h
> > +++ b/include/net/bluetooth/hci.h
> > @@ -93,6 +93,8 @@ enum {
> > =A0* states from the controller.
> > =A0*/
> > =A0enum {
> > + =A0 =A0 =A0 HCI_UNREGISTER,
> > +
> > =A0 =A0 =A0 =A0HCI_LE_SCAN,
> > =A0};
> >
> > diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
> > index d6448f0..22b6781 100644
> > --- a/net/bluetooth/hci_core.c
> > +++ b/net/bluetooth/hci_core.c
> > @@ -525,6 +525,11 @@ int hci_dev_open(__u16 dev)
> >
> > =A0 =A0 =A0 =A0hci_req_lock(hdev);
> >
> > + =A0 =A0 =A0 if (test_bit(HCI_UNREGISTER, &hdev->dev_flags)) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -ENODEV;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto done;
> > + =A0 =A0 =A0 }
> > +
>=20
> Isn't it enough to check for HCI_RUNNING here? We obviously have a
> race here as we take the device with hci_dev_get(), then sleep and
> then we do not check whether the device is still alive. However,
> drivers are required to reset HCI_RUNNING before calling
> hci_unregister_dev() (which is bogus anyway, but its the way we
> handled it in the past) therefore it should be enough for us to check
> for HCI_RUNNING.

I'm afraid this won't work as hci_dev_open is responsible for setting
HCI_RUNNING in the first place (set in hdev->open(hdev) called from
hci_dev_open).

Thanks,
Johan
