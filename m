From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ipv6: don't deliver packets with zero length to
 raw sockets
Date: Fri, 21 Apr 2017 10:48:54 -0400 (EDT)
Message-ID: <20170421.104854.1771467272185467653.davem@davemloft.net>
References: <1492747124-31821-1-git-send-email-jbainbri@redhat.com>
        <1492747124-31821-2-git-send-email-jbainbri@redhat.com>
        <20170421100112.GA4824@bistromath.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbainbri@redhat.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33324 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
        with ESMTP id S1041151AbdDUOtl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 10:49:41 -0400
In-Reply-To: <20170421100112.GA4824@bistromath.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Fri, 21 Apr 2017 12:01:12 +0200

> Hi Jamie,
> 
> 2017-04-21, 13:58:44 +1000, Jamie Bainbridge wrote:
>> IPv6 assumes there is data after the network header and blindly delivers
>> skbs to raw sockets without checking the presence of data.
>> 
>> With an application in a common loop where it checks select/poll/epoll
>> then ioctl(SIOCINQ/FIONREAD) is positive before continuing to
>> recvfrom(), this behaviour can cause the application to loop forever
>> on ioctl() because there is a zero-length skb to receive.
>> 
>> With this, it is very easy to make a Denial of Service attack by
>> crafting a packet which declares a Next Header in the IPv6 header but
>> does not actually supply a transport header and/or payload.
>> 
>> skb->len is already correctly set in ip6_input_finish() with pskb_pull()
>> so check this length before delivering zero data to raw sockets.
> 
> Isn't that changing behavior? recv() currently returns 0 when a packet
> that stops right after the IP header arrives. After this, the userspace
> program won't receive anything in this case?

Yes, just like UDP, zero length packets should be allowed and processed.

Not silently dropped.

And this would give us yet another behavioral difference between ipv4 and
ipv6, so no thanks...
