From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH v3 net-next 3/4] ixgbe: Add support for
	ndo_ll_poll
Date: Tue, 21 May 2013 10:19:39 -0400
Message-ID: <CA+FuTSeYQs7yhGbm_BGoQQbzSG77mEXdPccFubWb04UoMoE6nA@mail.gmail.com>
References: <20130520101552.14133.45953.stgit@ladj378.jer.intel.com>
	<20130520101622.14133.21998.stgit@ladj378.jer.intel.com>
	<CAJZOPZJx8vpSWqOhmN65gn=vi7hWXQO_J01+hAwGY9RwetX3DA@mail.gmail.com>
	<519B1A2B.4010909@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <or.gerlitz@gmail.com>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, HPA <hpa@zytor.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>,
	Eliezer Tamir <eliezer@tamir.org.il>, Dave Miller <davem@davemloft.net>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <519B1A2B.4010909@linux.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, May 21, 2013 at 2:54 AM, Eliezer Tamir
<eliezer.tamir@linux.intel.com> wrote:
> On 20/05/2013 23:20, Or Gerlitz wrote:
>>
>> On Mon, May 20, 2013 at 1:16 PM, Eliezer Tamir
>> <eliezer.tamir@linux.intel.com> wrote:
>>>
>>> Add the ixgbe driver code implementing ndo_ll_poll.
>>> It should be easy for other drivers to do something similar
>>> in order to enable support for CONFIG_INET_LL_RX_POLL
>>
>>
>> I am not sure,
>
>
> Willem ported this to <some undisclosed HW that they use at Google>, his
> feedback was that it was not a major effort.

The core ndo_ll_poll implementation is generally a subset of a device
driver's existing napi callback. It cleans the queues, but it skips
napi_complete and unmasking of the IRQ.

+       ixgbe_for_each_ring(ring, q_vector->rx) {
+               found = ixgbe_clean_rx_irq(q_vector, ring, 4);
+               if (found)
+                       break;
+       }

A subtle difference in the above code vs ixgbe_poll is that the
callback returns as soon as some data arrived on a queue, as opposed
to iterating over all queues. The budget is lower, too. Since not all
data arriving is necessarily destined towards polling socket, this may
or may not be an improvement.

Besides that, the driver has to mark the packet with
ll_mark_skb(&cq->napi, skb);

On devices where tx completion interrupts share the same IRQ as rx
interrupts, the driver may also have to clean the tx queue once in a
while (at obvious tail latency cost). LLS does not disable the IRQ,
but I think the suggestion was to set its moderation threshold very
high to avoid net_rx_action/LLS lock contention. If so, starvation may
occur.

The most difficult bit is handling mutual exclusion with the
interrupt-driven receive path. The ixgbe port has its own internal
locking mechanism in anticipation of future use cases that can be
lock-free. As first approximation, I just took the napi->poll_lock,
similar to how netpoll handles mutual exclusion with net_rx_action.

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
