From: Chris Ruehl <chris.ruehl@gtsys.com.hk>
Subject: ipv6: oops in datagram.c line 260
Date: Wed, 10 Dec 2014 13:43:01 +0800
Message-ID: <5487DD65.60800@gtsys.com.hk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.fpasia.hk ([202.130.89.98]:36980 "EHLO fpa01n0.fpasia.hk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751814AbaLJFnG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Dec 2014 00:43:06 -0500
Received: from localhost (localhost [127.0.0.1])
	by fpa01n0.fpasia.hk (Postfix) with ESMTP id 8494DCC25B2
	for <netdev@vger.kernel.org>; Wed, 10 Dec 2014 13:43:03 +0800 (HKT)
Received: from fpa01n0.fpasia.hk ([127.0.0.1])
	by localhost (fpa01n0.office.fpa.com.hk [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id txtp2dgWq3LY for <netdev@vger.kernel.org>;
	Wed, 10 Dec 2014 13:43:02 +0800 (HKT)
Received: from s01.gtsys.com.hk (gtsnode.office.fpasia.hk [10.10.37.40])
	by fpa01n0.fpasia.hk (Postfix) with ESMTP id 2936BCC25B1
	for <netdev@vger.kernel.org>; Wed, 10 Dec 2014 13:43:02 +0800 (HKT)
Received: from [192.168.10.46] (unknown [118.140.73.106])
	by s01.gtsys.com.hk (Postfix) with ESMTPSA id 7E03CC01F8F
	for <netdev@vger.kernel.org>; Wed, 10 Dec 2014 13:43:01 +0800 (HKT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

We running a Dell server which crash frequently with (dell crash video 
snapshot) vanilla 3.14.25

Capture viewed here: http://www.gtsys.com.hk/~chris/datagram_c_line260.png

The capture don't sadly don't show the full trace, so we lack on 
information.
1st line I can see in the crash video from the idrac : 
tcp_transmit_skb+0x461

RIP [<ffffffff815da587>] ipv6_local_error+0x17/0x140

The null pointer happen:
  Type "apropos word" to search for commands related to "word"...
Reading symbols from net/ipv6/datagram.o...done.
(gdb) list *(ipv6_local_error+0x17)
0xae7 is in ipv6_local_error (net/ipv6/datagram.c:260).
255        struct ipv6_pinfo *np = inet6_sk(sk);
256        struct sock_exterr_skb *serr;
257        struct ipv6hdr *iph;
258        struct sk_buff *skb;
259
260        if (!np->recverr)
261            return;
262
263        skb = alloc_skb(sizeof(struct ipv6hdr), GFP_ATOMIC);
264        if (!skb)
(gdb) quit


We running a 6in4 with ipsec tunnel on the 6. I found a pull request from
Steffen Klassert
here:
     http://article.gmane.org/gmane.linux.network/281469

Which might be relevant to this problem.

For time being I add a

         if (np == NULL){
                 LIMIT_NETDEBUG(KERN_DEBUG "ipv6_pinfo is NULL\n");
                 return;
         }

as work around to stop the server crashing


With kind regards
Chris
