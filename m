From: Andrey Vagin <avagin@openvz.org>
Subject: Re: [PATCH] net/unix: fix logic about sk_peek_offset
Date: Fri, 2 Oct 2015 12:04:39 +0300
Message-ID: <CANaxB-zvEL6WRNk2Ho7uJUVO8L=t_Nutp9Zxz=Do+Xp1JibHKw@mail.gmail.com>
References: <1443733536-992-1-git-send-email-avagin@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=047d7b3a84c61cd9c805211b74e4
Cc: Andrey Vagin <avagin@openvz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Aaron Conole <aconole@bytheb.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f196.google.com ([209.85.217.196]:35481 "EHLO
	mail-lb0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751823AbbJBJEl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 05:04:41 -0400
Received: by lbcao8 with SMTP id ao8so1943067lbc.2
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2015 02:04:39 -0700 (PDT)
In-Reply-To: <1443733536-992-1-git-send-email-avagin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--047d7b3a84c61cd9c805211b74e4
Content-Type: text/plain; charset=UTF-8

2015-10-02 0:05 GMT+03:00 Andrey Vagin <avagin@gmail.com>:
> From: Andrey Vagin <avagin@openvz.org>
>
> Now send with MSG_PEEK can return data from multiple SKBs.
>
> Unfortunately we take into account the peek offset for each skb,
> that is wrong. We need to apply the peek offset only once.
>
> In addition, the peek offset should be used only if MSG_PEEK is set.

The attached program can be used to reproduce the bug. It cycles in an
infinite loop without this patch, because recv() always returns data.

658   socketpair(PF_LOCAL, SOCK_STREAM, 0, [3, 4]) = 0
658   sendto(3, "Hello, World!", 13, MSG_DONTWAIT, NULL, 0) = 13
658   sendto(3, "Hello, World!", 13, MSG_DONTWAIT, NULL, 0) = 13
658   sendto(3, "Hello, World!", 13, MSG_DONTWAIT, NULL, 0) = 13
658   sendto(3, "Hello, World!", 13, MSG_DONTWAIT, NULL, 0) = 13
658   sendto(3, "Hello, World!", 13, MSG_DONTWAIT, NULL, 0) = 13
658   sendto(3, "Hello, World!", 13, MSG_DONTWAIT, NULL, 0) = 13
658   sendto(3, "Hello, World!", 13, MSG_DONTWAIT, NULL, 0) = 13
658   sendto(3, "Hello, World!", 13, MSG_DONTWAIT, NULL, 0) = 13
658   sendto(3, "Hello, World!", 13, MSG_DONTWAIT, NULL, 0) = 13
658   sendto(3, "Hello, World!", 13, MSG_DONTWAIT, NULL, 0) = 13
658   setsockopt(4, SOL_SOCKET, 0x2a /* SO_??? */, [0], 4) = 0
658   recvfrom(4, "Hello, World!H", 14, MSG_PEEK|MSG_DONTWAIT, NULL, NULL) = 14
658   fstat(1, {st_mode=S_IFCHR|0666, st_rdev=makedev(1, 3), ...}) = 0
658   ioctl(1, TCGETS, 0x7fff54e57b30)  = -1 ENOTTY (Inappropriate
ioctl for device)
658   mmap(NULL, 4096, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f3a86827000
658   recvfrom(4, "Hello, World!H", 14, MSG_PEEK|MSG_DONTWAIT, NULL, NULL) = 14
658   recvfrom(4, "Hello, World!H", 14, MSG_PEEK|MSG_DONTWAIT, NULL, NULL) = 14
658   recvfrom(4, "Hello, World!H", 14, MSG_PEEK|MSG_DONTWAIT, NULL, NULL) = 14
658   recvfrom(4, "Hello, World!H", 14, MSG_PEEK|MSG_DONTWAIT, NULL, NULL) = 14
658   recvfrom(4, "Hello, World!H", 14, MSG_PEEK|MSG_DONTWAIT, NULL, NULL) = 14
658   recvfrom(4, "Hello, World!H", 14, MSG_PEEK|MSG_DONTWAIT, NULL, NULL) = 14
658   recvfrom(4, "Hello, World!H", 14, MSG_PEEK|MSG_DONTWAIT, NULL, NULL) = 14
658   recvfrom(4, "Hello, World!H", 14, MSG_PEEK|MSG_DONTWAIT, NULL, NULL) = 14
658   recvfrom(4, "Hello, World!H", 14, MSG_PEEK|MSG_DONTWAIT, NULL, NULL) = 14
658   recvfrom(4, "Hello, World!H", 14, MSG_PEEK|MSG_DONTWAIT, NULL, NULL) = 14
658   recvfrom(4, "Hello, World!H", 14, MSG_PEEK|MSG_DONTWAIT, NULL, NULL) = 14
658   recvfrom(4, "Hello, World!H", 14, MSG_PEEK|MSG_DONTWAIT, NULL, NULL) = 14
658   recvfrom(4, "Hello, World!H", 14, MSG_PEEK|MSG_DONTWAIT, NULL, NULL) = 14
658   recvfrom(4, "Hello, World!H", 14, MSG_PEEK|MSG_DONTWAIT, NULL, NULL) = 14
658   recvfrom(4, "Hello, World!H", 14, MSG_PEEK|MSG_DONTWAIT, NULL, NULL) = 14
...

>
> Cc: "David S. Miller" <davem@davemloft.net> (maintainer:NETWORKING
> Cc: Eric Dumazet <edumazet@google.com> (commit_signer:1/14=7%)
> Cc: Aaron Conole <aconole@bytheb.org>
> Fixes: 9f389e35674f ("af_unix: return data from multiple SKBs on recv() with MSG_PEEK flag")
> Signed-off-by: Andrey Vagin <avagin@openvz.org>
> ---
>  net/unix/af_unix.c | 12 +++++++-----
>  1 file changed, 7 insertions(+), 5 deletions(-)
>
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index ef31b40..94f6582 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -2064,6 +2064,11 @@ static int unix_stream_read_generic(struct unix_stream_read_state *state)
>                 goto out;
>         }
>
> +       if (flags & MSG_PEEK)
> +               skip = sk_peek_offset(sk, flags);
> +       else
> +               skip = 0;
> +
>         do {
>                 int chunk;
>                 struct sk_buff *skb, *last;
> @@ -2112,7 +2117,6 @@ unlock:
>                         break;
>                 }
>
> -               skip = sk_peek_offset(sk, flags);
>                 while (skip >= unix_skb_len(skb)) {
>                         skip -= unix_skb_len(skb);
>                         last = skb;
> @@ -2179,14 +2183,12 @@ unlock:
>                         if (UNIXCB(skb).fp)
>                                 scm.fp = scm_fp_dup(UNIXCB(skb).fp);
>
> -                       if (skip) {
> -                               sk_peek_offset_fwd(sk, chunk);
> -                               skip -= chunk;
> -                       }
> +                       sk_peek_offset_fwd(sk, chunk);
>
>                         if (UNIXCB(skb).fp)
>                                 break;
>
> +                       skip = 0;
>                         last = skb;
>                         last_len = skb->len;
>                         unix_state_lock(sk);
> --
> 2.4.3
>

--047d7b3a84c61cd9c805211b74e4
Content-Type: text/x-csrc; charset=US-ASCII; name="test.c"
Content-Disposition: attachment; filename="test.c"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_if9eud1o0

I2luY2x1ZGUgPHN0ZGxpYi5oPgojaW5jbHVkZSA8c3RkaW8uaD4KI2luY2x1ZGUgPGVycm5vLmg+
CgojaW5jbHVkZSA8c3lzL3R5cGVzLmg+CiNpbmNsdWRlIDxzeXMvc29ja2V0Lmg+CgojZGVmaW5l
IFRFU1RfU1RSSU5HICJIZWxsbywgV29ybGQhIgoKaW50IG1haW4oKQp7CgljaGFyIGJ1ZlsxNV07
CglpbnQgc2tzWzJdOwoJaW50IGksIHNrLCByZXQ7CgoJaWYgKHNvY2tldHBhaXIoQUZfVU5JWCwg
U09DS19TVFJFQU0sIDAsIHNrcykpCgkJcmV0dXJuIDE7CgoJc2sgPSBza3NbMF07CgoJZm9yIChp
ID0gMDsgaSA8IDEwOyBpKyspIHsKCQlpZiAoc2VuZChzaywgVEVTVF9TVFJJTkcsIHNpemVvZihU
RVNUX1NUUklORykgLSAxLCBNU0dfRE9OVFdBSVQpIDwgMCkKCQkJcmV0dXJuIDE7Cgl9CgoJc2sg
PSBza3NbMV07CgoJcmV0ID0gMDsKCWlmIChzZXRzb2Nrb3B0KHNrLCBTT0xfU09DS0VULCBTT19Q
RUVLX09GRiwgJnJldCwgc2l6ZW9mKGludCkpKQoJCXJldHVybiAxOwoKCXdoaWxlICgxKSB7CgkJ
aW50IHJldDsKCQlyZXQgPSByZWN2KHNrLCBidWYsIHNpemVvZihidWYpIC0gMSwgTVNHX0RPTlRX
QUlUIHwgTVNHX1BFRUspOwoJCWlmIChyZXQgPCAwKSB7CgkJCWlmIChlcnJubyA9PSBFQUdBSU4p
CgkJCQlicmVhazsKCQkJcmV0dXJuIDE7CgkJfQoJCWlmIChyZXQgPT0gMCkKCQkJYnJlYWs7CgkJ
YnVmW3JldF0gPSAwOwoJCXByaW50ZigibXNnOiAlc1xuIiwgYnVmKTsKCX0KCglyZXR1cm4gMDsK
fQo=
--047d7b3a84c61cd9c805211b74e4--
