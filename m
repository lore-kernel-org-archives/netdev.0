From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [ofa-general] Re: [PATCH 1/10 REV5] [Doc] HOWTO Documentation for
	batching
Date: Fri, 14 Sep 2007 11:37:09 -0700
Message-ID: <20070914113709.80baba4d.randy.dunlap@oracle.com>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
	<20070914090118.17589.43799.sendpatchset@K50wks273871wss.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, jagana@us.ibm.com, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	kumarkr@linux.ibm.com, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, hadi@cyberus.ca,
	kaber@trash.net, jeff@garzik.org, general@lists.openfabrics.org,
	netdev@vger.kernel.org, tgraf@suug.ch, mcarlson@broadcom.com,
	sri@us.ibm.com, shemminger@linux-foundation.org,
	davem@davemloft.net, mchan@broadcom.com
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070914090118.17589.43799.sendpatchset@K50wks273871wss.in.ibm.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

On Fri, 14 Sep 2007 14:31:18 +0530 Krishna Kumar wrote:

> Add Documentation describing batching skb xmit capability.
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
>  batching_skb_xmit.txt |  107 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 107 insertions(+)
> 
> diff -ruNp org/Documentation/networking/batching_skb_xmit.txt new/Documentation/networking/batching_skb_xmit.txt
> --- org/Documentation/networking/batching_skb_xmit.txt	1970-01-01 05:30:00.000000000 +0530
> +++ new/Documentation/networking/batching_skb_xmit.txt	2007-09-14 10:25:36.000000000 +0530
> @@ -0,0 +1,107 @@
> +
> +Section 4: Nitty gritty details for driver writers
> +--------------------------------------------------
> +
> +	Batching is enabled from core networking stack only from softirq
> +	context (NET_TX_SOFTIRQ), and dev_queue_xmit() doesn't use batching.
> +
> +	This leads to the following situation:
> +		A skb was not sent out as either driver lock was contested or
> +		the device was blocked. When the softirq handler runs, it
> +		moves all skbs from the device queue to the batch list, but
> +		then it too could fail to send due to lock contention. The
> +		next xmit (of a single skb) called from dev_queue_xmit() will
> +		not use batching and try to xmit skb, while previous skbs are
> +		still present in the batch list. This results in the receiver
> +		getting out-of-order packets, and in case of TCP the sender
> +		would have unnecessary retransmissions.
> +
> +	To fix this problem, error cases where driver xmit gets called with a
> +	skb must code as follows:
> +		1. If driver xmit cannot get tx lock, return NETDEV_TX_LOCKED
> +		   as usual. This allows qdisc to requeue the skb.
> +		2. If driver xmit got the lock but failed to send the skb, it
> +		   should return NETDEV_TX_BUSY but before that it should have
> +		   queue'd the skb to the batch list. In this case, the qdisc

                   queued

> +		   does not requeue the skb.

and then
Acked-by: Randy Dunlap <randy.dunlap@oracle.com>

Thanks,
---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
