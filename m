From: Flavio Leitner <fbl@redhat.com>
Subject: ICMP redirect issue
Date: Tue, 27 Sep 2011 16:21:20 -0300
Message-ID: <20110927162120.30394030@asterix.rh>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3828 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751343Ab1I0TVX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Sep 2011 15:21:23 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p8RJLNCC024753
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 27 Sep 2011 15:21:23 -0400
Received: from asterix.rh (ovpn-113-121.phx2.redhat.com [10.3.113.121])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id p8RJLLAO009076
	for <netdev@vger.kernel.org>; Tue, 27 Sep 2011 15:21:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

While investigating an issue on Red Hat Enterprise Linux, I found that
upstream commit below removed the old_gw check.

commit f39925dbde7788cfb96419c0f092b086aa325c0f
Author: David S. Miller <davem@davemloft.net>
Date:   Wed Feb 9 22:00:16 2011 -0800

    ipv4: Cache learned redirect information in inetpeer.

The issue is about the gateway being a LVS, so the servers behind use
the IP alias address as the default gateway.  However, when the gateway
sends an ICMP redirect, it comes from the primary IP address which is
ignored on older kernels because of the old_gw check:

-                               if (rth->rt_dst != daddr ||
-                                   rth->rt_src != saddr ||
-                                   rth->dst.error ||
-                                   rth->rt_gateway != old_gw ||
-                                   rth->dst.dev != dev)
-                                       break;


Well, the consequence is that the issue doesn't happen in newer kernels
because it happily accepts the ICMP redirect.

The admin can still control using shared_media and secure_redirects if
the host should accept only the ICMP redirects for gateways listed in
default gateway list or not.

In terms of a security, if someone manages to send ICMP redirect, then
I think it possible to fake the saddr to appear as coming from the
correct gateway.

So, I'm not seeing a problem, but I was told to bring this up to netdev.
Thoughts?

thanks,
fbl
