From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [PATCH] net: sk_prot_alloc() should not blindly overwrite memory
Date: Wed, 8 Jul 2009 11:02:22 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365F8ACEC9A1@rrsmsx501.amr.corp.intel.com>
References: <4A537469.3040207@gmail.com>
	<EA929A9653AAE14F841771FB1DE5A1365F8ACEBEE9@rrsmsx501.amr.corp.intel.com>
	<4A53CD39.7080407@gmail.com> <20090707.191424.167842005.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "emils.tantilov@gmail.com" <emils.tantilov@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"jolsa@redhat.com" <jolsa@redhat.com>
To: David Miller <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:14694 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754100AbZGHRCo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 13:02:44 -0400
In-Reply-To: <20090707.191424.167842005.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 08 Jul 2009 00:33:29 +0200
> 
>> [PATCH] net: sk_prot_alloc() should not blindly overwrite memory
>> 
>> Some sockets use SLAB_DESTROY_BY_RCU, and our RCU code rely that some
>> fields should not be blindly overwritten, even with null.
>> 
>> These fields are sk->sk_refcnt and sk->sk_nulls_node.next
>> 
>> Current sk_prot_alloc() implementation doesnt respect this
>> hypothesis, calling kmem_cache_alloc() with __GFP_ZERO and setting
>> sk_refcnt to 1 instead of atomically increment it.
>> 
>> Reported-by: Emil S Tantilov <emils.tantilov@gmail.com>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> I've applied this but will wait for some more testing before
> I push it out for real to kernel.org

Still seeing traces during the test even with this patch applied:

[ 1089.430093] ------------[ cut here ]------------
[ 1089.435667] WARNING: at include/net/sock.h:423 udp_lib_unhash+0x73/0xa0()
[ 1089.435670] Hardware name: S5520HC
[ 1089.435671] Modules linked in: igb dca mdio [last unloaded: ixgbe]
[ 1089.435678] Pid: 15545, comm: netserver Not tainted 2.6.31-rc1-net-2.6-igb-ed-07071641 #4
[ 1089.435681] Call Trace:
[ 1089.435686]  [<ffffffff813e8a2f>] ? udp_lib_unhash+0x73/0xa0
[ 1089.435691]  [<ffffffff81057b49>] warn_slowpath_common+0x77/0x8f
[ 1089.435696]  [<ffffffff81057b70>] warn_slowpath_null+0xf/0x11
[ 1089.435700]  [<ffffffff813e8a2f>] udp_lib_unhash+0x73/0xa0
[ 1089.435705]  [<ffffffff8138e616>] sk_common_release+0x2f/0xb4
[ 1089.435710]  [<ffffffff81429028>] udp_lib_close+0x9/0xb
[ 1089.435715]  [<ffffffff813ee62a>] inet_release+0x58/0x5f
[ 1089.435720]  [<ffffffff814158e5>] inet6_release+0x30/0x35
[ 1089.435725]  [<ffffffff8138be4b>] sock_release+0x1a/0x6c
[ 1089.435729]  [<ffffffff8138c366>] sock_close+0x22/0x26
[ 1089.435735]  [<ffffffff810ec923>] __fput+0xf0/0x18c
[ 1089.435739]  [<ffffffff810eccd1>] fput+0x15/0x18
[ 1089.435742]  [<ffffffff810e9bfa>] filp_close+0x5c/0x67
[ 1089.435746]  [<ffffffff810e9c80>] sys_close+0x7b/0xb6
[ 1089.435751]  [<ffffffff81027aab>] system_call_fastpath+0x16/0x1b
[ 1089.435755] ---[ end trace a79410bd00b8b1ac ]---

Emil