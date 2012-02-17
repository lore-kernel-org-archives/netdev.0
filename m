From: Anthony Liguori <aliguori@us.ibm.com>
Subject: [PATCH 0/2][RFC] vhost: improve transmit rate with virtqueue polling
Date: Fri, 17 Feb 2012 17:02:04 -0600
Message-ID: <1329519726-25763-1-git-send-email-aliguori@us.ibm.com>
Cc: Michael Tsirkin <mst@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:41210 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753287Ab2BQXCQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Feb 2012 18:02:16 -0500
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <aliguori@us.ibm.com>;
	Fri, 17 Feb 2012 18:02:15 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 257CF38C8054
	for <netdev@vger.kernel.org>; Fri, 17 Feb 2012 18:02:11 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1HN2APs223546
	for <netdev@vger.kernel.org>; Fri, 17 Feb 2012 18:02:10 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1HN2937025325
	for <netdev@vger.kernel.org>; Fri, 17 Feb 2012 21:02:10 -0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

We've been studying small packet performance under KVM.  Currently, this type of
workload performs fairly poorly in KVM compared to other hypervisors.

After a lot of study, we concluded that two factors currently are bottlenecking
performance.

1) vhost uses a single thread to read both the transmit and receive rings.  The
   code is clearly structured to support multiple threads but only does a single
   thread today.  As these patches show, this has a significant affect on
   performance when running a two VCPU Linux guest under KVM.

2) When dealing with a workload like multiple TCP_RR instances, we process
   packets off the transmit queue too quickly.  It seems to be rare to actually
   get significant batching.  vhost does not use a timer for TX mitigation
   instead relying on scheduling latency to encourage batching.  But in an
   unloaded system, the vhost thread simply gets scheduled too quickly and the
   exit cost dominates the workload.

   In the second patch, we introduce an mechanism to poll the transmit ring for
   a short period of time.  While this series doesn't show it, in our testing
   with similar code, this can have a dramatic affect on throughput.

The second patch does manual tuning but we have a third patch that uses a simple
adaptive algorithm.  I'll follow up soon with this patch and results for it.

We're looking to get some feedback on the approach here.  I think the first
patch should be pretty non-controversial (other than the broadcast wake-up).
