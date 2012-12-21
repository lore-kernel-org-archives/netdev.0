From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: IPv6 over Firewire
Date: Sat, 22 Dec 2012 00:12:30 +0100
Message-ID: <20121222001230.3fe92bef@stein>
References: <50D49659.1000101@gmail.com>
	<50D4A219.7080807@linux-ipv6.org>
	<50D4ACFA.6040901@gmail.com>
	<50D4BD2F.7060006@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	stephan.gatzka@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:36415 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751593Ab2LUXMu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 18:12:50 -0500
In-Reply-To: <50D4BD2F.7060006@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Dec 22 YOSHIFUJI Hideaki wrote:
> Stephan Gatzka wrote:
> > 
> >> If you are talking about how to build NS/NA/RS/Redirect messages, you
> >> can just use ndisc_opt_addr_space() and ndisc_fill_addr_option() here.
> > 
> > Thanks, these functions are certainly helpful. But ndisc_opt_addr_space() calculates the required space from dev->addr_len and ndisc_addr_option_pad(dev->type). The latter is 0 for IEEE1394 (firewire). So the required option space just comes from dev->addr_len, which is 8 for firewire, resulting in an option address space of 16 (2 octets).
> > 
> > But rfc3146 requires an option address space of 3 octets. So my main question is if in such a situation the best is to reserve additional skb tail room using needed_tailroom in struct netdevice. This directly affects the memory allocated in ndisc_build_skb().
> 
> Something like this:
> 
>  static inline int ndisc_opt_addr_space(struct net_device *dev)
>  {
> -       return NDISC_OPT_SPACE(dev->addr_len + ndisc_addr_option_pad(dev->type));
> +       switch (dev->type) {
> +       case ARPHRD_IEEE1394:
> +               return sizeof(struct ndisc_opt_ieee1394_llinfo);
> +       default:
> +               return NDISC_OPT_SPACE(dev->addr_len + ndisc_addr_option_pad(dev->type));
> +       }
>  }

Can't we increase dev->addr_len for RFC 3146 interfaces?
Can't we add another dev->type besides ARPHRD_IEEE1394 (RFC 2734)?

Is a single dev instance transporting both IPv4 and IPv6 or will there be
separate instances for those?
-- 
Stefan Richter
-=====-===-- ==-- =-==-
http://arcgraph.de/sr/
