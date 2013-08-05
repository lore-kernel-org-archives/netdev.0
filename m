From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: fix send_peer_notif leekage on rtnl
 lock congestion
Date: Mon, 05 Aug 2013 16:12:12 -0700 (PDT)
Message-ID: <20130805.161212.421332729798966037.davem@davemloft.net>
References: <1375732053-829-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50789 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750888Ab3HEXMN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 19:12:13 -0400
In-Reply-To: <1375732053-829-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Mon,  5 Aug 2013 21:47:33 +0200

> @@ -2999,7 +3002,10 @@ void bond_activebackup_arp_mon(struct work_struct *work)
>  		if (!rtnl_trylock()) {
>  			read_lock(&bond->lock);
>  			delta_in_ticks = 1;
> -			should_notify_peers = false;
> +			if (should_notify_peers) {
> +				bond->send_peer_notif++;

I doubt this increment to a shared datastructure is safe with
the locks you hold here.

You don't hold RTNL and you only have bond->lock as a reader.
