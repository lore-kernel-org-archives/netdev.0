From: Andrew Morton <akpm@osdl.org>
Subject: Re: [IPV6] fix inet6_sk for non IPV6 builds
Date: Thu, 30 Dec 2004 00:21:15 -0800
Message-ID: <20041230002115.67c0dbbf.akpm@osdl.org>
References: <41D3306F.7080605@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com,
        James.Bottomley@HansenPartnership.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <41D3306F.7080605@conectiva.com.br>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Arnaldo Carvalho de Melo <acme@conectiva.com.br> wrote:
>
> 	Please apply this patch, the problem was noted by James Bottomley, that
>  doesn't enables CONFIG_IPV6.
> 
>  Signed-off-by: Arnaldo Carvalho de Melo
> 
>  - Arnaldo
> 
> 
> [inet6_sk.patch  text/plain (787 bytes)]
>  ===== include/linux/ipv6.h 1.23 vs edited =====
>  --- 1.23/include/linux/ipv6.h	2004-12-27 23:56:33 -02:00
>  +++ edited/include/linux/ipv6.h	2004-12-29 20:22:45 -02:00
>  @@ -273,6 +273,7 @@
>   	struct ipv6_pinfo inet6;
>   };
>   
>  +#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
>   static inline struct ipv6_pinfo * inet6_sk(const struct sock *__sk)
>   {
>   	return inet_sk(__sk)->pinet6;
>  @@ -283,7 +284,6 @@
>   	return &((struct raw6_sock *)__sk)->raw6;
>   }
>   
>  -#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
>   #define __ipv6_only_sock(sk)	(inet6_sk(sk)->ipv6only)
>   #define ipv6_only_sock(sk)	((sk)->sk_family == PF_INET6 && __ipv6_only_sock(sk))
>   #else

This breaks selinux:

security/selinux/avc.c: In function `avc_audit':
security/selinux/avc.c:640: warning: implicit declaration of function `inet6_sk'
security/selinux/avc.c:640: warning: initialization makes pointer from integer w

This is hastily tested:

--- 25/include/linux/ipv6.h~fix-inet6_sk-for-non-ipv6-builds	2004-12-30 00:19:06.550680488 -0800
+++ 25-akpm/include/linux/ipv6.h	2004-12-30 00:20:30.386935440 -0800
@@ -273,6 +273,7 @@ struct tcp6_sock {
 	struct ipv6_pinfo inet6;
 };
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 static inline struct ipv6_pinfo * inet6_sk(const struct sock *__sk)
 {
 	return inet_sk(__sk)->pinet6;
@@ -283,10 +284,20 @@ static inline struct raw6_opt * raw6_sk(
 	return &((struct raw6_sock *)__sk)->raw6;
 }
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 #define __ipv6_only_sock(sk)	(inet6_sk(sk)->ipv6only)
 #define ipv6_only_sock(sk)	((sk)->sk_family == PF_INET6 && __ipv6_only_sock(sk))
 #else
+
+static inline struct ipv6_pinfo * inet6_sk(const struct sock *__sk)
+{
+	return NULL;
+}
+
+static inline struct raw6_opt * raw6_sk(const struct sock *__sk)
+{
+	return NULL;
+}
+
 #define __ipv6_only_sock(sk)	0
 #define ipv6_only_sock(sk)	0
 #endif
_
