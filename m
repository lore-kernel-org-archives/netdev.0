From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2.6.17-rc5] support for TSO over IPv6.
Date: Mon, 5 Jun 2006 12:43:29 -0700
Message-ID: <20060605124329.6e643ad3@dxpl.pdx.osdl.net>
References: <Pine.GSO.4.10.10606051458530.20246-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com,
	leonid.grossman@neterion.com, ravinandan.arakali@neterion.com,
	rapuru.sriram@neterion.com, ananda.raju@neterion.com,
	sivakumar.subramani@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:18105 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751329AbWFETnc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2006 15:43:32 -0400
To: Ananda Raju <Ananda.Raju@neterion.com>
In-Reply-To: <Pine.GSO.4.10.10606051458530.20246-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 5 Jun 2006 15:09:45 -0400 (EDT)
Ananda Raju <Ananda.Raju@neterion.com> wrote:

> Hi,
> 	Neterion Xframe adapter supports TSO over IPv6 but the linux kernel 
> 	don't support TSO over Ipv6. This patch will allow TCP
> 	Segmentation Offload (TSO) packets to be created over IPv6. 
> 	
> 	The following table shows there is significant improvement in
> 	throughput with normal frames and CPU usage for both normal and jumbo.
> 
>         --------------------------------------------------
>         |          |     1500        |      9600         |
>         |          ------------------|-------------------|
>         |          | thru     CPU    |  thru     CPU     |
>         --------------------------------------------------
>         | TSO OFF  | 1.80   2.0% id  |  5.53   1.0% id   |
>         --------------------------------------------------
>         | TSO ON   | 2.61   74.0 id  |  5.52   32.0% id  |
>         --------------------------------------------------
> 
> Please review the patch.

There is one problem that may mean you have to rethink this.

You ignore the possible case of hardware that can do any kind of checksum
(ie. IP_F_HW_CSUM).  So I think you need to add a new flag NETIF_F_TSO6
for those types of devices, rather than overloading NETIF_F_TSO to mean
"can do TCP segmentation offload for IPV4 or IPV6".

Your proposal:
	ipv4 sum   : NETIF_F_IP_CSUM
	ipv6 sum   : NETIF_F_IP6_CSUM
	hw sum     : NETIF_F_HW_CSUM
	tso, ipv4  : NETIF_F_IP_CSUM + NETIF_F_TSO
	tso, ipv6  : NETIF_F_IP6_CSUM + NETIF_F_TSO

My proposal:
	ipv4 sum   : NETIF_F_IP_CSUM
	ipv6 sum   : NETIF_F_IP6_CSUM
	hw sum     : NETIF_F_HW_CSUM
	tso, ipv4  : NETIF_F_IP_CSUM + NETIF_F_TSO
	tso, ipv6  : NETIF_F_IP6_CSUM + NETIF_F_TSO6
	tso, hw    : NETIF_F_HW_CSUM + NETIF_F_TSO6

