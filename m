From: "Wong Edison" <hswong3i@gmail.com>
Subject: [PATCH 1/2] [TCP-LP] Kconfig and Makefile
Date: Fri, 26 May 2006 04:09:01 +0800
Message-ID: <3feffd230605251309y17e4064fvfaab649deba69800@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.177]:59735 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S1030395AbWEYUJC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 May 2006 16:09:02 -0400
Received: by py-out-1112.google.com with SMTP id w49so2285587pyg
        for <netdev@vger.kernel.org>; Thu, 25 May 2006 13:09:01 -0700 (PDT)
To: netdev <netdev@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

TCP Low Priority is a distributed algorithm whose goal is to utilize only
 the excess network bandwidth as compared to the ``fair share`` of
 bandwidth as targeted by TCP. Available from:
  http://www.ece.rice.edu/~akuzma/Doc/akuzma/TCP-LP.pdf

Original Author:
 Aleksandar Kuzmanovic <akuzma@northwestern.edu>

See http://www-ece.rice.edu/networks/TCP-LP/ for their implementation.
As of 2.6.13, Linux supports pluggable congestion control algorithms.
Due to the limitation of the API, we take the following changes from
the original TCP-LP implementation:
 o We use newReno in most core CA handling. Only add some checking
  within cong_avoid.
 o Error correcting in remote HZ, therefore remote HZ will be keeped
  on checking and updating.
 o Handling calculation of One-Way-Delay (OWD) within rtt_sample, sicne
  OWD have a similar meaning as RTT. Also correct the buggy formular.
 o Handle reaction for Early Congestion Indication (ECI) within
  pkts_acked, as mentioned within pseudo code.
 o OWD is handled in relative format, where local time stamp will in
  tcp_time_stamp format.

Port from 2.4.19 to 2.6.16 as module by:
 Wong Hoi Sing Edison <hswong3i@gmail.com>
 Hung Hing Lun <hlhung3i@gmail.com>

Signed-off-by: Wong Hoi Sing Edison <hswong3i@gmail.com>

---

diff -urpN linux-2.6.16.14/net/ipv4/Kconfig linux/net/ipv4/Kconfig
--- linux-2.6.16.14/net/ipv4/Kconfig    2006-05-05 08:03:45.000000000 +0800
+++ linux/net/ipv4/Kconfig      2006-05-07 01:41:33.000000000 +0800
@@ -531,6 +531,27 @@ config TCP_CONG_SCALABLE
      properties, though is known to have fairness issues.
      See http://www-lce.eng.cam.ac.uk/~ctk21/scalable/

+config TCP_CONG_LP
+       tristate "TCP Low Priority"
+       depends on EXPERIMENTAL
+       default n
+       ---help---
+       TCP Low Priority (TCP-LP), a distributed algorithm whose goal is
+       to utiliza only the excess network bandwidth as compared to the
+       ``fair share`` of bandwidth as targeted by TCP.
+       See http://www-ece.rice.edu/networks/TCP-LP/
+
+config TCP_CONG_LP_DEBUG
+       bool "TCP-LP Debug"
+       depends on TCP_CONG_LP
+       default n
+       ---help---
+       Turn on/off the debug message for TCP-LP. The debug message will
+       print to default kernel debug log file, e.g. /var/log/debug as
+       default. You can use dmesg to obtain the log too.
+
+       If unsure, say N.
+
 endmenu

 config TCP_CONG_BIC
diff -urpN linux-2.6.16.14/net/ipv4/Makefile linux/net/ipv4/Makefile
--- linux-2.6.16.14/net/ipv4/Makefile   2006-05-05 08:03:45.000000000 +0800
+++ linux/net/ipv4/Makefile     2006-05-07 01:41:33.000000000 +0800
@@ -41,6 +41,7 @@ obj-$(CONFIG_TCP_CONG_HYBLA) += tcp_hybl
 obj-$(CONFIG_TCP_CONG_HTCP) += tcp_htcp.o
 obj-$(CONFIG_TCP_CONG_VEGAS) += tcp_vegas.o
 obj-$(CONFIG_TCP_CONG_SCALABLE) += tcp_scalable.o
+obj-$(CONFIG_TCP_CONG_LP) += tcp_lp.o

 obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
                    xfrm4_output.o
