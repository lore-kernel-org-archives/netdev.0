From: =?gb2312?B?0c+6o8ur?= <yanhaishuang@cmss.chinamobile.com>
Subject: Re: [PATCH v4 2/3] ipv4: Namespaceify tcp_fastopen_key knob
Date: Tue, 26 Sep 2017 09:25:51 +0800
Message-ID: <F9EA5C4F-2306-4BC5-923A-3AB1D8F50FF1@cmss.chinamobile.com>
References: <1506088124-12650-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
 <1506088124-12650-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
 <20170925.162445.234890912211240693.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=gb2312
Content-Transfer-Encoding: 8BIT
Cc: kuznet@ms2.inr.ac.ru, edumazet@google.com, weiwan@google.com,
        lucab@debian.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170925.162445.234890912211240693.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> On 2017年9月26日, at 上午7:24, David Miller <davem@davemloft.net> wrote:
> 
> From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
> Date: Fri, 22 Sep 2017 21:48:43 +0800
> 
>> @@ -9,13 +9,18 @@
>> #include <net/inetpeer.h>
>> #include <net/tcp.h>
>> 
>> -struct tcp_fastopen_context __rcu *tcp_fastopen_ctx;
>> -
>> -static DEFINE_SPINLOCK(tcp_fastopen_ctx_lock);
>> -
>> -void tcp_fastopen_init_key_once(bool publish)
>> +void tcp_fastopen_init_key_once(struct net *net)
> 
> Why did you remove the 'publish' logic from this function?
> 

I think this logic is not necessary now, in proc_tcp_fastopen_key, I have removed 
tcp_fastopen_init_key_once(false) where the ‘publish’ is false:

-		/* Generate a dummy secret but don't publish it. This
-		 * is needed so we don't regenerate a new key on the
-		 * first invocation of tcp_fastopen_cookie_gen
-		 */
-		tcp_fastopen_init_key_once(false);
-		tcp_fastopen_reset_cipher(user_key, TCP_FASTOPEN_KEY_LENGTH);
+		tcp_fastopen_reset_cipher(net, user_key, TCP_FASTOPEN_KEY_LENGTH);

It said we don't regenerate a new key on first invocation of tcp_fastopen_cookie_gen, 
but in tcp_fastopen_cookie_gen，it didn’t  call tcp_fastopen_init_key_once since
from commit dfea2aa654243 (tcp: Do not call tcp_fastopen_reset_cipher from interrupt context)：

And in other places where call tcp_fastopen_init_key_once, the ‘publish’ is always true:

--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -222,7 +222,7 @@ int inet_listen(struct socket *sock, int backlog)
		    (tcp_fastopen & TFO_SERVER_ENABLE) &&
		    !inet_csk(sk)->icsk_accept_queue.fastopenq.max_qlen) {
			fastopen_queue_tune(sk, backlog);
-			tcp_fastopen_init_key_once(true);
+			tcp_fastopen_init_key_once(sock_net(sk));
		}

--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2749,7 +2749,7 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
	case TCP_FASTOPEN:
		if (val >= 0 && ((1 << sk->sk_state) & (TCPF_CLOSE |
		    TCPF_LISTEN))) {
-			tcp_fastopen_init_key_once(true);
+			tcp_fastopen_init_key_once(net);

			fastopen_queue_tune(sk, val);
		} else {


So I deleted ‘publish’ logic to ensure it was always true.
