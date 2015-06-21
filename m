From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next RFC v2 1/3] lwt: infrastructure to support light
 weight tunnels
Date: Sun, 21 Jun 2015 22:32:33 +0200
Message-ID: <20150621203233.GC4228@pox.localdomain>
References: <1434689355-4088-2-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ebiederm@xmission.com, rshearma@brocade.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:33316 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753126AbbFUUch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2015 16:32:37 -0400
Received: by wgwi7 with SMTP id i7so6456616wgw.0
        for <netdev@vger.kernel.org>; Sun, 21 Jun 2015 13:32:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1434689355-4088-2-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/18/15 at 09:49pm, Roopa Prabhu wrote:
> +#include <net/ip.h>
> +#include <net/rtnetlink.h>
> +
> +#define LWTUNNEL_HASH_BITS   7
> +#define LWTUNNEL_HASH_SIZE   (1 << LWTUNNEL_HASH_BITS)
> +
> +struct lwtunnel_hdr {
> +	int             len;
> +	__u8            data[0];
> +};

The name header is a bit misleading here. Certain encaps won't
preallocate the header. How we just add a len to lwt_state and
allow the user have private data? Not sure we need to split this
into a separate struct anyway.

> +/* lw tunnel state flags */
> +#define LWTUNNEL_STATE_OUTPUT_REDIRECT 0x1
> +
> +#define lwtunnel_output_redirect(lwtstate) (lwtstate && \
> +			(lwtstate->flags & LWTUNNEL_STATE_OUTPUT_REDIRECT))

Converting this to a static inline function would add type checks
by the compiler and it shouldn't result in any different code.

> +#define MAX_LWTUNNEL_ENCAP_OPS 8
> +extern const struct lwtunnel_encap_ops __rcu *
> +		lwtun_encaps[MAX_LWTUNNEL_ENCAP_OPS];

I guess we require everybody to add themselves to the enum so
we might as well just derive the MAX from the enum MAX. Unless you
want out of tree modules to register themselves.

> +
> +struct lwtunnel_state *lwtunnel_state_alloc(int hdr_len)
> +{
> +	struct lwtunnel_state *lws;
> +
> +	return kzalloc(sizeof(*lws) + hdr_len, GFP_KERNEL);

Should this set refcnt to 1?
