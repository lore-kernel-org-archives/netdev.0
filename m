From: Haim Daniel <Haim.Daniel@expand.com>
Subject: FW: tproxy + bridge  - possible redundant skb_orphan call ?
Date: Wed, 23 Feb 2011 12:56:21 +0200
Message-ID: <8D5E459AD91A394F9610088F8AFFAB481FA547F04C@exchange>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:44562 "EHLO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753744Ab1BWK51 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Feb 2011 05:57:27 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I use 2.6.34 on a transparent PEP:

A daemon listening to port 50800 on PEP is set.
The following transparent proxy rule is set for PEP:
iptables -t mangle -A PREROUTING  -p tcp --dport 666 -j TPROXY --tproxy-mark 0x1/0x1 --on-port 50800

In case of bridging: 
	the mangle PREROUTING is hooked from ebtables _before_ ip_rcv().
	the skb hits the TPROXY rule.
	nf_tproxy_assign_sock() sets skb->sk to local listen socket on port 50800.

However, ip_rcv() invokes later and orphans the skb. skb->sk is nulled => it prevents the
skb from reaching the local socket.

When the call to skb_orphan(skb) in ip_rcv() is removed, the skb reaches the local sk - ok.

On other cases, when the bridging is not involved, ip_rcv() is called before mangle PREROUTING ,hence skb
reaches the TPROXY target and being orphaned before skb->sk is set in nf_tproxy_assign_sock().

I don't understand what is the purpose of skb_orphan(skb) call in ip_rcv.
The comment above it states that it's related to tproxy:

/* Must drop socket now because of tproxy. */
skb_orphan(skb);

but since nf_tproxy_assign_sock() orphans the skb, it looks like
ip_rcv() skb_orphan() is redundant ?

appreciate your response,

best regards,

--haim d.
--eyal g.
