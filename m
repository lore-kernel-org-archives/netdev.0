From: Scott Feldman <sfeldma@pobox.com>
Subject: Re: [PATCH net-drivers-2.6 5/6] e100: Performance optimizations to e100 Tx Path
Date: Thu, 21 Apr 2005 09:55:00 -0700
Message-ID: <7e4e52dab6e50d8fc38c76651cac0f07@pobox.com>
References: <Pine.LNX.4.61.0504190534410.11186@anoushka.jf.intel.com>
Mime-Version: 1.0 (Apple Message framework v622)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>, "jgarzik@pobox.com" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <Pine.LNX.4.61.0504190534410.11186@anoushka.jf.intel.com>
To: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Apr 19, 2005, at 10:50 PM, Malli Chilakala wrote:

> Performance optimizations to e100 Tx Path

So what is the net performance improvement with these changes?

> -	nic->tx_command = cpu_to_le16(cb_tx | cb_i | cb_tx_sf |
> -		((nic->mac >= mac_82558_D101_A4) ? cb_cid : 0));
> +	/* no interrupt for every tx completion, delay = 256us if not 557*/
> +	nic->tx_command = cpu_to_le16(cb_tx | cb_tx_sf |
> +		((nic->mac >= mac_82558_D101_A4) ? cb_cid : cb_i));

Where is this 256us delay coming from?

>  	/* Template for a freshly allocated RFD */
>  	nic->blank_rfd.command = cpu_to_le16(cb_el);
> @@ -1289,12 +1294,15 @@ static inline void e100_xmit_prepare(str
>  	struct sk_buff *skb)
>  {
>  	cb->command = nic->tx_command;
> +	/* interrupt every 16 packets regardless of delay */
> +	if((nic->cbs_avail & ~15) == nic->cbs_avail) cb->command |= cb_i;

You messed up Big Endian.

So you send out 15 packets with no i-bit set.  Then what?  No interrupt 
means no NAPI means no cleanup of those 15 packet skbs.

-scott

P.S. I only saw this one patch for e100 but the subject line indicates 
there are 6.
