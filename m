From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] Fallback to ipv4 if we try to add join IPv4 multicast	group via
 ipv4-mapped address.
Date: Tue, 2 Oct 2007 08:35:08 -0700
Message-ID: <OFDC1D2E6E.2DCF75EA-ON88257368.0053513A-88257368.005586DC@us.ibm.com>
References: <1191319182.28331.6.camel@doriath.ww600.siemens.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: Dmitry Baryshkov <Dmitry.Baryshkov@siemens.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:37986 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752195AbXJBPfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 11:35:19 -0400
In-Reply-To: <1191319182.28331.6.camel@doriath.ww600.siemens.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dmitry,
        Good catch; a couple comments:

>     struct ipv6_pinfo *np = inet6_sk(sk);
>     int err;
> +   int addr_type = ipv6_addr_type(addr);
> +
> +   if (addr_type == IPV6_ADDR_MAPPED) {
> +      __be32 v4addr = addr->s6_addr32[3];
> +      struct ip_mreqn mreq;
> +      mreq.imr_multiaddr.s_addr = v4addr;
> +      mreq.imr_address.s_addr = INADDR_ANY;
> +      mreq.imr_ifindex = ifindex;
> +
> +      return ip_mc_join_group(sk, &mreq);
> +   }

        ipv6_addr_type() returns a bitmask, so you should use:

        if (addr_type & IPV6_ADDR_MAPPED) {

Also, you should have a blank line after the "mreq" declaration.

Ditto for both in ipv6_mc_sock_drop().

I don't expect the multicast source filtering interface will
behave well for mapped addresses, either. The mapped multicast
address won't appear to be a multicast address (and return
error there), and all the source filters would have to be
v4mapped addresses and modify the v4 source filters for this
to do as you expect. So, there's more to it (and it may be a
bit messy) to support mapped multicast addresses fully. I'll
think about that part some more.

                                                        +-DLS

