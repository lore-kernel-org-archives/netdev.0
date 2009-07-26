From: Michal Soltys <soltys@ziu.info>
Subject: r8169 (+others ?) and note_interrupt performance hit on 2.6.30.x
Date: Sun, 26 Jul 2009 02:31:10 +0200
Message-ID: <4A6BA3CE.9000607@ziu.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([80.72.38.138]:3154 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751793AbZGZAbY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jul 2009 20:31:24 -0400
Received: from drutsystem.com (localhost.drutsystem.com [127.0.0.1])
	by drutsystem.com (Postfix) with ESMTP id C73E4948089
	for <netdev@vger.kernel.org>; Sun, 26 Jul 2009 00:31:08 +0000 (GMT)
Received: from [10.0.0.2] (apn-77-112-0-177.dynamic.gprs.plus.pl [77.112.0.177])
	by drutsystem.com (Postfix) with ESMTP id 00C7B948078
	for <netdev@vger.kernel.org>; Sun, 26 Jul 2009 02:31:08 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've noticed, that on 2.6.30 kernels I took serious performance
hit compared to e.g. 2.6.28.10 (didn't check 2.6.29 ones).

Generally, with trivial nc -u other_host </dev/zero
- so ~ 1KB packets and 1gbit speed I went from:

01:30:25 AM  CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest   %idle
01:30:26 AM  all    0.91    0.00    8.68    0.00    2.28    7.31    0.00    0.00   80.82
01:30:26 AM    0    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
01:30:26 AM    1    1.68    0.00   15.13    0.00    5.04   13.45    0.00    0.00   64.71

running at full 1gbit speed with ease, to:

01:35:26 AM  CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest   %idle
01:35:27 AM  all    0.50    0.00   12.56    0.00   24.12   12.56    0.00    0.00   50.25
01:35:27 AM    0    0.00    0.00    0.00    0.00    0.00    0.00    0.00    0.00  100.00
01:35:27 AM    1    2.00    0.00   25.00    0.00   48.00   25.00    0.00    0.00    0.00

struggling at ~90MB/s (standard pfifo_fast)

Both netcat and interface interrupt were pinned at the same (2nd) core.

I did some quick oprofile, and noticed one new call -
note_interrupt - which wasn't present in the earlier kernel,
taking majority of the cpu time, relatively to the rest, e.g.:

samples  cum. samples  %        cum. %     symbol name
90984    90984         42.8695  42.8695    note_interrupt


The hardware is regular 32bit x86:

GA-MA74GM-S2H
AMD 4850e (2.5ghz)
onboard r8169

Both kernels with identical configuration, and tests done on idle machine.
