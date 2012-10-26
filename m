From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] netxen: explicity handle pause autoneg
 parameter
Date: Fri, 26 Oct 2012 22:10:42 +0100
Message-ID: <1351285842.2584.13.camel@bwh-desktop.uk.solarflarecom.com>
References: <1351271832-21275-1-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:57397 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S966569Ab2JZVKq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 17:10:46 -0400
In-Reply-To: <1351271832-21275-1-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-10-26 at 15:17 -0200, Flavio Leitner wrote:
> The hardware doesn't support controlling pause frames autoneg, so
> report that back correctly to userspace.
> 
> Signed-off-by: Flavio Leitner <fbl@redhat.com>
> ---
>  drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> I don't have the hardware handy to test this, so I appreciate
> if someone could do it.
> 
> diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
> index 10468e7..b4b46f9 100644
> --- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
> +++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
> @@ -488,6 +488,8 @@ netxen_nic_get_pauseparam(struct net_device *dev,
>  	__u32 val;
>  	int port = adapter->physical_port;
>  
> +	pause->autoneg = AUTONEG_DISABLE;

AUTONEG_DISABLE is really meant for use in ethtool_cmd::autoneg, not
ethtool_pauseparam::autoneg.  (Though they are both really booleans so
this works in practice.)

>  	if (adapter->ahw.port_type == NETXEN_NIC_GBE) {
>  		if ((port < 0) || (port >= NETXEN_NIU_MAX_GBE_PORTS))
>  			return;
> @@ -532,6 +534,10 @@ netxen_nic_set_pauseparam(struct net_device *dev,
>  	struct netxen_adapter *adapter = netdev_priv(dev);
>  	__u32 val;
>  	int port = adapter->physical_port;
> +
> +	if (pause->autoneg)
> +		return -EOPNOTSUPP;

Should be -EINVAL; the operation (ETHTOOL_SPAUSEPARAM) is supported but
not these particular arguments.

Ben.

>  	/* read mode */
>  	if (adapter->ahw.port_type == NETXEN_NIC_GBE) {
>  		if ((port < 0) || (port >= NETXEN_NIU_MAX_GBE_PORTS))

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
