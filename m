From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 04/14] e1000: consolidate managability enabling/disabling
Date: Fri, 15 Dec 2006 09:32:30 -0500
Message-ID: <4582B1FE.5070801@garzik.org>
References: <1166174907.3365.108.camel@laptopd505.fenrus.org> <1166175176.3365.118.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55128 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752001AbWLOOcc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Dec 2006 09:32:32 -0500
To: Arjan van de Ven <arjan@linux.intel.com>
In-Reply-To: <1166175176.3365.118.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arjan van de Ven wrote:
> +static void
> +e1000_init_manageability(struct e1000_adapter *adapter)
> +{
> +	if (adapter->en_mng_pt) {
> +		uint32_t manc2h = E1000_READ_REG(&adapter->hw, MANC2H);
> +		uint32_t manc = E1000_READ_REG(&adapter->hw, MANC);
> +
> +		/* disable hardware interception of ARP */
> +		manc &= ~(E1000_MANC_ARP_EN);
> +
> +		/* enable receiving management packets to the host */
> +		/* this will probably generate destination unreachable messages
> +		 * from the host OS, but the packets will be handled on SMBUS */
> +		if (adapter->hw.mac_type >= e1000_82571) {
> +			manc |= E1000_MANC_EN_MNG2HOST;
> +#define E1000_MNG2HOST_PORT_623 (1 << 5)
> +#define E1000_MNG2HOST_PORT_664 (1 << 6)
> +			manc2h |= E1000_MNG2HOST_PORT_623;
> +			manc2h |= E1000_MNG2HOST_PORT_664;
> +			E1000_WRITE_REG(&adapter->hw, MANC2H, manc2h);
> +		}
> +
> +		E1000_WRITE_REG(&adapter->hw, MANC, manc);
> +	}
> +}
> +
> +static void
> +e1000_release_manageability(struct e1000_adapter *adapter)
> +{
> +	if (adapter->en_mng_pt) {
> +		uint32_t manc = E1000_READ_REG(&adapter->hw, MANC);
> +
> +		/* re-enable hardware interception of ARP */
> +		manc |= E1000_MANC_ARP_EN;
> +
> +		if (adapter->hw.mac_type >= e1000_82571)
> +			manc &= ~E1000_MANC_EN_MNG2HOST;
> +
> +		/* don't explicitly have to mess with MANC2H since
> +		 * MANC has an enable disable that gates MANC2H */
> +
> +		E1000_WRITE_REG(&adapter->hw, MANC, manc);
> +	}
> +}

This patch adds more error-probe mac_type tests, rather than a simple 
and tough-to-screw-up E1000_HAS_MGMT feature bit.


> +	/* If the controller is 82573 and f/w is AMT, do not set
> +	 * DRV_LOAD until the interface is up.  For all other cases,
> +	 * let the f/w know that the h/w is now under the control
> +	 * of the driver. */
> +	if (adapter->hw.mac_type != e1000_82573 ||
> +	    !e1000_check_mng_mode(&adapter->hw))
> +		e1000_get_hw_control(adapter);
>  
> -	if (netif_running(netdev))
> -		mod_timer(&adapter->watchdog_timer, jiffies);

ditto

