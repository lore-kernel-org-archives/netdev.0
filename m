From: Glauber Costa <glommer@parallels.com>
Subject: Re: [v3.3-rc1 regression] TCP: too many of orphaned sockets
Date: Fri, 27 Jan 2012 18:35:32 +0400
Message-ID: <4F22B634.2020007@parallels.com>
References: <20120127124641.GA30819@elte.hu> <4F229D5C.4040300@parallels.com> <20120127125645.GA28131@elte.hu> <20120127141754.GA30202@elte.hu> <20120127142246.GA22318@elte.hu>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="------------040904050405020808000608"
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120127142246.GA22318@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--------------040904050405020808000608
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit

On 01/27/2012 06:22 PM, Ingo Molnar wrote:
>
> * Ingo Molnar<mingo@elte.hu>  wrote:
>
>> ok, i've bisected it, and the bad commit is:
>>
>> 3dc43e3e4d0b52197d3205214fe8f162f9e0c334 is the first bad commit
>> commit 3dc43e3e4d0b52197d3205214fe8f162f9e0c334
>> Author: Glauber Costa<glommer@parallels.com>
>> Date:   Sun Dec 11 21:47:05 2011 +0000
>>
>>      per-netns ipv4 sysctl_tcp_mem
>
> Might be related to this detail in the .config:
>
>   # CONFIG_PROC_SYSCTL is not set
>
> So former tcp_init() code does not get run?
>
> Thanks,
>
> 	Ingo

Can you tell me if the following patch fixes your problem?


--------------040904050405020808000608
Content-Type: text/x-patch; name="test.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="test.patch"

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 9bcdec3..366834b 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3276,9 +3276,23 @@ void __init tcp_init(void)
 	sysctl_tcp_max_orphans = cnt / 2;
 	sysctl_max_syn_backlog = max(128, cnt / 256);
 
+	/*
+	 * Despite the sysctl name, those values are always used in the code.
+	 * CONFIG_PROC_SYSCTL only exposes it as a sysctl, allowing the admin
+	 * to tweak them. If this is not configured, we need to provide
+	 * a default value here
+	 */
+#ifdef CONFIG_PROC_SYSCTL
 	/* Set per-socket limits to no more than 1/128 the pressure threshold */
 	limit = ((unsigned long)init_net.ipv4.sysctl_tcp_mem[1])
 		<< (PAGE_SHIFT - 7);
+#else
+	limit = nr_free_buffer_pages() / 8;
+	limit = max(limit, 128UL);
+	init_net.ipv4.sysctl_tcp_mem[0] = limit / 4 * 3;
+	init_net.ipv4.sysctl_tcp_mem[1] = limit;
+	init_net.ipv4.sysctl_tcp_mem[2] = sysctl_tcp_mem[0] * 2;
+#endif
 	max_share = min(4UL*1024*1024, limit);
 
 	sysctl_tcp_wmem[0] = SK_MEM_QUANTUM;

--------------040904050405020808000608--
