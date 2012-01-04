From: Joe Perches <joe@perches.com>
Subject: RE: [net-next 08/11] e1000e: add Receive Packet Steering (RPS)
 support
Date: Tue, 03 Jan 2012 16:12:54 -0800
Message-ID: <1325635974.24257.20.camel@joe2Laptop>
References: <1325618356-2655-9-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20120103.150936.572765552893657192.davem@davemloft.net>
	 <804857E1F29AAC47BF68C404FC60A1840292A5@ORSMSX102.amr.corp.intel.com>
	 <20120103.152739.1456113375065412910.davem@davemloft.net>
	 <804857E1F29AAC47BF68C404FC60A18402A7BC@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:55610 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754975Ab2ADAM4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jan 2012 19:12:56 -0500
In-Reply-To: <804857E1F29AAC47BF68C404FC60A18402A7BC@ORSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-01-03 at 20:28 +0000, Allan, Bruce W wrote:
> >From: David Miller [mailto:davem@davemloft.net]
> >Fair enough, I rescind my request and this patch is fine as-is.
> Okay, thanks Dave.

A couple of other comments though.

On Tue, 2012-01-03 at 11:19 -0800, Jeff Kirsher wrote:
> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> Enable RPS by default.  Disallow jumbo frames when both receive checksum
> and receive hashing are enabled because the hardware cannot do both IP
> payload checksum (enabled when receive checksum is enabled when using
> packet split which is used for jumbo frames) and provide RSS hash at the
> same time.
[]
> diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
[]
> +static void e1000e_setup_rss_hash(struct e1000_adapter *adapter)
[]
> +	static const u8 rsshash[40] = {
[]
+	};
> +
> +	/* Fill out hash function seeds */
> +	for (j = 0; j < 10; j++) {
> +		u32 rsskey = rsshash[(j * 4)];
> +		rsskey |= rsshash[(j * 4) + 1] << 8;
> +		rsskey |= rsshash[(j * 4) + 2] << 16;
> +		rsskey |= rsshash[(j * 4) + 3] << 24;

Strictly, don't these shifts first need a cast to u32?

	u32 rsskey = rsshash[j * 4];
	rsskey |= ((u32)rsshash[j * 4 + 1]) << 8;
	rsskey |= ((u32)rsshash[j * 4 + 2]) << 16;
	rsskey |= ((u32)rsshash[j * 4 + 3]) << 24;

[]

> +	if (adapter->rx_ps_pages &&
> +	    (features & NETIF_F_RXCSUM) && (features & NETIF_F_RXHASH)) {
> +		e_err("Enabling both receive checksum offload and receive hashing is not possible with jumbo frames.  Disable jumbos or enable only one of the receive offload features.\n");
> +		return -EINVAL;
> +	}
 
This is a very long output string.
I think keeping individual dmesg lines shorter is preferred.
It might be better to use 2 e_err lines like:

		e_err("Enabling both receive checksum offload and receive hashing is not possible with jumbo frames\n");
		e_err("Disable jumbos or enable only one of the receive offload features\n");

or

		e_err("Enabling both receive checksum offload and receive hashing is not possible with jumbo frames\n"
		      "Disable jumbos or enable only one of the receive offload features\n");
