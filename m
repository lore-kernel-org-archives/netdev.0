From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net] vti6: flush x-netns xfrm cache when vti interface is
 removed
Date: Wed, 12 Oct 2016 10:47:49 +0200
Message-ID: <20161012084749.GB19080@gauss.secunet.com>
References: <1475226667-22404-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Lance Richardson <lrichard@redhat.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:57497 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932283AbcJLIse (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Oct 2016 04:48:34 -0400
Content-Disposition: inline
In-Reply-To: <1475226667-22404-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 30, 2016 at 11:11:07AM +0200, Nicolas Dichtel wrote:
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

Applied to the ipsec tree, thanks!
