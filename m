From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] ehea: Fixing LRO configuration
Date: Sun, 12 Dec 2010 16:39:08 -0800
Message-ID: <AANLkTimvL2TdD9eYQMLZW65ESKbame818ObzjPYoBhPL@mail.gmail.com>
References: <1291833062-27446-1-git-send-email-leitao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, davem@davemloft.net, netdev@vger.kernel.org
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:57400 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753329Ab0LMAjK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Dec 2010 19:39:10 -0500
Received: by fxm18 with SMTP id 18so5717218fxm.2
        for <netdev@vger.kernel.org>; Sun, 12 Dec 2010 16:39:08 -0800 (PST)
In-Reply-To: <1291833062-27446-1-git-send-email-leitao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 8, 2010 at 10:31 AM,  <leitao@linux.vnet.ibm.com> wrote:
> In order to set LRO on ehea, the user must set a module parameter, wh=
ich
> is not the standard way to do so. This patch adds a way to set LRO us=
ing
> the ethtool tool.
>
> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
>
> diff --git a/drivers/net/ehea/ehea_ethtool.c b/drivers/net/ehea/ehea_=
ethtool.c
> index 75b099c..1f37ee6 100644
> --- a/drivers/net/ehea/ehea_ethtool.c
> +++ b/drivers/net/ehea/ehea_ethtool.c
> @@ -261,6 +261,13 @@ static void ehea_get_ethtool_stats(struct net_de=
vice *dev,
>
> =A0}
>
> +static int ehea_set_flags(struct net_device *dev, u32 data)
> +{
> + =A0 =A0 =A0 return ethtool_op_set_flags(dev, data, ETH_FLAG_LRO
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 | ETH_FLAG_TXVLAN
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 | ETH_FLAG_RXVLAN);

I don't think that this should enable those vlan offloading flags.  I
don't see any logic to actually disable vlan stripping on receive if
that flag is toggled.  Transmit might be OK, since it will cause the
networking core to insert the tag in software if offloading is
disabled.  However, I see some places where skb->protocol is accessed
to determine the protocol of the packet being transmitted.  In most
drivers this causes a problem when transmit vlan offloading is
disabled because the packet type becomes ETH_P_8021Q, instead of the
expected protocol.  On the other hand, it appears that there aren't
any offloads in vlan_features, so maybe it doesn't matter.
