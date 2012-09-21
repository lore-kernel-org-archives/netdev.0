From: Andres Lagar-Cavilla <andres.lagarcavilla@gmail.com>
Subject: Re: [PATCH] Xen backend support for paged out grant targets V4.
Date: Fri, 21 Sep 2012 15:30:01 -0400
Message-ID: <ACFBD23A-6B32-47F3-B71A-37F4557FDE47@gmail.com>
References: <1347632819-13684-1-git-send-email-andres@lagarcavilla.org> <1347869865.14977.15.camel@zakaz.uk.xensource.com> <5B5132A4-93B2-41D0-B1A6-048810565DB5@gridcentric.ca> <20120921185258.GA4931@phenom.dumpdata.com>
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andres Lagar-Cavilla <andreslc@gridcentric.ca>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Andres Lagar-Cavilla <andres@lagarcavilla.org>,
	xen-devel <xen-devel@lists.xen.org>,
	David Vrabel <david.vrabel@citrix.com>,
	David Miller <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120921185258.GA4931@phenom.dumpdata.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sep 21, 2012, at 2:52 PM, Konrad Rzeszutek Wilk wrote:

> On Mon, Sep 17, 2012 at 05:29:24AM -0400, Andres Lagar-Cavilla wrote:
>> On Sep 17, 2012, at 4:17 AM, Ian Campbell wrote:
>>=20
>>> (I think I forgot to hit send on this on Friday, sorry. Also
>>> s/xen.lists.org/lists.xen.org in the CC line=85)
>> I'm on a roll here=85
>>=20
>>>=20
>>> On Fri, 2012-09-14 at 15:26 +0100, Andres Lagar-Cavilla wrote:
>>>> Since Xen-4.2, hvm domains may have portions of their memory paged=
 out. When a
>>>> foreign domain (such as dom0) attempts to map these frames, the ma=
p will
>>>> initially fail. The hypervisor returns a suitable errno, and kicks=
 an
>>>> asynchronous page-in operation carried out by a helper. The foreig=
n domain is
>>>> expected to retry the mapping operation until it eventually succee=
ds. The
>>>> foreign domain is not put to sleep because itself could be the one=
 running the
>>>> pager assist (typical scenario for dom0).
>>>>=20
>>>> This patch adds support for this mechanism for backend drivers usi=
ng grant
>>>> mapping and copying operations. Specifically, this covers the blkb=
ack and
>>>> gntdev drivers (which map foregin grants), and the netback driver =
(which copies
>>>=20
>>>                          foreign
>>>=20
>>>> foreign grants).
>>>>=20
>>>> * Add a retry method for grants that fail with GNTST_eagain (i.e. =
because the
>>>> target foregin frame is paged out).
>>>=20
>>>         foreign
>>>=20
>>>> * Insert hooks with appropriate wrappers in the aforementioned dri=
vers.
>>>>=20
>>>> The retry loop is only invoked if the grant operation status is GN=
TST_eagain.
>>>> It guarantees to leave a new status code different from GNTST_eaga=
in. Any other
>>>> status code results in identical code execution as before.
>>>>=20
>>>> The retry loop performs 256 attempts with increasing time interval=
s through a
>>>> 32 second period. It uses msleep to yield while waiting for the ne=
xt retry.
>>> [...]
>>>> Signed-off-by: Andres Lagar-Cavilla <andres@lagarcavilla.org>
>>>=20
>>> Acked-by: Ian Campbell <ian.campbell@citrix.com>
>>>=20
>>> Since this is more about grant tables than netback this should prob=
ably
>>> go via Konrad rather than Dave, is that OK with you Dave?
>>=20
>> If that is the case hopefully Konrad can deal with the two typos? Ot=
herwise happy to re-spin the patch.
>=20
> So with this patch when I launch an PVHVM guest on Xen 4.1 I get this
> in the initial domain and the guest is crashed:
>=20
> [  261.927218] privcmd_fault: vma=3Dffff88002a31dce8 7f4edc095000-7f4=
edc195000, pgoff=3Dc8, uv=3D00007f4edc15d000

With this patch? Or with the mmapbatch v2? This is a page fault in a fo=
reign-mapped VMA. Not touched by this grant backend patch we are talkin=
g about.

Does the hypervisor dump anything to its console?

At which point during xc_hvm_build do you see this? (or elsewhere in th=
e toolstack?)

Thanks
Andres

>=20
> guest config:
>> more /mnt/lab/latest/hvm.xm=20
> kernel =3D "/usr/lib/xen/boot/hvmloader"
> builder=3D'hvm'
> memory=3D1024
> #maxmem=3D1024
> maxvcpus =3D 2
> serial=3D'pty'
> vcpus =3D 2
> disk =3D [ 'file:/mnt/lab/latest/root_image.iso,hdc:cdrom,r']
> boot=3D"dn"
> #vif =3D [ 'type=3Dioemu,model=3De1000,mac=3D00:0F:4B:00:00:71, bridg=
e=3Dswitch' ]
> vif =3D [ 'type=3Dnetfront, bridge=3Dswitch' ]
> #vfb =3D [ 'vnc=3D1, vnclisten=3D0.0.0.0 ,vncunused=3D1']
> vnc=3D1
> vnclisten=3D"0.0.0.0"
> usb=3D1
> xen_platform_pci=3D1
>=20
>=20
