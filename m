From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH iproute2] Re: HTB accuracy for high speed
Date: Mon, 18 May 2009 06:56:29 +0000
Message-ID: <20090518065629.GA6006@ff.dom.local>
References: <20090517201528.GA8552@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Antonio Almeida <vexwek@gmail.com>, netdev@vger.kernel.org,
	kaber@trash.net, davem@davemloft.net, devik@cdi.cz
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.29]:58409 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754044AbZERG4j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 02:56:39 -0400
Received: by yw-out-2324.google.com with SMTP id 5so1871078ywb.1
        for <netdev@vger.kernel.org>; Sun, 17 May 2009 23:56:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090517201528.GA8552@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Return non-zero tc_calc_xmittime() for rate tables

While looking at the problem of HTB accuracy for high speed (~500Mbit
rates) I've found that rate tables have cells filled with zeros for
the smallest sizes. It means such packets aren't accounted at all.
Apart from the correctness of such configs, let's make it safe with
rather overaccounting than living it unlimited.

Reported-by: Antonio Almeida <vexwek@gmail.com>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 tc/tc_core.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/tc/tc_core.c b/tc/tc_core.c
index 9a0ff39..14f25bc 100644
--- a/tc/tc_core.c
+++ b/tc/tc_core.c
@@ -58,7 +58,9 @@ unsigned tc_core_ktime2time(unsigned ktime)
 
 unsigned tc_calc_xmittime(unsigned rate, unsigned size)
 {
-	return tc_core_time2tick(TIME_UNITS_PER_SEC*((double)size/rate));
+	unsigned t;
+	t = tc_core_time2tick(TIME_UNITS_PER_SEC*((double)size/rate));
+	return t ? : 1;
 }
 
 unsigned tc_calc_xmitsize(unsigned rate, unsigned ticks)
