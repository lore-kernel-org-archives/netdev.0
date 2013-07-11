From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] bnx2x: fix tunneling CSUM calculation
Date: Thu, 11 Jul 2013 06:54:12 -0700
Message-ID: <1373550852.4600.39.camel@edumazet-glaptop>
References: <1373546901-26741-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	alexander.h.duyck@intel.com, pshelar@nicira.com,
	xiyou.wangcong@gmail.com, eilong@broadcom.com
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33107 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932442Ab3GKNyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 09:54:13 -0400
Received: by mail-pa0-f50.google.com with SMTP id fb1so7800601pad.23
        for <netdev@vger.kernel.org>; Thu, 11 Jul 2013 06:54:13 -0700 (PDT)
In-Reply-To: <1373546901-26741-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-07-11 at 15:48 +0300, Dmitry Kravkov wrote:
> Since commit c957d09ffda417f6c8e3d1f10e2b05228607d6d7
> "bnx2x: Remove sparse and coccinelle warnings"
> driver provided wrong partial csum for HW in tunneing
> scenarios.
> 
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Alexander Duyck <alexander.h.duyck@intel.com>
> CC: Pravin Shelar <pshelar@nicira.com>
> CC: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> 
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> index 3353efe..ee350bd 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> @@ -3543,9 +3543,9 @@ static void bnx2x_update_pbds_gso_enc(struct sk_buff *skb,
>  	/* outer IP header info */
>  	if (xmit_type & XMIT_CSUM_V4) {
>  		struct iphdr *iph = ip_hdr(skb);
> -		u16 csum = (__force u16)(~iph->check) -
> -			   (__force u16)iph->tot_len -
> -			   (__force u16)iph->frag_off;
> +		u32 csum = (__force u32)(~iph->check) -
> +			   (__force u32)iph->tot_len -
> +			   (__force u32)iph->frag_off;
>  
>  		pbd2->fw_ip_csum_wo_len_flags_frag =
>  			bswab16(csum_fold((__force __wsum)csum));



Tested-by: Eric Dumazet <edumazet@google.com>

Thanks guys !

lpq83:~# ethtool -K gre1 tso on 
lpq83:~# ./netperf -H 7.7.8.84
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 7.7.8.84 () port 0 AF_INET
Recv   Send    Send                          
Socket Socket  Message  Elapsed              
Size   Size    Size     Time     Throughput  
bytes  bytes   bytes    secs.    10^6bits/sec  

 87380  16384  16384    10.00    5723.17   
lpq83:~# ethtool -K gre1 tso off
lpq83:~# ./netperf -H 7.7.8.84
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 7.7.8.84 () port 0 AF_INET
Recv   Send    Send                          
Socket Socket  Message  Elapsed              
Size   Size    Size     Time     Throughput  
bytes  bytes   bytes    secs.    10^6bits/sec  

 87380  16384  16384    10.00    3813.60   
