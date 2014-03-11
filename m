From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: ip6_append_data_mtu do not handle the mtu of the second fragment properly
Date: Tue, 11 Mar 2014 15:49:06 +0100
Message-ID: <20140311144906.GA29404@order.stressinduktion.org>
References: <1394512309-8823-1-git-send-email-lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: network dev <netdev@vger.kernel.org>,
	Gao feng <gaofeng@cn.fujitsu.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:56672 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753217AbaCKOtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 10:49:07 -0400
Content-Disposition: inline
In-Reply-To: <1394512309-8823-1-git-send-email-lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 11, 2014 at 12:31:49PM +0800, Xin Long wrote:
> -			*mtu = min(*mtu, pmtuprobe ?
> -				   rt->dst.dev->mtu :
> -				   dst_mtu(rt->dst.path));
> +			*mtu = pmtuprobe ? rt->dst.dev->mtu :
> +				   dst_mtu(rt->dst.path);

Sorry, that is not correct:

The min() protects the mtu going over np->frag_size (if set). In case we
remove the min we would fallback to dev->mtu or dst_mtu and thus this could
lead to a situation where the first fragment respects frag_size but second
not. This confuses ip6_append_data and would lead to a crash.

I am thinking about changing this to

min(*mtu + rt->dst.header_len, pmtuprobe ? rt->dst.dev->mtu : dst_mtu(rt->dst.path))

or we pass the np directly and test for frag_size again.

Good catch which should be fixed. Thanks!
