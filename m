From: Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>
Subject: [V2 PATCH 0/5] Introduce ACPI _CCA support and device_dma_is_coherent
 API
Date: Tue, 5 May 2015 10:12:04 -0500
Message-ID: <1430838729-21572-1-git-send-email-Suravee.Suthikulpanit@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: al.stone@linaro.org, arnd@arndb.de, linaro-acpi@lists.linaro.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-acpi@vger.kernel.org, leo.duran@amd.com, hanjun.guo@linaro.org, Suravee
 Suthikulpanit <Suravee.Suthikulpanit@amd.com>, msalter@redhat.com,
 grant.likely@linaro.org, linux-arm-kernel@lists.infradead.org,
 linux-crypto@vger.kernel.org
To: <rjw@rjwysocki.net>, <lenb@kernel.org>, <catalin.marinas@arm.com>,
 <will.deacon@arm.com>, <thomas.lendacky@amd.com>,
 <herbert@gondor.apana.org.au>, <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
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

 arch/arm64/Kconfig                        |   2 +
 arch/arm64/include/asm/dma-mapping.h      |  18 +++++-
 arch/arm64/mm/dma-mapping.c               | 104 ++++++++++++++++++++++++++++++
 drivers/acpi/Kconfig                      |   6 ++
 drivers/acpi/acpi_platform.c              |   4 +-
 drivers/acpi/scan.c                       |  62 ++++++++++++++++++
 drivers/base/property.c                   |  12 ++++
 drivers/crypto/ccp/ccp-platform.c         |  60 +----------------
 drivers/net/ethernet/amd/xgbe/xgbe-main.c |  27 +-------
 include/acpi/acpi_bus.h                   |  11 +++-
 include/linux/acpi.h                      |   5 ++
 include/linux/property.h                  |   2 +
 12 files changed, 224 insertions(+), 89 deletions(-)

-- 
2.1.0
