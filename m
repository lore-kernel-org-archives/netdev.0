From: Emil Goode <emilgoode@gmail.com>
Subject: Re: [PATCH] net: asix: fix bad header length bug
Date: Fri, 7 Feb 2014 14:53:20 +0100
Message-ID: <20140207135320.GA4252@lianli>
References: <1391691384-8486-1-git-send-email-emilgoode@gmail.com>
 <1391692768.2843.4.camel@X1Carbon.localdomain>
 <063D6719AE5E284EB5DD2968C1650D6D0F6B99F7@AcuExch.aculab.com>
 <20140206224121.GB5251@lianli>
 <87wqh7i7pf.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Laight <David.Laight@ACULAB.COM>,
	'Igor Gnatenko' <i.gnatenko.brain@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ming Lei <ming.lei@canonical.com>,
	Mark Brown <broonie@linaro.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Glen Turner <gdt@gdt.id.au>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: =?utf-8?B?QmrDuHJu?= Mork <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87wqh7i7pf.fsf@nemi.mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 07, 2014 at 10:38:04AM +0100, Bj=C3=B8rn Mork wrote:
> Emil Goode <emilgoode@gmail.com> writes:
> > On Thu, Feb 06, 2014 at 03:28:13PM +0000, David Laight wrote:
> >> From: Igor Gnatenko
> >> > On Thu, 2014-02-06 at 13:56 +0100, Emil Goode wrote:
> >> > > The AX88772B occasionally send rx packets that cross urb bound=
aries
> >> > > and the remaining partial packet is sent with no header.
> >> > > When the buffer with a partial packet is of less number of oct=
ets
> >> > > than the value of hard_header_len the buffer is discarded by t=
he
> >> > > usbnet module. This is causing dropped packages and error mess=
ages
> >> > > in dmesg.
>=20
> > I will do some more digging in the code, but the test of skb->len
> > against hard_header_len is done already in the completion callback
> > function passed to usb_fill_bulk_urb so it seems that buffers of le=
ss
> > than hard_header_len number of octets will be dropped regardless.
>=20
> I am pretty sure you are right about this bug. And the exact same
> solution is already used by the cx82310_eth minidriver, so I don't se=
e
> the problem.  Your fix is fine IMHO.  But you should apply it to all =
the
> devices using asix_rx_fixup_common(), not just the ax88772 ones.
>=20
> You could maybe make this a usbnet flag instead and create a generic
> solution in usbnet, but frankly I believe the number of flags and the=
ir
> meaning have exceeded drivers authors capabilities a long time ago.  =
At
> least mine, which are quite limited ;-)
>=20
> An example of that problem is another bloody obvious bug I noticed wh=
ile
> looking at this driver: The 'struct driver_info ax88178_info' points =
to
> asix_rx_fixup_common without setting the FLAG_MULTI_PACKET.  This wil=
l
> result in usbnet rx_process() calling usbnet_skb_return() on skbs whi=
ch
> are already consumed by the minidriver.  Not a big problem, but will
> give some odd results.  But if you allow skbs shorter than ETH_HLEN t=
o
> slip through then it might go boom, so you should probably fix that a=
s
> well.
>=20
>=20
> Bj=C3=B8rn

Yes I believe the patch is necessary, but maybe it would be nice with
a prettier solution rather than setting hard_header_len to 0 for all
devices with this behaviour. Perhaps it would be better to let each
driver that uses the usbnet module decide what skbs to discard?

What David describes seems to be another bug, but I don't think it is
related to this patch as I'm able to reproduce the bug without the patc=
h
beeing applied by setting the mtu to pretty much any value other than=20
1500 and using ping with a larger packet size than that mtu value.

Best regards,

Emil Goode
