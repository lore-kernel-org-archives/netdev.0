From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] bnx2x: Prevent FW assertion when using Vxlan
Date: Sun, 13 Dec 2015 15:21:26 +0300
Message-ID: <566D62C6.8050004@cogentembedded.com>
References: <1449992945-31883-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ariel Elior <Ariel.Elior@qlogic.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:33255 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751273AbbLMMVa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Dec 2015 07:21:30 -0500
Received: by lbbkw15 with SMTP id kw15so92344461lbb.0
        for <netdev@vger.kernel.org>; Sun, 13 Dec 2015 04:21:29 -0800 (PST)
In-Reply-To: <1449992945-31883-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/13/2015 10:49 AM, Yuval Mintz wrote:

> FW has a rare corner case in which a fragmented packet using lots
> of frags would not be linearized, causing the FW to assert while trying
> to transmit the packet.
>
> To prevent this, we need to make sure the window of fragements containing
> MSS worth of data contains 1 BD less than for regular packets due to
> the additional parsing BD.
>
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
> Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
> ---
> Hi Dave,
>
> Please consider applying this to `net'.
>
> Thanks,
> Yuval
> ---
>   drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 22 +++++++++++++---------
>   1 file changed, 13 insertions(+), 9 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> index f8d7a2f..3718362 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> @@ -3430,25 +3430,29 @@ static u32 bnx2x_xmit_type(struct bnx2x *bp, struct sk_buff *skb)
>   	return rc;
>   }
>
> -#if (MAX_SKB_FRAGS >= MAX_FETCH_BD - 3)
> +/* VXLAN: 4 = 1 (for linear data BD) + 3 (2 for PBD and last BD) */
> +#define BNX2X_NUM_VXLAN_TSO_WIN_SUB_BDS         4
> +
> +/* Regular: 3 = 1 (for linear data BD) + 2 (for PBD and last BD) */
> +#define BNX2X_NUM_TSO_WIN_SUB_BDS               3
> +
> +#if (MAX_SKB_FRAGS >= MAX_FETCH_BD - BDS_PER_TX_PKT)
>   /* check if packet requires linearization (packet is too fragmented)
>      no need to check fragmentation if page size > 8K (there will be no
>      violation to FW restrictions) */
>   static int bnx2x_pkt_req_lin(struct bnx2x *bp, struct sk_buff *skb,
>   			     u32 xmit_type)
>   {
> -	int to_copy = 0;
> -	int hlen = 0;
> -	int first_bd_sz = 0;
> +	int first_bd_sz = 0, num_tso_win_sub = BNX2X_NUM_TSO_WIN_SUB_BDS;
> +	int to_copy = 0, hlen = 0;
>
> -	/* 3 = 1 (for linear data BD) + 2 (for PBD and last BD) */
> -	if (skb_shinfo(skb)->nr_frags >= (MAX_FETCH_BD - 3)) {
> +	if (xmit_type & XMIT_GSO_ENC)
> +			num_tso_win_sub = BNX2X_NUM_VXLAN_TSO_WIN_SUB_BDS;

    Indented too much.

[...]

MBR, Sergei
