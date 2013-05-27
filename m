From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 4/4] igb: enable auxiliary PHC
	functions for the i210.
Date: Mon, 27 May 2013 11:21:45 +0200
Message-ID: <cfbb4fdcf968d81b2211b97c75c9b5bf820570e4.1369645944.git.richardcochran@gmail.com>
References: <cover.1369645944.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, Jacob Keller <jacob.e.keller@intel.com>,
	David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <cover.1369645944.git.richardcochran@gmail.com>
In-Reply-To: <cover.1369645944.git.richardcochran@gmail.com>
References: <cover.1369645944.git.richardcochran@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The i210 device offers a number of special PTP Hardware Clock features on
the Software Defined Pins (SDPs). This patch adds support for three of the
possible functions, namely time stamping external events, a periodic
output signal, and an internal PPS event for adjusting the kernel system
time.

A pair of module parameters lets the user choose which of the four SDPs
will be used as the input signal and which as the output.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/intel/igb/igb.h      |    2 +
 drivers/net/ethernet/intel/igb/igb_main.c |   30 ++++++
 drivers/net/ethernet/intel/igb/igb_ptp.c  |  157 ++++++++++++++++++++++++++++-
 3 files changed, 188 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 15ea8dc..802b79c 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -435,6 +435,8 @@ struct igb_adapter {
 	struct timecounter tc;
 	u32 tx_hwtstamp_timeouts;
 	u32 rx_hwtstamp_cleared;
+	struct timespec start;
+	struct timespec period;
 
 	char fw_version[32];
 #ifdef CONFIG_IGB_HWMON
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index d25a965..58120cd 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -5038,12 +5038,42 @@ void igb_update_stats(struct igb_adapter *adapter,
 static void igb_tsync_interrupt(struct igb_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
+	struct ptp_clock_event event;
 	u32 tsicr = rd32(E1000_TSICR);
 
+	if (tsicr & TSINTR_SYS_WRAP) {
+		event.type = PTP_CLOCK_PPS;
+		ptp_clock_event(adapter->ptp_clock, &event);
+	}
+
 	if (tsicr & E1000_TSICR_TXTS) {
 		/* retrieve hardware timestamp */
 		schedule_work(&adapter->ptp_tx_work);
 	}
+
+	if (tsicr & TSINTR_TT0) {
+		struct timespec ts;
+		u32 tsauxc;
+		spin_lock(&adapter->tmreg_lock);
+		ts = timespec_add(adapter->start, adapter->period);
+		wr32(E1000_TRGTTIML0, ts.tv_nsec);
+		wr32(E1000_TRGTTIMH0, ts.tv_sec);
+		tsauxc = rd32(E1000_TSAUXC);
+		tsauxc |= TSAUXC_EN_TT0;
+		wr32(E1000_TSAUXC, tsauxc);
+		adapter->start = ts;
+		spin_unlock(&adapter->tmreg_lock);
+	}
+
+	if (tsicr & TSINTR_AUTT0) {
+		u32 sec, nsec;
+		nsec = rd32(E1000_AUXSTMPL0);
+		sec  = rd32(E1000_AUXSTMPH0);
+		event.type = PTP_CLOCK_EXTTS;
+		event.index = 0;
+		event.timestamp = sec * 1000000000ULL + nsec;
+		ptp_clock_event(adapter->ptp_clock, &event);
+	}
 }
 
 static irqreturn_t igb_msix_other(int irq, void *data)
diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index 5944de0..8cf4b8a 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -23,6 +23,15 @@
 
 #include "igb.h"
 
+static int igb_input_sdp = 0;
+static int igb_output_sdp = 1;
+module_param(igb_input_sdp, int, 0444);
+module_param(igb_output_sdp, int, 0444);
+MODULE_PARM_DESC(igb_input_sdp,
+		 "The SDP used as an input, to time stamp external events");
+MODULE_PARM_DESC(igb_output_sdp,
+		 "The SDP used to output the programmable periodic signal");
+
 #define INCVALUE_MASK		0x7fffffff
 #define ISGN			0x80000000
 
@@ -359,6 +368,86 @@ static int igb_ptp_settime_i210(struct ptp_clock_info *ptp,
 	return 0;
 }
 
+static int igb_ptp_enable_i210(struct ptp_clock_info *ptp,
+			       struct ptp_clock_request *rq, int on)
+{
+	struct igb_adapter *igb = container_of(ptp, struct igb_adapter,
+					       ptp_caps);
+	struct e1000_hw *hw = &igb->hw;
+	unsigned long flags;
+	struct timespec ts;
+	u32 tsauxc, tsim;
+	s64 ns;
+
+	switch (rq->type) {
+	case PTP_CLK_REQ_EXTTS:
+		if (rq->extts.index != 0)
+			return -EINVAL;
+		spin_lock_irqsave(&igb->tmreg_lock, flags);
+		tsauxc = rd32(E1000_TSAUXC);
+		tsim = rd32(E1000_TSIM);
+		if (on) {
+			tsauxc |= TSAUXC_EN_TS0;
+			tsim |= TSINTR_AUTT0;
+		} else {
+			tsauxc &= ~TSAUXC_EN_TS0;
+			tsim &= ~TSINTR_AUTT0;
+		}
+		wr32(E1000_TSAUXC, tsauxc);
+		wr32(E1000_TSIM, tsim);
+		spin_unlock_irqrestore(&igb->tmreg_lock, flags);
+		return 0;
+
+	case PTP_CLK_REQ_PEROUT:
+		if (rq->perout.index != 0)
+			return -EINVAL;
+
+		ts.tv_sec = rq->perout.period.sec;
+		ts.tv_nsec = rq->perout.period.nsec;
+		ns = timespec_to_ns(&ts);
+		ns = ns >> 1;
+		if (on && ns < 500000LL) {
+			/* 2k interrupts per second is an awful lot. */
+			return -EINVAL;
+		}
+		ts = ns_to_timespec(ns);
+
+		spin_lock_irqsave(&igb->tmreg_lock, flags);
+		tsauxc = rd32(E1000_TSAUXC);
+		tsim = rd32(E1000_TSIM);
+		if (on) {
+			igb->start.tv_sec = rq->perout.start.sec;
+			igb->start.tv_nsec = rq->perout.start.nsec;
+			igb->period.tv_sec = ts.tv_sec;
+			igb->period.tv_nsec = ts.tv_nsec;
+			wr32(E1000_TRGTTIML0, rq->perout.start.sec);
+			wr32(E1000_TRGTTIMH0, rq->perout.start.nsec);
+			tsauxc |= TSAUXC_EN_TT0;
+			tsim |= TSINTR_TT0;
+		} else {
+			tsauxc &= ~TSAUXC_EN_TT0;
+			tsim &= ~TSINTR_TT0;
+		}
+		wr32(E1000_TSAUXC, tsauxc);
+		wr32(E1000_TSIM, tsim);
+		spin_unlock_irqrestore(&igb->tmreg_lock, flags);
+		return 0;
+
+	case PTP_CLK_REQ_PPS:
+		spin_lock_irqsave(&igb->tmreg_lock, flags);
+		tsim = rd32(E1000_TSIM);
+		if (on)
+			tsim |= TSINTR_SYS_WRAP;
+		else
+			tsim &= ~TSINTR_SYS_WRAP;
+		wr32(E1000_TSIM, tsim);
+		spin_unlock_irqrestore(&igb->tmreg_lock, flags);
+		return 0;
+	}
+
+	return -EOPNOTSUPP;
+}
+
 static int igb_ptp_enable(struct ptp_clock_info *ptp,
 			  struct ptp_clock_request *rq, int on)
 {
@@ -711,6 +800,68 @@ int igb_ptp_hwtstamp_ioctl(struct net_device *netdev,
 		-EFAULT : 0;
 }
 
+static int igb_sdp_init(struct igb_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u32 ctrl, ctrl_ext, tssdp = 0;
+
+	if (igb_input_sdp == igb_output_sdp) {
+		pr_err("SDP %d set as both input and output\n", igb_input_sdp);
+		return -1;
+	}
+
+	ctrl     = rd32(E1000_CTRL);
+	ctrl_ext = rd32(E1000_CTRL_EXT);
+
+	switch (igb_input_sdp) {
+	case 0:
+		tssdp |= AUX0_TS_SDP_EN | AUX0_SEL_SDP0;
+		ctrl  &= ~E1000_CTRL_SDP0_DIR;
+		break;
+	case 1:
+		tssdp |= AUX0_TS_SDP_EN | AUX0_SEL_SDP1;
+		ctrl  &= ~E1000_CTRL_SDP1_DIR;
+		break;
+	case 2:
+		tssdp |= AUX0_TS_SDP_EN | AUX0_SEL_SDP2;
+		ctrl_ext &= ~E1000_CTRL_EXT_SDP2_DIR;
+		break;
+	case 3:
+		tssdp |= AUX0_TS_SDP_EN | AUX0_SEL_SDP3;
+		ctrl_ext &= ~E1000_CTRL_EXT_SDP3_DIR;
+		break;
+	default:
+		pr_err("Input SDP %d out of range\n", igb_input_sdp);
+	}
+
+	switch (igb_output_sdp) {
+	case 0:
+		tssdp |= TS_SDP0_SEL_TT0 | TS_SDP0_EN;
+		ctrl |= E1000_CTRL_SDP0_DIR;
+		break;
+	case 1:
+		tssdp |= TS_SDP1_SEL_TT0 | TS_SDP1_EN;
+		ctrl |= E1000_CTRL_SDP1_DIR;
+		break;
+	case 2:
+		tssdp |= TS_SDP2_SEL_TT0 | TS_SDP2_EN;
+		ctrl_ext |= E1000_CTRL_EXT_SDP2_DIR;
+		break;
+	case 3:
+		tssdp |= TS_SDP3_SEL_TT0 | TS_SDP3_EN;
+		ctrl_ext |= E1000_CTRL_EXT_SDP3_DIR;
+		break;
+	default:
+		pr_err("Output SDP %d out of range\n", igb_output_sdp);
+	}
+
+	wr32(E1000_TSSDP, tssdp);
+	wr32(E1000_CTRL, ctrl);
+	wr32(E1000_CTRL_EXT, ctrl_ext);
+
+	return 0;
+}
+
 void igb_ptp_init(struct igb_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
@@ -766,7 +917,7 @@ void igb_ptp_init(struct igb_adapter *adapter)
 		adapter->ptp_caps.adjtime = igb_ptp_adjtime_i210;
 		adapter->ptp_caps.gettime = igb_ptp_gettime_i210;
 		adapter->ptp_caps.settime = igb_ptp_settime_i210;
-		adapter->ptp_caps.enable = igb_ptp_enable;
+		adapter->ptp_caps.enable = igb_ptp_enable_i210;
 		/* Enable the timer functions by clearing bit 31. */
 		wr32(E1000_TSAUXC, 0x0);
 		break;
@@ -785,6 +936,10 @@ void igb_ptp_init(struct igb_adapter *adapter)
 		struct timespec ts = ktime_to_timespec(ktime_get_real());
 
 		igb_ptp_settime_i210(&adapter->ptp_caps, &ts);
+		igb_sdp_init(adapter);
+		adapter->ptp_caps.n_ext_ts = 1;
+		adapter->ptp_caps.n_per_out = 1;
+		adapter->ptp_caps.pps = 1;
 	} else {
 		timecounter_init(&adapter->tc, &adapter->cc,
 				 ktime_to_ns(ktime_get_real()));
-- 
1.7.10.4


------------------------------------------------------------------------------
Try New Relic Now & We'll Send You this Cool Shirt
New Relic is the only SaaS-based application performance monitoring service 
that delivers powerful full stack analytics. Optimize and monitor your
browser, app, & servers with just a few lines of code. Try New Relic
and get this awesome Nerd Life shirt! http://p.sf.net/sfu/newrelic_d2d_may
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
