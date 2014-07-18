From: James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: [PATCH 0/25] Replace DEFINE_PCI_DEVICE_TABLE macro use
Date: Fri, 18 Jul 2014 11:50:21 -0700
Message-ID: <1405709421.30262.8.camel@dabdike.int.hansenpartnership.com>
References: <1405697232-11785-1-git-send-email-benoit.taine@lip6.fr>
	 <20140718162213.GC31114@tuxdriver.com> <20140718164340.GA24960@kroah.com>
	 <1405702472.30262.1.camel@dabdike.int.hansenpartnership.com>
	 <20140718181759.GB2193@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Benoit Taine <benoit.taine@lip6.fr>, linux-mips@linux-mips.org,
	linux-fbdev@vger.kernel.org, linux-pci@vger.kernel.org,
	dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org,
	ath5k-devel@venema.h4ckr.net, linux-acenic@sunsite.dk,
	linux-scsi@vger.kernel.org, linux-rdma@vger.kernel.org,
	ath10k@lists.infradead.org, linux-hippi@sunsite.dk,
	industrypack-devel@lists.sourceforge.net,
	linux-mmc@vger.kernel.org, MPT-FusionLinux.pdl@avagotech.com,
	virtualization@lists.linux-foundation.org,
	ath9k-devel@venema.h4ckr.net, wil6210@qca.qualcomm.com,
	linux-pcmcia@lists.infradead.org, linux-can@vger.kernel.org,
	xen-devel@lists.xenproject.org,
	platform-driver-x86@vger.kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, users@rt2x00.serialmonkey.com,
	e1000-devel@lists.sourceforge.net, linux-crypto@vger.kernel.org,
	deve
To: Greg KH <greg@kroah.com>
Return-path: <linux-mmc-owner@vger.kernel.org>
In-Reply-To: <20140718181759.GB2193@kroah.com>
Sender: linux-mmc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-07-18 at 11:17 -0700, Greg KH wrote:
> On Fri, Jul 18, 2014 at 09:54:32AM -0700, James Bottomley wrote:
> > On Fri, 2014-07-18 at 09:43 -0700, Greg KH wrote:
> > > On Fri, Jul 18, 2014 at 12:22:13PM -0400, John W. Linville wrote:
> > > > On Fri, Jul 18, 2014 at 05:26:47PM +0200, Benoit Taine wrote:
> > > > > We should prefer `const struct pci_device_id` over
> > > > > `DEFINE_PCI_DEVICE_TABLE` to meet kernel coding style guideli=
nes.
> > > > > This issue was reported by checkpatch.
> > > >=20
> > > > Honestly, I prefer the macro -- it stands-out more.  Maybe the =
style
> > > > guidelines and/or checkpatch should change instead?
> > >=20
> > > The macro is horrid, no other bus has this type of thing just to =
save a
> > > few characters in typing
> >=20
> > OK, so this is the macro:
> >=20
> > #define DEFINE_PCI_DEVICE_TABLE(_table) \
> > 	const struct pci_device_id _table[]
> >=20
> > Could you explain what's so horrible?
> >=20
> > The reason it's useful today is that people forget the const (and
> > sometimes the [] making it a true table instead of a pointer).  If =
you
> > use the DEFINE_PCI_DEVICE_TABLE macro, the compile breaks if you us=
e it
> > wrongly (good) and you automatically get the correct annotations.
>=20
> We have almost 1000 more uses of the non-macro version than the "macr=
o"
> version in the kernel today:
> $ git grep -w DEFINE_PCI_DEVICE_TABLE | wc -l
> 262
> $ git grep "const struct pci_device_id" | wc -l
> 1254
>=20
> My big complaint is that we need to be consistant, either pick one or
> the other and stick to it.  As the macro is the least used, it's easi=
est
> to fix up, and it also is more consistant with all other kernel
> subsystems which do not have such a macro.

I've a weak preference for consistency, but not at the expense of
hundreds of patches churning the kernel to remove an innocuous macro.
Churn costs time and effort.

> As there is no need for the __init macro mess anymore, there's no rea=
l
> need for the DEFINE_PCI_DEVICE_TABLE macro either.  I think checkpatc=
h
> will catch the use of non-const users for the id table already today,=
 it
> catches lots of other uses like this already.
>=20
> > > , so why should PCI be "special" in this regard
> > > anymore?
> >=20
> > I think the PCI usage dwarfs most other bus types now, so you could=
 turn
> > the question around.  However, I don't think majority voting is a g=
ood
> > guide to best practise; lets debate the merits for their own sake.
>=20
> Not really "dwarf", USB is close with over 700 such structures:
> $ git grep "const struct usb_device_id" | wc -l
> 725
>=20
> And i2c is almost just as big as PCI:
> $ git grep "const struct i2c_device_id" | wc -l
> 1223
>=20
> So again, this macro is not consistent with the majority of PCI drive=
rs,
> nor with any other type of "device id" declaration in the kernel, whi=
ch
> is why I feel it should be removed.
>=20
> And finally, the PCI documentation itself says to not use this macro,=
 so
> this isn't a "new" thing.  From Documentation/PCI/pci.txt:
>=20
> 	The ID table is an array of struct pci_device_id entries ending with=
 an
> 	all-zero entry.  Definitions with static const are generally preferr=
ed.
> 	Use of the deprecated macro DEFINE_PCI_DEVICE_TABLE should be avoide=
d.
>=20
> That wording went into the file last December, when we last talked ab=
out
> this and everyone in that discussion agreed to remove the macro for t=
he
> above reasons.
>=20
> Consistency matters.

In this case, I don't think it does that much ... a cut and paste eithe=
r
way (from a macro or non-macro based driver) yields correct code.  Sinc=
e
there's no bug here and no apparent way to misuse the macro, why bother=
?

Anyway, it's PCI code ... let the PCI maintainer decide.  However, if h=
e
does want this do it as one big bang patch via either the PCI or Trivia=
l
tree (latter because Ji=C5=99=C3=AD has experience doing this, but the =
former
might be useful so the decider feels the pain ...)

James


