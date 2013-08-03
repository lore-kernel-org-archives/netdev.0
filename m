From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] bonding: fix arp monitoring with vlan slaves
Date: Fri, 02 Aug 2013 17:03:43 -0700
Message-ID: <1375488223.4457.16.camel@edumazet-glaptop>
References: <1375461665-4186-1-git-send-email-nikolay@redhat.com>
	  <20130802.153212.1340051334413929810.davem@davemloft.net>
	 <1375485466.4457.4.camel@edumazet-glaptop> <51FC40E5.6050809@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	andy@greyhouse.net, fubar@us.ibm.com
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:49582 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752386Ab3HCADo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 20:03:44 -0400
Received: by mail-pd0-f181.google.com with SMTP id g10so1198175pdj.12
        for <netdev@vger.kernel.org>; Fri, 02 Aug 2013 17:03:44 -0700 (PDT)
In-Reply-To: <51FC40E5.6050809@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-08-03 at 01:29 +0200, Nikolay Aleksandrov wrote:

> I knew it was because of the LLTX, but I was wondering about the possible
> reasons for the xmit_lock_owner check.
> So basically the arp monitoring (or any dev_trans_start code) won't work
> with LLTX devices because they don't get their trans_start updated (not the
> txq trans_start nor the dev->trans_start), is this correct ?

Nope : LLTX devices are supposed to update their own dev->trans_start
I added for these case a special comment as in :

drivers/net/ethernet/atheros/atl1e/atl1e_main.c:1883:   netdev->trans_start = jiffies; /* NETIF_F_LLTX driver :( */

trans_start is a txq property, and vlan devices have a single txq.

Updating the vlandev->trans_start or the vlantxq->trans_start would be a
performance killer on MQ ethernet.

And frankly, as this trans_start is really seldom queried, it makes no
sense to set it on fast path on the vlan device, if its properly done on
the real device anyway.

> But what if the txqs get bound to a particular CPU, then the txq
> trans_start is okay to be updated I suppose.

Not sure what you are saying. vlan xmit can be called from any cpus.
