From: Mark Salter <msalter@redhat.com>
Subject: Re: [V5 PATCH 2/5] arm64 : Introduce support for ACPI _CCA object
Date: Wed, 03 Jun 2015 11:03:09 -0400
Message-ID: <1433343789.24429.9.camel@deneb.redhat.com>
References: <1432159758-4486-1-git-send-email-Suravee.Suthikulpanit@amd.com>
	 <1432159758-4486-3-git-send-email-Suravee.Suthikulpanit@amd.com>
	 <1432867099.24429.4.camel@deneb.redhat.com> <556F1115.3080302@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kashyap.desai@avagotech.com, sumit.saxena@avagotech.com,
	uday.lingala@avagotech.com, rjw@rjwysocki.net, lenb@kernel.org,
	catalin.marinas@arm.com, will.deacon@arm.com,
	thomas.lendacky@amd.com, herbert@gondor.apana.org.au,
	davem@davemloft.net, arnd@arndb.de, hanjun.guo@linaro.org,
	al.stone@linaro.org, grant.likely@linaro.org, leo.duran@amd.com,
	linux-arm-kernel@lists.infradead.org, linux-acpi@vger.kernel.org,
	linux-kernel@vger.kernel.org, linaro-acpi@lists.linaro.org,
	netdev@vger.kernel.org, linux-crypto@vger.kernel.org,
	megaraidlinux.pdl@avagotech.com, linux-scsi@vger.kernel.org
To: Suravee Suthikulanit <suravee.suthikulpanit@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33257 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932610AbbFCPDO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jun 2015 11:03:14 -0400
In-Reply-To: <556F1115.3080302@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-06-03 at 09:37 -0500, Suravee Suthikulanit wrote:
> On 5/28/2015 9:38 PM, Mark Salter wrote:
> > On Wed, 2015-05-20 at 17:09 -0500, Suravee Suthikulpanit wrote:
> >> >Fromhttp://www.uefi.org/sites/default/files/resources/ACPI_6.0.pd=
f,
> >> >section 6.2.17 _CCA states that ARM platforms require ACPI _CCA
> >> >object to be specified for DMA-cabpable devices. Therefore, this =
patch
> >> >specifies ACPI_CCA_REQUIRED in arm64 Kconfig.
> >> >
> >> >In addition, to handle the case when _CCA is missing, arm64 would=
 assign
> >> >dummy_dma_ops to disable DMA capability of the device.
> >> >
> >> >Acked-by: Catalin Marinas<catalin.marinas@arm.com>
> >> >Signed-off-by: Mark Salter<msalter@redhat.com>
> >> >Signed-off-by: Suravee Suthikulpanit<Suravee.Suthikulpanit@amd.co=
m>
> >> >---
> >> >  arch/arm64/Kconfig                   |  1 +
> >> >  arch/arm64/include/asm/dma-mapping.h | 18 ++++++-
> >> >  arch/arm64/mm/dma-mapping.c          | 92 +++++++++++++++++++++=
+++++++++++++++
> >> >  3 files changed, 109 insertions(+), 2 deletions(-)
> >> >
> >> >diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> >> >index 4269dba..95307b4 100644
> >> >--- a/arch/arm64/Kconfig
> >> >+++ b/arch/arm64/Kconfig
> >> >@@ -1,5 +1,6 @@
> >> >  config ARM64
> >> >  	def_bool y
> >> >+	select ACPI_CCA_REQUIRED if ACPI
> >> >  	select ACPI_GENERIC_GSI if ACPI
> >> >  	select ACPI_REDUCED_HARDWARE_ONLY if ACPI
> >> >  	select ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE
> >> >diff --git a/arch/arm64/include/asm/dma-mapping.h b/arch/arm64/in=
clude/asm/dma-mapping.h
> >> >index 9437e3d..f0d6d0b 100644
> >> >--- a/arch/arm64/include/asm/dma-mapping.h
> >> >+++ b/arch/arm64/include/asm/dma-mapping.h
> >> >@@ -18,6 +18,7 @@
> >> >
> >> >  #ifdef __KERNEL__
> >> >
> >> >+#include <linux/acpi.h>
> >> >  #include <linux/types.h>
> >> >  #include <linux/vmalloc.h>
> >> >
> > ^^^ This hunk causes build issues with a couple of drivers:
> >
> > drivers/scsi/megaraid/megaraid_sas_fp.c:69:0: warning: "FALSE" rede=
fined [enabled by default]
> >   #define FALSE 0
> >   ^
> > In file included from include/acpi/acpi.h:58:0,
> >                   from include/linux/acpi.h:37,
> >                   from ./arch/arm64/include/asm/dma-mapping.h:21,
> >                   from include/linux/dma-mapping.h:86,
> >                   from ./arch/arm64/include/asm/pci.h:7,
> >                   from include/linux/pci.h:1460,
> >                   from drivers/scsi/megaraid/megaraid_sas_fp.c:37:
> > include/acpi/actypes.h:433:0: note: this is the location of the pre=
vious definition
> >   #define FALSE                           (1 =3D=3D 0)
> >   ^
> >
> >
> > In file included from include/acpi/acpi.h:58:0,
> >                   from include/linux/acpi.h:37,
> >                   from ./arch/arm64/include/asm/dma-mapping.h:21,
> >                   from include/linux/dma-mapping.h:86,
> >                   from include/scsi/scsi_cmnd.h:4,
> >                   from drivers/scsi/ufs/ufshcd.h:60,
> >                   from drivers/scsi/ufs/ufshcd.c:43:
> > include/acpi/actypes.h:433:41: error: expected identifier before =E2=
=80=98(=E2=80=99 token
> >   #define FALSE                           (1 =3D=3D 0)
> >                                           ^
> > drivers/scsi/ufs/unipro.h:203:2: note: in expansion of macro =E2=80=
=98FALSE=E2=80=99
> >    FALSE =3D 0,
> >    ^
> >
> > This happens because the ACPI definitions of TRUE and FALSE conflic=
t
> > with local definitions in megaraid and enum declaration in ufs.
> >
> Mark,
>=20
> Thanks for pointing this out. Although, I would think that the=20
> megaraid_sas_fp.c should have had the #ifndef to check before definin=
g=20
> the TRUE and FALSE as following.
>=20
> #ifndef TRUE
> #define TRUE 1
> #endif
> #ifndef FALSE
> #define FALSE 0
> #endif
>=20
> This seems to be what other drivers are also doing. If this is okay, =
I=20
> can send out a fix-up patch for the megaraid driver.
>=20

Yeah, or #undef them if defined so megaraid defines them as desired.
And #undef if defined would work for unipro.h as well.
