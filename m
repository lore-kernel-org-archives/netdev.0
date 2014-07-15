From: Veaceslav Falico <vfalico@gmail.com>
Subject: Re: [PATCH net v2] bonding: enhance L2 hash helper with packet type
Date: Tue, 15 Jul 2014 10:20:28 +0200
Message-ID: <20140715082028.GA28235@mikrodark.usersys.redhat.com>
References: <1405410083-26489-1-git-send-email-Jianhua.Xie@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Pan Jiafei <Jiafei.Pan@freescale.com>
To: Xie Jianhua <Jianhua.Xie@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:54476 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751509AbaGOIX1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 04:23:27 -0400
Received: by mail-wi0-f172.google.com with SMTP id n3so3904195wiv.5
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 01:23:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1405410083-26489-1-git-send-email-Jianhua.Xie@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 15, 2014 at 03:41:23PM +0800, Xie Jianhua wrote:
>From: Jianhua Xie <jianhua.xie@freescale.com>
>
>Current L2 hash helper calculates destination eth addr and
>source ether addr as L2 hash factors. This patch is adding
>packet type ID field into hash factors, which can help to
>distribute different types of packets like IPv4/IPv6 packets
>to different slave devices while only BOND_XMIT_POLICY_LAYER2
>is applied.

1) It's also used in BOND_XMIT_POLICY_{LAYER|ENCAP}23, for the 2nd level
hash.
2) The documentation (D/networking/bonding.txt) also needs an update.

Otherwise, looks good.

>
>CC: Jay Vosburgh <j.vosburgh@gmail.com>
>CC: Veaceslav Falico <vfalico@gmail.com>
>CC: Andy Gospodarek <andy@greyhouse.net>
>CC: David S. Miller <davem@davemloft.net>
>CC: Pan Jiafei <Jiafei.Pan@freescale.com>
>
>Suggested-by: David S. Miller <davem@davemloft.net>
>Signed-off-by: Jianhua Xie <jianhua.xie@freescale.com>
>---
>
>v2-changes:
> Use the appropriate interface skb_header_pointer()
> to check skb headlen, fragmented packet or not is
> not distinguished any more.
>
>
> drivers/net/bonding/bond_main.c | 8 ++++----
> 1 file changed, 4 insertions(+), 4 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 3a451b6..bcff90c 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -2999,11 +2999,11 @@ static struct notifier_block bond_netdev_notifier = {
> /* L2 hash helper */
> static inline u32 bond_eth_hash(struct sk_buff *skb)
> {
>-	struct ethhdr *data = (struct ethhdr *)skb->data;
>-
>-	if (skb_headlen(skb) >= offsetof(struct ethhdr, h_proto))
>-		return data->h_dest[5] ^ data->h_source[5];
>+	struct ethhdr *ep, hdr_tmp;
>
>+	ep = skb_header_pointer(skb, 0, sizeof(hdr_tmp), &hdr_tmp);
>+	if (ep)
>+		return ep->h_dest[5] ^ ep->h_source[5] ^ ep->h_proto;
> 	return 0;
> }
>
>-- 
>1.8.5
>
