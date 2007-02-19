From: "Angelo P. Castellani" <angelo.castellani@gmail.com>
Subject: Re: [PATCH 2/2][TCP] YeAH-TCP: limited slow start exported function
Date: Mon, 19 Feb 2007 11:36:57 +0100
Message-ID: <45D97DC9.1030305@gmail.com>
References: <45D97D5D.9040101@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060105070006000608060402"
Cc: Andrea Baiocchi <andrea.baiocchi@uniroma1.it>,
	Francesco Vacirca <francesco@net.infocom.uniroma1.it>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:33666 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750886AbXBSKhC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Feb 2007 05:37:02 -0500
Received: by nf-out-0910.google.com with SMTP id o25so2385544nfa
        for <netdev@vger.kernel.org>; Mon, 19 Feb 2007 02:37:01 -0800 (PST)
In-Reply-To: <45D97D5D.9040101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060105070006000608060402
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Forgot the patch..

Angelo P. Castellani ha scritto:
> From: Angelo P. Castellani <angelo.castellani@gmail.con>
>
> RFC3742: limited slow start
>
> See http://www.ietf.org/rfc/rfc3742.txt
>
> Signed-off-by: Angelo P. Castellani <angelo.castellani@gmail.con>
> ---
>
> To allow code reutilization I've added the limited slow start 
> procedure as an exported symbol of linux tcp congestion control.
>
> On large BDP networks canonical slow start should be avoided because 
> it requires large packet losses to converge, whereas at lower BDPs 
> slow start and limited slow start are identical. Large BDP is defined 
> through the max_ssthresh variable.
>
> I think limited slow start could safely replace the canonical slow 
> start procedure in Linux.
>
> Regards,
> Angelo P. Castellani
>
> p.s.: in the attached patch is added an exported function currently 
> used only by YeAH TCP
>
> include/net/tcp.h   |    1 +
> net/ipv4/tcp_cong.c |   23 +++++++++++++++++++++++
> 2 files changed, 24 insertions(+)
>
>


--------------060105070006000608060402
Content-Type: text/x-patch;
 name="tcp_yeah-2of2.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="tcp_yeah-2of2.diff"

diff -uprN linux-2.6.20-a/include/net/tcp.h linux-2.6.20-c/include/net/tcp.h
--- linux-2.6.20-a/include/net/tcp.h	2007-02-04 19:44:54.000000000 +0100
+++ linux-2.6.20-c/include/net/tcp.h	2007-02-19 10:54:10.000000000 +0100
@@ -669,6 +669,7 @@ extern void tcp_get_allowed_congestion_c
 extern int tcp_set_allowed_congestion_control(char *allowed);
 extern int tcp_set_congestion_control(struct sock *sk, const char *name);
 extern void tcp_slow_start(struct tcp_sock *tp);
+extern void tcp_limited_slow_start(struct tcp_sock *tp);
 
 extern struct tcp_congestion_ops tcp_init_congestion_ops;
 extern u32 tcp_reno_ssthresh(struct sock *sk);
diff -uprN linux-2.6.20-a/net/ipv4/tcp_cong.c linux-2.6.20-c/net/ipv4/tcp_cong.c
--- linux-2.6.20-a/net/ipv4/tcp_cong.c	2007-02-04 19:44:54.000000000 +0100
+++ linux-2.6.20-c/net/ipv4/tcp_cong.c	2007-02-19 10:54:10.000000000 +0100
@@ -297,6 +297,29 @@ void tcp_slow_start(struct tcp_sock *tp)
 }
 EXPORT_SYMBOL_GPL(tcp_slow_start);
 
+void tcp_limited_slow_start(struct tcp_sock *tp)
+{
+	/* RFC3742: limited slow start
+	 * the window is increased by 1/K MSS for each arriving ACK,
+	 * for K = int(cwnd/(0.5 max_ssthresh))
+	 */
+
+	const int max_ssthresh = 100;
+
+	if (max_ssthresh > 0 && tp->snd_cwnd > max_ssthresh) {
+		u32 k = max(tp->snd_cwnd / (max_ssthresh >> 1), 1U);
+		if (++tp->snd_cwnd_cnt >= k) {
+			if (tp->snd_cwnd < tp->snd_cwnd_clamp)
+				tp->snd_cwnd++;
+			tp->snd_cwnd_cnt = 0;
+		}
+	} else {
+		if (tp->snd_cwnd < tp->snd_cwnd_clamp)
+			tp->snd_cwnd++;
+	}
+}
+EXPORT_SYMBOL_GPL(tcp_limited_slow_start);
+
 /*
  * TCP Reno congestion control
  * This is special case used for fallback as well.

--------------060105070006000608060402--
