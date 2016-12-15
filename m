From: Jonathan Maxwell <jmaxwell37@gmail.com>
Subject: Re: [PATCH net] ibmveth: calculate gso_segs for large packets
Date: Fri, 16 Dec 2016 08:49:15 +1100
Message-ID: <CAGHK07B6c=4DStub4JUfXsQ1BQhZRw1SbPLw83xZWTYm6pRFpA@mail.gmail.com>
References: <1481674509-14256-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Brian King <brking@linux.vnet.ibm.com>,
        marcelo.leitner@gmail.com, pradeeps@linux.vnet.ibm.com,
        zdai@us.ibm.com, Eric Dumazet <eric.dumazet@gmail.com>
To: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:36477 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755300AbcLOWCK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2016 17:02:10 -0500
Received: by mail-io0-f194.google.com with SMTP id b194so9917025ioa.3
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2016 14:02:10 -0800 (PST)
In-Reply-To: <1481674509-14256-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 14, 2016 at 11:15 AM, Thomas Falcon
<tlfalcon@linux.vnet.ibm.com> wrote:
> Include calculations to compute the number of segments
> that comprise an aggregated large packet.
>
> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

Reviewed-by: Jonathan Maxwell <jmaxwell37@gmail.com>

> ---
>  drivers/net/ethernet/ibm/ibmveth.c | 12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
> index fbece63..a831f94 100644
> --- a/drivers/net/ethernet/ibm/ibmveth.c
> +++ b/drivers/net/ethernet/ibm/ibmveth.c
> @@ -1181,7 +1181,9 @@ static netdev_tx_t ibmveth_start_xmit(struct sk_buff *skb,
>
>  static void ibmveth_rx_mss_helper(struct sk_buff *skb, u16 mss, int lrg_pkt)
>  {
> +       struct tcphdr *tcph;
>         int offset = 0;
> +       int hdr_len;
>
>         /* only TCP packets will be aggregated */
>         if (skb->protocol == htons(ETH_P_IP)) {
> @@ -1208,14 +1210,20 @@ static void ibmveth_rx_mss_helper(struct sk_buff *skb, u16 mss, int lrg_pkt)
>         /* if mss is not set through Large Packet bit/mss in rx buffer,
>          * expect that the mss will be written to the tcp header checksum.
>          */
> +       tcph = (struct tcphdr *)(skb->data + offset);
>         if (lrg_pkt) {
>                 skb_shinfo(skb)->gso_size = mss;
>         } else if (offset) {
> -               struct tcphdr *tcph = (struct tcphdr *)(skb->data + offset);
> -
>                 skb_shinfo(skb)->gso_size = ntohs(tcph->check);
>                 tcph->check = 0;
>         }
> +
> +       if (skb_shinfo(skb)->gso_size) {
> +               hdr_len = offset + tcph->doff * 4;
> +               skb_shinfo(skb)->gso_segs =
> +                               DIV_ROUND_UP(skb->len - hdr_len,
> +                                            skb_shinfo(skb)->gso_size);
> +       }
>  }
>
>  static int ibmveth_poll(struct napi_struct *napi, int budget)
> --
> 1.8.3.1
>
