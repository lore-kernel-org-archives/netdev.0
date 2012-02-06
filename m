From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [patch v1, kernel version 3.2.1] rtnetlink workaround around
 the skb buff size issue
Date: Mon, 6 Feb 2012 17:29:09 +0000
Message-ID: <C5551D9AAB213A418B7FD5E4A6F30A0702F806E3@ORSMSX106.amr.corp.intel.com>
References: <5422254.3711328278789768.JavaMail.root@5-MeO-DMT.ynet.sk>
 <10521320.3761328279061644.JavaMail.root@5-MeO-DMT.ynet.sk>
 <20120203.192933.510206531351047222.davem@davemloft.net>
 <C5551D9AAB213A418B7FD5E4A6F30A0702F7F86F@ORSMSX106.amr.corp.intel.com>
 <CAGsizzLFoXdUQrA-WtdRq4FDdnDNnevyK6HCRmrT2joUV=ZRXg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?iso-8859-2?Q?=A9tefan_Gula?= <steweg@ynet.sk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGsizzLFoXdUQrA-WtdRq4FDdnDNnevyK6HCRmrT2joUV=ZRXg@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: steweg@gmail.com [mailto:steweg@gmail.com] On Behalf Of =A9tefa=
n Gula
> Sent: Monday, February 06, 2012 12:53 AM
> To: Rose, Gregory V
> Cc: David Miller; linux-kernel@vger.kernel.org; netdev@vger.kernel.or=
g
> Subject: Re: [patch v1, kernel version 3.2.1] rtnetlink workaround ar=
ound
> the skb buff size issue
>=20
> 2012/2/6 Rose, Gregory V <gregory.v.rose@intel.com>:
> >
> > The patch below is what I've got so far. =A0Right now the bit mask =
array
> is global so if you enable display of VF (n) on one interface it will
> enable display of the same VF on other interfaces. =A0I intend to mov=
e the
> bit mask array into the net_device structure so we can set the displa=
y
> mask for each interface independently.
> >
> > The command to set the filter mask is "set only", I see no reason t=
o add
> it to the info dump. =A0If other folks see it differently then I can =
do that
> too.
> >
> > Anyway, it will allow the user to control which VFs are getting
> displayed during the info dump. =A0They all default to off so initial=
ly no
> VF info gets displayed.
> >
> > I've also whipped up a patch for the iproute2 ip command. =A0It'll =
work
> like this:
> >
> > 'ip link set <dev> vf (n) filter [on|off]'
> >
> > So if you have 128 VFs on the device you could enable info dumps fo=
r
> arbitrary VFs, e.g. VFs 3, 9, 16, 21, and 31. =A0Only the info for th=
ose VFs
> would display. =A0This method has the advantage of not breaking scrip=
ts
> which parse the current VF info display. =A0Of course, one could also=
 script
> up something to sequentially enable the display of a single VF, dump =
the
> info for it, and then move on to the next.
> As this patch will allow one to filter some information and possible
> lower the need on skb buffer size, the general idea is ok. On the
> other hand it will not eliminate the problem. e.g.:
> - assume that one didn't know the limits behind it and put all option=
s
> enabled
> - it also doesn't fix the need to fill relevant info by interface
> bigger than buffer size, e.g. my macvlan interface mac address list.
> If I try to request for it, it will eventually fail with a lot of
> records even with filtering...
>=20
> So I would rather see a proper general method for requesting some
> information in cycles inside the single interface like sending reques=
t
> to kernel per VF for particular device or per MAC address from macvla=
n
> associated lists. This approach is I believe slightly more scalable a=
s
> it can be potentially reused on other types of network devices as
> well.
>=20
> My original idea was to have these methods:
> 1st kernel method will return some info about the absolute number of
> cycles needed per given interface - this can be done in standard
> GETLINK operation with some associated IFLA_* value.
> 2nd user-space method will based on that number sends netlink request
> per records or reasonable page of records (e.g. 10) and parse the
> output in the user-space.
>  - this is needed to overcome another issue when kernel generates so
> many netlink messages with NLM_F_MULTI that netlink socket will not b=
e
> able to hold and further write/read code will fail.
> 3rd kernel method, which will allocated, fill, and send required info
> per record -> this one can be done by ops/command netlink association
> (in my proposal it is DEVDUMP)
>=20
> To sum up, I believe that both approaches (using cycles and filtering=
)
> should be allowed to coexists in kernel, but they should be considere=
d
> separately as they are doing different jobs.

Stefan,

That is exactly my approach.  We currently have a *bug* in the kernel t=
hat this patch is addressing.  The kernel is attempting to provide too =
much information for the netlink interface to handle and it's breaking =
things.  So what I want to do is fix the immediate problem while still =
providing a way for folks to get the information they need.  I've accom=
plished this by doing exactly what Dave asked me to do, provide a filte=
r that defaults to off and then provide a way for the user to request d=
iscrete chunks of information in the dump that won't exceed the netlink=
 buffer limits.

The patch is fairly unobtrusive and simple to understand.

I appreciate that it doesn't do all that you'd like to see done and I s=
ee no reason why you couldn't go on and develop the extended features t=
hat you would like to see, correct?  There's nothing in my patch that w=
ould prevent that so far as I can tell, although I'm not that familiar =
with your requirements or proposals yet.

- Greg

>=20
> I can provide whole example of code (not just rtnetlink part), if the
> list is interested to see live example.
