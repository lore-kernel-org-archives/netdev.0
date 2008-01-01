From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [IPSEC] flow : Remove an unecessary ____cacheline_aligned
Date: Tue, 01 Jan 2008 16:33:33 +0100
Message-ID: <477A5D4D.6000800@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020908040403010509010209"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:58770 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752185AbYAAPds (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jan 2008 10:33:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020908040403010509010209
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

We use a percpu variable named flow_hash_info, which holds 12 bytes.

It is currently marked as ____cacheline_aligned, which makes linker
skip space to properly align this variable.

Before :
c065cc90 D per_cpu__softnet_data
c065cd00 d per_cpu__flow_tables
<Here, hole of 124 bytes>
c065cd80 d per_cpu__flow_hash_info
<Here, hole of 116 bytes>
c065ce00 d per_cpu__flow_flush_tasklets
c065ce14 d per_cpu__rt_cache_stat


This alignement is quite unproductive, and removing it reduces the
size of percpu data (by 240 bytes on my x86 machine), and improves
performance (flow_tables & flow_hash_info can share a single cache
line)

After patch :
c065cc04 D per_cpu__softnet_data
c065cc4c d per_cpu__flow_tables
c065cc50 d per_cpu__flow_hash_info
c065cc5c d per_cpu__flow_flush_tasklets
c065cc70 d per_cpu__rt_cache_stat

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------020908040403010509010209
Content-Type: text/plain;
 name="flow2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="flow2.patch"

diff --git a/net/core/flow.c b/net/core/flow.c
index a618f89..2a735ba 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -52,7 +52,7 @@ struct flow_percpu_info {
 	int hash_rnd_recalc;
 	u32 hash_rnd;
 	int count;
-} ____cacheline_aligned;
+};
 static DEFINE_PER_CPU(struct flow_percpu_info, flow_hash_info) = { 0 };
 
 #define flow_hash_rnd_recalc(cpu) \

--------------020908040403010509010209--
