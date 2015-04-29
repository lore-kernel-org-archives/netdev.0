From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC net-next] pktgen: introduce 'rx' mode
Date: Tue, 28 Apr 2015 21:14:13 -0700
Message-ID: <1430280853.3711.19.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1430273488-8403-1-git-send-email-ast@plumgrid.com>
	 <1430273488-8403-2-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Thomas Graf <tgraf@suug.ch>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:35478 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751417AbbD2EOQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 00:14:16 -0400
Received: by igbyr2 with SMTP id yr2so109136564igb.0
        for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 21:14:15 -0700 (PDT)
In-Reply-To: <1430273488-8403-2-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-04-28 at 19:11 -0700, Alexei Starovoitov wrote:

> +	if (pkt_dev->flags & F_DO_RX) {
> +		local_bh_disable();
> +		atomic_add(burst, &pkt_dev->skb->users);
> +		do {
> +			ret = netif_receive_skb(pkt_dev->skb);
> +			if (ret == NET_RX_DROP)
> +				pkt_dev->errors++;
> +			pkt_dev->last_ok = 1;
> +			pkt_dev->sofar++;
> +			pkt_dev->seq_num++;
> +		} while (--burst > 0);
> +		local_bh_enable();
> +		goto out;
> +	}
> +

This looks buggy.

skb can be put on a queue, so skb->next and skb->prev cannot be reused,
or queues will be corrupted.

Note that on TX, it is possible to have the same issue if you use a
virtual device like bonding, and skb is queued on a slave qdisc.

(Thats why we have this IFF_TX_SKB_SHARING flag)
