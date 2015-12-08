From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v3 2/4] i40e: geneve tunnel offload support
Date: Tue, 8 Dec 2015 10:20:06 -0800
Message-ID: <20151208182005.GB77166@ast-mbp.thefacebook.com>
References: <1449598334-97674-1-git-send-email-anjali.singhai@intel.com>
 <1449598334-97674-3-git-send-email-anjali.singhai@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.org,
	Kiran Patil <kiran.patil@intel.com>, tom@herbertland.com
To: Anjali Singhai Jain <anjali.singhai@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33240 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751716AbbLHSUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 13:20:11 -0500
Received: by pabur14 with SMTP id ur14so15781664pab.0
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2015 10:20:11 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1449598334-97674-3-git-send-email-anjali.singhai@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 08, 2015 at 10:12:12AM -0800, Anjali Singhai Jain wrote:
> +/**
> + * i40e_add_geneve_port - Get notifications about GENEVE ports that come up
> + * @netdev: This physical port's netdev
> + * @sa_family: Socket Family that GENEVE is notifying us about
> + * @port: New UDP port number that GENEVE started listening to
> + **/
> +static void i40e_add_geneve_port(struct net_device *netdev,
> +				 sa_family_t sa_family, __be16 port)
> +{
> +#if IS_ENABLED(CONFIG_GENEVE)
...
> +	/* New port: add it and mark its index in the bitmap */
> +	pf->udp_ports[next_idx].index = port;
> +	pf->udp_ports[next_idx].type = I40E_AQC_TUNNEL_TYPE_NGE;

the function suppose to deal with geneve but tunnel type is NGE ?!

> -#define I40E_MAX_TUNNEL_HDR_LEN 80
> +/* Hardware supports L4 tunnel length of 128B (=2^7) which includes
> + * inner mac plus all inner ethertypes.
> + */
> +#define I40E_MAX_TUNNEL_HDR_LEN 128

so the driver lied about actual hw capabilities earlier
or it needs firmware update to work this way?

> -	if (!(tx_flags & I40E_TX_FLAGS_VXLAN_TUNNEL)) {
> +	if (!(tx_flags & I40E_TX_FLAGS_UDP_TUNNEL)) {
...
> @@ -163,7 +163,7 @@ enum i40e_dyn_idx_t {
>  #define I40E_TX_FLAGS_FSO		BIT(7)
>  #define I40E_TX_FLAGS_TSYN		BIT(8)
>  #define I40E_TX_FLAGS_FD_SB		BIT(9)
> -#define I40E_TX_FLAGS_VXLAN_TUNNEL	BIT(10)
> +#define I40E_TX_FLAGS_UDP_TUNNEL	BIT(10)

these changes implying that HW actually doesn't have special 'geneve or vxlan'
hard coded logic and it's generic enough to understand most of udp tunnels.
Then why you cannot generalize this whole things as generic udp tunnel offload
and do not add any protocol specific hooks and ndos.
