From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next] xfrm: Correctly parse netlink msg from 32bits
 ip command on 64bits host
Date: Thu, 20 Feb 2014 10:59:34 +0100
Message-ID: <20140220095934.GF32371@secunet.com>
References: <1392801176-2656-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:55448 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751891AbaBTJ7h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Feb 2014 04:59:37 -0500
Content-Disposition: inline
In-Reply-To: <1392801176-2656-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 19, 2014 at 05:12:56PM +0800, Fan Du wrote:
>  
> +#ifdef CONFIG_COMPAT
> +
> +struct compat_xfrm_userpolicy_info {
> +	struct xfrm_selector		sel;
> +	struct xfrm_lifetime_cfg	lft;
> +	struct xfrm_lifetime_cur	curlft;
> +	__u32				priority;
> +	__u32				index;
> +	__u8				dir;
> +	__u8				action;
> +#define XFRM_POLICY_ALLOW	0
> +#define XFRM_POLICY_BLOCK	1
> +	__u8				flags;
> +#define XFRM_POLICY_LOCALOK	1	/* Allow user to override global policy */
> +	/* Automatically expand selector to include matching ICMP payloads. */
> +#define XFRM_POLICY_ICMP	2
> +	__u8				share;
> +} __attribute__((packed));
> +
> +struct compat_xfrm_usersa_info {
> +	struct xfrm_selector		sel;
> +	struct xfrm_id			id;
> +	xfrm_address_t			saddr;
> +	struct xfrm_lifetime_cfg	lft;
> +	struct xfrm_lifetime_cur	curlft;
> +	struct xfrm_stats		stats;
> +	__u32				seq;
> +	__u32				reqid;
> +	__u16				family;
> +	__u8				mode;		/* XFRM_MODE_xxx */
> +	__u8				replay_window;
> +	__u8				flags;
> +#define XFRM_STATE_NOECN	1
> +#define XFRM_STATE_DECAP_DSCP	2
> +#define XFRM_STATE_NOPMTUDISC	4
> +#define XFRM_STATE_WILDRECV	8
> +#define XFRM_STATE_ICMP		16
> +#define XFRM_STATE_AF_UNSPEC	32
> +#define XFRM_STATE_ALIGN4	64
> +#define XFRM_STATE_ESN		128
> +} __attribute__((packed));
> +

You define two structures that you actually don't use,
all you do is checking their size.

The only reason why this works is because these two
structures differ only on some padding bytes at the
end. If we want to support 32 bit ipsec tools on
64 bit kernels, we need a complete compat layer
for all the userspace exported structures.

A lot of userspace exported structures differ not only
on some padding bytes at the end.

For example the layout of xfrm_userspi_info:

on 32 bit:

struct xfrm_userspi_info {
        struct xfrm_usersa_info    info;                 /*     0   220 */

        /* XXX last struct has 3 bytes of padding */

        /* --- cacheline 3 boundary (192 bytes) was 28 bytes ago --- */
        __u32                      min;                  /*   220     4 */
        __u32                      max;                  /*   224     4 */

        /* size: 228, cachelines: 4, members: 3 */
        /* paddings: 1, sum paddings: 3 */
        /* last cacheline: 36 bytes */
};

on 64 bit:

struct xfrm_userspi_info {
        struct xfrm_usersa_info    info;                 /*     0   224 */

        /* XXX last struct has 7 bytes of padding */

        /* --- cacheline 3 boundary (192 bytes) was 32 bytes ago --- */
        __u32                      min;                  /*   224     4 */
        __u32                      max;                  /*   228     4 */

        /* size: 232, cachelines: 4, members: 3 */
        /* paddings: 1, sum paddings: 7 */
        /* last cacheline: 40 bytes */
};


So the 'min' field has an offest of 220 bytes on 32 bit and an offset
of 224 bytes on 64 bit. We would need a compatability layer like we
have it for system calls to map this correct.

For now I think we should just refuse to do anything if someone tries
to configure ipsec with 32 bit tools on a 64 bit machine.
