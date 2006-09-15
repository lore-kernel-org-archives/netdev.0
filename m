From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Missing csum_fold() in ip6t_HL.c ?
Date: Fri, 15 Sep 2006 14:37:56 +0400
Message-ID: <20060915103755.GB5286@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@lists.netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:28718 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1750990AbWIOKhv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Sep 2006 06:37:51 -0400
Received: by nf-out-0910.google.com with SMTP id o25so2200791nfa
        for <netdev@vger.kernel.org>; Fri, 15 Sep 2006 03:37:50 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It looks like "diffs" array is write-only. It also looks like ipv4
occurences use some csum_fold() trickery. Was is forgotten here? Should
"diffs" be removed?

    20	static unsigned int ip6t_hl_target(struct sk_buff **pskb,
    21					   const struct net_device *in,
    22					   const struct net_device *out,
    23					   unsigned int hooknum,
    24					   const struct xt_target *target,
    25					   const void *targinfo, void *userinfo)
    26	{
    27		struct ipv6hdr *ip6h;
    28		const struct ip6t_HL_info *info = targinfo;
    29	===>	u_int16_t diffs[2];	<===
    30		int new_hl;
    31
    32		if (!skb_make_writable(pskb, (*pskb)->len))
    33			return NF_DROP;
    34
    35		ip6h = (*pskb)->nh.ipv6h;
    36
    37		switch (info->mode) {
    38			case IP6T_HL_SET:
    39				new_hl = info->hop_limit;
    40				break;
    41			case IP6T_HL_INC:
    42				new_hl = ip6h->hop_limit + info->hop_limit;
    43				if (new_hl > 255)
    44					new_hl = 255;
    45				break;
    46			case IP6T_HL_DEC:
    47				new_hl = ip6h->hop_limit - info->hop_limit;
    48				if (new_hl < 0)
    49					new_hl = 0;
    50				break;
    51			default:
    52				new_hl = ip6h->hop_limit;
    53				break;
    54		}
    55
    56		if (new_hl != ip6h->hop_limit) {
    57	===>		diffs[0] = htons(((unsigned)ip6h->hop_limit) << 8) ^ 0xFFFF;
    58			ip6h->hop_limit = new_hl;
    59	===>		diffs[1] = htons(((unsigned)ip6h->hop_limit) << 8);
    60		}
    61
    62		return IP6T_CONTINUE;
    63	}

