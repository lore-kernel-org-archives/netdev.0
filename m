From: Haicheng Li <haicheng.li@linux.intel.com>
Subject: Re: [net:master 1/9] pch_gbe_main.c:(.text+0x510370): undefined reference
 to `pch_ch_control_write'
Date: Sat, 06 Oct 2012 20:07:08 +0800
Message-ID: <50701EEC.7080805@linux.intel.com>
References: <20121006075954.GA29618@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121006075954.GA29618@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The failure is due to the CONFIG_PPS is not set there, consequently 
CONFIG_PTP_1588_CLOCK can not be set as =y anyway.

So David's patch of "da1586461e53a4dd045738cce309ab488970f0ef [1/9] pch_gbe: 
Fix PTP dependencies" is buggy. Furthermore, I think using "selects" to 
resolve such dependency issue is not good idea as it won't visit the dependencies.

David, I would still suggest to take my original patch:
https://lkml.org/lkml/2012/9/28/70

+    depends on PTP_1588_CLOCK_PCH && (PCH_GBE=m || PTP_1588_CLOCK_PCH=y)

or simply like:
---
From: Haicheng Li <haicheng.lee@gmail.com>

Fix build error caused by broken PCH_PTP module dependency.
The .config is:
         CONFIG_PCH_GBE=y
         CONFIG_PCH_PTP=y
         CONFIG_PTP_1588_CLOCK=m

The build error:

drivers/built-in.o: In function `pch_tx_timestamp':
.../pch_gbe_main.c:215: undefined reference to `pch_ch_event_read'
.../pch_gbe_main.c:225: undefined reference to `pch_tx_snap_read'
.../pch_gbe_main.c:231: undefined reference to `pch_ch_event_write'

.../pch_gbe_main.c:170: undefined reference to `pch_ch_event_read'
.../pch_gbe_main.c:175: undefined reference to `pch_src_uuid_lo_read'
.../pch_gbe_main.c:176: undefined reference to `pch_src_uuid_hi_read'
.../pch_gbe_main.c:190: undefined reference to `pch_ch_event_write'
.../pch_gbe_main.c:184: undefined reference to `pch_rx_snap_read'

.../pch_gbe_main.c:267: undefined reference to `pch_ch_control_write'
.../pch_gbe_main.c:271: undefined reference to `pch_ch_control_write'
.../pch_gbe_main.c:275: undefined reference to `pch_ch_control_write'
.../pch_gbe_main.c:281: undefined reference to `pch_ch_control_write'
.../pch_gbe_main.c:283: undefined reference to `pch_set_station_address'
.../pch_gbe_main.c:290: undefined reference to `pch_ch_event_write'

Signed-off-by: Haicheng Li <haicheng.lee@gmail.com>
---
  drivers/net/ethernet/oki-semi/pch_gbe/Kconfig |    4 ++--
  1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig 
b/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
index bce0164..df1e649 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
@@ -21,12 +21,12 @@ config PCH_GBE
        ML7223/ML7831 is companion chip for Intel Atom E6xx series.
        ML7223/ML7831 is completely compatible for Intel EG20T PCH.

-if PCH_GBE
+if PTP_1588_CLOCK_PCH

  config PCH_PTP
      bool "PCH PTP clock support"
      default n
-    depends on PTP_1588_CLOCK_PCH
+    depends on PTP_1588_CLOCK_PCH=y || PCH_GBE=m
      ---help---
        Say Y here if you want to use Precision Time Protocol (PTP) in the
        driver. PTP is a method to precisely synchronize distributed clocks



On 10/06/2012 03:59 PM, Fengguang Wu wrote:
> Hi David,
>
> FYI, kernel build failed on
>
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master
> head:   c0b8b99287235626a5850ef7e5bfc842d1ebcecd
> commit: da1586461e53a4dd045738cce309ab488970f0ef [1/9] pch_gbe: Fix PTP dependencies.
> config: x86_64-randconfig-s052 (attached as .config)
>
> All error/warnings:
>
> drivers/built-in.o: In function `pch_gbe_ioctl':
> pch_gbe_main.c:(.text+0x510370): undefined reference to `pch_ch_control_write'
> pch_gbe_main.c:(.text+0x510393): undefined reference to `pch_ch_control_write'
> pch_gbe_main.c:(.text+0x5103b3): undefined reference to `pch_ch_control_write'
> pch_gbe_main.c:(.text+0x5103e1): undefined reference to `pch_set_station_address'
> pch_gbe_main.c:(.text+0x510403): undefined reference to `pch_ch_control_write'
> pch_gbe_main.c:(.text+0x510431): undefined reference to `pch_set_station_address'
> pch_gbe_main.c:(.text+0x51043e): undefined reference to `pch_ch_event_write'
> drivers/built-in.o: In function `pch_gbe_xmit_frame':
> pch_gbe_main.c:(.text+0x510fe4): undefined reference to `pch_ch_event_read'
> pch_gbe_main.c:(.text+0x511049): undefined reference to `pch_tx_snap_read'
> pch_gbe_main.c:(.text+0x51106f): undefined reference to `pch_ch_event_write'
> drivers/built-in.o: In function `pch_gbe_napi_poll':
> pch_gbe_main.c:(.text+0x511537): undefined reference to `pch_ch_event_read'
> pch_gbe_main.c:(.text+0x511562): undefined reference to `pch_src_uuid_lo_read'
> pch_gbe_main.c:(.text+0x51156d): undefined reference to `pch_src_uuid_hi_read'
> pch_gbe_main.c:(.text+0x511659): undefined reference to `pch_ch_event_write'
> pch_gbe_main.c:(.text+0x511dc1): undefined reference to `pch_rx_snap_read'
>
> ---
> 0-DAY kernel build testing backend         Open Source Technology Center
> Fengguang Wu, Yuanhan Liu                              Intel Corporation
