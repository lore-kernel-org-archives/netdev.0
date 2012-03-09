From: David Herrmann <dh.herrmann@googlemail.com>
Subject: Re: [PATCH 1/2] bluetooth: hci_ldisc: fix NULL-pointer dereference on tty_close
Date: Fri, 9 Mar 2012 16:02:21 +0100
Message-ID: <CANq1E4TcUKKXetitjWJZgP9550gnB43rncnAcwwdz_6HpZf_Ug@mail.gmail.com>
References: <1331136120-27075-1-git-send-email-jhovold@gmail.com>
	<1331136120-27075-2-git-send-email-jhovold@gmail.com>
	<1331148797.3392.191.camel@aeonflux>
	<20120308115721.GB4497@localhost>
	<1331228722.14217.7.camel@aeonflux>
	<20120309130413.GC4497@localhost>
	<CANq1E4RjnCdUfZuKawHs2te9wX30H-boC5tUPFarBCVbtn2n5Q@mail.gmail.com>
	<20120309144013.GE4497@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Marcel Holtmann <marcel@holtmann.org>,
	"Gustavo F. Padovan" <padovan@profusion.mobi>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, stable <stable@vger.kernel.org>
To: Johan Hovold <jhovold@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120309144013.GE4497@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 9, 2012 at 3:40 PM, Johan Hovold <jhovold@gmail.com> wrote:
> On Fri, Mar 09, 2012 at 02:52:00PM +0100, David Herrmann wrote:
>> On Fri, Mar 9, 2012 at 2:04 PM, Johan Hovold <jhovold@gmail.com> wro=
te:
>> > On Thu, Mar 08, 2012 at 09:45:22AM -0800, Marcel Holtmann wrote:
>> >> > > > Do not close protocol driver until device has been unregist=
ered.
>> >> > > >
>> >> > > > This fixes a race between tty_close and hci_dev_open which =
can result in
>> >> > > > a NULL-pointer dereference.
>> >> > > >
>> >> > > > The line discipline closes the protocol driver while we may=
 still have
>> >> > > > hci_dev_open sleeping on the req_lock mutex resulting in a =
NULL-pointer
>> >> > > > dereference when lock is acquired and hci_init_req called.
>> >> >
>> >> > [...]
>> >> >
>> >> > > what kernel version is this against? Our changes in bluetooth=
-next fixed
>> >> > > some of the destruct handling.
>> >> >
>> >> > This is against the latest rc as it needs to be fixed in 3.3, b=
ut I
>> >> > missed a dependency to bluetooth-next as you point out below.
>> >> >
>> >> > > Also hci_unregister_dev should be calling the destruct handle=
r and thus
>> >> > > your change is now accessing hu but it got freed already.
>> >> >
>> >> > You're right, my patch depends on 010666a126fc ("Bluetooth: Mak=
e
>> >> > hci-destruct callback optional") and 797fe796c4 ("Bluetooth: ua=
rt-ldisc:
>> >> > Fix memory leak and remove destruct cb") from bluetooth-next.
>> >> >
>> >> > But since the latter one fixes a memory leak it should have bee=
n marked
>> >> > for stable as well as pushed to Linus for 3.3, right?
>> >>
>> >> we need to look into this and propose patches for -stable. Is you=
r
>> >> problem still present with bluetooth-next or not?
>> >
>> > Yes, both races are present in bluetooth-next of today (b8622cbd58=
f34)
>> > and only takes an additional manual step to trigger (as the core n=
o
>> > longer tries to open the device twice automatically).
>> >
>> > My two patches on top of either the two patches by David Herrmann
>> > mentioned above or the following minimal fix of the same memory le=
ak
>> > would be sufficient to fix both races in 3.3:
>> >
>> > diff --git a/drivers/bluetooth/hci_ldisc.c b/drivers/bluetooth/hci=
_ldisc.c
>> > index 0711448..97c5faa 100644
>> > --- a/drivers/bluetooth/hci_ldisc.c
>> > +++ b/drivers/bluetooth/hci_ldisc.c
>> > @@ -237,7 +237,6 @@ static void hci_uart_destruct(struct hci_dev *=
hdev)
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
>> >
>> > =A0 =A0 =A0 =A0BT_DBG("%s", hdev->name);
>> > - =A0 =A0 =A0 kfree(hdev->driver_data);
>> > =A0}
>> >
>> > =A0/* ------ LDISC part ------ */
>> > @@ -316,6 +315,7 @@ static void hci_uart_tty_close(struct tty_stru=
ct *tty)
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0hci=
_free_dev(hdev);
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(hu);
>> > =A0 =A0 =A0 =A0}
>> > =A0}
>>
>> The "destruct"-callback was broken in many ways but working around i=
t
>> without removing it seems wrong.
>
> The reason for not doing so would be to keep the fixes minimal and th=
us
> more appropriate for the stable trees.
>
> Furthermore, according to you patch own description "Several drivers
> already provide an empty callback" so I didn't consider it to be
> a problem.

It's just a proposal, feel free to keep your patch. But please include
a comment in your commit-message that you explicitly avoid using the
destruct-callback as it is, and always was, broken. Otherwise, it looks
wrong seeing such a commit.
Or simply link to the patches that remove the destruct callback in the
-next tree.

>> This memory-leak occurs only if a
>> tty-device uses the uart-ldisc without a protocol bound to it.
>> Therefore, I didn't consider it important enough for stable.
>
> See my answer to you previous mail regarding this.
>
>> However,
>> if you want to fix this, leave the kfree() inside the destruct
>> callback but add another kfree() into the hci_uart_close() in an
>> "else"-clause like this:
>>
>> if (test_and_clear_bit(...)) {
>> } else {
>> + =A0 kfree(...);
>> }
>
> You really don't want to free the hci_uart in it's own close method..=
=2E
>
> The hci_uart is allocated in tty_open and should be freed in tty_clos=
e.

Oops, I obviously meant hci_uart_tty_close(), sorry.

>> This will still keep the bogus ref-counts inside hci_dev with the
>> destruct() callback but will also free the ldisc if no protocol is
>> set.
>
> Thanks,
> Johan
