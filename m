From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Bonding in active-backup mode with arp monitoring on Xen
Date: Tue, 30 Oct 2007 14:48:29 -0700
Message-ID: <25246.1193780909@death>
References: <47253487.3010909@nb.jp.nec.com>
Cc: netdev@vger.kernel.org
To: Tsutomu Fujii <t-fujii@nb.jp.nec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:42510 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752024AbXJ3Vsc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2007 17:48:32 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9ULmVBL005888
	for <netdev@vger.kernel.org>; Tue, 30 Oct 2007 17:48:31 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9ULmVfc501152
	for <netdev@vger.kernel.org>; Tue, 30 Oct 2007 17:48:31 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9ULmVEW029479
	for <netdev@vger.kernel.org>; Tue, 30 Oct 2007 17:48:31 -0400
In-reply-to: <47253487.3010909@nb.jp.nec.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tsutomu Fujii <t-fujii@nb.jp.nec.com> wrote:
[...]
>The network structure is the following.
>
>+-------------------------------+
>|        virtual I/F(eth0)      | <- have IP address.
>+-------------------------------+
>|      virtual bridge(xenbr0)   |
>+-------------------------------+
>|         bonding(bond0)        | <- don't have IP address
>+--------------+-+--------------+
>|phy I/F(peth0)| |phy I/F(peth1)|
>+--------------+ +--------------+
[...]
>How about removing bond_has_ip() from the condition for calling
>bond_arp_send_all() to use bonding with xen?
>When I removed bond_has_ip(), the resulting kernel worked fine and
>active-backup mode works with arp monitoring.

	I looked at this a bit.  I believe that when you remove the
bond_has_ip() test, the ARP probes sent out will be of the form "ARP
who-has A.B.C.D tell 0.0.0.0", which the linux kernel will interpret as
IPv4 Duplicate Address Detection probes (as a special case in
arp_process()), and generate some type of reply.  That reply appears to
be enough to keep the ARP monitor happy.

	I'm not sure if this is a solution that will work for any peer
(some peers may not reply to an ARP with an IP source of all zeros).  At
first glance, there doesn't seem to be much of a downside, but I'll have
to experiment with it a bit to see if the check should be optional or
simply removed entirely.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
