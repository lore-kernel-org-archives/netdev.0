From: Matthew Rosato <mjrosato@linux.vnet.ibm.com>
Subject: Regression in throughput between kvm guests over virtual bridge
Date: Tue, 12 Sep 2017 13:56:15 -0400
Message-ID: <4c7e2924-b10f-0e97-c388-c8809ecfdeeb@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, mst@redhat.com
To: netdev@vger.kernel.org, jasowang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:46548 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751493AbdILR4U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2017 13:56:20 -0400
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8CHs0YS050472
        for <netdev@vger.kernel.org>; Tue, 12 Sep 2017 13:56:19 -0400
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2cxgydbqsb-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 12 Sep 2017 13:56:19 -0400
Received: from localhost
        by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <mjrosato@linux.vnet.ibm.com>;
        Tue, 12 Sep 2017 11:56:18 -0600
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are seeing a regression for a subset of workloads across KVM guests
over a virtual bridge between host kernel 4.12 and 4.13.  Bisecting
points to c67df11f "vhost_net: try batch dequing from skb array"

In the regressed environment, we are running 4 kvm guests, 2 running as
uperf servers and 2 running as uperf clients, all on a single host.
They are connected via a virtual bridge.  The uperf client profile looks
like:

<?xml version="1.0"?>
<profile name="TCP_STREAM">
  <group nprocs="1">
    <transaction iterations="1">
      <flowop type="connect" options="remotehost=192.168.122.103
protocol=tcp"/>
    </transaction>
    <transaction duration="300">
      <flowop type="write" options="count=16 size=30000"/>
    </transaction>
    <transaction iterations="1">
      <flowop type="disconnect"/>
    </transaction>
  </group>
</profile>

So, 1 tcp streaming instance per client.  When upgrading the host kernel
from 4.12->4.13, we see about a 30% drop in throughput for this
scenario.  After the bisect, I further verified that reverting c67df11f
on 4.13 "fixes" the throughput for this scenario.

On the other hand, if we increase the load by upping the number of
streaming instances to 50 (nprocs="50") or even 10, we see instead a
~10% increase in throughput when upgrading host from 4.12->4.13.

So it may be the issue is specific to "light load" scenarios.  I would
expect some overhead for the batching, but 30% seems significant...  Any
thoughts on what might be happening here?
