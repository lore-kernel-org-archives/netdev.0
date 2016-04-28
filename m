From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv2] netem: Segment GSO packets on enqueue.
Date: Thu, 28 Apr 2016 13:58:53 -0700
Message-ID: <1461877133.5535.119.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1461692618-21333-1-git-send-email-nhorman@tuxdriver.com>
	 <1461874148-14937-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>,
	netem@lists.linux-foundation.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34455 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753162AbcD1U64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 16:58:56 -0400
Received: by mail-pa0-f47.google.com with SMTP id r5so37156316pag.1
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 13:58:55 -0700 (PDT)
In-Reply-To: <1461874148-14937-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-04-28 at 16:09 -0400, Neil Horman wrote:
> This was recently reported to me, and reproduced on the latest net kernel, when
> attempting to run netperf from a host that had a netem qdisc attached to the
> egress interface:

>  
> -	return NET_XMIT_SUCCESS;
> +finish_segs:
> +	while (segs) {
> +		skb2 = segs->next;
> +		segs->next = NULL;
> +		qdisc_skb_cb(segs)->pkt_len = segs->len;
> +		rc = qdisc_enqueue(segs, sch);
> +		if (rc != NET_XMIT_SUCCESS) {
> +			if (net_xmit_drop_count(rc))
> +				qdisc_qstats_drop(sch);
> +		}
> +		segs = skb2;
> +	}
> +	return rc;
>  }

It seems you missed the qdisc_tree_reduce_backlog() call ?
