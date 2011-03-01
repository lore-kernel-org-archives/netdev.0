From: Anders Nilsson Plymoth <lml@telhoc.se>
Subject: ICMP reply uses wrong source address as destinatio
Date: Tue, 1 Mar 2011 09:49:19 +0100
Message-ID: <AANLkTinOCp3e6tiWgesPtKYwB7Mj=Ch6Ccm1xeSFLcpD@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:57423 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755757Ab1CAItU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 03:49:20 -0500
Received: by fxm17 with SMTP id 17so4577802fxm.19
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2011 00:49:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear linux kernel enthusiasts,

I came upon an issue where ICMP reply packets were issued towards the
IP address of the receiving interface, rather than the source IP
address.
Looking at the kernel code, I saw that this is caused by the following
line in net/ipv4/icmp.c function icmp_reply:

daddr = ipc.addr = rt->rt_src;

For most cases the original line of code is ok, but in some situations
doesn't arrive to the kernel from the network device, but through some
other mechanism such as a userspace application. In these cases the
receiving device in the skb appears to be the loopback interface, not
a physical device. icmp_reply will thus issue the reply to the
loopback IP address, rather than the source IP address as it should.

While googling to see if this issue have been submitted, I found this
two posts that address the same problem:
h**p://www.mail-archive.com/linux-kernel@vger.kernel.org/msg209746.html
h**p://www.mail-archive.com/linux-kernel@vger.kernel.org/msg208272.html
Some of the questions there are easy to answer; such as this doesn't
affect DNAT, and if source address is not set then you can' reply
anyway.

As to the statement:
"... which IP address should be used as the source

1. the destination address of the packet that generated the message

or.

2. the IP address that the machine would use by default if the machine
were to generate a new connection to the destination."

These may be relevant questions, but the ICMP RFC clearly states the
answer is 1. 2. may seem relevant to multi-homing, but its not the
role of the ICMP reply to resolve multi-homing issues.

The following code will correct the issue.

{
   struct iphdr *ip = ip_hdr(skb);
   daddr = ipc.addr = ip->saddr;
}

The only functions that use icmp_reply are icmp_echo and
icmp_timestamp, and this change do not modify their behavior. After
extensive testing, in regular setups and DNATed situations, I can
verify this change works as intended.

Thanks,
Anders
