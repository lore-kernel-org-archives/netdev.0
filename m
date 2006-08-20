From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] getsockopt() early argument sanity checking
Date: Sun, 20 Aug 2006 19:50:44 +0900 (JST)
Message-ID: <20060820.195044.84187776.yoshfuji@linux-ipv6.org>
References: <20060819230532.GA16442@openwall.com>
	<200608201034.43588.ak@suse.de>
	<20060820101528.GE602@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, solar@openwall.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:46353 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1750734AbWHTKtA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Aug 2006 06:49:00 -0400
To: w@1wt.eu
In-Reply-To: <20060820101528.GE602@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

In article <20060820101528.GE602@1wt.eu> (at Sun, 20 Aug 2006 12:15:28 +0200), Willy Tarreau <w@1wt.eu> says:

> But I don't want to induce such large changes in this kernel. The goal of
> this test is a preventive measure to catch easily exploitable errors that
> might have remained undetected. For instance, a quick glance shows this
> portion of code in net/ipv4/raw.c (both 2.4 and 2.6) :
> 
> static int raw_seticmpfilter(struct sock *sk, char *optval, int optlen)
> {
>         if (optlen > sizeof(struct icmp_filter))
>                 optlen = sizeof(struct icmp_filter);
>         if (copy_from_user(&sk->tp_pinfo.tp_raw4.filter, optval, optlen))
>                 return -EFAULT;
>         return 0;
> }
> 
> It only relies on sock_setsockopt() refusing optlen values < sizeof(int),
> and this is not documented. Having part of this code being copied for use
> in another code path would open a breach for optlen < 0.
:
> There are two tests in this patch :
> 
>   - one on the validity of the optlen address. This one is race-free and
>     should be conserved anyway.
> 
>   - one on the optlen range which is valid for most cases but which is
>     subject to a race condition and which might be circumvented by
>     carefully written code and with some luck as in all race conditions
>     issues.

Don't mix getsockopt() and setsockopt() code paths.

For setsockopt(), optlen < 0 is checked in net/socket.c:sys_setsockopt().

For getsockopt(), optlen and *optlen < 0 is (and should be) checked
(or handled) in each getsockopt function; e.g. do_ip_getsockopt(),
raw_geticmpfilter() etc.

--yoshfuji
