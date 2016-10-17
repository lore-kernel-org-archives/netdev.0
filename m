From: "Koehrer Mathias (ETAS/ESW5)" <mathias.koehrer@etas.com>
Subject: RE: Kernel 4.6.7-rt13: Intel Ethernet driver igb causes huge
 latencies in cyclictest
Date: Mon, 17 Oct 2016 15:00:43 +0000
Message-ID: <82dcd5bb210f4f82af1e88313c3ec742@FE-MBX1012.de.bosch.com>
References: <584755c2766e4b94a604ece16760fe14@FE-MBX1012.de.bosch.com>
 <20161005155959.GH10625@jcartwri.amer.corp.natinst.com>
 <13c3cd3ffee4490fb22b8de383e51361@FE-MBX1012.de.bosch.com>
 <AAEA33E297BCAC4B9BB20A7C2DF0AB8D8045E418@FMSMSX113.amr.corp.intel.com>
 <29250f87b1d84aacb8aa312935582291@FE-MBX1012.de.bosch.com>
 <20161010193958.GE22235@jcartwri.amer.corp.natinst.com>
 <e9661abf93194ad3849e3864a8361993@FE-MBX1012.de.bosch.com>
 <b77ea8ab312149d2b20a717d3ab0a8dc@FE-MBX1012.de.bosch.com>
 <20161013161839.GV10625@jcartwri.amer.corp.natinst.com>
 <f395ea6cd1274fac83d2744121da7441@FE-MBX1012.de.bosch.com>
 <20161014195536.GB27124@jcartwri.amer.corp.natinst.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
        boundary="_003_82dcd5bb210f4f82af1e88313c3ec742FEMBX1012deboschcom_"
Cc: "Williams, Mitch A" <mitch.a.williams@intel.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "linux-rt-users@vger.kernel.org" <linux-rt-users@vger.kernel.org>,
        Sebastian Andrzej Siewior <sebastian.siewior@linutronix.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        Greg <gvrose8192@gmail.com>,
        "Matthew Garrett" <mjg59@coreos.com>,
        Bjorn Helgaas <bhelgaas@google.com>,
        "Bjorn Helgaas" <helgaas@kernel.org>
To: Julia Cartwright <julia@ni.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-v.fe.bosch.de ([139.15.237.11]:13618 "EHLO
        smtp6-v.fe.bosch.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753104AbcJQPAq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 11:00:46 -0400
In-Reply-To: <20161014195536.GB27124@jcartwri.amer.corp.natinst.com>
Content-Language: de-DE
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--_003_82dcd5bb210f4f82af1e88313c3ec742FEMBX1012deboschcom_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi Julia!
> > > Have you tested on a vanilla (non-RT) kernel?  I doubt there is
> > > anything RT specific about what you are seeing, but it might be nice
> > > to get confirmation.  Also, bisection would probably be easier if you=
 confirm on a
> vanilla kernel.
> > >
> > > I find it unlikely that it's a kernel config option that changed
> > > which regressed you, but instead was a code change to a driver.
> > > Which driver is now the question, and the surface area is still big
> > > (processor mapping attributes for this region, PCI root complex confi=
guration,
> PCI brige configuration, igb driver itself, etc.).
> > >
> > > Big enough that I'd recommend a bisection.  It looks like a
> > > bisection between 3.18 and 4.8 would take you about 18 tries to narro=
w down,
> assuming all goes well.
> > >
> >
> > I have now repeated my tests using the vanilla kernel.
> > There I got the very same issue.
> > Using kernel 4.0 is fine, however starting with kernel 4.1, the issue a=
ppears.
>=20
> Great, thanks for confirming!  That helps narrow things down quite a bit.
>=20
> > Here is my exact (reproducible) test description:
> > I applied the following patch to the kernel to get the igb trace.
> > This patch instruments the igb_rd32() function to measure the call to
> > readl() which is used to access registers of the igb NIC.
>=20
> I took your test setup and ran it between 4.0 and 4.1 on the hardware on =
my desk,
> which is an Atom-based board with dual I210s, however I didn't see much
> difference.
>=20
> However, it's a fairly simple board, with a much simpler PCI topology tha=
n your
> workstation.  I'll see if I can find some other hardware to test on.
>=20
> [..]
> > This means, that I think that some other stuff in kernel 4.1 has
> > changed, which has impact on the igb accesses.
> >
> > Any idea what component could cause this kind of issue?
>=20
> Can you continue your bisection using 'git bisect'?  You've already narro=
wed it down
> between 4.0 and 4.1, so you're well on your way.
>=20

OK - done.
And finally I was successful!
The following git commit is the one that is causing the trouble!
(The full commit is in the attachment).
+++++++++++++++++++++ BEGIN +++++++++++++++++++++++++++
commit 387d37577fdd05e9472c20885464c2a53b3c945f
Author: Matthew Garrett <mjg59@coreos.com>
Date:   Tue Apr 7 11:07:00 2015 -0700

    PCI: Don't clear ASPM bits when the FADT declares it's unsupported

    Communications with a hardware vendor confirm that the expected behavio=
ur
    on systems that set the FADT ASPM disable bit but which still grant ful=
l
    PCIe control is for the OS to leave any BIOS configuration intact and
    refuse to touch the ASPM bits.  This mimics the behaviour of Windows.

    Signed-off-by: Matthew Garrett <mjg59@coreos.com>
    Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
+++++++++++++++++++++ HEADER +++++++++++++++++++++++++++

The only files that are modified by this commit are=20
drivers/acpi/pci_root.c
drivers/pci/pcie/aspm.c
include/linux/pci-aspm.h

This is all generic PCIe stuff - however I do not really understand what
the changes of the commit are...

In my setup I am using a dual port igb Ethernet adapter.
This has an onboard PCIe switch and it might be that the configuration of t=
his
PCIe switch on the Intel board is causing the trouble.

Please see also the output of "lspci -v" in the attachment.
The relevant PCI address of the NIC is 04:00.0 / 04:00.1

Any feedback on this is welcome!

Thanks

Mathias






--_003_82dcd5bb210f4f82af1e88313c3ec742FEMBX1012deboschcom_
Content-Type: application/x-gzip;
	name="387d37577fdd05e9472c20885464c2a53b3c945f.patch.gz"
Content-Description: 387d37577fdd05e9472c20885464c2a53b3c945f.patch.gz
Content-Disposition: attachment;
	filename="387d37577fdd05e9472c20885464c2a53b3c945f.patch.gz"; size=1694;
	creation-date="Mon, 17 Oct 2016 14:59:41 GMT";
	modification-date="Mon, 17 Oct 2016 14:51:13 GMT"
Content-Transfer-Encoding: base64

H4sICGHlBFgAAzM4N2QzNzU3N2ZkZDA1ZTk0NzJjMjA4ODU0NjRjMmE1M2IzYzk0NWYucGF0Y2gA
rVf7b9pIEP4Z/xVzOSnlZTCEZ9JWebYXNS8VpF6lk6zFXsM2xsvZa5K0l//9ZnZtAhTa9FGlGHl2
Zme++eaBJ6dToWCv1/X3uu1uN/B9p837rW7Tazq9XrvVaXlN1t4b7Xn9VjuwjlI1kfE+XDKlJvwO
3rI45krBy+mncbt/6MmYy6Tmyelr65Qpvg8Aw5TD0SyGLjQa+05333Gg6TTaYDtdx7EsPAE3J+f7
cCqjFwq8kLMYjgY3lzASKoG7CY8Ar4I3R6dD8LkXspgnINSLBNIoSWczGSvuazP64wQjSiPhMSVk
hPpCTYDBhMX+HWrCnEe+jMGTUSDiKVpmSpvn9zPuoSEY8QmbC5nG2pqMIHlIFJ8m5mjC1ZM32ktf
JGwUcvIWRqlCh4U3gUSJMIRxzCIFQRqGeZicblaxDEEkEKAjZOx6AEoCBj7nwKIHOD7HN9rDcRrr
OEBEinkKpSbSmAdpwklLyRSvIysLzGqI+QTNT8VUeImWLYICGcAHgRDcJbUnzAZiHHHflkFgjx6e
ldwNWsefZBzBXzwcM5bAy9HEfDscSzkOuVGzfBEEYNtjBIvV/VjMeZzUmTcT9Zkn3FhKVfNgtE1i
oef8Hjo91g66jVqtMWq3O30PGo7TabUs27a3W7Uqlco3LB8egt1q7lV7UKFHF/CFTNW+BY8WnP19
c/1+6A4+Xh5fXxRJ1SVVmXhulk4XiVE6sMCyE4UZ82AuhQ8RH0slsA7waH6ymKg4pVTmVsgBKNNn
ldIM5Ui6LJlNq5ZdwH/mnS4L/bpkVX7bFSULvlhQSPeakFVSNednFTn2b8qR+j6GVdCm6N40AfM4
MJD129WGg5j1W9VGk0D7jfFDoYAFL32+jHTRnNzBEonkXe5usrPwnNJQKIgATKLGo9Claq2NUM8N
QjZOYBeOTm7O9Wv36tqlyilpJAqFelnDDmX4wLFrzLO6WqBCJb5oAEhHajQ8yXV0j1jvTTU40U1N
qJpV+XHb2miu+LXtC902+L3AlhONV9vGQmvRPWAWc2yBKu87QSynpoeQMnkIWqWuI1qiHbyCxoG2
5/O5K6JAFnfxm/C4/RqfmJA1r3VoYsXZKqQJXfN1f/sn2ikZ63n2zX3oDJZf4RF4iO3uy3cZseDs
zhJ/S4aq7WYby7rSbnZMdWdEJcqtcNFlvr9CUhMmlM2TaEk6OIXSUJGL2wm9qJwJQh9SzvXjFeTI
mRcHCDaZfArdqcIK9A6Bs3aEjCOnQ5hIhS7jKzOpdJly+OMVDD4OhmeX7vH19fD86i11Jyho517B
7WcWhtIrJuIzl8HGmixV4e2bG/fd2furs4scw15LY9hr/yqGmSv266kXjOl4jF6t2hhz5S6kRQOV
6bGFjY3F0GA3bx+wu9Q0Cb9nKJUMSNgEgOpmeHy6D1cctwIc3RQljwOGYdDg5lE65Ya99dVZjSOW
rOKAJcg6Tld3yI7Tq3Z+kXcFDEAi86Zyzl1/ymLiwKNGhPrdUrxYK/b2Uj3VOwuVoq7S4lrp4nBe
LdySqU+0iM5y9+meosnhKE20mGqVHHkaL5lG9qKo8d24A+Ax+s/rdG5lB1iTZDtAr+l0Ww6r1bp+
K/D8LTvAuu7qDrAupXR1e81qswUVeup06UFGOcoWPRdxuzU1lmdLS/kcyjMNL2VWy0sblofNlgyt
86tWEF66A2GGMmFt2ZTe9duxh4c4rO2MDaTtIlM99AMzh5tcGkdGrIcc8tvMJVo5NQ9wh0lnTysx
Lch6Z57gPufhLiiwEHAnoqVY0YKJrmg7NCxCnD90m8uZN3FxwsQPRe0QFhee08xDBiY05RKXTmcc
dd0t4GbaWHln7sX51Tt3MDwa4ldnAP+Z1ajwtbCxXXZy8e7msppLA4YTpQoIIc+oa+OftVydOhMa
RQTGnclQeBgT/qjAXyn4ewLKc4ZDO8vCLY8jHrozFrMplG9n2WpFdsTBKuVF5IWpz+sYa3pPBLQ1
/ybIzG2inPQsaHUaTq2G5PfancYq6bcqG9ZvFRPtm33q6/i5wvks/Fk2U1wMOxpvpj0xeF1N3mGV
4Xbimv6ok/td5Z+ps2+ruzjobrn/DCvPr8CVaPPuRm9I8idtK0tUQlf4OjgiEup7IZbMit2t9nHB
7qxNj01GfwDxbe79XJv7Qp3O3ubbc7rZ43a8VuDN7vofvM+fYLgQAAA=

--_003_82dcd5bb210f4f82af1e88313c3ec742FEMBX1012deboschcom_
Content-Type: application/x-gzip; name="lspci.gz"
Content-Description: lspci.gz
Content-Disposition: attachment; filename="lspci.gz"; size=2038;
	creation-date="Mon, 17 Oct 2016 14:59:41 GMT";
	modification-date="Mon, 17 Oct 2016 14:52:18 GMT"
Content-Transfer-Encoding: base64

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

--_003_82dcd5bb210f4f82af1e88313c3ec742FEMBX1012deboschcom_--
