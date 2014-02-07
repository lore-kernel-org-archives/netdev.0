From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] net: asix: fix bad header length bug
Date: Fri, 07 Feb 2014 10:38:04 +0100
Message-ID: <87wqh7i7pf.fsf@nemi.mork.no>
References: <1391691384-8486-1-git-send-email-emilgoode@gmail.com>
	<1391692768.2843.4.camel@X1Carbon.localdomain>
	<063D6719AE5E284EB5DD2968C1650D6D0F6B99F7@AcuExch.aculab.com>
	<20140206224121.GB5251@lianli>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Laight <David.Laight@ACULAB.COM>,
	"'Igor Gnatenko'" <i.gnatenko.brain@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ming Lei <ming.lei@canonical.com>,
	Mark Brown <broonie@linaro.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Glen Turner <gdt@gdt.id.au>,
	"linux-usb\@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Emil Goode <emilgoode@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140206224121.GB5251@lianli> (Emil Goode's message of "Thu, 6
	Feb 2014 23:41:21 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Emil Goode <emilgoode@gmail.com> writes:
> On Thu, Feb 06, 2014 at 03:28:13PM +0000, David Laight wrote:
>> From: Igor Gnatenko
>> > On Thu, 2014-02-06 at 13:56 +0100, Emil Goode wrote:
>> > > The AX88772B occasionally send rx packets that cross urb boundar=
ies
>> > > and the remaining partial packet is sent with no header.
>> > > When the buffer with a partial packet is of less number of octet=
s
>> > > than the value of hard_header_len the buffer is discarded by the
>> > > usbnet module. This is causing dropped packages and error messag=
es
>> > > in dmesg.

> I will do some more digging in the code, but the test of skb->len
> against hard_header_len is done already in the completion callback
> function passed to usb_fill_bulk_urb so it seems that buffers of less
> than hard_header_len number of octets will be dropped regardless.

I am pretty sure you are right about this bug. And the exact same
solution is already used by the cx82310_eth minidriver, so I don't see
the problem.  Your fix is fine IMHO.  But you should apply it to all th=
e
devices using asix_rx_fixup_common(), not just the ax88772 ones.

You could maybe make this a usbnet flag instead and create a generic
solution in usbnet, but frankly I believe the number of flags and their
meaning have exceeded drivers authors capabilities a long time ago.  At
least mine, which are quite limited ;-)

An example of that problem is another bloody obvious bug I noticed whil=
e
looking at this driver: The 'struct driver_info ax88178_info' points to
asix_rx_fixup_common without setting the FLAG_MULTI_PACKET.  This will
result in usbnet rx_process() calling usbnet_skb_return() on skbs which
are already consumed by the minidriver.  Not a big problem, but will
give some odd results.  But if you allow skbs shorter than ETH_HLEN to
slip through then it might go boom, so you should probably fix that as
well.


Bj=C3=B8rn
