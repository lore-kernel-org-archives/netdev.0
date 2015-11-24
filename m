From: Eric Dumazet <edumazet@google.com>
Subject: Re: use-after-free in sock_wake_async
Date: Tue, 24 Nov 2015 14:12:35 -0800
Message-ID: <CANn89iK9PHPUMwYf=ns=mW2yigx56jQtOOhOzKihMr5RCZ0hRw@mail.gmail.com>
References: <CACT4Y+ZZQ0ooT9LekV35u_jUAtAHJfg5O5SD=xATfHUF5UdNBQ@mail.gmail.com>
	<CANn89i+Uw+YzhRbQVSyf=FAQBO06JfFoxQpSHxfmDpS5_iZBQw@mail.gmail.com>
	<5654D6D9.1050108@akamai.com>
	<20151124214512.GM27046@kvack.org>
	<CANn89iK=whv2XgeECNyvqn56dt7Apqhc=Mk2UwF8KtSF_jOG1g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jason Baron <jbaron@akamai.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	David Howells <dhowells@redhat.com>,
	Ying Xue <ying.xue@windriver.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:35673 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754601AbbKXWMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 17:12:37 -0500
Received: by wmuu63 with SMTP id u63so115279438wmu.0
        for <netdev@vger.kernel.org>; Tue, 24 Nov 2015 14:12:36 -0800 (PST)
In-Reply-To: <CANn89iK=whv2XgeECNyvqn56dt7Apqhc=Mk2UwF8KtSF_jOG1g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 24, 2015 at 2:03 PM, Eric Dumazet <edumazet@google.com> wrote:

>
> This might be a data race in sk_wake_async() if inlined by compiler
> (see https://lkml.org/lkml/2015/11/24/680 for another example)
>
> KASAN adds register pressure and compiler can then do 'stupid' things :(
>
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 7f89e4ba18d1..2af6222ccc67 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -2008,7 +2008,7 @@ static inline unsigned long sock_wspace(struct sock *sk)
>  static inline void sk_wake_async(struct sock *sk, int how, int band)
>  {
>         if (sock_flag(sk, SOCK_FASYNC))
> -               sock_wake_async(sk->sk_socket, how, band);
> +               sock_wake_async(READ_ONCE(sk->sk_socket), how, band);
>  }
>
>  /* Since sk_{r,w}mem_alloc sums skb->truesize, even a small frame might

Oh well, sock_wake_async() can not be inlined, scratch this.
