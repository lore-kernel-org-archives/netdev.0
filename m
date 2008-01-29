From: Chuck Ebbert <cebbert@redhat.com>
Subject: Still oopsing in nf_nat_move_storage()
Date: Tue, 29 Jan 2008 12:11:54 -0500
Message-ID: <479F5E5A.8050108@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:42573 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764108AbYA2RL7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2008 12:11:59 -0500
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id m0THBurB009917
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 12:11:56 -0500
Received: from mail.boston.redhat.com (mail.boston.redhat.com [172.16.76.12])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id m0THBtK4016393
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 12:11:55 -0500
Received: from [172.16.83.145] (dhcp83-145.boston.redhat.com [172.16.83.145])
	by mail.boston.redhat.com (8.13.1/8.13.1) with ESMTP id m0THBs9h003321
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 12:11:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nf_nat_move_storage():
/usr/src/debug/kernel-2.6.23/linux-2.6.23.i686/net/ipv4/netfilter/nf_nat_core.c:612
      87:       f7 47 64 80 01 00 00    testl  $0x180,0x64(%edi)
      8e:       74 39                   je     c9 <nf_nat_move_storage+0x65>

line 612:
        if (!(ct->status & IPS_NAT_DONE_MASK))
                return;

ct is NULL



To reproduce, this is the Fedora iptables config file:

*nat
:PREROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
-A PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to :21
COMMIT

*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -p icmp --icmp-type any -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -i eth0 -m state --state NEW -m tcp -p tcp --dport 21 -j ACCEPT
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -j REJECT --reject-with icmp-host-prohibited
COMMIT
