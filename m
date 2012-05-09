From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [v12 PATCH 2/3] NETFILTER module xt_hmark, new target for HASH
 based fwmark
Date: Wed, 9 May 2012 12:38:20 +0200
Message-ID: <20120509103820.GA22608@1984>
References: <1335188128-23645-1-git-send-email-hans.schillstrom@ericsson.com>
 <201205071409.47945.hans.schillstrom@ericsson.com>
 <20120507122232.GA32146@1984>
 <201205080937.36853.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "kaber@trash.net" <kaber@trash.net>,
	"jengelh@medozas.de" <jengelh@medozas.de>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hans@schillstrom.com" <hans@schillstrom.com>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44291 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750877Ab2EIKi3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2012 06:38:29 -0400
Content-Disposition: inline
In-Reply-To: <201205080937.36853.hans.schillstrom@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 08, 2012 at 09:37:35AM +0200, Hans Schillstrom wrote:
> From d5065af3988cc7561a02f30bae8342e1a89126a4 Mon Sep 17 00:00:00 2001
> From: Hans Schillstrom <hans.schillstrom@ericsson.com>
> Date: Wed, 2 May 2012 07:49:47 +0000
> Subject: netfilter: add xt_hmark target for hash-based skb
>  marking
> 
> The target allows you to create rules in the "raw" and "mangle" tables
> which set the skbuff mark by means of hash calculation within a given
> range. The nfmark can influence the routing method (see "Use netfilter
> MARK value as routing key") and can also be used by other subsystems to
> change their behaviour.
> 
> Some examples:
> 
> * Default rule handles all TCP, UDP, SCTP, ESP & AH
> 
>  iptables -t mangle -A PREROUTING -m state --state NEW,ESTABLISHED,RELATED \
> 	-j HMARK --hmark-offset 10000 --hmark-mod 10
> 
> * Handle SCTP and hash dest port only and produce a nfmark between 100-119.
> 
>  iptables -t mangle -A PREROUTING -p SCTP -j HMARK --src-mask 0 --dst-mask 0 \
> 	--sp-mask 0 --offset 100 --mod 20
> 
> * Fragment safe Layer 3 only, that keep a class C network flow together
> 
>  iptables -t mangle -A PREROUTING -j HMARK --method L3 \
> 	--src-mask 24 --mod 20 --offset 100

I have removed these examples. Just in case we make changes to the
user-space part. We'll have the time for this (the entire 3.5 cycle).

Some minor glitches I made on this patch:

>  include/linux/netfilter/xt_HMARK.h |   48 +++++
>  net/netfilter/Kconfig              |   15 ++
>  net/netfilter/Makefile             |    1 +
>  net/netfilter/xt_HMARK.c           |  358 ++++++++++++++++++++++++++++++++++++
>  4 files changed, 422 insertions(+)
>  create mode 100644 include/linux/netfilter/xt_HMARK.h
>  create mode 100644 net/netfilter/xt_HMARK.c
> 
> diff --git a/include/linux/netfilter/xt_HMARK.h b/include/linux/netfilter/xt_HMARK.h
> new file mode 100644
> index 0000000..05e43ba
> --- /dev/null
> +++ b/include/linux/netfilter/xt_HMARK.h
> @@ -0,0 +1,46 @@
> +#ifndef XT_HMARK_H_
> +#define XT_HMARK_H_
> +
> +#include <linux/types.h>
> +
> +enum {
> +	XT_HMARK_NONE,

this means (1 << 0) is unused. I have removed this _NONE.

> +	XT_HMARK_SADR_MASK,
> +	XT_HMARK_DADR_MASK,
> +	XT_HMARK_SPI_MASK,
> +	XT_HMARK_SPI,
> +	XT_HMARK_SPORT_MASK,
> +	XT_HMARK_DPORT_MASK,
> +	XT_HMARK_SPORT,
> +	XT_HMARK_DPORT,
> +	XT_HMARK_PROTO_MASK,
> +	XT_HMARK_RND,
> +	XT_HMARK_MODULUS,
> +	XT_HMARK_OFFSET,
> +	XT_HMARK_CT,
> +	XT_HMARK_METHOD_L3,
> +	XT_HMARK_METHOD_L3_4,

I have also rearrange the order of the flags:

enum {
        XT_HMARK_SADDR_MASK,
        XT_HMARK_DADDR_MASK,
        XT_HMARK_SPI,       
        XT_HMARK_SPI_MASK,  
        XT_HMARK_SPORT,     
        XT_HMARK_DPORT,     
        XT_HMARK_SPORT_MASK,
        XT_HMARK_DPORT_MASK,
        XT_HMARK_PROTO_MASK,
        XT_HMARK_RND,       
        XT_HMARK_MODULUS,   
        XT_HMARK_OFFSET,    
        XT_HMARK_CT,        
        XT_HMARK_METHOD_L3, 
        XT_HMARK_METHOD_L3_4,
};

I don't want people to ask me why we where using some strange order in
the flag definition in the future (yes, you'll have to recompile your
iptables HMARK support in your setups, sorry)

> +};
> +#define XT_HMARK_FLAG(flag)	(1 << flag)
> +
> +union hmark_ports {
> +	struct {
> +		__u16	src;
> +		__u16	dst;
> +	} p16;
> +	__u32	v32;
> +};
> +
> +struct xt_hmark_info {
> +	union nf_inet_addr	src_mask;	/* Source address mask */
> +	union nf_inet_addr	dst_mask;	/* Dest address mask */
> +	union hmark_ports	port_mask;
> +	union hmark_ports	port_set;
> +	__u32			flags;		/* Print out only */
> +	__u16			proto_mask;	/* L4 Proto mask */
> +	__u32			hashrnd;
> +	__u32			hmodulus;	/* Modulus */
> +	__u32			hoffset;	/* Offset */

I've removed these comments, they provide no extra information. Still
I left the one that described hoffset, that may seem not obvious.

> +#endif /* XT_HMARK_H_ */

I have applied this, I'm going to pass it to davem.
