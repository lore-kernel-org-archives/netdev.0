From: Huan Le <huan@apcera.com>
Subject: Re: tc ingress filters not applied
Date: Mon, 6 Jul 2015 17:24:34 +0000 (UTC)
Message-ID: <loom.20150706T190215-28@post.gmane.org>
References: <20150330141523.GQ23551@haze>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:45311 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754457AbbGFRfH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jul 2015 13:35:07 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1ZCAIL-0001J6-8k
	for netdev@vger.kernel.org; Mon, 06 Jul 2015 19:35:05 +0200
Received: from 4.16.82.26 ([4.16.82.26])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2015 19:35:05 +0200
Received: from huan by 4.16.82.26 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2015 19:35:05 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Erik Hugne <erik.hugne <at> ericsson.com> writes:

> 
> I'm having troubles with TC policing, the ingress filters does not seem to be
> applied.
> 
> 
> Kernel: net-next/latest 
> iproute2: shemminger/master
> 
> //E
> 

I observed similar behavior when configuring a filter on ingress qdisc.
Test shows that traffic was rate-limited to the configured value. 
However, "tc filter show" does not show any filtering rule.

(1) add ingress qdisc on eth1
# tc qdisc add dev eth1 ingress
# tc qdisc show dev eth1 ingress
qdisc pfifo_fast 0: root refcnt 2 bands 3 priomap \
 1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
qdisc ingress ffff: parent ffff:fff1 ---------------- 

(2) add filter under ingress qdisc
# tc filter add dev eth1 parent ffff: protocol all \
 u32 match ip src 0.0.0.0/0 \
 police rate 256kbit burst 10k drop flowid :1
# tc filter show dev eth1

(3) verified sch_ingress kernel module is installed
# lsmod  | grep sch_ingress
sch_ingress            12866  1

(4) uname -a (if needed for debugging)
Linux huan-lnx 3.16.0-30-generic #40~14.04.1-Ubuntu SMP 
Thu Jan 15 17:43:14 UTC 2015 x86_64 x86_64 x86_64 GNU/Linux

I am testing this using ubuntu 14.04 on a virtualbox VM
(eth1 is a host-only adapter).

Thanks,
Huan
