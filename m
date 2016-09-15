From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v3] net: ip, diag -- Add diag interface for raw sockets
Date: Thu, 15 Sep 2016 14:39:40 -0600
Message-ID: <9caf84ac-a42e-1723-f7fe-c0857eec3402@cumulusnetworks.com>
References: <20160913171950.GC32643@uranus>
 <8260ff1f-6907-aed8-caae-68d63a4ad529@cumulusnetworks.com>
 <20160915202219.GB1867@uranus.lan>
 <cc67e1b1-ad0c-f0f6-4b4d-2eab80e940da@cumulusnetworks.com>
 <1473971768.22679.53.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, avagin@openvz.org, stephen@networkplumber.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35552 "EHLO
        mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754485AbcIOUjn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 16:39:43 -0400
Received: by mail-pa0-f46.google.com with SMTP id oz2so14577644pac.2
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 13:39:43 -0700 (PDT)
In-Reply-To: <1473971768.22679.53.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/15/16 2:36 PM, Eric Dumazet wrote:
> On Thu, 2016-09-15 at 14:25 -0600, David Ahern wrote:
>> On 9/15/16 2:22 PM, Cyrill Gorcunov wrote:
>>>> ss -K is not working. Socket lookup fails to find a match due to a protocol mismatch.
>>>>
>>>> haven't had time to track down why there is a mismatch since the kill uses the socket returned
>>>> from the dump. Won't have time to come back to this until early next week.
>>>
>>> Have you ran iproute2 patched? I just ran ss -K and all sockets get closed
>>> (including raw ones), which actually kicked me off the testing machine sshd :/
>>
>> yes.
>>
> 
> And CONFIG_INET_DIAG_DESTROY is also set in your .config ?
yes

dsa@kenny:~/kernel.git$ grep INET_DIAG_DESTROY kbuild/perf/.config
CONFIG_INET_DIAG_DESTROY=y

raw_diag_destroy is getting called, but protocol is 255:

diff --git a/net/ipv4/raw_diag.c b/net/ipv4/raw_diag.c
index c730e14618ab..95542b3dad76 100644
--- a/net/ipv4/raw_diag.c
+++ b/net/ipv4/raw_diag.c
@@ -192,6 +192,11 @@ static int raw_diag_destroy(struct sk_buff *in_skb,
        struct sock *sk;

        sk = raw_sock_get(net, r);
+
+if (r->sdiag_family == AF_INET)
+pr_warn("raw_diag_destroy: family IPv4 protocol %d dst %pI4 src %pI4 dev %d sk %p\n",
+        r->sdiag_protocol, &r->id.idiag_dst[0], &r->id.idiag_src[0], r->id.idiag_if, sk);
+
        if (IS_ERR(sk))
                return PTR_ERR(sk);
        return sock_diag_destroy(sk, ECONNABORTED);



so it never finds a match to an actual raw socket:

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 03618ed03532..6d0489629e74 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -124,9 +124,14 @@ EXPORT_SYMBOL_GPL(raw_unhash_sk);
 struct sock *__raw_v4_lookup(struct net *net, struct sock *sk,
                unsigned short num, __be32 raddr, __be32 laddr, int dif)
 {
+pr_warn("num %d raddr %pI4 laddr %pI4 dif %d\n", num, &raddr, &laddr, dif);
+
        sk_for_each_from(sk) {
                struct inet_sock *inet = inet_sk(sk);

+pr_warn("sk: num %d raddr %pI4 laddr %pI4 dif %d\n",
+       inet->inet_num, &inet->inet_daddr, &inet->inet_rcv_saddr,sk->sk_bound_dev_if);
+
                if (net_eq(sock_net(sk), net) && inet->inet_num == num  &&
                    !(inet->inet_daddr && inet->inet_daddr != raddr)    &&
                    !(inet->inet_rcv_saddr && inet->inet_rcv_saddr != laddr) &&

so raw_abort is not called.
