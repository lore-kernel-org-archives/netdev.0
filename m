From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.30-rc1: e1000: list_add corruption
Date: Thu, 09 Apr 2009 01:08:42 -0700 (PDT)
Message-ID: <20090409.010842.56147646.davem@davemloft.net>
References: <a4423d670904082045q41274747ha08d28a0645ae378@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	kernel-testers@vger.kernel.org
To: a.beregalov@gmail.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <a4423d670904082045q41274747ha08d28a0645ae378@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Alexander Beregalov <a.beregalov@gmail.com>
Date: Thu, 9 Apr 2009 07:45:39 +0400

>  WARNING: at lib/list_debug.c:30 __list_add+0x89/0x90()
>  Hardware name:
>  list_add corruption. prev->next should be next (c06ea834), but was
> f70244c8. (prev=c06ea834).
>  Modules linked in: w83627hf hwmon_vid i2c_nforce2
>  Pid: 1436, comm: portageq Not tainted 2.6.30-rc1 #1
>  Call Trace:
>   [<c0129d73>] warn_slowpath+0x73/0xd0

I'll push the following fix for this:

forcedeth: Use napi_complete() not __napi_complete().

It's not enough that forcedeth's interrupts are disabled,
local cpu interrupts have to unconditionally be off
when we remove the device from the poll list.

Based upon a crash report from
Alexander Beregalov <a.beregalov@gmail.com>:

 WARNING: at lib/list_debug.c:30 __list_add+0x89/0x90()
 Hardware name:
 list_add corruption. prev->next should be next (c06ea834), but was
f70244c8. (prev=c06ea834).
 Modules linked in: w83627hf hwmon_vid i2c_nforce2
 Pid: 1436, comm: portageq Not tainted 2.6.30-rc1 #1
 Call Trace:
  [<c0129d73>] warn_slowpath+0x73/0xd0
  [<c03c6008>] ? __kfree_skb+0x38/0x90
  [<c03f9b06>] ? tcp_data_snd_check+0x26/0xe0
  [<c03fd67f>] ? tcp_rcv_established+0x2bf/0x5e0
  [<c040557a>] ? tcp_v4_rcv+0x47a/0x610
  [<c014cebd>] ? print_lock_contention_bug+0x1d/0x110
  [<c044a967>] ? _spin_unlock+0x27/0x50
  [<c040564b>] ? tcp_v4_rcv+0x54b/0x610
  [<c02d86f9>] __list_add+0x89/0x90
  [<c03ccff9>] __napi_schedule+0x29/0x60
  [<c036946d>] e1000_intr+0xbd/0x1a0
  [<c015c5de>] handle_IRQ_event+0x3e/0x120
  [<c015e190>] handle_fasteoi_irq+0x60/0xd0
  [<c0104fd4>] handle_irq+0x34/0x60
  [<c015f748>] ? rcu_irq_enter+0x8/0x40
  [<c0104b29>] do_IRQ+0x39/0xa0
  [<c03c592c>] ? skb_release_head_state+0x2c/0x60
  [<c01034ee>] common_interrupt+0x2e/0x34
  [<c02d8601>] ? list_del+0x21/0x90
  [<c014e54b>] ? trace_hardirqs_on+0xb/0x10
  [<c03cd4da>] __napi_complete+0x1a/0x30
  [<c0381971>] nv_napi_poll+0xd1/0x5c0
  [<c014e54b>] ? trace_hardirqs_on+0xb/0x10
  [<c03cd5f6>] net_rx_action+0x106/0x1b0
  [<c012e8df>] __do_softirq+0x6f/0x100
  [<c044a967>] ? _spin_unlock+0x27/0x50
  [<c015e1b8>] ? handle_fasteoi_irq+0x88/0xd0
  [<c012e9cd>] do_softirq+0x5d/0x70
  [<c012ebad>] irq_exit+0x7d/0xa0
  [<c0104b32>] do_IRQ+0x42/0xa0
  [<c012e9b7>] ? do_softirq+0x47/0x70
  [<c01034ee>] common_interrupt+0x2e/0x34

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index d374650..11d5db1 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -3745,14 +3745,14 @@ static int nv_napi_poll(struct napi_struct *napi, int budget)
 			mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
 		}
 		spin_unlock_irqrestore(&np->lock, flags);
-		__napi_complete(napi);
+		napi_complete(napi);
 		return rx_work;
 	}
 
 	if (rx_work < budget) {
 		/* re-enable interrupts
 		   (msix not enabled in napi) */
-		__napi_complete(napi);
+		napi_complete(napi);
 
 		writel(np->irqmask, base + NvRegIrqMask);
 	}

------------------------------------------------------------------------------
This SF.net email is sponsored by:
High Quality Requirements in a Collaborative Environment.
Download a free trial of Rational Requirements Composer Now!
http://p.sf.net/sfu/www-ibm-com
