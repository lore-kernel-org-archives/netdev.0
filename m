From: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Subject: [iproute2 net-next 3/3] man: Add initial manpage for tc-cbs(8)
Date: Tue, 26 Sep 2017 16:39:58 -0700
Message-ID: <20170926233958.12027-3-vinicius.gomes@intel.com>
References: <20170926233958.12027-1-vinicius.gomes@intel.com>
Cc: Vinicius Costa Gomes <vinicius.gomes@intel.com>, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, jiri@resnulli.us, andre.guedes@intel.com,
        ivan.briano@intel.com, jesus.sanchez-palencia@intel.com,
        boon.leong.ong@intel.com, richardcochran@gmail.com,
        henrik@austad.us
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:41230 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1031407AbdIZXkF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 19:40:05 -0400
In-Reply-To: <20170926233958.12027-1-vinicius.gomes@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vinicius Costa Gomes <vinicius.gomes@intel.com>
---
 man/man8/tc-cbs.8 | 100 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 100 insertions(+)
 create mode 100644 man/man8/tc-cbs.8

diff --git a/man/man8/tc-cbs.8 b/man/man8/tc-cbs.8
new file mode 100644
index 00000000..e84c5495
--- /dev/null
+++ b/man/man8/tc-cbs.8
@@ -0,0 +1,100 @@
+.TH CBS 8 "18 Sept 2017" "iproute2" "Linux"
+.SH NAME
+CBS \- Credit Based Shaper (CBS) Qdisc
+.SH SYNOPSIS
+.B tc qdisc ... dev
+dev
+.B parent
+classid
+.B [ handle
+major:
+.B ] cbs idleslope
+idleslope
+.B sendslope
+sendslope
+.B hicredit
+hicredit
+.B locredit
+locredit
+
+.SH DESCRIPTION
+The CBS (Credit Based Shaper) qdisc implements the shaping algorithm
+defined by the IEEE 802.1Q-2014 Section 8.6.8.2, which applies a well
+defined rate limiting method to the traffic.
+
+This queueing discipline is intended to be used by TSN (Time Sensitive
+Networking) applications, the CBS parameters are derived directly by
+what is described by the Annex L of the IEEE 802.1Q-2014
+Sepcification. The algorithm and how it affects the latency are
+detailed there.
+
+CBS is meant to be installed under another qdisc that maps packet
+flows to traffic classes, one example is
+.BR mqprio(8).
+
+.SH PARAMETERS
+.TP
+idleslope
+Idleslope is the rate of credits that is accumulated (in kilobits per
+second) when there is at least one packet waiting for transmission.
+Packets are transmitted when the current value of credits is equal or
+greater than zero. When there is no packet to be transmitted the
+amount of credits is set to zero. This is the main tunable of the CBS
+algorithm.
+.TP
+sendslope
+Sendslope is the rate of credits that is depleted (it should be a
+negative number of kilobits per second) when a transmission is
+ocurring. It can be calculated as follows, (IEEE 802.1Q-2014 Section
+8.6.8.2 item g):
+
+sendslope = idleslope - port_transmit_rate
+
+.TP
+hicredit
+Hicredit defines the maximum amount of credits (in bytes) that can be
+accumulated. Hicredit depends on the characteristics of interfering
+traffic, 'max_interference_size' is the maximum size of any burst of
+traffic that can delay the transmission of a frame that is available
+for transmission for this traffic class, (IEEE 802.1Q-2014 Annex L,
+Equation L-3):
+
+hicredit = max_interference_size * (idleslope / port_transmit_rate)
+
+.TP
+locredit
+Locredit is the minimum amount of credits that can be reached. It is a
+function of the traffic flowing through this qdisc (IEEE 802.1Q-2014
+Annex L, Equation L-2):
+
+locredit = max_frame_size * (sendslope / port_transmit_rate)
+
+.SH EXAMPLES
+
+CBS is used to enforce a Quality of Service by limiting the data rate
+of a traffic class, to separate packets into traffic classes the user
+may choose
+.BR mqprio(8),
+and configure it like this:
+
+.EX
+# tc qdisc add dev eth0 handle 100: parent root mqprio num_tc 3 \\
+	map 2 2 1 0 2 2 2 2 2 2 2 2 2 2 2 2 \\
+	queues 1@0 1@1 2@2 \\
+	hw 0
+.EE
+.P
+To replace the current queuing disciple by CBS in the current queueing
+discipline connected to traffic class number 0, issue:
+.P
+.EX
+# tc qdisc replace dev eth0 parent 100:4 cbs \\
+	locredit -1470 hicredit 30 sendslope -980000 idleslope 20000
+.EE
+
+These values are obtained from the following parameters, idleslope is
+20mbit/s, the transmission rate is 1Gbit/s and the maximum interfering
+frame size is 1500 bytes.
+
+.SH AUTHORS
+Vinicius Costa Gomes <vinicius.gomes@intel.com>
-- 
2.14.2
