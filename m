From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] vlan: Add GRO support for non hardware
 accelerated vlan
Date: Mon, 01 Jun 2015 07:12:37 -0700
Message-ID: <1433167957.1895.4.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1433163307-9299-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:33723 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751540AbbFAOMk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 10:12:40 -0400
Received: by iebgx4 with SMTP id gx4so109515629ieb.0
        for <netdev@vger.kernel.org>; Mon, 01 Jun 2015 07:12:39 -0700 (PDT)
In-Reply-To: <1433163307-9299-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-06-01 at 21:55 +0900, Toshiaki Makita wrote:

> @@ -668,6 +753,9 @@ static int __init vlan_proto_init(void)
>  	if (err < 0)
>  		goto err5;
>  
> +	for (i = 0; i < ARRAY_SIZE(vlan_packet_offloads); i++)
> +		dev_add_offload(&vlan_packet_offloads[i]);
> +
>  	vlan_ioctl_set(vlan_ioctl_handler);
>  	return 0;

My concern about this is :

This might slow down GRO stack for other traffic, if dev_add_offload()
for vlan offloads is called after 
dev_add_offload(&ip_packet_offload) /
dev_add_offload(&ipv6_packet_offload)


This is because list_add_rcu is used and this inserts in front of the
offload_base list.

void dev_add_offload(struct packet_offload *po)
{
        struct list_head *head = &offload_base;

        spin_lock(&offload_lock);
        list_add_rcu(&po->list, head);
        spin_unlock(&offload_lock);
}

Can we ensure offload_base contains a sensible order of expected types ?
