From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 00/18] Export SPI and OF module aliases in missing drivers
Date: Thu, 20 Aug 2015 09:07:13 +0200
Message-ID: <1440054451-1223-1-git-send-email-javier@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-fbdev@vger.kernel.org, linux-iio@vger.kernel.org,
 linux-mmc@vger.kernel.org, Krzysztof Kozlowski <k.kozlowski@samsung.com>,
 Andrzej Hajda <a.hajda@samsung.com>, netdev@vger.kernel.org,
 linux-mtd@lists.infradead.org, Peter Meerwald <pmeerw@pmeerw.net>,
 Lee Jones <lee.jones@linaro.org>,
 Aloisio Almeida Jr <aloisio.almeida@openbossa.org>, devel@driverdev.osuosl.org,
 Lars-Peter Clausen <lars@metafoo.de>, Stephen Warren <swarren@nvidia.com>,
 Samuel Ortiz <sameo@linux.intel.com>,
 =?UTF-8?q?S=C3=B8ren=20Andersen?= <san@rosetechnology.dk>,
 Andrea Galbusera <gizero@gmail.com>, Antonio Borneo <borneo.antonio@gmail.com>,
 Javier Martinez Canillas <javier@osg.samsung.com>,
 Tomi Valkeinen <tomi.valkeinen@ti.com>, Ulf Hansson <ulf.hansson@linaro.org>,
 Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
 linux-media@vger.kernel.org, Michael Hennerich <Michael.Hennerich@analog
To: linux-kernel@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Hello,

Short version:

This patch series is the SPI equivalent of the I2C one posted before [0].

This series add the missing MODULE_DEVICE_TABLE() for OF and SPI tables
to export that information so modules have the correct aliases built-in
and autoloading works correctly.

Longer version:

The SPI core always reports the MODALIAS uevent as "spi:<modalias>"
regardless of the mechanism that was used to register the device (i.e:
OF or board code) and the table that is used later to match the driver
with the device (i.e: SPI id table or OF match table).

But this means that OF-only drivers needs to have both OF and SPI id
tables that have to be kept in sync and also the device node's compatible
manufacturer prefix is stripped when reporting the MODALIAS. Which can
lead to issues if two vendors use the same SPI device name for example.

Also, there are many SPI drivers whose module auto-loading is not working
because of this fact that the SPI core always reports the MODALIAS as
spi:<modalias> and many developers didn't expect this since is not how
other subsystems behave.

I've identified SPI drivers with 3 types of different issues:

a) Those that have an spi_table but are not exported. The match works
   if the driver is built-in but since the ID table is not exported,
   module auto-load won't work.

b) Those that have a of_table but are not exported. This is currently
   not an issue since even when the of_table is used to match the dev
   with the driver, an OF modalias is not reported by the SPI core.
   But if the SPI core is changed to report the MODALIAS of the form
   of:N*T*C as it's made by other subsystems, then module auto-load
   will break for these drivers.

c) Those that don't have an of_table but should since are OF drivers
   with DT bindings doc for them. Since the SPI core does not report
   a OF modalias and since spi_match_device() fallbacks to match the
   device part of the compatible string with the SPI device ID table,
   many OF drivers don't have an of_table to match. After all having
   a SPI device ID table is mandatory so it works without a of_table.

So, in order to not make mandatory to have a SPI device ID table, all
these three kind of issues have to be addressed. This series does that.

I split the changes so the patches in this series are independent and
can be picked individually by subsystem maintainers.

Patches #1 and #2 solves a), patches #3 to #8 solves b) and patches

Patch #18 changes the logic of spi_uevent() to report an OF modalias if
the device was registered using OF. But this patch is included in the
series only as an RFC for illustration purposes since changing that
without first applying all the other patches in this series, will break
module autoloading for the drivers of devices registered using OF but
that lacks an of_match_table. I'll repost patch #18 once all the patches
in this series have landed.

[0]: https://lkml.org/lkml/2015/7/30/519

Best regards,
Javier


Javier Martinez Canillas (18):
  iio: Export SPI module alias information in missing drivers
  staging: iio: hmc5843: Export missing SPI module alias information
  mtd: dataflash: Export OF module alias information
  OMAPDSS: panel-sony-acx565akm: Export OF module alias information
  mmc: mmc_spi: Export OF module alias information
  staging: mt29f_spinand: Export OF module alias information
  net: ks8851: Export OF module alias information
  [media] s5c73m3: Export OF module alias information
  mfd: cros_ec: spi: Add OF match table
  iio: dac: ad7303: Add OF match table
  iio: adc: max1027: Set struct spi_driver .of_match_table
  mfd: stmpe: Add OF match table
  iio: adc: mcp320x: Set struct spi_driver .of_match_table
  iio: as3935: Add OF match table
  iio: adc128s052: Add OF match table
  iio: frequency: adf4350: Add OF match table
  NFC: trf7970a: Add OF match table
  spi: (RFC, don't apply) report OF style modalias when probing using DT

 drivers/iio/adc/max1027.c                                   |  1 +
 drivers/iio/adc/mcp320x.c                                   |  1 +
 drivers/iio/adc/ti-adc128s052.c                             |  8 ++++++++
 drivers/iio/amplifiers/ad8366.c                             |  1 +
 drivers/iio/dac/ad7303.c                                    |  7 +++++++
 drivers/iio/frequency/adf4350.c                             |  9 +++++++++
 drivers/iio/proximity/as3935.c                              |  7 +++++++
 drivers/media/i2c/s5c73m3/s5c73m3-spi.c                     |  1 +
 drivers/mfd/cros_ec_spi.c                                   |  7 +++++++
 drivers/mfd/stmpe-spi.c                                     | 13 +++++++++++++
 drivers/mmc/host/mmc_spi.c                                  |  1 +
 drivers/mtd/devices/mtd_dataflash.c                         |  1 +
 drivers/net/ethernet/micrel/ks8851.c                        |  1 +
 drivers/nfc/trf7970a.c                                      |  7 +++++++
 drivers/spi/spi.c                                           |  8 ++++++++
 drivers/staging/iio/magnetometer/hmc5843_spi.c              |  1 +
 drivers/staging/mt29f_spinand/mt29f_spinand.c               |  1 +
 .../video/fbdev/omap2/displays-new/panel-sony-acx565akm.c   |  1 +
 18 files changed, 76 insertions(+)

-- 
2.4.3
