From: Tom Herbert <therbert@google.com>
Subject: [PATCH 0/2] rps: Receive packet steering
Date: Tue, 10 Nov 2009 22:53:06 -0800
Message-ID: <65634d660911102253x10b7e513oda60f1c0e0f126a9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:50510 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752890AbZKKGxF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 01:53:05 -0500
Received: from zps78.corp.google.com (zps78.corp.google.com [172.25.146.78])
	by smtp-out.google.com with ESMTP id nAB6r9O8009989
	for <netdev@vger.kernel.org>; Tue, 10 Nov 2009 22:53:10 -0800
Received: from iwn15 (iwn15.prod.google.com [10.241.68.79])
	by zps78.corp.google.com with ESMTP id nAB6r6Mm011753
	for <netdev@vger.kernel.org>; Tue, 10 Nov 2009 22:53:07 -0800
Received: by iwn15 with SMTP id 15so737557iwn.27
        for <netdev@vger.kernel.org>; Tue, 10 Nov 2009 22:53:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the third version of the the patch that implements software rec=
eive
side packet steering (RPS). =A0RPS distributes the load of received pac=
ket
processing across multiple CPUs. =A0This version allows per NAPI steeri=
ng maps
as well as using HW provided hash as an optimization.

These patches are also the basis for per-flow steering which was previo=
usly
discussed; we are still working on a general solution for the per flow
steering which prevents OOO packets.

Problem statement: Protocol processing done in the NAPI context for rec=
eived
packets is serialized per device queue and becomes a bottleneck under h=
igh
packet load. =A0This substantially limits pps that can be achieved on a=
 single
queue NIC and provides no scaling with multiple cores.

This solution queues packets early on in the receive path on the backlo=
g queues
of other CPUs. =A0 This allows protocol processing (e.g. IP and TCP) to=
 be
performed on packets in parallel. =A0 For each device (or NAPI instance=
 for
a multi-queue device) a mask of CPUs is set to indicate the CPUs that c=
an
process packets for the device. A CPU is selected on a per packet basis=
 by
hashing contents of the packet header (the TCP or UDP 4-tuple) and usin=
g the
result to index into the CPU mask. =A0The IPI mechanism is used to rais=
e
networking receive softirqs between CPUs. =A0This effectively emulates =
in
software what a multi-queue NIC can provide, but is generic requiring n=
o device
support.

Many devices now provide a hash over the 4-tuple on a per packet basis
(Toeplitz is popular). =A0This patch allow drivers to set the HW report=
ed hash
in an skb field, and that value in turn is used to index into the RPS m=
aps.
Using the HW generated hash can avoid cache misses on the packet when
steering the packet to a remote CPU.

The CPU masks is set on a per device basis in the sysfs variable
/sys/class/net/<device>/rps_cpus. =A0This is a set of canonical bit map=
s for
each NAPI nstance of the device. =A0For example:

echo "0b 0b0 0b00 0b000" > /sys/class/net/eth0/rps_cpus

would set maps for four NAPI instances on eth0.

The first patch in this set adds the RPS functionality to the core netw=
orking.

The second patch adds support to the bnx2x driver to record the Toeplit=
z hash
reported by the device for received skbs.

Generally, we have found this technique increases pps capabilities of a=
 single
queue device with good CPU utilization. =A0Optimal settings for the CPU=
 mask
seems to depend on architectures and cache hierarcy. =A0Below are some =
results
running 700 instances of netperf TCP_RR test with 1 byte req. and resp.
Results show cumulative transaction rate and system CPU utilization.

tg3 on 8 core Intel
=A0 Without RPS: 90K tps at 34% CPU
=A0 With RPS: =A0 =A0285K tps at 70% CPU

e1000 on 8 core Intel
=A0 Without RPS: 90K tps at 34% CPU
=A0 With RPS: =A0 =A0292K tps at 66% CPU

foredeth on 16 core AMD
=A0 Without RPS: 117K tps at 10% CPU
=A0 With RPS: =A0 =A0327K tps at 29% CPU

bnx2x on 16 core AMD
=A0 Single queue without RPS: =A0 =A0 =A0 =A0139K tps at 17% CPU
=A0 Single queue with RPS: =A0 =A0 =A0 =A0 =A0 352K tps at 30% CPU
=A0 Multi queue (1 queues per CPU) =A0 204K tps at 12%

We have been running a variant of this patch on production servers for =
a while
with good results. =A0In some of our more networking intensive applicat=
ions we
have seen 30-50% gains in end application performance.

Tom

Signed-off-by: Tom Herbert <therbert@google.com>
