From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] net: ipv6: Make address flushing on ifdown optional
Date: Sat, 13 Feb 2016 23:25:19 +0100
Message-ID: <56BFAD4F.5080600@cumulusnetworks.com>
References: <1455402207-9217-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:37387 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750961AbcBMWZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Feb 2016 17:25:22 -0500
Received: by mail-wm0-f41.google.com with SMTP id g62so63259152wme.0
        for <netdev@vger.kernel.org>; Sat, 13 Feb 2016 14:25:21 -0800 (PST)
In-Reply-To: <1455402207-9217-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

grrr.... changed the subject in send-email editor which dropped it. 
obviously this is for net-next

On 2/13/16 11:23 PM, David Ahern wrote:
> Currently, all ipv6 addresses are flushed when the interface is configured
> down, including global, static addresses:
>
>      $ ip -6 addr add dev eth1 2000:11:1:1::1/64
>      $ ip addr show dev eth1
>      3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
>          link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
>          inet6 2000:11:1:1::1/64 scope global tentative
>             valid_lft forever preferred_lft forever
>      $ ip link set dev eth1 up
>      $ ip link set dev eth1 down
>      $ ip addr show dev eth1
>      3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN group default qlen 1000
>          link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
>
> Add a new sysctl to make this behavior optional. The new setting defaults to
> flush all addresses to maintain backwards compatibility. When the set global
> addresses with no expire times are not flushed on an admin down:
>
>      $ echo 1 > /proc/sys/net/ipv6/conf/eth1/keep_addr_on_down
>      $ ip -6 addr add dev eth1 2000:11:1:1::1/64
>      $ ip addr show dev eth1
>      3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN group default qlen 1000
>          link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
>          inet6 2000:11:1:1::1/64 scope global tentative
>             valid_lft forever preferred_lft forever
>      $ ip link set dev eth1 up
>      $ ip link set dev eth1 down
>      $ ip addr show dev eth1
>      3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN group default qlen 1000
>          link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
>          inet6 2000:11:1:1::1/64 scope global
>             valid_lft forever preferred_lft forever
>          inet6 fe80::4:11ff:fe22:3301/64 scope link
>             valid_lft forever preferred_lft forever
>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
