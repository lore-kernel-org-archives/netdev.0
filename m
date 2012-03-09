From: Johan Hovold <jhovold@gmail.com>
Subject: Re: [PATCH 1/2] bluetooth: hci_ldisc: fix NULL-pointer dereference
 on tty_close
Date: Fri, 9 Mar 2012 15:29:39 +0100
Message-ID: <20120309142939.GD4497@localhost>
References: <1331136120-27075-1-git-send-email-jhovold@gmail.com>
 <1331136120-27075-2-git-send-email-jhovold@gmail.com>
 <CANq1E4Sd45FtZN6NXs7TZ1k6VrFkbcAZug-1UQwW-XPB0e5Aag@mail.gmail.com>
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
In-Reply-To: <CANq1E4Sd45FtZN6NXs7TZ1k6VrFkbcAZug-1UQwW-XPB0e5Aag@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Fri, Mar 09, 2012 at 02:44:30PM +0100, David Herrmann wrote:
> On Wed, Mar 7, 2012 at 5:01 PM, Johan Hovold <jhovold@gmail.com> wrot=
e:
> > Do not close protocol driver until device has been unregistered.
> >
> > This fixes a race between tty_close and hci_dev_open which can resu=
lt in
> > a NULL-pointer dereference.
> >
> > The line discipline closes the protocol driver while we may still h=
ave
> > hci_dev_open sleeping on the req_lock mutex resulting in a NULL-poi=
nter
> > dereference when lock is acquired and hci_init_req called.

[...]

> > diff --git a/drivers/bluetooth/hci_ldisc.c b/drivers/bluetooth/hci_=
ldisc.c
> > index 0711448..6946081 100644
> > --- a/drivers/bluetooth/hci_ldisc.c
> > +++ b/drivers/bluetooth/hci_ldisc.c
> > @@ -310,11 +310,11 @@ static void hci_uart_tty_close(struct tty_str=
uct *tty)
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0hci_uart_close(hdev)=
;
> >
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (test_and_clear_bit(HCI_UART_PROT=
O_SET, &hu->flags)) {
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hu->proto->close(hu);
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (hdev) {
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0hci_=
unregister_dev(hdev);
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0hci_=
free_dev(hdev);
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hu->proto->close(hu);
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> > =A0 =A0 =A0 =A0}
> > =A0}
>=20
> I can confirm this. hci_uart_set_proto() opens the proto before it
> registers the hci device. Hence, we should also unregister the hci
> device before closing the proto. I also looked whether this introduce=
s
> other race conditions but no proto-callback can be called here as the=
y
> are all protected by the tty-layer which synchronizes all
> tty-callbacks. Therefore, I think this is the correct fix.
>=20
> We can apply this to stable even without the "destruct"-fixes from me
> as hu->proto->$cb$() doesn't care whether hdev is valid or not. I
> don't think the destruct-fixes are important enough to send them to
> stable.

Unfortunately hu is is not valid once hci_unregister returns as it will
call the destruct callback. So my patch depends on changing this
behaviour first. (I could also store a pointer to the protocol before
calling unregister in my patch.)

Secondly, I must disagree with you regarding whether the memory leak yo=
u
found is critical enough to be added to the stable trees. We're leaking
kernel memory in a deterministic and easily triggered way which could b=
e
exploited by a malicious user.

> Reviewed-by: David Herrmann <dh.herrmann@googlemail.com>

Thanks,
Johan
