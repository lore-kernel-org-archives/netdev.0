From: Lance Richardson <lrichard@redhat.com>
Subject: Re: [PATCH net] vti6: flush x-netns xfrm cache when vti interface
 is removed
Date: Mon, 3 Oct 2016 22:19:01 -0400 (EDT)
Message-ID: <296031074.628156.1475547541859.JavaMail.zimbra@redhat.com>
References: <1475226667-22404-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net,
        steffen klassert <steffen.klassert@secunet.com>,
        netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx5-phx2.redhat.com ([209.132.183.37]:33935 "EHLO
        mx5-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751662AbcJDCTJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2016 22:19:09 -0400
In-Reply-To: <1475226667-22404-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: "Nicolas Dichtel" <nicolas.dichtel@6wind.com>
> To: davem@davemloft.net, "steffen klassert" <steffen.klassert@secunet.com>
> Cc: netdev@vger.kernel.org, "Nicolas Dichtel" <nicolas.dichtel@6wind.com>, "Lance Richardson" <lrichard@redhat.com>
> Sent: Friday, September 30, 2016 5:11:07 AM
> Subject: [PATCH net] vti6: flush x-netns xfrm cache when vti interface is removed
> 
> This is the same fix than commit a5d0dc810abf ("vti: flush x-netns xfrm
> cache when vti interface is removed")
> 
> This patch fixes a refcnt problem when a x-netns vti6 interface is removed:
> unregister_netdevice: waiting for vti6_test to become free. Usage count = 1
> 
> Here is a script to reproduce the problem:
> 
> ip link set dev ntfp2 up
> ip addr add dev ntfp2 2001::1/64
> ip link add vti6_test type vti6 local 2001::1 remote 2001::2 key 1
> ip netns add secure
> ip link set vti6_test netns secure
> ip netns exec secure ip link set vti6_test up
> ip netns exec secure ip link s lo up
> ip netns exec secure ip addr add dev vti6_test 2003::1/64
> ip -6 xfrm policy add dir out tmpl src 2001::1 dst 2001::2 proto esp \
> 	   mode tunnel mark 1
> ip -6 xfrm policy add dir in tmpl src 2001::2 dst 2001::1 proto esp \
> 	   mode tunnel mark 1
> ip xfrm state add src 2001::1 dst 2001::2 proto esp spi 1 mode tunnel \
> 	   enc des3_ede 0x112233445566778811223344556677881122334455667788 mark 1
> ip xfrm state add src 2001::2 dst 2001::1 proto esp spi 1 mode tunnel \
> 	   enc des3_ede 0x112233445566778811223344556677881122334455667788 mark 1
> ip netns exec secure  ping6 -c 4 2003::2
> ip netns del secure
> 
> CC: Lance Richardson <lrichard@redhat.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---

Looks good, corresponds closely to the ipv4 version of the fix.

Acked-by: Lance Richardson <lrichard@redhat.com>
