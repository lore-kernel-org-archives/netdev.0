From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] inet_diag: report TCP MD5 signing keys and
 addresses
Date: Wed, 23 Aug 2017 20:20:22 -0700
Message-ID: <1503544822.2499.73.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170824012210.m3b2hsll4avrr42i@ycc.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ivan Delalande <colona@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34124 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750715AbdHXDUZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 23:20:25 -0400
Received: by mail-pg0-f67.google.com with SMTP id p14so1911275pgd.1
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 20:20:25 -0700 (PDT)
In-Reply-To: <20170824012210.m3b2hsll4avrr42i@ycc.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-08-24 at 03:22 +0200, Ivan Delalande wrote:
> Report TCP MD5 (RFC2385) signing keys, addresses and address prefixes to
> processes with CAP_NET_ADMIN requesting INET_DIAG_INFO. Currently it is
> not possible to retrieve these from the kernel once they have been
> configured on sockets.

I really find that all these changes in net/ipv4/inet_diag.c
for TCP stuff (and #ifdef CONFIG_TCP_MD5SIG all over the places) are
ugly.

Also, since you do not lock the socket, inet_diag_put_md5sig()
might see different lists (&md5sig->head) and you could either write non
reserved memory, or at the contrary report not initialized kernel data
to user.

+static int inet_diag_put_md5sig(struct sk_buff *skb,
+                               const struct tcp_md5sig_info *md5sig)
+{
+       const struct tcp_md5sig_key *key;
+       struct nlattr *attr;
+       struct tcp_md5sig *info = NULL;
+       int md5sig_count = 0;
+
+       hlist_for_each_entry_rcu(key, &md5sig->head, node)
+               md5sig_count++;
+
+       attr = nla_reserve(skb, INET_DIAG_MD5SIG,
+                          md5sig_count * sizeof(struct tcp_md5sig));
+       if (!attr)
+               return -EMSGSIZE;
+
+       info = nla_data(attr);
+       hlist_for_each_entry_rcu(key, &md5sig->head, node) {
+               inet_diag_md5sig_fill(info, key);
+               info++;

Here we might see different keys than computed (in md5sig_count)

+       }
+
+       return 0;
+}
+#endif
+
