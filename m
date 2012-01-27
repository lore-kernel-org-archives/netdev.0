From: Glauber Costa <glommer@parallels.com>
Subject: Re: [v3.3-rc1 regression] TCP: too many of orphaned sockets
Date: Fri, 27 Jan 2012 20:27:06 +0400
Message-ID: <4F22D05A.8030604@parallels.com>
References: <20120127124641.GA30819@elte.hu> <4F229D5C.4040300@parallels.com> <20120127125645.GA28131@elte.hu> <20120127141754.GA30202@elte.hu> <20120127142246.GA22318@elte.hu> <4F22B634.2020007@parallels.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="------------090700050908010709090008"
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F22B634.2020007@parallels.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--------------090700050908010709090008
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit

On 01/27/2012 06:35 PM, Glauber Costa wrote:
> On 01/27/2012 06:22 PM, Ingo Molnar wrote:
>>
>> * Ingo Molnar<mingo@elte.hu> wrote:
>>
>>> ok, i've bisected it, and the bad commit is:
>>>
>>> 3dc43e3e4d0b52197d3205214fe8f162f9e0c334 is the first bad commit
>>> commit 3dc43e3e4d0b52197d3205214fe8f162f9e0c334
>>> Author: Glauber Costa<glommer@parallels.com>
>>> Date: Sun Dec 11 21:47:05 2011 +0000
>>>
>>> per-netns ipv4 sysctl_tcp_mem
>>
>> Might be related to this detail in the .config:
>>
>> # CONFIG_PROC_SYSCTL is not set
>>
>> So former tcp_init() code does not get run?
>>
>> Thanks,
>>
>> Ingo
>
> Can you tell me if the following patch fixes your problem?
>
Update on this:

What really makes it break is CONFIG_SYSCTL.
CONFIG_PROC_SYSCTL selects that, so if you get the one, you
end up getting the other. (The config mingo provided lacks both)

Also, I believe there is no harm in initializing this unconditionally,
so instead of cluttering tcp_init() with #ifdef, I am proposing we just 
init it here, and then init it again in sysctl initialization. I don't
expect it to harm workload, since it is a one-shot.

Now, I am attaching my proposed final patch for this, but I can't really
generate a config without sysctl that boots okay for me.

Ingo, would you please confirm that this fixes the problem for you? If 
I'm mistaken, let me know and I'll get back to it ASAP.

Dave, once Ingo acks that it fixes the problem he says, I'll submit the 
patch formally.

Thanks.

--------------090700050908010709090008
Content-Type: text/x-patch;
	name="0001-fix-tcp-sysctl-initialization-with-CONFIG_SYSCTL-dis.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename*0="0001-fix-tcp-sysctl-initialization-with-CONFIG_SYSCTL-dis.pa";
	filename*1="tch"

>From 49318a2c917f970373e66e21d747a38a595eb462 Mon Sep 17 00:00:00 2001
From: Glauber Costa <glommer@parallels.com>
Date: Fri, 27 Jan 2012 19:34:17 +0400
Subject: [PATCH] fix tcp sysctl initialization with CONFIG_SYSCTL disabled.

sysctl_tcp_mem initialization was moved to sysctl_tcp_ipv4.c
in commit 3dc43e3e4d0b52197d3205214fe8f162f9e0c334, since it
became a per-ns value.

That code, however, will never run when CONFIG_SYSCTL is disabled,
leading to bogus values on those fields.

This patch fixes it by keeping an initialization code in tcp_init().
It will be overwritten by the first net namespace init if CONFIG_SYSCTL
is compiled in, and do the right thing if it is compiled out.

Signed-off-by: Glauber Costa <glommer@parallels.com>
Reported-by: Ingo Molnar <mingo@elte.hu>
---
 include/net/tcp.h          |    2 ++
 net/ipv4/sysctl_net_ipv4.c |    1 +
 net/ipv4/tcp.c             |   16 +++++++++++++---
 3 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 0118ea9..b04a3e9 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -311,6 +311,8 @@ extern struct proto tcp_prot;
 #define TCP_ADD_STATS_USER(net, field, val) SNMP_ADD_STATS_USER((net)->mib.tcp_statistics, field, val)
 #define TCP_ADD_STATS(net, field, val)	SNMP_ADD_STATS((net)->mib.tcp_statistics, field, val)
 
+extern void init_tcp_mem(struct net *net);
+
 extern void tcp_v4_err(struct sk_buff *skb, u32);
 
 extern void tcp_shutdown (struct sock *sk, int how);
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 4aa7e9d..1d67cde 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -814,6 +814,7 @@ static __net_init int ipv4_sysctl_init_net(struct net *net)
 
 	net->ipv4.sysctl_rt_cache_rebuild_count = 4;
 
+	init_tcp_mem(net);
 	limit = nr_free_buffer_pages() / 8;
 	limit = max(limit, 128UL);
 	net->ipv4.sysctl_tcp_mem[0] = limit / 4 * 3;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 9bcdec3..34e4051 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3216,6 +3216,16 @@ static int __init set_thash_entries(char *str)
 }
 __setup("thash_entries=", set_thash_entries);
 
+void init_tcp_mem(struct net *net)
+{
+	/* Set per-socket limits to no more than 1/128 the pressure threshold */
+	unsigned long limit = nr_free_buffer_pages() / 8;
+	limit = max(limit, 128UL);
+	net->ipv4.sysctl_tcp_mem[0] = limit / 4 * 3;
+	net->ipv4.sysctl_tcp_mem[1] = limit;
+	net->ipv4.sysctl_tcp_mem[2] = net->ipv4.sysctl_tcp_mem[0] * 2;
+}
+
 void __init tcp_init(void)
 {
 	struct sk_buff *skb = NULL;
@@ -3276,9 +3286,9 @@ void __init tcp_init(void)
 	sysctl_tcp_max_orphans = cnt / 2;
 	sysctl_max_syn_backlog = max(128, cnt / 256);
 
-	/* Set per-socket limits to no more than 1/128 the pressure threshold */
-	limit = ((unsigned long)init_net.ipv4.sysctl_tcp_mem[1])
-		<< (PAGE_SHIFT - 7);
+	init_tcp_mem(&init_net);
+	limit = nr_free_buffer_pages() / 8;
+	limit = max(limit, 128UL);
 	max_share = min(4UL*1024*1024, limit);
 
 	sysctl_tcp_wmem[0] = SK_MEM_QUANTUM;
-- 
1.7.7.4


--------------090700050908010709090008--
