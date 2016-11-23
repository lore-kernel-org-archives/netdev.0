From: Julian Anastasov <ja@ssi.bg>
Subject: Re: net/arp: ARP cache aging failed.
Date: Wed, 23 Nov 2016 10:33:13 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1611230928140.1659@ja.home.ssi.bg>
References: <957c2a80-7302-1ce9-726e-1e7512a941f4@huawei.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: yuehaibing <yuehaibing@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:58589 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S932982AbcKWIdg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Nov 2016 03:33:36 -0500
In-Reply-To: <957c2a80-7302-1ce9-726e-1e7512a941f4@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 23 Nov 2016, yuehaibing wrote:

> 	As to my topo,HOST1 and HOST3 share one route on HOST2, tcp connection between HOST2 and HOST3 may call tcp_ack to set dst->pending_confirm.
> 	
> So dst_neigh_output may wrongly freshed  n->confirmed which stands for HOST1,however HOST1'MAC had been changed.
> 
> 	The possibility of this occurred Significantly increases ,when ping and TCP transaction are set the same processor affinity on the HOST2.
> 
> 	It seems that the issue is brought in commit 5110effee8fde2edfacac9cd12a9960ab2dc39ea ("net: Do delayed neigh confirmation.").

	Bad news. Problem is not in delayed confirmation but
in the mechanism to use same dst for different neighbours on
LAN. We don't have a dst->neighbour reference anymore.

	For IPv4 this is related to rt->rt_uses_gateway but
also to DST_NOCACHE. In the other cases we can not call
dst_confirm, may be we should lookup the neigh entry instead.
But we need a way to reduce such lookups on every packet,
for example, by remembering in struct sock and checking if
some bits of jiffies (at least 4-5) are changed from
previous lookup.

Regards
