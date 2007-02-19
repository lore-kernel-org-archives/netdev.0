From: John Heffner <jheffner@psc.edu>
Subject: Re: [PATCH 2/2][TCP] YeAH-TCP: limited slow start exported function
Date: Mon, 19 Feb 2007 16:00:06 -0500
Message-ID: <45DA0FD6.9020404@psc.edu>
References: <45D97D5D.9040101@gmail.com> <45D97DC9.1030305@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020109030701070801070801"
Cc: netdev@vger.kernel.org,
	Andrea Baiocchi <andrea.baiocchi@uniroma1.it>,
	Francesco Vacirca <francesco@net.infocom.uniroma1.it>,
	David Miller <davem@davemloft.net>
To: "Angelo P. Castellani" <angelo.castellani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.66.106]:62951 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932659AbXBSVAT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Feb 2007 16:00:19 -0500
In-Reply-To: <45D97DC9.1030305@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020109030701070801070801
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

I'd prefer to make it apply automatically across all congestion controls 
that do slow-start, and also make the max_ssthresh parameter 
controllable via sysctl.  This patch (attached) should implement this. 
Note the default value for sysctl_tcp_max_ssthresh = 0, which disables 
limited slow-start.  This should make ABC apply during LSS as well.

Note the patch is compile-tested only!  I can do some real testing if 
you'd like to apply this Dave.

Thanks,
   -John


Angelo P. Castellani wrote:
> Forgot the patch..
> 
> Angelo P. Castellani ha scritto:
>> From: Angelo P. Castellani <angelo.castellani@gmail.con>
>>
>> RFC3742: limited slow start
>>
>> See http://www.ietf.org/rfc/rfc3742.txt
>>
>> Signed-off-by: Angelo P. Castellani <angelo.castellani@gmail.con>
>> ---
>>
>> To allow code reutilization I've added the limited slow start 
>> procedure as an exported symbol of linux tcp congestion control.
>>
>> On large BDP networks canonical slow start should be avoided because 
>> it requires large packet losses to converge, whereas at lower BDPs 
>> slow start and limited slow start are identical. Large BDP is defined 
>> through the max_ssthresh variable.
>>
>> I think limited slow start could safely replace the canonical slow 
>> start procedure in Linux.
>>
>> Regards,
>> Angelo P. Castellani
>>
>> p.s.: in the attached patch is added an exported function currently 
>> used only by YeAH TCP
>>
>> include/net/tcp.h   |    1 +
>> net/ipv4/tcp_cong.c |   23 +++++++++++++++++++++++
>> 2 files changed, 24 insertions(+)
>>
>>
> 
> 
> ------------------------------------------------------------------------
> 
> diff -uprN linux-2.6.20-a/include/net/tcp.h linux-2.6.20-c/include/net/tcp.h
> --- linux-2.6.20-a/include/net/tcp.h	2007-02-04 19:44:54.000000000 +0100
> +++ linux-2.6.20-c/include/net/tcp.h	2007-02-19 10:54:10.000000000 +0100
> @@ -669,6 +669,7 @@ extern void tcp_get_allowed_congestion_c
>  extern int tcp_set_allowed_congestion_control(char *allowed);
>  extern int tcp_set_congestion_control(struct sock *sk, const char *name);
>  extern void tcp_slow_start(struct tcp_sock *tp);
> +extern void tcp_limited_slow_start(struct tcp_sock *tp);
>  
>  extern struct tcp_congestion_ops tcp_init_congestion_ops;
>  extern u32 tcp_reno_ssthresh(struct sock *sk);
> diff -uprN linux-2.6.20-a/net/ipv4/tcp_cong.c linux-2.6.20-c/net/ipv4/tcp_cong.c
> --- linux-2.6.20-a/net/ipv4/tcp_cong.c	2007-02-04 19:44:54.000000000 +0100
> +++ linux-2.6.20-c/net/ipv4/tcp_cong.c	2007-02-19 10:54:10.000000000 +0100
> @@ -297,6 +297,29 @@ void tcp_slow_start(struct tcp_sock *tp)
>  }
>  EXPORT_SYMBOL_GPL(tcp_slow_start);
>  
> +void tcp_limited_slow_start(struct tcp_sock *tp)
> +{
> +	/* RFC3742: limited slow start
> +	 * the window is increased by 1/K MSS for each arriving ACK,
> +	 * for K = int(cwnd/(0.5 max_ssthresh))
> +	 */
> +
> +	const int max_ssthresh = 100;
> +
> +	if (max_ssthresh > 0 && tp->snd_cwnd > max_ssthresh) {
> +		u32 k = max(tp->snd_cwnd / (max_ssthresh >> 1), 1U);
> +		if (++tp->snd_cwnd_cnt >= k) {
> +			if (tp->snd_cwnd < tp->snd_cwnd_clamp)
> +				tp->snd_cwnd++;
> +			tp->snd_cwnd_cnt = 0;
> +		}
> +	} else {
> +		if (tp->snd_cwnd < tp->snd_cwnd_clamp)
> +			tp->snd_cwnd++;
> +	}
> +}
> +EXPORT_SYMBOL_GPL(tcp_limited_slow_start);
> +
>  /*
>   * TCP Reno congestion control
>   * This is special case used for fallback as well.


--------------020109030701070801070801
Content-Type: text/plain; x-mac-type="0"; x-mac-creator="0";
 name="lss.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="lss.patch"

Add RFC3742 Limited Slow-Start, controlled by variable sysctl_tcp_max_ssthresh.

Signed-off-by: John Heffner <jheffner@psc.edu>

---
commit 97033fa201705e6cfc68ce66f34ede3277c3d645
tree 5df4607728abce93aa05b31015a90f2ce369abff
parent 8a03d9a498eaf02c8a118752050a5154852c13bf
author John Heffner <jheffner@psc.edu> Mon, 19 Feb 2007 15:52:16 -0500
committer John Heffner <jheffner@psc.edu> Mon, 19 Feb 2007 15:52:16 -0500

 include/linux/sysctl.h     |    1 +
 include/net/tcp.h          |    1 +
 net/ipv4/sysctl_net_ipv4.c |    8 ++++++++
 net/ipv4/tcp_cong.c        |   33 +++++++++++++++++++++++----------
 4 files changed, 33 insertions(+), 10 deletions(-)

diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 2c5fb38..a2dce72 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -438,6 +438,7 @@ enum
 	NET_CIPSOV4_RBM_STRICTVALID=121,
 	NET_TCP_AVAIL_CONG_CONTROL=122,
 	NET_TCP_ALLOWED_CONG_CONTROL=123,
+	NET_TCP_MAX_SSTHRESH=124,
 };
 
 enum {
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 5c472f2..521da28 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -230,6 +230,7 @@ extern int sysctl_tcp_mtu_probing;
 extern int sysctl_tcp_base_mss;
 extern int sysctl_tcp_workaround_signed_windows;
 extern int sysctl_tcp_slow_start_after_idle;
+extern int sysctl_tcp_max_ssthresh;
 
 extern atomic_t tcp_memory_allocated;
 extern atomic_t tcp_sockets_allocated;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 0aa3047..d68effe 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -803,6 +803,14 @@ #endif /* CONFIG_NETLABEL */
 		.proc_handler   = &proc_allowed_congestion_control,
 		.strategy	= &strategy_allowed_congestion_control,
 	},
+	{
+		.ctl_name	= NET_TCP_MAX_SSTHRESH,
+		.procname	= "tcp_max_ssthresh",
+		.data		= &sysctl_tcp_max_ssthresh,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
 	{ .ctl_name = 0 }
 };
 
diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index c1b34f1..7fd2910 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -12,6 +12,8 @@ #include <linux/types.h>
 #include <linux/list.h>
 #include <net/tcp.h>
 
+int sysctl_tcp_max_ssthresh = 0;
+
 static DEFINE_SPINLOCK(tcp_cong_list_lock);
 static LIST_HEAD(tcp_cong_list);
 
@@ -271,10 +273,13 @@ #endif
 
 
 /*
- * Linear increase during slow start
+ * Slow start (exponential increase) with
+ * RFC3742 Limited Slow Start (fast linear increase) support.
  */
 void tcp_slow_start(struct tcp_sock *tp)
 {
+	int cnt = 0;
+	
 	if (sysctl_tcp_abc) {
 		/* RFC3465: Slow Start
 		 * TCP sender SHOULD increase cwnd by the number of
@@ -283,17 +288,25 @@ void tcp_slow_start(struct tcp_sock *tp)
 		 */
 		if (tp->bytes_acked < tp->mss_cache)
 			return;
-
-		/* We MAY increase by 2 if discovered delayed ack */
-		if (sysctl_tcp_abc > 1 && tp->bytes_acked >= 2*tp->mss_cache) {
-			if (tp->snd_cwnd < tp->snd_cwnd_clamp)
-				tp->snd_cwnd++;
-		}
 	}
+	
+	if (sysctl_tcp_max_ssthresh > 0 &&
+	    tp->snd_cwnd > sysctl_tcp_max_ssthresh)
+		cnt += sysctl_tcp_max_ssthresh>>1;
+	else
+		cnt += tp->snd_cwnd;
+
+	/* RFC3465: We MAY increase by 2 if discovered delayed ack */
+	if (sysctl_tcp_abc > 1 && tp->bytes_acked >= 2*tp->mss_cache)
+		cnt <<= 1;
 	tp->bytes_acked = 0;
-
-	if (tp->snd_cwnd < tp->snd_cwnd_clamp)
-		tp->snd_cwnd++;
+	
+	tp->snd_cwnd_cnt += cnt;
+	while (tp->snd_cwnd_cnt >= tp->snd_cwnd) {
+		if (tp->snd_cwnd < tp->snd_cwnd_clamp)
+			tp->snd_cwnd++;
+		tp->snd_cwnd_cnt -= tp->snd_cwnd;
+	}
 }
 EXPORT_SYMBOL_GPL(tcp_slow_start);
 

--------------020109030701070801070801--
