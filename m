From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v2 2/2] e1000: bundle xdp xmit routines
Date: Fri, 9 Sep 2016 16:37:06 -0700
Message-ID: <57D347A2.4060909@gmail.com>
References: <20160909212915.4001.25504.stgit@john-Precision-Tower-5810>
 <20160909212938.4001.40540.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, intel-wired-lan@lists.osuosl.org,
        u9012063@gmail.com, netdev@vger.kernel.org
To: bblanco@plumgrid.com, alexei.starovoitov@gmail.com,
        jeffrey.t.kirsher@intel.com, brouer@redhat.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33859 "EHLO
        mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750833AbcIIXhU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 19:37:20 -0400
Received: by mail-pa0-f44.google.com with SMTP id to9so32625082pac.1
        for <netdev@vger.kernel.org>; Fri, 09 Sep 2016 16:37:20 -0700 (PDT)
In-Reply-To: <20160909212938.4001.40540.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-09 02:29 PM, John Fastabend wrote:
> e1000 supports a single TX queue so it is being shared with the stack
> when XDP runs XDP_TX action. This requires taking the xmit lock to
> ensure we don't corrupt the tx ring. To avoid taking and dropping the
> lock per packet this patch adds a bundling implementation to submit
> a bundle of packets to the xmit routine.
> 
> I tested this patch running e1000 in a VM using KVM over a tap
> device using pktgen to generate traffic along with 'ping -f -l 100'.
> 
> Suggested-by: Jesper Dangaard Brouer <brouer@redhat.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---

This patch is a bit bogus in a few spots as well...


> -
> -	if (E1000_DESC_UNUSED(tx_ring) < 2) {
> -		HARD_TX_UNLOCK(netdev, txq);
> -		return;
> +	for (; i < E1000_XDP_XMIT_BUNDLE_MAX && buffer_info[i].buffer; i++) {
> +		e1000_xmit_raw_frame(buffer_info[i].buffer,
> +				     buffer_info[i].length,
> +				     adapter, tx_ring);
> +		buffer_info[i].buffer->rxbuf.page = NULL;
> +		buffer_info[i].buffer = NULL;
> +		buffer_info[i].length = 0;
> +		i++;
              ^^^^^^^^
