From: Tushar Gohad <tgohad@mvista.com>
Subject: ping6 sets IPV6_PMTUDISC_DO option on multicast packets
Date: Fri, 16 Nov 2007 14:29:09 -0700
Message-ID: <473E0BA5.9070804@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:20459 "EHLO
	gateway-1237.mvista.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752015AbXKPVXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2007 16:23:23 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Yoshifuji-san,

I noticed that ping6 forces the IPV6_PMTUDISC_DO option on packets sent 
to multicast destinations. Is this a requirement?

Due to the following check recently introduced in the ip6_fragment() 
code, multicast packets that are over PMTU in size are never sent out, 
since ping6 code always sets the PMTUDISC_DO option and ip6_fragment() 
always fails.


=== net/ipv6/ip6_output.c ===

  573 static int ip6_fragment(struct sk_buff *skb, int (*output)
                              (struct sk_buff *))
  574 {
  ......
  592         /* We must not fragment if the socket is set to force MTU
                 discovery
  ......

  596         if (!np || np->pmtudisc >= IPV6_PMTUDISC_DO) {
  597                 skb->dev = skb->dst->dev;
  598                 icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu,
                                    skb->dev);
  599                 IP6_INC_STATS(ip6_dst_idev(skb->dst),
                                    IPSTATS_MIB_FRAGFAILS);
  600                 kfree_skb(skb);
  601                 return -EMSGSIZE;
  602         }
  ......
--


This check in the kernel code makes perfect sense, since the option is 
implies "do not fragment."

Should the ping6 code be fixed in that case?


Thanks,
- Tushar
