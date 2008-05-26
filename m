From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH] devinet: sysctl setup off by one
Date: Mon, 26 May 2008 11:39:21 +0400
Message-ID: <483A6929.6060905@openvz.org>
References: <20080523153559.156a1fb5@speedy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:58574 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751884AbYEZHlv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 May 2008 03:41:51 -0400
In-Reply-To: <20080523153559.156a1fb5@speedy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> It look like the code to setup /proc/sys/net/ipv4/conf/XXX has an off by one bug
> that causes the last entry (arp_accept) not to be adjusted properly.  This causes
> changes to the value to occur in the default namespace not the clone? Don't use
> network namespaces myself, but this looks like a bug.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> --- a/net/ipv4/devinet.c	2008-05-23 15:23:19.000000000 -0700
> +++ b/net/ipv4/devinet.c	2008-05-23 15:29:17.000000000 -0700
> @@ -1466,7 +1466,7 @@ static int __devinet_sysctl_register(str
>  	if (!t)
>  		goto out;
>  
> -	for (i = 0; i < ARRAY_SIZE(t->devinet_vars) - 1; i++) {
> +	for (i = 0; i < ARRAY_SIZE(t->devinet_vars); i++) {
>  		t->devinet_vars[i].data += (char *)p - (char *)&ipv4_devconf;
>  		t->devinet_vars[i].extra1 = p;
>  		t->devinet_vars[i].extra2 = net;
> 

This off-by-one is required, since the very last element of this array
is used as a sentinel, that shows sysctl engine when to stop processing 
the table.

Look, the sizeof(t->devinet_vars) is __NET_IPV4_CONF_MAX == 22, thus
entries 0, 1, ... 20 are tables and the 21-st is this sentinel, so the
initialization of this last entry, whose index is (this_sizeof() - 1),
is not required.

Thanks,
Pavel
