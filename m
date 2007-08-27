From: James Chapman <jchapman@katalix.com>
Subject: Re: RFC: issues concerning the next NAPI interface
Date: Mon, 27 Aug 2007 16:51:29 +0100
Message-ID: <46D2F301.7050105@katalix.com>
References: <46CF127D.1090609@katalix.com>	<20070824.144711.18301866.davem@davemloft.net>	<46D1D634.7060007@katalix.com> <20070826.185815.93042514.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, ossthema@de.ibm.com,
	akepner@sgi.com, netdev@vger.kernel.org, raisch@de.ibm.com,
	themann@de.ibm.com, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, meder@de.ibm.com, tklein@de.ibm.com,
	stefan.roscher@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:60241 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755762AbXH0Pvl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Aug 2007 11:51:41 -0400
In-Reply-To: <20070826.185815.93042514.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: James Chapman <jchapman@katalix.com>
> Date: Sun, 26 Aug 2007 20:36:20 +0100
> 
>> David Miller wrote:
>>> From: James Chapman <jchapman@katalix.com>
>>> Date: Fri, 24 Aug 2007 18:16:45 +0100
>>>
>>>> Does hardware interrupt mitigation really interact well with NAPI?
>>> It interacts quite excellently.
>> If NAPI disables interrupts and keeps them disabled while there are more 
>> packets arriving or more transmits being completed, why do hardware 
>> interrupt mitigation / coalescing features of the network silicon help?
> 
> Because if your packet rate is low enough such that the cpu can
> process the interrupt fast enough and thus only one packet gets
> processed per NAPI poll, the cost of going into and out of NAPI mode
> dominates the packet processing costs.

In the second half of my previous reply (which seems to have been 
deleted), I suggest a way to avoid this problem without using hardware 
interrupt mitigation / coalescing. Original text is quoted below.

 >> I've seen the same and I'm suggesting that the NAPI driver keeps
 >> itself in polled mode for N polls or M jiffies after it sees
 >> workdone=0. This has always worked for me in packet forwarding
 >> scenarios to maximize packets/sec and minimize latency.

To implement this, there's no need for timers, hrtimers or generic NAPI 
support that others have suggested. A driver's poll() would set an 
internal flag and record the current jiffies value when finding 
workdone=0 rather than doing an immediate napi_complete(). Early in 
poll() it would test this flag and if set, do a low-cost test to see if 
it had any work to do. If no work, it would check the saved jiffies 
value and do the napi_complete() only if no work has been done for a 
configurable number of jiffies. This keeps interrupts disabled longer at 
the expense of many more calls to poll() where no work is done. So 
critical to this scheme is modifying the driver's poll() to fastpath the 
case of having no work to do while waiting for its local jiffy count to 
expire.

Here's an untested patch for tg3 that illustrates the idea.

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 710dccc..59e151b 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -3473,6 +3473,24 @@ static int tg3_poll(struct napi_struct *napi,
  	struct tg3_hw_status *sblk = tp->hw_status;
  	int work_done = 0;

+	/* fastpath having no work while we're holding ourself in
+	 * polled mode
+	 */
+	if ((tp->exit_poll_time) && (!tg3_has_work(tp))) {
+		if (time_after(jiffies, tp->exit_poll_time)) {
+			tp->exit_poll_time = 0;
+			/* tell net stack and NIC we're done */
+			netif_rx_complete(netdev, napi);
+			tg3_restart_ints(tp);
+		}
+		return 0;
+	}
+
+	/* if we get here, there might be work to do so disable the
+	 * poll hold fastpath above
+	 */
+	tp->exit_poll_time = 0;
+
  	/* handle link change and other phy events */
  	if (!(tp->tg3_flags &
  	      (TG3_FLAG_USE_LINKCHG_REG |
@@ -3511,11 +3529,11 @@ static int tg3_poll(struct napi_struct *napi,
  	} else
  		sblk->status &= ~SD_STATUS_UPDATED;

-	/* if no more work, tell net stack and NIC we're done */
-	if (!tg3_has_work(tp)) {
-		netif_rx_complete(netdev, napi);
-		tg3_restart_ints(tp);
-	}
+	/* if no more work, set the time in jiffies when we should
+	 * exit polled mode
+	 */
+	if (!tg3_has_work(tp))
+		tp->exit_poll_time = jiffies + 2;

  	return work_done;
  }
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index a6a23bb..a0d24d3 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2163,6 +2163,7 @@ struct tg3 {
  	u32				last_tag;

  	u32				msg_enable;
+	unsigned long			exit_poll_time;

  	/* begin "tx thread" cacheline section */
  	void				(*write32_tx_mbox) (struct tg3 *, u32,


-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

