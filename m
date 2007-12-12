From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [PATCH] [NET]: Fix Ooops of napi net_rx_action.
Date: Tue, 11 Dec 2007 16:38:37 -0800
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F5203FBAF94@orsmsx418.amr.corp.intel.com>
References: <001801c83bd6$2001d410$9c94fea9@jason> <20071211.023218.31965443.davem@davemloft.net> <b25c3fa70712110457g2bf04c6flc387f2b9cb51cf3b@mail.gmail.com> <36D9DB17C6DE9E40B059440DB8D95F5203F82FC3@orsmsx418.amr.corp.intel.com> <b25c3fa70712111612o16a62b49g6709aa728f31e27a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <herbert@gondor.apana.org.au>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: "Joonwoo Park" <joonwpark81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:47001 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751232AbXLLAlo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 19:41:44 -0500
Content-class: urn:content-classes:message
In-Reply-To: <b25c3fa70712111612o16a62b49g6709aa728f31e27a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joonwoo Park wrote:
> 2007/12/12, Brandeburg, Jesse <jesse.brandeburg@intel.com>:
>> 
>> all drivers using NAPI in 2.6.24+ (NNAPI??) must return zero here,
>> after calling netif_rx_complete.  netif_rx_complete plus work_done
>> != 0 causes a bug. 
>> 
> 
> Brandeburg,
> Don't we need to return non-zero work_done after netif_rx_complete if
> work_done != weight?

Actually we just need to make sure we don't return work_done == weight
as it is checked on line 2210 of dev.c.
I should also note that I was wrong above, and that the requirement is
that we MUST not return work_done == weight when indicating
netif_rx_complete.

So, returning 0 when we actually did some work, but are being removed
from the poll list because something like !netif_running, is probably
okay, but I'm sure someone will disagree with me.  Maybe returning like
this would be better
diff --git a/drivers/net/e1000/e1000_main.c
b/drivers/net/e1000/e1000_main.c
index 724f067..76d5e3b 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3933,6 +3933,10 @@ quit_polling:
                        e1000_set_itr(adapter);
                netif_rx_complete(poll_dev, napi);
                e1000_irq_enable(adapter);
+               if (work_done == weight)
+                       return work_done - 1;
+               else
+                       return work_done;
        }

        return work_done;

Jesse

 
