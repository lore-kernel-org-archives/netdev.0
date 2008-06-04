From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [GIT PULL net-2.6] IPv6 fixes.
Date: Wed, 04 Jun 2008 11:37:51 +0900 (JST)
Message-ID: <20080604.113751.123223388.yoshfuji@linux-ipv6.org>
References: <20080604.094917.75827853.yoshfuji@linux-ipv6.org>
	<4845EDB0.7030809@hp.com>
	<4845FDA1.1040009@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: Brian.Haley@hp.com, davem@davemloft.net, netdev@vger.kernel.org
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:58057 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751895AbYFDChP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 22:37:15 -0400
In-Reply-To: <4845FDA1.1040009@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <4845FDA1.1040009@cn.fujitsu.com> (at Wed, 04 Jun 2008 10:27:45 +0800), Shan Wei <shanwei@cn.fujitsu.com> says:

> Brian Haley 写道:
> > YOSHIFUJI Hideaki / 吉藤英明 wrote:
> >> Please consider pulling following fixes on top of net-2.6 tree
> >> available at
> >>     git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-fix.git
> >> net-2.6-misc-20080604b
> >>
> > ...
> >> commit c878bc2da63acd3b80ba4cf428702f6e98c55b3c
> >> Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> >> Date:   Mon Jun 2 18:45:23 2008 +0900
> >>
> >>     [IPv6]: Check outgoing interface even if source address is
> >> unspecified.
> >>         The outgoing interface index (ipi6_ifindex) in IPV6_PKTINFO
> >>     ancillary data, is not checked if the source address (ipi6_addr)
> >>     is unspecified.  If the ipi6_ifindex is the not-exist interface,
> >>     it should be fail and the errno should be set ENODEV.
> >>         Based on patch from Shan Wei <shanwei@cn.fujitsu.com>.
> >>         Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
> >>     Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> >>
> >> diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
> >> index 94fa6ae..76d4ab4 100644
> >> --- a/net/ipv6/datagram.c
> >> +++ b/net/ipv6/datagram.c
> >> @@ -535,27 +535,29 @@ int datagram_send_ctl(struct msghdr *msg, struct
> >> flowi *fl,
> >>                  fl->oif = src_info->ipi6_ifindex;
> >>              }
> >>  
> >> -            addr_type = ipv6_addr_type(&src_info->ipi6_addr);
> >> +            if (fl->oif) {
> >> +                dev = dev_get_by_index(&init_net, fl->oif);
> >> +                if (!dev)
> >> +                    return -ENODEV;
> >> +            }
> >>  
> >> -            if (addr_type == IPV6_ADDR_ANY)
> >> +            addr_type = ipv6_addr_type(&src_info->ipi6_addr);
> >> +            if (addr_type == IPV6_ADDR_ANY) {
> >> +                if (dev)
> >> +                    dev_put(dev);
> >>                  break;
> >> -
> >> -            if (addr_type & IPV6_ADDR_LINKLOCAL) {
> >> -                if (!src_info->ipi6_ifindex)
> >> -                    return -EINVAL;
> >> -                else {
> >> -                    dev = dev_get_by_index(&init_net,
> >> src_info->ipi6_ifindex);
> >> -                    if (!dev)
> >> -                        return -ENODEV;
> >> -                }
> >>              }
> >> -            if (!ipv6_chk_addr(&init_net, &src_info->ipi6_addr,
> >> +
> >> +            if (((addr_type & IPV6_ADDR_LINKLOCAL) &&
> >> +                 !src_info->ipi6_ifindex) ||
> >> +                !ipv6_chk_addr(&init_net, &src_info->ipi6_addr,
> > 
> > I think this !src_info->ipi6_ifindex here should be !fl->oif - that will
> > have been assigned correctly if it was zero and src_info->ipi6_ifindex
> > was passed-in, and is what we used to do the device lookup.
> 
> the attached patch fix it.

Ah, this reminds me I used wrong patch, sorry...

--yoshfuji
