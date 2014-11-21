From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCHv2 net] i40e: Implement ndo_gso_check()
Date: Thu, 20 Nov 2014 16:19:33 -0800
Message-ID: <CAEP_g=-VEWi2Qo6gcJGr2+NXWEhkuMyu7BiAke6H=x+PTLcNcg@mail.gmail.com>
References: <1416525081-27779-1-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Shannon Nelson <shannon.nelson@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Tom Herbert <therbert@google.com>, linux.nics@intel.com,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog110.obsmtp.com ([74.125.149.203]:37445 "HELO
	na3sys009aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755490AbaKUATy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 19:19:54 -0500
Received: by mail-qg0-f46.google.com with SMTP id z107so1420728qgd.33
        for <netdev@vger.kernel.org>; Thu, 20 Nov 2014 16:19:54 -0800 (PST)
In-Reply-To: <1416525081-27779-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 20, 2014 at 3:11 PM, Joe Stringer <joestringer@nicira.com> wrote:
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index c3a7f4a..2b01c8d 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> @@ -7447,6 +7447,36 @@ static int i40e_ndo_fdb_dump(struct sk_buff *skb,
>
>  #endif /* USE_DEFAULT_FDB_DEL_DUMP */
>  #endif /* HAVE_FDB_OPS */
> +static bool i40e_gso_check(struct sk_buff *skb, struct net_device *dev)
> +{
> +       if ((skb_shinfo(skb)->gso_type & SKB_GSO_IPIP) &&
> +           (skb->inner_protocol_type != ENCAP_TYPE_IPPROTO ||
> +            skb->inner_protocol != htons(IPPROTO_IPIP))) {

I think this check on inner_protocol isn't really semantically correct
- that field is a union with inner_ipproto, so it would be more
correct to check against that and then you wouldn't need to use htons
either.

I don't know if we need to have the check at all for IPIP though -
after all the driver doesn't expose support for it all (actually it
doesn't expose GRE either). This raises kind of an interesting
question about the checks though - it's pretty easy to add support to
the driver for a new GSO type (and I imagine that people will be
adding GRE soon) and forget to update the check.

> +       if (skb_shinfo(skb)->gso_type & (SKB_GSO_GRE | SKB_GSO_UDP_TUNNEL)) {
> +               unsigned char *ihdr;
> +
> +               if (skb->inner_protocol_type != ENCAP_TYPE_ETHER)
> +                       return false;

I guess if you want to be nice, it might be good to check the
equivalent IP protocol types as well.
