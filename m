From: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Subject: [RFC net-next 5/5] samples/tsn: Add script for calculating CBS config
Date: Thu, 31 Aug 2017 18:26:25 -0700
Message-ID: <20170901012625.14838-6-vinicius.gomes@intel.com>
References: <20170901012625.14838-1-vinicius.gomes@intel.com>
Cc: Andre Guedes <andre.guedes@intel.com>, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, jiri@resnulli.us,
        intel-wired-lan@lists.osuosl.org, ivan.briano@intel.com,
        jesus.sanchez-palencia@intel.com, boon.leong.ong@intel.com,
        richardcochran@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:20239 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751264AbdIAB0b (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 31 Aug 2017 21:26:31 -0400
In-Reply-To: <20170901012625.14838-1-vinicius.gomes@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andre Guedes <andre.guedes@intel.com>

Add a script that takes as input the parameters of the Credit-based
shaper used on FQTSS - link rate, max frame size of best effort
traffic, idleslope and maximum frame size of the time-sensitive
traffic class - for SR classes A and B, and calculates how the CBS
qdisc must be configured for each traffic class.

For example, if you want to have Class A with a bandwidth of 300 Mbps
and Class B of 200 Mbps, and the max frame size of both classes'
traffic is 1500 bytes:

$ ./calculate_cbs_params.py -A 300000 -a 1500 -B 200000 -b 1500

would give you the correct cbs qdisc config command lines to be used.

This script is just a helper to ease testing of the TSN samples -
talker and listener - and shouldn't be taken as highly accurate.

Signed-off-by: Andre Guedes <andre.guedes@intel.com>
Signed-off-by: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
---
 samples/tsn/calculate_cbs_params.py | 112 ++++++++++++++++++++++++++++++++++++
 1 file changed, 112 insertions(+)
 create mode 100755 samples/tsn/calculate_cbs_params.py

diff --git a/samples/tsn/calculate_cbs_params.py b/samples/tsn/calculate_cbs_params.py
new file mode 100755
index 000000000000..9c46210b699f
--- /dev/null
+++ b/samples/tsn/calculate_cbs_params.py
@@ -0,0 +1,112 @@
+#!/usr/bin/env python3
+#
+# Copyright (c) 2017, Intel Corporation
+#
+# Redistribution and use in source and binary forms, with or without
+# modification, are permitted provided that the following conditions are met:
+#
+#     * Redistributions of source code must retain the above copyright notice,
+#       this list of conditions and the following disclaimer.
+#     * Redistributions in binary form must reproduce the above copyright
+#       notice, this list of conditions and the following disclaimer in the
+#       documentation and/or other materials provided with the distribution.
+#     * Neither the name of Intel Corporation nor the names of its contributors
+#       may be used to endorse or promote products derived from this software
+#       without specific prior written permission.
+#
+# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
+# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
+# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
+# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
+# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
+# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
+# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
+# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+
+import argparse
+import math
+import sys
+
+def print_cbs_params_for_class_a(args):
+    idleslope = args.idleslope_a
+    sendslope = idleslope - args.link_speed
+
+    # According to 802.1Q-2014 spec, Annex L, hiCredit and
+    # loCredit for SR class A are calculated following the
+    # equations L-10 and L-12, respectively.
+    hicredit = math.ceil(idleslope * args.frame_non_sr / args.link_speed)
+    locredit = math.ceil(sendslope * args.frame_a / args.link_speed)
+
+    print("Class A --> # tc qdisc replace dev IFACE parent ID cbs " \
+          "locredit %d hicredit %d sendslope %d idleslope %d" % \
+          (locredit, hicredit, sendslope, idleslope))
+
+def print_cbs_params_for_class_b(args):
+    idleslope = args.idleslope_b
+    sendslope = idleslope - args.link_speed
+
+    # Annex L doesn't present a straightforward equation to
+    # calculate hiCredit for Class B so we have to derive it
+    # based on generic equations presented in that Annex.
+    #
+    # L-3 is the primary equation to calculate hiCredit. Section
+    # L.2 states that the 'maxInterferenceSize' for SR class B
+    # is the maximum burst size for SR class A plus the
+    # maxInterferenceSize from SR class A (which is equal to the
+    # maximum frame from non-SR traffic).
+    #
+    # The maximum burst size for SR class A equation is shown in
+    # L-16. Merging L-16 into L-3 we get the resulting equation
+    # which calculates hiCredit B (refer to section L.3 in case
+    # you're not familiar with the legend):
+    #
+    # hiCredit B = Rb * (     Mo         Ma   )
+    #                     ---------- + ------
+    #                      Ro - Ra       Ro
+    #
+    hicredit = math.ceil(idleslope * \
+               ((args.frame_non_sr / (args.link_speed - args.idleslope_a)) + \
+               (args.frame_a / args.link_speed)))
+
+    # loCredit B is calculated following equation L-2.
+    locredit = math.ceil(sendslope * args.frame_b / args.link_speed)
+
+    print("Class B --> # tc qdisc replace dev IFACE parent ID cbs " \
+          "locredit %d hicredit %d sendslope %d idleslope %d" % \
+          (locredit, hicredit, sendslope, idleslope))
+
+def main():
+    parser = argparse.ArgumentParser()
+
+    parser.add_argument('-S', dest='link_speed', default=1000000.0, type=float,
+                        help='Link speed in kbps (default=1000000)')
+    parser.add_argument('-s', dest='frame_non_sr', default=1500.0, type=float,
+                        help='Maximum frame size from non-SR traffic (MTU size'
+                        ' usually, default=1500)')
+    parser.add_argument('-A', dest='idleslope_a', default=0, type=float,
+                        help='Idleslope for SR class A in kbps')
+    parser.add_argument('-a', dest='frame_a', default=0, type=float,
+                        help='Maximum frame size for SR class A traffic')
+    parser.add_argument('-B', dest='idleslope_b', default=0, type=float,
+                        help='Idleslope for SR class B in kbps')
+    parser.add_argument('-b', dest='frame_b', default=0, type=float,
+                        help='Maximum frame size for SR class B traffic')
+
+    args = parser.parse_args()
+
+    if not len(sys.argv) > 1:
+        parser.print_help()
+    else:
+        print("\nConfiguration lines to be used are:")
+
+    if args.idleslope_a > 0:
+        print_cbs_params_for_class_a(args)
+
+    if args.idleslope_b > 0:
+        print_cbs_params_for_class_b(args)
+
+
+if __name__ == "__main__":
+    main()
-- 
2.14.1
