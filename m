From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [IPV6]: Do not set IF_READY if device is down
Date: Tue, 27 Mar 2007 14:57:18 +0100
Message-ID: <1175003838.3277.41.camel@pmac.infradead.org>
References: <200703080359.l283xo6S012573@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:45270 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753866AbXC0N53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 09:57:29 -0400
In-Reply-To: <200703080359.l283xo6S012573@hera.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-03-08 at 03:59 +0000, Linux Kernel Mailing List wrote:
> Gitweb:     http://git.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=c7ababbdc647e67e953d153ddf62cbdc9fe3297e
> Commit:     c7ababbdc647e67e953d153ddf62cbdc9fe3297e
> Parent:     16bec31db751030171b31d7767fa3a5bdbe980ea
> Author:     Herbert Xu <herbert@gondor.apana.org.au>
> AuthorDate: Wed Mar 7 16:02:40 2007 -0800
> Committer:  David S. Miller <davem@sunset.davemloft.net>
> CommitDate: Wed Mar 7 16:08:12 2007 -0800
> 
>     [IPV6]: Do not set IF_READY if device is down
>     
>     Now that we add the IPv6 device at registration time we don't need
>     to set IF_READY in ipv6_add_dev anymore because we will always get
>     a NETDEV_UP event later on should the device ever become ready.
>     
>     Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>     Signed-off-by: David S. Miller <davem@davemloft.net>

This commit seems to have broken NetworkManager, which removes the
link-local IPv6 address from each wireless interface while it's only
intending to use it for scanning, then adds it back when it actually
wants to _use_ the interface in question.

After this commit, any IPv6 address added to an interface which had none
will be marked as 'tentative', and will never become real.

A failing test looks like this....

+ ip -6 addr del fe80::203:ccff:fe3c:27d/64 dev eth0                            
+ ip -6 addr del 2001:8b0:10b:1:203:ccff:fe3c:27d/64 dev eth0                   
+ ip -6 addr list eth0                                                          
+ ip -6 addr add fe80::203:ccff:fe3c:27d/64 dev eth0                            
+ ip -6 addr list eth0                                                          
4: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000                   
    inet6 fe80::203:ccff:fe3c:27d/64 scope link tentative                       
       valid_lft forever preferred_lft forever                                  
+ sleep 3                                                                       
+ ip -6 addr list eth0                                                          
4: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000                   
    inet6 fe80::203:ccff:fe3c:27d/64 scope link tentative                       
       valid_lft forever preferred_lft forever  

... while on a good kernel it looks like this...

+ ip -6 addr del fe80::203:ccff:fe3c:27d/64 dev eth0                            
+ ip -6 addr del 2001:8b0:10b:1:203:ccff:fe3c:27d/64 dev eth0                   
+ ip -6 addr list eth0                                                          
+ ip -6 addr add fe80::203:ccff:fe3c:27d/64 dev eth0                            
+ ip -6 addr list eth0                                                          
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000                   
    inet6 fe80::203:ccff:fe3c:27d/64 scope link tentative                       
       valid_lft forever preferred_lft forever                                  
+ sleep 3                                                                       
+ ip -6 addr list eth0                                                          
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000                   
    inet6 2001:8b0:10b:1:203:ccff:fe3c:27d/64 scope global dynamic              
       valid_lft 298sec preferred_lft 118sec                                    
    inet6 fe80::203:ccff:fe3c:27d/64 scope link                                 
       valid_lft forever preferred_lft forever                                  

If I add an extra IPv6 address before running the script on a 'bad'
kernel, it behaves correctly. The problem only happens when you remove
_all_ IPv6 addresses from an interface.

Answers of "don't do that then" should be accompanied with an
alternative plan which allows NetworkManager to use a wireless device
for scanning without actually having any other effect.

-- 
dwmw2

