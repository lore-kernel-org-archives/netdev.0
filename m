From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v4 1/2] net: sched: tbf: fix calculation of max_size
Date: Mon, 02 Dec 2013 20:59:53 -0800
Message-ID: <1386046793.30495.12.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386041214-72744-1-git-send-email-yangyingliang@huawei.com>
	 <1386041214-72744-2-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, brouer@redhat.com,
	jpirko@redhat.com, jbrouer@redhat.com
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:56369 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752027Ab3LCE7z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 23:59:55 -0500
Received: by mail-pb0-f42.google.com with SMTP id uo5so20504045pbc.29
        for <netdev@vger.kernel.org>; Mon, 02 Dec 2013 20:59:54 -0800 (PST)
In-Reply-To: <1386041214-72744-2-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-12-03 at 11:26 +0800, Yang Yingliang wrote:

> +	for (max_size = 0; max_size < MAX_PKT_LEN; max_size++)
> +		if (psched_l2t_ns(&q->rate, max_size) > q->buffer)
> +			break;
> +	if (--max_size <= 0)
> +		goto unlock_done;
> +

This seems dubious. With your new code, max_size < 65536

Prior code had :

for (n = 0; n < 256; n++)
    if (rtab->data[n] > qopt->buffer)
        break;
max_size = (n << qopt->rate.cell_log) - 1;

So we could have much bigger max_size.

The reason I ask is that its possible to have qdisc_pkt_len(skb) being
bigger than 65536, for TCP packets with low MSS value.
