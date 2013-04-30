From: annie li <annie.li@oracle.com>
Subject: Re: [Xen-devel] [PATCH V5 6/7] xen-netback: coalesce slots in TX
 path and fix regressions
Date: Tue, 30 Apr 2013 14:06:01 -0400
Message-ID: <51800809.9070407@oracle.com>
References: <1366045581-31349-1-git-send-email-wei.liu2@citrix.com> <1366045581-31349-7-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xen.org,
	ian.campbell@citrix.com, konrad.wilk@oracle.com,
	david.vrabel@citrix.com, jbeulich@suse.com, wdauchy@gmail.com
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:18912 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760203Ab3D3SGR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 14:06:17 -0400
In-Reply-To: <1366045581-31349-7-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2013-4-15 13:06, Wei Liu wrote:
> This patch tries to coalesce tx requests when constructing grant copy
> structures. It enables netback to deal with situation when frontend's
> MAX_SKB_FRAGS is larger than backend's MAX_SKB_FRAGS.
>
> With the help of coalescing, this patch tries to address two regressions and
> avoid reopening the security hole in XSA-39.
>
> Regression 1. The reduction of the number of supported ring entries (slots)
> per packet (from 18 to 17). This regression has been around for some time but
> remains unnoticed until XSA-39 security fix. This is fixed by coalescing
> slots.
>
> Regression 2. The XSA-39 security fix turning "too many frags" errors from
> just dropping the packet to a fatal error and disabling the VIF. This is fixed
> by coalescing slots (handling 18 slots when backend's MAX_SKB_FRAGS is 17)
> which rules out false positive (using 18 slots is legit) and dropping packets
> using 19 to `max_skb_slots` slots.
>
> To avoid reopening security hole in XSA-39, frontend sending packet using more
> than max_skb_slots is considered malicious.
>
> The behavior of netback for packet is thus:
>
>      1-18            slots: valid
>     19-max_skb_slots slots: drop and respond with an error
>     max_skb_slots+   slots: fatal error
>
> max_skb_slots is configurable by admin, default value is 20.
>
> Also change variable name from "frags" to "slots" in netbk_count_requests.
>
> Please note that RX path still has dependency on MAX_SKB_FRAGS. This will be
> fixed with separate patch.

Wei,

The RX path dependency on MAX_SKB_FRAGS in netback should not cause 
packet dropping issue like TX path, RX path only calls netif_stop_queue 
if RX ring is full.
What is your plan on RX path? Is it in your schedule or you started it 
already?

Thanks
Annie
