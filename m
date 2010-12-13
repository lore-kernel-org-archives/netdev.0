From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-2.6 3/3] bonding/vlan: Fix mangled NAs on slaves without VLAN tag insertion
Date: Mon, 13 Dec 2010 12:43:06 -0800
Message-ID: <32094.1292272986@death>
References: <1292264216.9860.11.camel@bwh-desktop> <1292264424.9860.15.camel@bwh-desktop>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, Jesse Gross <jesse@nicira.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:53689 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754044Ab0LMUnN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 15:43:13 -0500
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e38.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id oBDKTRvH026482
	for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 13:29:27 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oBDKhADM166104
	for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 13:43:10 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oBDKh9kf021423
	for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 13:43:09 -0700
In-reply-to: <1292264424.9860.15.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <bhutchings@solarflare.com> wrote:

>bond_na_send() attempts to insert a VLAN tag in between building and
>sending packets of the respective formats.  If the slave does not
>implement hardware VLAN tag insertion then vlan_put_tag() will mangle
>the network-layer header because the Ethernet header is not present at
>this point (unlike in bond_arp_send()).
>
>Fix this by adding the tag out-of-line and relying on
>dev_hard_start_xmit() to insert it inline if necessary.
>
>Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

>---
> drivers/net/bonding/bond_ipv6.c |    7 ++++++-
> 1 files changed, 6 insertions(+), 1 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_ipv6.c b/drivers/net/bonding/bond_ipv6.c
>index 121b073..84fbd4e 100644
>--- a/drivers/net/bonding/bond_ipv6.c
>+++ b/drivers/net/bonding/bond_ipv6.c
>@@ -88,7 +88,12 @@ static void bond_na_send(struct net_device *slave_dev,
> 	}
>
> 	if (vlan_id) {
>-		skb = vlan_put_tag(skb, vlan_id);
>+		/* The Ethernet header is not present yet, so it is
>+		 * too early to insert a VLAN tag.  Force use of an
>+		 * out-of-line tag here and let dev_hard_start_xmit()
>+		 * insert it if the slave hardware can't.
>+		 */
>+		skb = __vlan_hwaccel_put_tag(skb, vlan_id);
> 		if (!skb) {
> 			pr_err("failed to insert VLAN tag\n");
> 			return;
>-- 
>1.7.3.2
>
>
>-- 
>Ben Hutchings, Senior Software Engineer, Solarflare Communications
>Not speaking for my employer; that's the marketing department's job.
>They asked us to note that Solarflare product names are trademarked.
>
