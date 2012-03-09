From: David Herrmann <dh.herrmann-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: Re: [PATCH 1/2] bluetooth: hci_ldisc: fix NULL-pointer dereference on tty_close
Date: Fri, 9 Mar 2012 15:35:46 +0100
Message-ID: <CANq1E4TzcQCuKomPv1bNTdkJ7LDTYjKiMqUwV8ZaoYG6FJO9Qw@mail.gmail.com>
References: <1331136120-27075-1-git-send-email-jhovold@gmail.com>
	<1331136120-27075-2-git-send-email-jhovold@gmail.com>
	<CANq1E4Sd45FtZN6NXs7TZ1k6VrFkbcAZug-1UQwW-XPB0e5Aag@mail.gmail.com>
	<20120309142939.GD4497@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	"Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johan Hovold <jhovold-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120309142939.GD4497@localhost>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 9, 2012 at 3:29 PM, Johan Hovold <jhovold-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> Hi David,
>
> On Fri, Mar 09, 2012 at 02:44:30PM +0100, David Herrmann wrote:
>> On Wed, Mar 7, 2012 at 5:01 PM, Johan Hovold <jhovold-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wro=
te:
>> > Do not close protocol driver until device has been unregistered.
>> >
>> > This fixes a race between tty_close and hci_dev_open which can res=
ult in
>> > a NULL-pointer dereference.
>> >
>> > The line discipline closes the protocol driver while we may still =
have
>> > hci_dev_open sleeping on the req_lock mutex resulting in a NULL-po=
inter
>> > dereference when lock is acquired and hci_init_req called.
>
> [...]
>
>> > diff --git a/drivers/bluetooth/hci_ldisc.c b/drivers/bluetooth/hci=
_ldisc.c
>> > index 0711448..6946081 100644
>> > --- a/drivers/bluetooth/hci_ldisc.c
>> > +++ b/drivers/bluetooth/hci_ldisc.c
>> > @@ -310,11 +310,11 @@ static void hci_uart_tty_close(struct tty_st=
ruct *tty)
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0hci_uart_close(hdev=
);
>> >
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (test_and_clear_bit(HCI_UART_PRO=
TO_SET, &hu->flags)) {
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hu->proto->close(hu)=
;
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (hdev) {
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0hci=
_unregister_dev(hdev);
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0hci=
_free_dev(hdev);
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hu->proto->close(hu)=
;
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>> > =A0 =A0 =A0 =A0}
>> > =A0}
>>
>> I can confirm this. hci_uart_set_proto() opens the proto before it
>> registers the hci device. Hence, we should also unregister the hci
>> device before closing the proto. I also looked whether this introduc=
es
>> other race conditions but no proto-callback can be called here as th=
ey
>> are all protected by the tty-layer which synchronizes all
>> tty-callbacks. Therefore, I think this is the correct fix.
>>
>> We can apply this to stable even without the "destruct"-fixes from m=
e
>> as hu->proto->$cb$() doesn't care whether hdev is valid or not. I
>> don't think the destruct-fixes are important enough to send them to
>> stable.
>
> Unfortunately hu is is not valid once hci_unregister returns as it wi=
ll
> call the destruct callback. So my patch depends on changing this
> behaviour first. (I could also store a pointer to the protocol before
> calling unregister in my patch.)

Right, I missed that, sorry.

> Secondly, I must disagree with you regarding whether the memory leak =
you
> found is critical enough to be added to the stable trees. We're leaki=
ng
> kernel memory in a deterministic and easily triggered way which could=
 be
> exploited by a malicious user.

Are you planning on sending a patch to stable-ML or should I do so? How=
 about
my proposal in the other mail? Could you include this fix when resendin=
g this?

>> Reviewed-by: David Herrmann <dh.herrmann-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
>
> Thanks,
> Johan

Regards
David
