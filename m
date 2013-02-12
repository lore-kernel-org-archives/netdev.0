From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [PATCH net-next 2/5] gianfar: Cleanup and optimize struct gfar_private
Date: Tue, 12 Feb 2013 17:58:27 +0200
Message-ID: <511A66A3.7040704@freescale.com>
References: <1360673237-349-1-git-send-email-claudiu.manoil@freescale.com> <1360673237-349-2-git-send-email-claudiu.manoil@freescale.com> <511A5BA3.4020306@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe006.messaging.microsoft.com ([213.199.154.144]:35326
	"EHLO db3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758579Ab3BLP6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 10:58:47 -0500
In-Reply-To: <511A5BA3.4020306@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/12/2013 5:11 PM, Paul Gortmaker wrote:
> On 13-02-12 07:47 AM, Claudiu Manoil wrote:
>> * group run-time critical fields within the 1st cacheline
>>    followed by the tx|rx_queue reference arrays and the interrupt
>>    group instances (gfargrp) (all cacheline aligned)
>> * change 'padding' from unsigned short to u16
>> * clear 20+ byte memory hole
>
> Per prev. mail, it gets harder to see which change is where,
> when they are all lumped together like this.  For example, it
> wasn't obvious to me where the 20 byte hole was.  Also, it
> doesn't look like you changed the padding, but rather instead
> totally re-purposed it, leaving no alignment padding after the
> uchar bitfields (where it was originally).
>
> P.

The 20 byte hole was here:

struct gfar_private {
         unsigned int               num_tx_queues;
         unsigned int               num_rx_queues;
         unsigned int               num_grps;
         unsigned int               mode;
         unsigned int               total_tx_ring_size;
         unsigned int               total_rx_ring_size;
         struct device_node *       node;
         struct net_device *        ndev;
         /* --- cacheline 1 boundary (32 bytes) --- */
         struct platform_device *   ofdev;
         enum gfar_errata           errata;

         /* XXX 24 bytes hole, try to pack */

         /* --- cacheline 2 boundary (64 bytes) --- */
         struct gfar_priv_grp       gfargrp[2];


At the end of the patch series the first cacheline is without holes.
Please note that the re-grouping of members and their order is most
important. For instance why keep in the first cacheline something
as unimportant as total_rx_ring_size? Members like rx_buffer_size,
or padding, or even errata, are critical however for the fast path.
Rx processing (gfar_poll + clean_rx_ring) is the bottleneck here,
keeping the CPU to 100%. So the main goal is to optimize this path,
including memory access/cache optimizations. For instance, better 
results were obtained by inverting rx|tx_queue[] with gfargrp[], originally:
         /* --- cacheline 1 boundary (32 bytes) --- */
         struct gfar_priv_tx_q *    tx_queue[8];  /*    32    32 */
         /* --- cacheline 2 boundary (64 bytes) --- */
         struct gfar_priv_rx_q *    rx_queue[8]; /*    64    32 */
         /* --- cacheline 3 boundary (96 bytes) --- */
         struct gfar_priv_grp       gfargrp[2];  /*    96   192 */

The uchar bitfields are unimportant here (used at "init time"), and
they take 4 bytes including padding anyway. So whether it's uchar or
uint, it's the same, maybe better left uchar to discourage the abuse
of these bitfields. (A 2-3byte hole here doesn't change anything
to the whole structure size, which is padded to be at least a 32B
multiple.)

Thanks,
Claudiu
