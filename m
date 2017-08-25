From: "Waskiewicz Jr, Peter" <peter.waskiewicz.jr@intel.com>
Subject: Re: [RFC PATCH] net: limit maximum number of packets to mark with
 xmit_more
Date: Fri, 25 Aug 2017 15:36:22 +0000
Message-ID: <E0D909EE5BB15A4699798539EA149D7F07793B3E@ORSMSX103.amr.corp.intel.com>
References: <20170825152449.29790-1-jacob.e.keller@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Keller, Jacob E" <jacob.e.keller@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:10931 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933386AbdHYPg2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Aug 2017 11:36:28 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/25/17 11:25 AM, Jacob Keller wrote:
> Under some circumstances, such as with many stacked devices, it is
> possible that dev_hard_start_xmit will bundle many packets together, and
> mark them all with xmit_more.
> 
> Most drivers respond to xmit_more by skipping tail bumps on packet
> rings, or similar behavior as long as xmit_more is set. This is
> a performance win since it means drivers can avoid notifying hardware of
> new packets repeat daily, and thus avoid wasting unnecessary PCIe or other
> bandwidth.
> 
> This use of xmit_more comes with a trade off because bundling too many
> packets can increase latency of the Tx packets. To avoid this, we should
> limit the maximum number of packets with xmit_more.
> 
> Driver authors could modify their drivers to check for some determined
> limit, but this requires all drivers to be modified in order to gain
> advantage.
> 
> Instead, add a sysctl "xmit_more_max" which can be used to configure the
> maximum number of xmit_more skbs to send in a sequence. This ensures
> that all drivers benefit, and allows system administrators the option to
> tune the value to their environment.
> 
> Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
> ---
> 
> Stray thoughts and further questions....
> 
> Is this the right approach? Did I miss any other places where we should
> limit? Does the limit make sense? Should it instead be a per-device
> tuning nob instead of a global? Is 32 a good default?

I actually like the idea of a per-device knob.  A xmit_more_max that's 
global in a system with 1GbE devices along with a 25/50GbE or more just 
doesn't make much sense to me.  Or having heterogeneous vendor devices 
in the same system that have different HW behaviors could mask issues 
with latency.

This seems like another incarnation of possible buffer-bloat if the max 
is too high...

> 
>   Documentation/sysctl/net.txt |  6 ++++++
>   include/linux/netdevice.h    |  2 ++
>   net/core/dev.c               | 10 +++++++++-
>   net/core/sysctl_net_core.c   |  7 +++++++
>   4 files changed, 24 insertions(+), 1 deletion(-)
> 
> diff --git a/Documentation/sysctl/net.txt b/Documentation/sysctl/net.txt
> index b67044a2575f..3d995e8f4448 100644
> --- a/Documentation/sysctl/net.txt
> +++ b/Documentation/sysctl/net.txt
> @@ -230,6 +230,12 @@ netdev_max_backlog
>   Maximum number  of  packets,  queued  on  the  INPUT  side, when the interface
>   receives packets faster than kernel can process them.
>   
> +xmit_more_max
> +-------------
> +
> +Maximum number of packets in a row to mark with skb->xmit_more. A value of zero
> +indicates no limit.

What defines "packet?"  MTU-sized packets, or payloads coming down from 
the stack (e.g. TSO's)?

-PJ
