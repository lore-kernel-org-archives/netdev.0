From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 3/4] NetXen: Add correct routines to setup multicast address
Date: Sun, 10 Jun 2007 11:54:11 +0200
Message-ID: <200706101154.11746.mb@bu3sch.de>
References: <200706071134.l57BYbpH007596@dut39.unminc.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amitkale@netxen.com, jeff@garzik.org,
	netxenproj@linsyssoft.com, rob@netxen.com
To: Mithlesh Thukral <mithlesh@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:57975
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753001AbXFJJzi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jun 2007 05:55:38 -0400
In-Reply-To: <200706071134.l57BYbpH007596@dut39.unminc.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 07 June 2007 13:34:37 Mithlesh Thukral wrote:
> NetXen: Add multi cast filter code
> This patch adds multi cast filter code to NetXen NIC driver.
> It also adds capabilities to setup the multicast address in hardware
> from the host side.

> +int netxen_nic_enable_mcast_filter(struct netxen_adapter *adapter)
> +{
> +	u32 val = 0;

> +	memcpy(&val, adapter->mac_addr, 3);

Broken on BigEndian architectures.

> +	netxen_crb_writelit_adapter(adapter, NETXEN_UNICAST_ADDR(port,1), val);
> +
> +	memcpy(&val, adapter->mac_addr+3, 3);

Broken on BigEndian architectures.

> +	netxen_crb_writelit_adapter(adapter, NETXEN_UNICAST_ADDR(port,1) + 4,
> +					val);
> +
> +	adapter->mc_enabled = 1;
> +	return 0;
> +}
> +
> +int netxen_nic_disable_mcast_filter(struct netxen_adapter *adapter)
> +{
> +	u32 val =  0;
> +	u16 port = physical_port[adapter->portnum];
> +
> +	if(!adapter->mc_enabled)
> +		return 0;
> +
> +	netxen_crb_writelit_adapter(adapter, NETXEN_MAC_ADDR_CNTL_REG, val);
> +
> +	memcpy(&val, adapter->mac_addr, 3);

Broken on BigEndian architectures.

> +	netxen_crb_writelit_adapter(adapter, NETXEN_UNICAST_ADDR(port,0), val);
> +
> +	memcpy(&val, adapter->mac_addr+3, 3);

Broken on BigEndian architectures.

> +	netxen_crb_writelit_adapter(adapter, NETXEN_UNICAST_ADDR(port,0) + 4,
> +					val);
> +
> +	adapter->mc_enabled = 0;
> +	return 0;
> +}
> +
> +#define NETXEN_MCAST_ADDR(port, index)	\
> +	(NETXEN_MULTICAST_ADDR_BASE+(port*0x80)+(index*8))
> +
> +int netxen_nic_set_mcast_addr(struct netxen_adapter *adapter, int index, 
> +				u8 *addr)
> +{
> +	u32 hi = 0;
> +	u32 lo = 0;
> +	u16 port = physical_port[adapter->portnum];
> +
> +	hi = (u32) addr[0] | 
> +		((u32) addr[1] << 8) |
> +		((u32) addr[2] << 16);
> +	lo = (u32) addr[3] |
> +		((u32) addr[4] << 8) |
> +		((u32) addr[5] << 16);

That is the correct solution. Do that above, too.

> +	netxen_crb_writelit_adapter(adapter, NETXEN_MCAST_ADDR(port,index), hi);
> +	netxen_crb_writelit_adapter(adapter, NETXEN_MCAST_ADDR(port,index) + 4,
> +					hi);
> +	return 0;
> +}

-- 
Greetings Michael.
