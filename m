From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH V5 2/6 net-next] netdevice.h: Add zero-copy flag in netdevice
Date: Wed, 18 May 2011 14:48:24 +0200
Message-ID: <BANLkTikOsR9RUJboG1P=oG8ofr5BLbgQ4Q@mail.gmail.com>
References: <1305574680.3456.33.camel@localhost.localdomain>
 <1305575253.2885.28.camel@bwh-desktop> <20110516211459.GE18148@redhat.com>
 <1305588738.3456.65.camel@localhost.localdomain> <BANLkTimvOK3tyo6+L5AD=so5DjiDPV-AAA@mail.gmail.com>
 <1305671318.10756.49.camel@localhost.localdomain> <20110518103819.GL7589@redhat.com>
 <BANLkTimc1RbC3uQsra1HUvS_Trg63iMWGA@mail.gmail.com> <20110518111734.GO7589@redhat.com>
 <BANLkTim9RQ94MT4L0QHx-yzZT5nXdbi0aQ@mail.gmail.com> <20110518115602.GT7589@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shirley Ma <mashirle@us.ibm.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110518115602.GT7589@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

W dniu 18 maja 2011 13:56 u=BFytkownik Michael S. Tsirkin
<mst@redhat.com> napisa=B3:
> On Wed, May 18, 2011 at 01:47:33PM +0200, Micha=B3 Miros=B3aw wrote:
>> W dniu 18 maja 2011 13:17 u=BFytkownik Michael S. Tsirkin
>> <mst@redhat.com> napisa=B3:
>> > On Wed, May 18, 2011 at 01:10:50PM +0200, Micha=B3 Miros=B3aw wrot=
e:
>> >> 2011/5/18 Michael S. Tsirkin <mst@redhat.com>:
>> >> > On Tue, May 17, 2011 at 03:28:38PM -0700, Shirley Ma wrote:
>> >> >> On Tue, 2011-05-17 at 23:48 +0200, Micha=B3 Miros=B3aw wrote:
>> >> >> > 2011/5/17 Shirley Ma <mashirle@us.ibm.com>:
>> >> >> > > Hello Michael,
>> >> >> > >
>> >> >> > > Looks like to use a new flag requires more time/work. I am=
 thinking
>> >> >> > > whether we can just use HIGHDMA flag to enable zero-copy i=
n macvtap
>> >> >> > to
>> >> >> > > avoid the new flag for now since mavctap uses real NICs as=
 lower
>> >> >> > device?
>> >> >> >
>> >> >> > Is there any other restriction besides requiring driver to n=
ot recycle
>> >> >> > the skb? Are there any drivers that recycle TX skbs?
>> >> > Not just recycling skbs, keeping reference to any of the pages =
in the
>> >> > skb. Another requirement is to invoke the callback
>> >> > in a timely fashion. =A0For example virtio-net doesn't limit th=
e time until
>> >> > that happens (skbs are only freed when some other packet is
>> >> > transmitted), so we need to avoid zcopy for such (nested-virt)
>> >> > scenarious, right?
>> >> Hmm. But every hardware driver supporting SG will keep reference =
to
>> >> the pages until the packet is sent (or DMA'd to the device). This=
 can
>> >> take a long time if hardware queue happens to stall for some reas=
on.
>> > That's a fundamental property of zero copy transmit.
>> > You can't let the application/guest reuse the memory until
>> > no one looks at it anymore.
>>
>> One more question: is userspace (or whatever is sending those packet=
s)
>> denied from modifying passed pages? I assume it is, but just want to
>> be sure.
>>
>> Best Regards,
>> Micha=B3 Miros=B3aw
>
> Good point.
>
> It's not denied in the sense that it still can modify them if it's
> buggy (the pages might not be read-only).
> But well-behaved userspace won't modify them until the callback
> is invoked.
>
> That would be a problem if the underlying device is
> a bridge where we might try to e.g. filter these packets -
> data can get modified after the filter. We'd have to copy
> whatever the filter accesses and use the copy - it's rarely
> the data itself.
>
> That's not normally a problem for macvtap connected to a physical NIC=
,
> as that already bypasses any and all filtering.
>
> But that's another limitation we should note in the comment,
> and another reason to limit to specific devices.

It looks like this feature can be used only in very strict circumstance=
s.

What about tcpdump listening on the device or lowerdev? This path
might clone the skb for any device.

Best Regards,
Micha=B3 Miros=B3aw
