From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: [REGRESSION] 362899b ("macvtap: switch to use skb array") causes
 oops during teardown
Date: Wed, 10 Aug 2016 18:40:32 +0200
Message-ID: <20160810184032.51f5429e.cornelia.huck@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Christian Borntraeger <borntraeger@de.ibm.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:40634 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751059AbcHJSjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2016 14:39:43 -0400
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7AGXxIj112550
	for <netdev@vger.kernel.org>; Wed, 10 Aug 2016 12:40:39 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0b-001b2d01.pphosted.com with ESMTP id 24qm9qxmq5-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 10 Aug 2016 12:40:39 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <cornelia.huck@de.ibm.com>;
	Wed, 10 Aug 2016 17:40:37 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm hitting the following oops during shutdown (halt command in guest)
of a libvirt-managed qemu guest 100% of the time:

[  108.920486] Unable to handle kernel pointer dereference in virtual kernel address space
[  108.920492] Failing address: 6b6b6b6b6b6b6000 TEID: 6b6b6b6b6b6b6803
[  108.920495] Fault in home space mode while using kernel ASCE.
[  108.920504] AS:0000000000e20007 R3:0000000000000024 
[  108.920588] Oops: 0038 ilc:2 [#1] PREEMPT SMP 
[  108.920592] Modules linked in: nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ipt_REJECT nf_reject_ipv4 xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc ghash_s390 prng ecb aes_s390 des_s390 des_generic sha512_s390 sha256_s390 sha1_s390 sha_common lockd grace vhost_net tun vhost macvtap macvlan kvm sunrpc dm_multipath dm_mod autofs4
[  108.920628] CPU: 8 PID: 2648 Comm: qemu-system-s39 Not tainted 4.8.0-rc1-00031-gd3d312e #25
[  108.920630] Hardware name: IBM              2964 NC9              704              (LPAR)
[  108.920634] Krnl PSW : 0704e00180000000 000000000064a3e8 (kfree_skb+0x38/0x288)
[  108.920640]            R:0 T:1 IO:1 EX:1 Key:0 M:1 W:0 P:0 AS:3 CC:2 PM:0 RI:0 EA:3
Krnl GPRS: 000000009fb04a5f 00000007a7a37d48 6b6b6b6b6b6b6b6b 000003ff80721af0
[  108.920645]            000000000078d626 00000007a7a34000 0000000000000000 0000000000000008
[  108.920647]            00000007b0f04210 00000007bde65718 000003ff80721afa 6b6b6b6b6b6b6b6b
[  108.920648]            00000007bde65698 0000000000807180 000003ff80721afa 00000007a7a37d08
[  108.920656] Krnl Code: 000000000064a3da: b90400ae            lgr     %r10,%r14
           000000000064a3de: b90400b2           lgr     %r11,%r2
          #000000000064a3e2: ec280121007c       cgij    %r2,0,8,64a624
          >000000000064a3e8: 581020e4           l       %r1,228(%r2)
           000000000064a3ec: ec160005017e       cij     %r1,1,6,64a3f6
           000000000064a3f2: a7f4000b           brc     15,64a408
           000000000064a3f6: a718ffff           lhi     %r1,-1
           000000000064a3fa: eb1120e400f8       laa     %r1,%r1,228(%r2)
[  108.920673] Call Trace:
[  108.920675] ([<00000007a7a37d28>] 0x7a7a37d28)
[  108.920679] ([<000003ff80721afa>] macvtap_sock_destruct+0x92/0xa8 [macvtap])
[  108.920681] ([<0000000000647026>] __sk_destruct+0x3e/0x1f0)
[  108.920684] ([<000003ff80723ed8>] macvtap_release+0x150/0x1b0 [macvtap])
[  108.920688] ([<000000000031bd72>] __fput+0x132/0x230)
[  108.920691] ([<000000000015f7aa>] task_work_run+0xb2/0xe8)
[  108.920695] ([<000000000078e494>] system_call+0xdc/0x270)
[  108.920697] INFO: lockdep is turned off.
[  108.920698] Last Breaking-Event-Address:
[  108.920700]  [<000003ff80721100>] 0x3ff80721100
[  108.920703]  Kernel panic - not syncing: Fatal exception: panic_on_oops

s390 host with a qeth device as the sole networking interface, one
network interface in the guest, using vhost (I can try to figure out
what libvirt is doing, if needed).

If I revert 362899b ("macvtap: switch to use skb array") and its
companion patch 0d7eacb ("macvtap: correctly free skb during socket
destruction"), starting a guest via libvirt and halting it again from
the guest works 100% of the time again.

I'm willing to collect debug info if you tell me what you need.
