From: Ben Greear <greearb@candelatech.com>
Subject: Re: local_bh_enable & hard_start_xmit
Date: Mon, 18 Apr 2005 17:24:52 -0700
Message-ID: <42644FD4.3030200@candelatech.com>
References: <42642892.2040300@candelatech.com>	<20050418151421.41a8f64a.davem@davemloft.net>	<42643BB9.6050705@candelatech.com> <20050418160147.6fd7ac9a.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050418160147.6fd7ac9a.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

> So write the patch to add such comments.  It would have taken the
> same amount of typing as writing that paragraph saying how great an
> addition this would be. :)

Signed-off-by:  Ben Greear <greearb@candelatech.com>


--- linux-2.6.11/Documentation/networking/netdevices.txt        2005-03-01 23:37:50.000000000 -0800+++ linux-2.6.11.p4s/Documentation/networking/netdevices.txt    2005-04-18 16:59:43.000000000 -0700@@ -51,6 +51,8 @@
         set_multicast_list
         Context: BHs disabled
         Notes: netif_queue_stopped() is guaranteed false
+               Interrupts must be enabled when calling hard_start_xmit.
+                (Interrupts must also be enabled when enabling the BH handler.)
         Return codes:
         o NETDEV_TX_OK everything ok.
         o NETDEV_TX_BUSY Cannot transmit packet, try later


Second patch:

[greear@lanforge-nx 2.6]$ diff -u linux-2.6.11/net/core/dev.c linux-2.6.11.mostly-clean/net/core/dev.c
--- linux-2.6.11/net/core/dev.c 2005-03-01 23:38:09.000000000 -0800
+++ linux-2.6.11.mostly-clean/net/core/dev.c    2005-04-18 17:23:21.767951600 -0700
@@ -1214,6 +1214,19 @@
   *     A negative errno code is returned on a failure. A success does not
   *     guarantee the frame will be transmitted as it may be dropped due
   *     to congestion or traffic shaping.
+ *
+ * -----------------------------------------------------------------------------------
+ *      I notice this method can also return errors from the queue disciplines,
+ *      including NET_XMIT_DROP, which is a positive value.  So, errors can also
+ *      be positive.
+ *
+ *      Regardless of the return value, the skb is consumed, so it is currently
+ *      difficult to retry a send to this method.  (You can bump the ref count
+ *      before sending to hold a reference for retry if you are careful.)
+ *
+ *      When calling this method, interrupts MUST be enabled.  This is because
+ *      the BH enable code must have IRQs enabled so that it will not deadlock.
+ *          --BLG
   */

  int dev_queue_xmit(struct sk_buff *skb)


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
