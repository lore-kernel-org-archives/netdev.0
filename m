From: "Grumbach, Emmanuel" <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC v2 1/3] iwlwifi: mvm: add real TSO implementation
Date: Wed, 19 Aug 2015 17:05:23 +0000
Message-ID: <0BA3FCBA62E2DC44AF3030971E174FB32E825194@hasmsx107.ger.corp.intel.com>
References: <1439989181-4444-1-git-send-email-emmanuel.grumbach@intel.com>
	 <1439989181-4444-2-git-send-email-emmanuel.grumbach@intel.com>
 <1439993864.6610.11.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"ido-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org" <ido-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 08/19/2015 05:18 PM, Eric Dumazet wrote:
> On Wed, 2015-08-19 at 15:59 +0300, Emmanuel Grumbach wrote:
>> The segmentation is done completely in software. The
>> driver creates several MPDUs out of a single large send.
>> Each MPDU is a newly allocated SKB.
>> A page is allocated to create the headers that need to be
>> duplicated (SNAP / IP / TCP). The WiFi header is in the
>> header of the newly created SKBs.
>>
>> type=feature
>>
>> Change-Id: I238ffa79cacc5bbdacdfbf3e9673c8d4f02b462a
>> Signed-off-by: Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>> ---
>>  drivers/net/wireless/iwlwifi/mvm/tx.c | 513 +++++++++++++++++++++++++++++++---
>>  1 file changed, 481 insertions(+), 32 deletions(-)
> 
> Ouch dynamic allocations while doing xmit are certainly not needed.
> Your driver should pre-allocated space for headers.

This is right as long as you don't need *several* headers in one single
skb. In the case of A-MSDU, I need to have several TCP / IP / SNAP
headers in the same skb. At least that's how my HW layer in the driver
is built. See the other thread.

> 
> Drivers willing to implement tso have to use net/core/tso.c provided
> helpers.
> 
> $ git grep -n tso_build_hdr
> drivers/net/ethernet/cavium/thunder/nicvf_queues.c:1030:                tso_build_hdr(skb, hdr, &tso, data_left, total_len == 0);
> drivers/net/ethernet/freescale/fec_main.c:729:          tso_build_hdr(skb, hdr, &tso, data_left, total_len == 0);
> drivers/net/ethernet/marvell/mv643xx_eth.c:842:         tso_build_hdr(skb, hdr, &tso, data_left, total_len == 0);
> drivers/net/ethernet/marvell/mvneta.c:1650:             tso_build_hdr(skb, hdr, &tso, data_left, total_len == 0);
> include/net/tso.h:15:void tso_build_hdr(struct sk_buff *skb, char *hdr, struct tso_t *tso,
> net/core/tso.c:14:void tso_build_hdr(struct sk_buff *skb, char *hdr, struct tso_t *tso,
> net/core/tso.c:37:EXPORT_SYMBOL(tso_build_hdr);
> 
> 

This looks promising indeed. I'll take a close look.
Thanks a bunch.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
