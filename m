From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] multicast: Extend ip address command to enable
 multicast group join/leave on IP level.
Date: Tue, 17 Feb 2015 03:10:10 -0800
Message-ID: <1424171410.4942.74.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1424125238-4505-1-git-send-email-challa@noironetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Madhu Challa <challa@noironetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:52130 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755156AbbBQLKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2015 06:10:14 -0500
Received: by mail-qg0-f49.google.com with SMTP id q107so27329234qgd.8
        for <netdev@vger.kernel.org>; Tue, 17 Feb 2015 03:10:14 -0800 (PST)
In-Reply-To: <1424125238-4505-1-git-send-email-challa@noironetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-02-16 at 14:20 -0800, Madhu Challa wrote:
> Joining multicast group on ethernet level via "ip maddr" command would
> not work if we have an Ethernet switch that does igmp snooping since
> the switch would not replicate multicast packets on ports that did not
> have IGMP reports for the multicast addresses.
> 
...
> +struct mc_autojoin_request {
> +	union {
> +		struct sockaddr_in sin;
> +		struct sockaddr_in6 sin6;
> +	} addr;
> +	int ifindex;
> +	struct sock *sk;
> +	struct work_struct ipv4_work;
> +	struct work_struct ipv6_work;
> +	bool join;
> +};

This looks a net-next patch, right ?

You do not need 2 separate work_struct. A single one is enough, or even
no work queue at all as a matter of fact.

I'll send a preparation patch like this one, then you'll be able to call
__ip_mc_{join|leave}_group() directly while RTNL is held.

[PATCH net-next] igmp: add __ip_mc_{join|leave}_group()

There is a need to perform igmp join/leave operations while RTNL is
held. Make ip_mc_{join|leave}_group() wrappers around __ip_mc_{join|
leave}_group() to avoid the proliferation of work queues.

...
