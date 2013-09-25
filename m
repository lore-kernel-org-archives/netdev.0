From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next v5 2/6] bonding: remove the no effect lock for
 bond_3ad_lacpdu_recv()
Date: Wed, 25 Sep 2013 12:33:00 +0200
Message-ID: <20130925103300.GB23575@redhat.com>
References: <5242B253.2070002@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25213 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750832Ab3IYKfD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Sep 2013 06:35:03 -0400
Content-Disposition: inline
In-Reply-To: <5242B253.2070002@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 25, 2013 at 05:52:19PM +0800, Ding Tianhong wrote:
>There is no pointer needed read lock protection, remove the unnecessary lock
>and improve performance for the 3ad recv path.

I don't really understand it. Here's the code path:

rx_handler (holding rcu_read_lock()) -> bond_handle_frame() ->
bond->recv_probe -> bond_3ad_lacpdu_recv(). So we're holding only the
rcu_read_lock() there. What stops us from racing with
bond_3ad_unbind_slave(), for example?

As in:

CPU0				CPU1
--------			-----------
...				bond_3ad_unbind_slave()
bond_3ad_rx_indication()	...
if (!port->slave) {		...			//slave is ok
				port->slave = NULL;
ad_marker_info_received()	...
ad_marker_send()		...
slave = port->slave;		...
skb->dev = slave->dev;		...
	   ^^^ NULL pointer dereference.


I'm not saying that this approach is wrong, maybe I'm missing something,
but when removing locks it's usually a good thing to do - to comment it in
depth in the commit message why it's not already needed.

>
>Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>Cc: Nikolay Aleksandrov <nikolay@redhat.com>
>---
> drivers/net/bonding/bond_3ad.c | 2 --
> 1 file changed, 2 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>index 7a3860f..c134f43 100644
>--- a/drivers/net/bonding/bond_3ad.c
>+++ b/drivers/net/bonding/bond_3ad.c
>@@ -2494,9 +2494,7 @@ int bond_3ad_lacpdu_recv(const struct sk_buff *skb, struct bonding *bond,
> 	if (!lacpdu)
> 		return ret;
>
>-	read_lock(&bond->lock);
> 	ret = bond_3ad_rx_indication(lacpdu, slave, skb->len);
>-	read_unlock(&bond->lock);
> 	return ret;
> }
>
>-- 
>1.8.2.1
>
>
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
