From: "Ilya V. Matveychikov" <i.matveychikov@securitycode.ru>
Subject: question: update_pmtu doesn't update dst mtu
Date: Thu, 3 Apr 2014 15:37:33 +0400
Message-ID: <533D47FD.9020904@securitycode.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from itna.infosec.ru ([82.198.190.199]:23266 "EHLO itna.infosec.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751853AbaDCLqh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Apr 2014 07:46:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Is this a place where I can post questions not the patches? If so, can anybody
explain me what the problem I have when trying to update dst PMTU value.

So, the scheme is the following:

                  skb->dst                   rt(pmtu)
IN_DEV (MTU 1500) -------> TUNNEL (MTU 1440) -------> OUT_DEV (MTU 1500)

I have a simple tunnel_xmit function that handles all the packets that goes
trough the tunnel. So, I have an skb with valid skb->dst value (filled earlier
in ip_input_route_noref).

Next, when encapsulation is done, I needed to get an output route for the packet
(rt at the scheme). At this point I know that the output route may have a PMTU
value that is different from the OUT_DEV->mtu. So, I'm trying to update the
input skb->dst route's PMTU with the update_pmtu function. It seems that all is
OK, but when I trying to get the dst mtu value (using dst_mtu(skb_dst(skb))) I
always get the value of 1440 (TUNNEL's MTU):

tunnel_xmit:
    ...
    pmtu = dst_mtu(&rt->dst) - OVERHEAD; // pmtu = 1300, for example
    skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, pmtu);
    // dst_mtu(skb_dst(skb)) still returns 1440

Looking through the code gives me that rt_pmtu is always 0 for the skb->dst
entry and ipv4_mtu that called via the dst->ops->mtu() uses dev->mtu :(

So, the question is what I missed when trying to dynamically tunning tunnel's
input route path MTU?

Thanks :)

-- 
Ilya V. Matveychikov
