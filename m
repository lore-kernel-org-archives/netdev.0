From: Nikolay Borisov <kernel@kyup.com>
Subject: Slow veth performance over ipoib interface on 4.7.0 (and earlier)
 (Was Re: [IPOIB] Excessive TX packet drops due to IPOIB_MAX_PATH_REC_QUEUE)
Date: Thu, 4 Aug 2016 16:34:00 +0300
Message-ID: <57A34448.1040600@kyup.com>
References: <5799E5E6.3060104@kyup.com>
 <CAAk-MO83mJTq=E_MC=izqq8fEmVujY=5egVmKfFjxAz4jO3hHg@mail.gmail.com>
 <579F065C.602@kyup.com>
 <CAAk-MO9C7i0en5ZE=pufz6tMecUi23kL=5FR36JNfPzuO1G5-g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080503050403020500040501"
Cc: "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	netdev@vger.kernel.org
To: Erez Shitrit <erezsh@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:38817 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933771AbcHDNeF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2016 09:34:05 -0400
Received: by mail-wm0-f41.google.com with SMTP id o80so378662382wme.1
        for <netdev@vger.kernel.org>; Thu, 04 Aug 2016 06:34:04 -0700 (PDT)
In-Reply-To: <CAAk-MO9C7i0en5ZE=pufz6tMecUi23kL=5FR36JNfPzuO1G5-g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080503050403020500040501
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit



On 08/01/2016 11:56 AM, Erez Shitrit wrote:
> The GID (9000:0:2800:0:bc00:7500:6e:d8a4) is not regular, not from
> local subnet prefix.
> why is that?
>

So I managed to debug this and it tuns out the problem lies between veth
and ipoib interaction:

I've discovered the following strange thing. If I have a vethpair where
the 2 devices are in a different net namespaces as shown in the scripts
I have attached then the performance of sending a file, originating from
the veth interface inside the non-init netnamespace, going across the
ipoib interface is very slow (100kb). For simple reproduction I'm attaching
2 scripts which have to be run on 2 machine and the respective ip addresses
set on them. Then sending node woult initiate a simple file copy over NC.
I've observed this behavior on upstream 4.4, 4.5.4 and 4.7.0 kernels both
with ipv4 and ipv6 addresses. Here is what the debug log of the ipoib
module shows:

ib%d: max_srq_sge=128
ib%d: max_cm_mtu = 0xfff0, num_frags=16
ib0: enabling connected mode will cause multicast packet drops
ib0: mtu > 4092 will cause multicast packet drops.
ib0: bringing up interface
ib0: starting multicast thread
ib0: joining MGID ff12:401b:ffff:0000:0000:0000:ffff:ffff
ib0: restarting multicast task
ib0: adding multicast entry for mgid ff12:601b:ffff:0000:0000:0000:0000:0001
ib0: restarting multicast task
ib0: adding multicast entry for mgid ff12:401b:ffff:0000:0000:0000:0000:0001
ib0: join completion for ff12:401b:ffff:0000:0000:0000:ffff:ffff (status 0)
ib0: Created ah ffff88081063ea80
ib0: MGID ff12:401b:ffff:0000:0000:0000:ffff:ffff AV ffff88081063ea80, LID 0xc000, SL 0
ib0: joining MGID ff12:601b:ffff:0000:0000:0000:0000:0001
ib0: joining MGID ff12:401b:ffff:0000:0000:0000:0000:0001
ib0: successfully started all multicast joins
ib0: join completion for ff12:601b:ffff:0000:0000:0000:0000:0001 (status 0)
ib0: Created ah ffff880839084680
ib0: MGID ff12:601b:ffff:0000:0000:0000:0000:0001 AV ffff880839084680, LID 0xc002, SL 0
ib0: join completion for ff12:401b:ffff:0000:0000:0000:0000:0001 (status 0)
ib0: Created ah ffff88081063e280
ib0: MGID ff12:401b:ffff:0000:0000:0000:0000:0001 AV ffff88081063e280, LID 0xc004, SL 0

When the transfer is initiated I can see the following errors
on the sending node:

ib0: PathRec status -22 for GID 0401:0000:1400:0000:a0a8:ffff:1c01:4d36
ib0: neigh free for 000003 0401:0000:1400:0000:a0a8:ffff:1c01:4d36
ib0: Start path record lookup for 0401:0000:1400:0000:a0a8:ffff:1c01:4d36
ib0: PathRec status -22 for GID 0401:0000:1400:0000:a0a8:ffff:1c01:4d36
ib0: neigh free for 000003 0401:0000:1400:0000:a0a8:ffff:1c01:4d36
ib0: Start path record lookup for 0401:0000:1400:0000:a0a8:ffff:1c01:4d36
ib0: PathRec status -22 for GID 0401:0000:1400:0000:a0a8:ffff:1c01:4d36
ib0: neigh free for 000003 0401:0000:1400:0000:a0a8:ffff:1c01:4d36
ib0: Start path record lookup for 0401:0000:1400:0000:a0a8:ffff:1c01:4d36
ib0: PathRec status -22 for GID 0401:0000:1400:0000:a0a8:ffff:1c01:4d36
ib0: Start path record lookup for 0401:0000:1400:0000:a0a8:ffff:1c01:4d36
ib0: PathRec status -22 for GID 0401:0000:1400:0000:a0a8:ffff:1c01:4d36
ib0: neigh free for 000003 0401:0000:1400:0000:a0a8:ffff:1c01:4d36
ib0: neigh free for 000003 0401:0000:1400:0000:a0a8:ffff:1c01:4d36

Here is the port guid of the sending node: 0x0011750000772664 and
on the receiving one: 0x0011750000774d36

Here is how the paths look like on the sending node, 
clearly the paths being requested from the veth interface

cat /sys/kernel/debug/ipoib/ib0_path
GID: 401:0:1400:0:a0a8:ffff:1c01:4d36
complete: no

GID: 401:0:1400:0:a410:ffff:1c01:4d36
complete: no

GID: fe80:0:0:0:11:7500:77:2a1a
complete: yes
DLID: 0x0004
SL: 0
rate: 40.0 Gb/sec

GID: fe80:0:0:0:11:7500:77:4d36
complete: yes
DLID: 0x000a
SL: 0
rate: 40.0 Gb/sec

Testing the same scenario but instead of using veth devices I create
the device in the non-init netnamespace via the following commands
I can achieve sensible speeds:
ip link add link ib0 name ip1 type ipoib
ip link set dev ip1 netns test-netnamespace




 
[Snipped a lot of useless stuff]

--------------080503050403020500040501
Content-Type: application/x-shellscript;
 name="receive-node.sh"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="receive-node.sh"

IyEvYmluL2Jhc2gKCmxvY2FsX2liX2FkZHI9MTcyLjE2LjAuMTUwCnJlbW90ZV9pYl9hZGRy
PTE3Mi4xNi4wLjEwMwpyZW1vdGVfdmV0aF9uZXQ9MTcyLjE2LjEuMAoKaXAgcm91dGUgYWRk
ICRyZW1vdGVfdmV0aF9uZXQvMjQgdmlhICRyZW1vdGVfaWJfYWRkcgoKbmMgLWwgNTY3OCB8
IHB2ID4gcmVjZWl2ZWQuaW1nCg==
--------------080503050403020500040501
Content-Type: application/x-shellscript;
 name="sending-node.sh"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="sending-node.sh"

IyEvYmluL2Jhc2gKCmxvY2FsX2liX2FkZHI9MTcyLjE2LjAuMTUwCnJlbW90ZV9pYl9hZGRy
PTE3Mi4xNi4wLjEwMgpsb2NhbF92ZXRoX25ldD0xNzIuMTYuMS4wCmxvY2FsX3ZldGgwX2Fk
ZHI9MTcyLjE2LjEuMQpsb2NhbF92ZXRoMV9hZGRyPTE3Mi4xNi4xLjIKdG1wX2ZpbGU9JCht
a3RlbXAgLXUgLXAgLikKCiNjcmVhdGUgbmFtZXNwYWNlCmlwIG5ldG5zIGFkZCB0ZXN0LW5l
dG5hbWVzcGFjZQoKI2luaXQgdmV0aDAKaXAgbGluayBhZGQgdmV0aDAgdHlwZSB2ZXRoIHBl
ZXIgbmFtZSB2ZXRoMQppcCBsaW5rIHNldCB1cCBkZXYgdmV0aDAKaXAgYWRkciBhZGQgJGxv
Y2FsX3ZldGgwX2FkZHIvMjQgZGV2IHZldGgwCgojaW5pdCB2ZXRoMSBhbmQgcHV0IGluIG5l
dG5hbWVzcGFjZQppcCBsaW5rIHNldCBkZXYgdmV0aDEgbmV0bnMgdGVzdC1uZXRuYW1lc3Bh
Y2UKaXAgbmV0bnMgZXhlYyB0ZXN0LW5ldG5hbWVzcGFjZSBpcCBsaW5rIHNldCB1cCBkZXYg
dmV0aDEKaXAgbmV0bnMgZXhlYyB0ZXN0LW5ldG5hbWVzcGFjZSBpcCBhZGRyIGFkZCAkbG9j
YWxfdmV0aDFfYWRkci8yNCBkZXYgdmV0aDEKCiNhZGQgcm91dGVzCmlwIG5ldG5zIGV4ZWMg
dGVzdC1uZXRuYW1lc3BhY2UgaXAgcm91dGUgYWRkIGRlZmF1bHQgdmlhICRsb2NhbF92ZXRo
MF9hZGRyCgojZXhlY3V0ZSBzZW5kZXIKZGQgaWY9L2Rldi91cmFuZG9tIG9mPSR0bXBfZmls
ZSBicz0xTSBjb3VudD0xNTAKaXAgbmV0bnMgZXhlYyB0ZXN0LW5ldG5hbWVzcGFjZSBuYyAk
cmVtb3RlX2liX2FkZHIgNTY3OCA8ICR0bXBfZmlsZQoKcm0gLWYgJHRtcF9maWxlCgo=
--------------080503050403020500040501--
