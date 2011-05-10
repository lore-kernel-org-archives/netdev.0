From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 3/3] RFC gianfar: add rx_ntuple feature
Date: Tue, 10 May 2011 20:38:26 +0100
Message-ID: <1305056306.2859.83.camel@bwh-desktop>
References: <OF56049997.B9542799-ON8525788C.00470640-8525788C.00470642@BeldenCDT.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Sebastian.Poehn@Belden.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:34247 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751702Ab1EJTi3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 15:38:29 -0400
In-Reply-To: <OF56049997.B9542799-ON8525788C.00470640-8525788C.00470642@BeldenCDT.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As a general warning, you may find that the RX NFC interface makes more
sense.  So far only ixgbe and sfc implement the RX n-tuple interface and
ixgbe will be moving to RX NFC.

I don't know quite what the capabilities of this hardware are, so it may
be that RX NFC doesn't make much sense.

On Tue, 2011-05-10 at 08:55 -0400, Sebastian.Poehn@Belden.com wrote:
> This  is the main part. Functionality to add and remove ntuples,
> conversion  from ntuple to hardware binary rx filer format,
> optimization of hardware  filer table entries and extended hardware
> capability check.
> 
> --- gianfar_ethtool.c.orig	2011-05-10 11:45:33.301745000 +0200
> +++ gianfar_ethtool.c	2011-05-10 13:27:23.041744819 +0200

Diffs should be made from above the linux-2.6 directory (or using 'git
diff' or similar).

> @@ -42,6 +42,8 @@
>  
>  extern void gfar_start(struct net_device *dev);
>  extern int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit);
> +extern void sort(void *, size_t, size_t, int(*cmp_func)(const void *,
> +		const void *), void(*swap_func)(void *, void *, int size));

Why are you declaring this here rather than including <linux/sort.h>?

>  #define GFAR_MAX_COAL_USECS 0xffff
>  #define GFAR_MAX_COAL_FRAMES 0xff
> @@ -787,6 +789,1011 @@ static int gfar_set_nfc(struct net_devic
>  	return ret;
>  }
>  
> +/*Global pointer on table*/
> +struct filer_table *ref;
> +u32 filer_index;
> +struct interf *queue;
> +
> +enum nop {
> +	ASC = 0, DESC = 1
> +} row;

Is this global state really necessary?  I think not.

> +static inline void toggle_order(void)
> +{
> +	row ^= 1;
> +}
> +
> +static int my_comp(const void *a, const void *b)
> +{
> +
> +	signed int temp;
> +	if (*(u32 *) a > *(u32 *) b)
> +		temp = -1;
> +	else if (*(u32 *) a == *(u32 *) b)
> +		temp = 0;
> +	else
> +		temp = 1;
> +
> +	if (row == DESC)
> +		return temp;
> +	else
> +		return -temp;
> +}

Use a second comparison function to reverse the order.

> +static void my_swap(void *a, void *b, int size)
> +{
> +	u32 t1 = *(u32 *) a;
> +	u32 t2 = *(u32 *) (a + 4);
> +	u32 t3 = *(u32 *) (a + 8);
> +	u32 t4 = *(u32 *) (a + 12);
> +	*(u32 *) a = *(u32 *) b;
> +	*(u32 *) (a + 4) = *(u32 *) (b + 4);
> +	*(u32 *) (a + 8) = *(u32 *) (b + 8);
> +	*(u32 *) (a + 12) = *(u32 *) (b + 12);
> +	*(u32 *) b = t1;
> +	*(u32 *) (b + 4) = t2;
> +	*(u32 *) (b + 8) = t3;
> +	*(u32 *) (b + 12) = t4;
> +}
> +
> +/*Write a mask to hardware*/
> +static inline void set_mask(u32 mask)
> +{
> +	ref->fe[filer_index].ctrl = RQFCR_AND | RQFCR_PID_MASK
> +			| RQFCR_CMP_EXACT;
> +	ref->fe[filer_index].prop = mask;
> +	filer_index++;
> +}
> +
> +/*Sets parse bits (e.g. IP or TCP)*/
> +static void set_parse_bits(u32 host, u32 mask)
> +{
> +	set_mask(mask);
> +	ref->fe[filer_index].ctrl = RQFCR_CMP_EXACT | RQFCR_PID_PARSE
> +			| RQFCR_AND;
> +	ref->fe[filer_index].prop = host;
> +	filer_index++;
> +}
> +
> +/*For setting a tuple of host,mask of type flag
> + *Example:
> + *IP-Src = 10.0.0.0/255.0.0.0
> + *host: 0x0A000000 mask: FF000000 flag: RQFPR_IPV4
> + *Note:
> + *For better usage of hardware 16 and 8 bit masks should be filled up
> + *with ones*/
> +static void set_attribute(unsigned int host, unsigned int mask,
> +		unsigned int flag)

It would be clearer to rename 'host' as 'value'.

> +{
> +	if (host || ~mask) {

If all bits are masked then the 'host' value must be ignored.  So just
check ~mask.

> +		/*This is to deal with masks smaller than 32bit
> +		 * and for special processing of MAC-filtering and
> +		 * VLAN-filtering*/
> +		switch (flag) {
> +		/*3bit*/
> +		case RQFCR_PID_PRI:
> +			if (((host & 0x7) == 0) && ((mask & 0x7) == 0))
> +				return;

Doesn't this mean that an n-tuple filter that should match priority 0
will actually match all priority values?

> +			host &= 0x7;
> +			break;
> +			/*8bit*/
> +		case RQFCR_PID_L4P:
> +		case RQFCR_PID_TOS:
> +			if (!(mask & 0xFF))
> +				mask = 0xFFFFFFFF;

I don't understand this special case.  Are you sure you shouldn't be
using something like:

			mask ^= 0xff;

> +			break;
> +			/*12bit*/
> +		case RQFCR_PID_VID:
> +			if (((host & 0xFFF) == 0) && ((mask & 0xFFF) == 0))
> +				return;

Again, this seems to mean that a filter that should match VID 0 (i.e.
untagged) will match both tagged and untagged frames.

> +			host &= 0xFFF;
> +			break;
> +			/*16bit*/
> +		case RQFCR_PID_DPT:
> +		case RQFCR_PID_SPT:
> +		case RQFCR_PID_ETY:
> +			if (!(mask & 0xFFFF))
> +				mask = 0xFFFFFFFF;

Again, I don't understand this special case.

> +			break;
> +			/*24bit*/
> +		case RQFCR_PID_DAH:
> +		case RQFCR_PID_DAL:
> +		case RQFCR_PID_SAH:
> +		case RQFCR_PID_SAL:
> +			host &= 0x00FFFFFF;
> +			break;
> +			/*for all real 32bit masks*/
> +		default:
> +			if (!mask)
> +				mask = 0xFFFFFFFF;
> +			break;
> +		}
> +
> +		set_mask(mask);
> +		ref->fe[filer_index].ctrl = RQFCR_CMP_EXACT | RQFCR_AND | flag;
> +		ref->fe[filer_index].prop = host;
> +		filer_index++;
> +	}
> +}
> +
> +/*Translates host and mask for UDP,TCP or SCTP*/
> +static void set_basic_ip(struct ethtool_tcpip4_spec *host,
> +		struct ethtool_tcpip4_spec *mask)
> +{
> +	set_attribute(host->ip4src, mask->ip4src, RQFCR_PID_SIA);
> +	set_attribute(host->ip4dst, mask->ip4dst, RQFCR_PID_DIA);
> +	set_attribute(host->pdst, mask->pdst | 0xFFFF0000, RQFCR_PID_DPT);
> +	set_attribute(host->psrc, mask->psrc | 0xFFFF0000, RQFCR_PID_SPT);
> +	set_attribute(host->tos, mask->tos | 0xFFFFFF00, RQFCR_PID_TOS);
> +}
> +
> +/*Translates host and mask for USER-IP4*/
> +static inline void set_user_ip(struct ethtool_usrip4_spec *host,
> +		struct ethtool_usrip4_spec *mask)
> +{
> +
> +	set_attribute(host->ip4src, mask->ip4src, RQFCR_PID_SIA);
> +	set_attribute(host->ip4dst, mask->ip4dst, RQFCR_PID_DIA);
> +	set_attribute(host->tos, mask->tos | 0xFFFFFF00, RQFCR_PID_TOS);
> +	set_attribute(host->proto, mask->proto | 0xFFFFFF00, RQFCR_PID_L4P);
> +	set_attribute(host->l4_4_bytes, mask->l4_4_bytes, RQFCR_PID_ARB);
> +
> +}
> +
> +/*Translates host and mask for ETHER spec*/
> +static inline void set_ether(struct ethhdr *host, struct ethhdr *mask)
> +{
> +	u32 upper_temp_mask = 0;
> +	u32 lower_temp_mask = 0;
> +	/*Source address*/
> +	if (!(is_zero_ether_addr(host->h_source) && is_broadcast_ether_addr(
> +			mask->h_source))) {

Just check !is_broadcast_ether_addr(mask->h_source).

> +		if (is_zero_ether_addr(mask->h_source)) {
> +			upper_temp_mask = 0xFFFFFFFF;
> +			lower_temp_mask = 0xFFFFFFFF;
> +		} else {
> +			upper_temp_mask = mask->h_source[0] << 16
> +					| mask->h_source[1] << 8
> +					| mask->h_source[2] | 0xFF000000;
> +			lower_temp_mask = mask->h_source[3] << 16
> +					| mask->h_source[4] << 8
> +					| mask->h_source[5] | 0xFF000000;
> +		}
> +		/*Upper 24bit*/
> +		set_attribute(0x80000000 | host->h_source[0] << 16
> +				| host->h_source[1] << 8 | host->h_source[2],
> +				upper_temp_mask, RQFCR_PID_SAH);
> +		/*And the same for the lower part*/
> +		set_attribute(0x80000000 | host->h_source[3] << 16
> +				| host->h_source[4] << 8 | host->h_source[5],
> +				lower_temp_mask, RQFCR_PID_SAL);
> +	}
> +	/*Destination address*/
> +	if (!(is_zero_ether_addr(host->h_dest) && is_broadcast_ether_addr(
> +			mask->h_dest))) {

Similarly here, just test the mask.

> +		/*Special for destination is limited broadcast*/
> +		if ((is_broadcast_ether_addr(host->h_dest)
> +				&& is_zero_ether_addr(mask->h_dest))) {
> +			set_parse_bits(RQFPR_EBC, RQFPR_EBC);
> +		} else {
> +
> +			if (is_zero_ether_addr(mask->h_dest)) {
> +				upper_temp_mask = 0xFFFFFFFF;
> +				lower_temp_mask = 0xFFFFFFFF;
> +			} else {
> +				upper_temp_mask = mask->h_dest[0] << 16
> +						| mask->h_dest[1] << 8
> +						| mask->h_dest[2] | 0xFF000000;
> +				lower_temp_mask = mask->h_dest[3] << 16
> +						| mask->h_dest[4] << 8
> +						| mask->h_dest[5] | 0xFF000000;
> +			}
> +
> +			/*Upper 24bit*/
> +			set_attribute(0x80000000 | host->h_dest[0] << 16
> +					| host->h_dest[1] << 8
> +					| host->h_dest[2], upper_temp_mask,
> +					RQFCR_PID_DAH);
> +			/*And the same for the lower part*/
> +			set_attribute(0x80000000 | host->h_dest[3] << 16
> +					| host->h_dest[4] << 8
> +					| host->h_dest[5], lower_temp_mask,
> +					RQFCR_PID_DAL);
> +		}
> +	}
> +
> +	/*Set Ethertype*/
> +	if ((host->h_proto || ~(mask->h_proto | 0xFFFF0000))) {

Similarly here, just test the mask.

> +		set_attribute(host->h_proto, mask->h_proto | 0xFFFF0000,
> +				RQFCR_PID_ETY);
> +	}
> +
> +	/*
> +	 * Question: What the hell does the 0x80000000 do?
> +	 * Answer: It is just a dirty hack to prevent the setAtribute()
> +	 * to ignore a half MAC address which is like 0x000000/0xFFFFFF
> +	 */

Why would it do that?

Is a filter that matches only upper or only lower 24 bits of a MAC
address invalid?

[Skipped more stuff; I haven't got time to review all of this.]

[...]
> +static int gfar_set_rx_ntuple(struct net_device *dev,
> +		struct ethtool_rx_ntuple *cmd)
> +{	struct gfar __iomem *regs = NULL;
> +	struct gfar_private *priv = netdev_priv(dev);
> +	int i = 0;
> +	static struct interf *store[10];
> +
> +	regs = priv->gfargrp[0].regs;
> +
> +	/*Only values between -2 and num_rx_queues -1 allowed*/
> +	if ((cmd->fs.action >= (signed int)priv->num_rx_queues) ||
> +	(cmd->fs.action < ETHTOOL_RXNTUPLE_ACTION_CLEAR))
> +		return -EINVAL;
> +
> +	for (i = 0; i < 10; i++) {
> +		if (store[i] == 0) {
> +			store[i] = init_table(priv);
> +			if (store[i] == (struct interf *)-1) {
> +				store[i] = 0;
> +				return -1;
> +			}
> +			strcpy(store[i]->name, dev->name);
> +			break;
> +		} else if (!strcmp(store[i]->name, dev->name)) {
> +			queue = store[i];
> +			break;
> +		}
> +
> +	}

Why aren't you putting this state in struct gfar_private?

You can't use name as a key anyway; interfaces can be renamed.

> +	do_action(&cmd->fs, priv);
> +
> +	return 0;
> +}
> +
> +
>  const struct ethtool_ops gfar_ethtool_ops = {
>  	.get_settings = gfar_gsettings,
>  	.set_settings = gfar_ssettings,
> @@ -808,4 +1815,6 @@ const struct ethtool_ops gfar_ethtool_op
>  	.set_wol = gfar_set_wol,
>  #endif
>  	.set_rxnfc = gfar_set_nfc,
> +	/*function for accessing rx queue filer*/
> +	.set_rx_ntuple = gfar_set_rx_ntuple
>  };
>  
> Signed-off-by: Sebastian Poehn <sebastian.poehn@belden.com>

This belongs at the top, but is not important for an RFC anyway.

> DISCLAIMER:
> 
> Privileged and/or Confidential information may be contained in this
> message. If you are not the addressee of this message, you may not
> copy, use or deliver this message to anyone. In such event, you
> should destroy the message and kindly notify the sender by reply
> e-mail. It is understood that opinions or conclusions that do not
> relate to the official business of the company are neither given
> nor endorsed by the company.

Well this wasn't sent specifically to me, so am I in trouble now?
Please get rid of this nonsense.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

