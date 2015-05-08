From: Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>
Subject: [V3 PATCH 0/5] ACPI: Introduce support for _CCA object
Date: Thu, 7 May 2015 19:37:11 -0500
Message-ID: <1431045436-8690-1-git-send-email-Suravee.Suthikulpanit@amd.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <msalter@redhat.com>, <hanjun.guo@linaro.org>,
	<al.stone@linaro.org>, <grant.likely@linaro.org>,
	<leo.duran@amd.com>, <linux-arm-kernel@lists.infradead.org>,
	<linux-acpi@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linaro-acpi@lists.linaro.org>, <netdev@vger.kernel.org>,
	<linux-crypto@vger.kernel.org>,
	"Suravee Suthikulpanit" <Suravee.Suthikulpanit@amd.com>
To: <rjw@rjwysocki.net>, <lenb@kernel.org>, <catalin.marinas@arm.com>,
	<will.deacon@arm.com>, <thomas.lendacky@amd.com>,
	<herbert@gondor.apana.org.au>, <davem@davemloft.net>,
	<arnd@arndb.de>
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series introduce support for _CCA object, which is currently
used mainly by ARM64 platform to specify DMA coherency attribute for
devices when booting with ACPI.

A copy of ACPIv6 can be found here:
    http://www.uefi.org/sites/default/files/resources/ACPI_6.0.pdf

This patch also introduces 2 new APIS:
    1. acpi_dma_is_coherent() as part of ACPI API.
    2. device_dma_is_coherent() as part of unified device property API.

This simplifies the logic in device drivers to determine device coherency
attribute regardless of booting with DT vs ACPI.

This has been tested on AMD-Seattle platform, which implements _CCA 
object as described in the AMD Opteron A1100 Series Processor ACPI Porting Guide:

http://amd-dev.wpengine.netdna-cdn.com/wordpress/media/2012/10/Seattle_ACPI_Guide.pdf

Changes from V2 (https://lkml.org/lkml/2015/5/5/510):
    * Reword ACPI_MUST_HAVE_CCA to ACPI_CCA_REQUIRED (per Rafael)
    * Reword ACPI_SUPPORT_CCA_ZERO to ARCH64_SUPPORT_ACPI_CCA_ZERO
      (per Rafael and Arnd)
    * Misc code styling clean up (per Rafael)
    * Only print missing _CCA warning message in debug mode.
    * Refactor logic in acpi_setup_device_dma() into
      if acpi_dma_is_supported() then call arch_setup_dma_ops().
    * Do not allocate device dma_mask if !acpi_dma_is_supported()
      (per Arnd).
    * Re-use the dummy functions with the same signature.

Changes from V1 (https://lkml.org/lkml/2015/4/29/290):
    * Remove supports for 32-bit ARM since doesn't currently
      supporting ACPI (Per Catalin suggestions.)
    * Do not call arch_setup_dma_ops() and when _CCA is missing.
      (per Arnd suggestion)
    * Add CONFIG_ACPI_SUPPORT_CCA_ZERO kernel config flag to
      allow architectures to specify the behavior when _CCA=0.
    * Add dummy_dma_ops for ARM64 (per Catalin suggestions).
    * Fixed build error when ACPI is not configured by defining
      acpi_dma_is_coherent() for when CONFIG_ACPI is not set.
    * Introduce device_dma_is_coherent().
    * Use device_dma_is_coherent in crypto/ccp and amd-xgbe driver.

Changes from RFC: (https://lkml.org/lkml/2015/4/1/389)
    * New logic for deriving and propagating coherent attribute from
      parent devices. (by Mark)
    * Introducing acpi_dma_is_coherent() API (Per Tom suggestion)
    * Introducing CONFIG_ACPI_MUST_HAVE_CCA kernel configuration.
    * Rebased to linux-4.1-rc1

Suravee Suthikulpanit (5):
  ACPI / scan: Parse _CCA and setup device coherency
  arm64 : Introduce support for ACPI _CCA object
  device property: Introduces device_dma_is_coherent()
  crypto: ccp - Unify coherency checking logic with
    device_dma_is_coherent()
  amd-xgbe: Unify coherency checking logic with device_dma_is_coherent()

 arch/arm64/Kconfig                        |  2 +
 arch/arm64/include/asm/dma-mapping.h      | 18 +++++-
 arch/arm64/mm/dma-mapping.c               | 92 +++++++++++++++++++++++++++++++
 drivers/acpi/Kconfig                      |  6 ++
 drivers/acpi/acpi_platform.c              | 10 +++-
 drivers/acpi/scan.c                       | 42 ++++++++++++++
 drivers/base/property.c                   | 12 ++++
 drivers/crypto/ccp/ccp-platform.c         | 60 +-------------------
 drivers/net/ethernet/amd/xgbe/xgbe-main.c | 27 +--------
 include/acpi/acpi_bus.h                   | 32 ++++++++++-
 include/linux/acpi.h                      | 10 ++++
 include/linux/property.h                  |  2 +
 12 files changed, 222 insertions(+), 91 deletions(-)

-- 
2.1.0
