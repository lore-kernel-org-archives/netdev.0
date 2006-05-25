From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 8/9] Resending NetXen 1G/10G NIC driver patch
Date: Thu, 25 May 2006 10:03:39 -0700
Message-ID: <20060525100339.40b19371@dxpl.pdx.osdl.net>
References: <Pine.LNX.4.33.0605250356420.5844-100000@unmsrvr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sanjeev@netxen.com, unmproj@linsyssoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:28828 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030286AbWEYRDu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 May 2006 13:03:50 -0400
To: "Linsys Contractor Amit S. Kale" <amitkale@unminc.com>
In-Reply-To: <Pine.LNX.4.33.0605250356420.5844-100000@unmsrvr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The object factoring is a mess here. You have too many allocations
and indirections. My expectation would be:

1. One PCI device maps to one board and that is the adapter structure
   allocated with kzalloc.  (You are doing this right)

2. An adapter can have up to four ports. Each of these should be a
   netdevice and any port specific memory should be part of netdev_priv().

3. Have an array of pointers in the adapter structure for the maximum
   possible value, if the board has less the memory waste for three
   extra pointers is less than cost of dynamically sized array.

Something like

pci_prvdata -> adapter --> dev[0] -> netdevice { private data }
                       --> dev[1] ...
or
pci_privdata -> adapter -> port[0] -> private data
                        -> port[1]

In the later case, you need to have port->netdev pointer back to the
start of the net_device data structure.

If you do it this way, you won't need:

> +	adapter->port = kcalloc(adapter->ahw.max_ports,
> +				sizeof(struct netxen_adapter), GFP_KERNEL);

and

> +		netlist = kzalloc(sizeof(struct netdev_list), GFP_KERNEL);
> +		if (netlist == NULL)
> +			goto err_out_free_dev;

Also, do you really need to have such a big TX ring that it requires
a vmalloc?
