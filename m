From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: IPv6 over Firewire
Date: Sat, 22 Dec 2012 04:49:03 +0900
Message-ID: <50D4BD2F.7060006@linux-ipv6.org>
References: <50D49659.1000101@gmail.com> <50D4A219.7080807@linux-ipv6.org> <50D4ACFA.6040901@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: stephan.gatzka@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:33335 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752090Ab2LUTtF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 14:49:05 -0500
In-Reply-To: <50D4ACFA.6040901@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephan Gatzka wrote:
> 
>> If you are talking about how to build NS/NA/RS/Redirect messages, you
>> can just use ndisc_opt_addr_space() and ndisc_fill_addr_option() here.
> 
> Thanks, these functions are certainly helpful. But ndisc_opt_addr_space() calculates the required space from dev->addr_len and ndisc_addr_option_pad(dev->type). The latter is 0 for IEEE1394 (firewire). So the required option space just comes from dev->addr_len, which is 8 for firewire, resulting in an option address space of 16 (2 octets).
> 
> But rfc3146 requires an option address space of 3 octets. So my main question is if in such a situation the best is to reserve additional skb tail room using needed_tailroom in struct netdevice. This directly affects the memory allocated in ndisc_build_skb().

Something like this:

 static inline int ndisc_opt_addr_space(struct net_device *dev)
 {
-       return NDISC_OPT_SPACE(dev->addr_len + ndisc_addr_option_pad(dev->type));
+       switch (dev->type) {
+       case ARPHRD_IEEE1394:
+               return sizeof(struct ndisc_opt_ieee1394_llinfo);
+       default:
+               return NDISC_OPT_SPACE(dev->addr_len + ndisc_addr_option_pad(dev->type));
+       }
 }

--yoshfuji
