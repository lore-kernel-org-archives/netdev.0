From: Michal Soltys <soltys@ziu.info>
Subject: questions / potential bug: e1000e and tx delay setting in msi-x mode
Date: Wed, 09 Sep 2009 22:15:42 +0200
Message-ID: <4AA80CEE.5030704@ziu.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([80.72.38.138]:2793 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752576AbZIIUPg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Sep 2009 16:15:36 -0400
Received: from drutsystem.com (localhost.drutsystem.com [127.0.0.1])
	by drutsystem.com (Postfix) with ESMTP id 330189480FD
	for <netdev@vger.kernel.org>; Wed,  9 Sep 2009 20:15:38 +0000 (GMT)
Received: from [10.0.0.2] (unknown [80.72.44.82])
	by drutsystem.com (Postfix) with ESMTP id DC4489480E4
	for <netdev@vger.kernel.org>; Wed,  9 Sep 2009 22:15:37 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While experimenting a bit with intel PRO/1000 CT nic (reported by lspci as Intel 
Corporation 82574L Gigabit Network Connection), I noticed following issues (?):

1) under default IntMode (MSI-X), TxAbsIntDelay doesn't seem to limit interrupt 
rate (as seen via /proc/interrupts), although it is capped by InterruptThrottleRate 
(or not at all, if this one is disabled).

For example: with TxIntDelay 100 and TxAbsIntDelay 1000 - rate (as read from 
/proc/interrupts) under simple udp netcat bombarding (1k packet size):

nc -u somehost someport </dev/zero

... will be around 115k int/sec - expected value w/o any interrupt moderation.

When IntMode is set to 0 or 1 (so either regular or MSI) - both TxIntDelay and 
TxAbsIntDelay  seem to work properly - in the above example, rate would stay below 
1500 int/sec. But ...

2) ... at the same time, cpu load (as reported by mpstat -P ALL 1) is barely better 
in the latter case. Furthermore, if I disable any delays, e.g. load e1000e module with:

options e1000e TxIntDelay=0 TxAbsIntDelay=0 RxIntDelay=0 RxAbsIntDelay=0 InterruptThrottleRate=0 IntMode=1

.. then netcat test will max cpu core, and it will be unable to reach full 1gbit, while:

options e1000e TxIntDelay=0 TxAbsIntDelay=0 RxIntDelay=0 RxAbsIntDelay=0 InterruptThrottleRate=0 IntMode=2

.. will easily handle 1gbit with ~50%+ idle core (in my case at least).


Should the difference between MSI and MSI-X modes be so large ?


Earlier tests (pt. #1):

options e1000e TxIntDelay=100 TxAbsIntDelay=1000 RxIntDelay=0 RxAbsIntDelay=0 InterruptThrottleRate=0 IntMode=1

.. handles 1gbit with ~60%+ idle core.

and:

options e1000e TxIntDelay=100 TxAbsIntDelay=1000 RxIntDelay=0 RxAbsIntDelay=0 InterruptThrottleRate=0 IntMode=2
options e1000e TxIntDelay=0 TxAbsIntDelay=0 RxIntDelay=0 RxAbsIntDelay=0 InterruptThrottleRate=0 IntMode=2

.. are roughly identical as far as cpu load goes.





Those quick tests were done with nic interrupt(s) and netcat pinned at the same core.


Tested with current 2.6.31-rc9 and stable 2.6.30 tree.


