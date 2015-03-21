From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 2/4] ptp/clcok:Introduce the setktime/getktime interfaces
 with "ktime_t" type
Date: Sat, 21 Mar 2015 17:52:03 +0100
Message-ID: <20150321165203.GA14320@localhost.localdomain>
References: <1426743909-24335-1-git-send-email-baolin.wang@linaro.org>
 <201503201443.42672.arnd@linaro.org>
 <20150320164951.GA25334@localhost.localdomain>
 <201503210216.41497.arnd@linaro.org>
 <20150321072407.GA4701@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Baolin Wang <baolin.wang@linaro.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, John Stultz <john.stultz@linaro.com>,
	tglx@linutronix.de
To: Arnd Bergmann <arnd@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150321072407.GA4701@netboy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 21, 2015 at 08:24:09AM +0100, Richard Cochran wrote:
> 
> I disagree with the approach presented here.  The problem at hand is
> the 2038 issue.  Let's fix that first, in the easiest way, with the
> least churn, namely by using timespec64 in place of timespec.  Once
> that is done, we can change over to ktime_t, if and when the need
> arises.

Just for laughs, I hacked up the change from timespec to timespec64,
to get an idea of the dimension.  The diffstat:

  drivers/net/ethernet/adi/bfin_mac.c              |    4 ++--
  drivers/net/ethernet/amd/xgbe/xgbe-ptp.c         |    8 ++++----
  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    4 ++--
  drivers/net/ethernet/broadcom/tg3.c              |    6 +++---
  drivers/net/ethernet/freescale/fec_ptp.c         |    4 ++--
  drivers/net/ethernet/freescale/gianfar_ptp.c     |    8 ++++----
  drivers/net/ethernet/intel/e1000e/ptp.c          |   10 +++++-----
  drivers/net/ethernet/intel/fm10k/fm10k_ptp.c     |    8 ++++----
  drivers/net/ethernet/intel/i40e/i40e_ptp.c       |   16 ++++++++++------
  drivers/net/ethernet/intel/igb/igb_ptp.c         |   22 +++++++++++++---------
  drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c     |    6 +++---
  drivers/net/ethernet/mellanox/mlx4/en_clock.c    |    6 +++---
  drivers/net/ethernet/sfc/ptp.c                   |   18 +++++++++---------
  drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c |    4 ++--
  drivers/net/ethernet/ti/cpts.c                   |    8 ++++----
  drivers/net/ethernet/tile/tilegx.c               |   11 +++++++----
  drivers/net/phy/dp83640.c                        |    7 ++++---
  drivers/ptp/ptp_chardev.c                        |    6 +++---
  drivers/ptp/ptp_ixp46x.c                         |    4 ++--
  drivers/ptp/ptp_pch.c                            |    4 ++--
  include/linux/ptp_clock_kernel.h                 |    4 ++--
  21 files changed, 90 insertions(+), 78 deletions(-)

compares favorably with Baolin's

  5 files changed, 50 insertions(+), 41 deletions(-)

considering he adapted only two drivers out of nineteen.

This exercise showed me that we really do need to convert the drivers
one by one.  Some of these drivers have 2038 issues at the hardware
level, for example because the register level representation lacks the
needed range.  Fixing the PHC API won't solve those problems.

I want flag these drivers now, so that they can be fixed later on.
Already I had been thinking about how to fix the phyter, which has a
32 seconds counter.  The solution I came up with will also help some
of the other drivers, so it will become part of the core.  However,
for that to work, I really do want to keep the timespec64
representation.

I'll reformat my changes into a proper series, to show what I mean...
 
Thanks,
Richard
