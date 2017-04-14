From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH net-next] bonding: do not pass link-local packets to master-interface
Date: Fri, 14 Apr 2017 12:30:24 -0700
Message-ID: <2810.1492198224@famine>
References: <20170414180022.124453-1-chonggangli@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: andy@greyhouse.net, vfalico@gmail.com, nikolay@redhat.com,
        edumazet@google.com, davem@davemloft.net, netdev@vger.kernel.org,
        Mahesh Bandewar <maheshb@google.com>,
        =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>
To: Chonggang Li <chonggangli@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:42016 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752257AbdDNTab (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 15:30:31 -0400
In-reply-to: <20170414180022.124453-1-chonggangli@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Chonggang Li <chonggangli@google.com> wrote:

>Previously link-local packets excluding LACP (which are handled by
>the recv_probe) received on bond slave interfaces are delivered to
>stack with bond-master device with RX_HANDLER_ANOTHER, however all
>link-local packets are link specific and should be delivered with
>exact same link/dev.

	In what case is the current behavior a problem (my guess would
be something related to LLDP)?  What if, e.g., the bond is a bridge
port, will STP frames no longer propagate to the bridge?

	Also, I think the description would be better if it mentioned
specifically that the patch is changing how skb->dev is set for link
local frames (bond->dev vs receiving interface), e.g.,

	"[...] however all link-local packets are link specific and
	should be delivered with skb->dev set to the original device."

>Signed-off-by: Chonggang Li <chonggangli@google.com>
>Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>Signed-off-by: Maciej Żenczykowski <maze@google.com>
>---
> drivers/net/bonding/bond_main.c | 3 +++
> 1 file changed, 3 insertions(+)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 01e4a69af421..aeca3d8541b9 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -1176,6 +1176,9 @@ static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
> 		}
> 	}
> 
>+	/* link-local packets should not be passed to master interface */
>+	if (is_link_local_ether_addr(eth_hdr(skb)->h_dest))
>+		return RX_HANDLER_PASS;

	Since this returns _PASS and not _EXACT, the packet will go
through the ptype_base packet handlers, so is the comment strictly
correct?

	-J

> 	if (bond_should_deliver_exact_match(skb, slave, bond))
> 		return RX_HANDLER_EXACT;
> 
>-- 
>2.12.2.762.g0e3151a226-goog
>

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
