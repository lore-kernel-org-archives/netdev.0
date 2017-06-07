From: David Ahern <dsahern@gmail.com>
Subject: Re: Repeatable inet6_dump_fib crash in stock 4.12.0-rc4+
Date: Tue, 6 Jun 2017 18:00:04 -0600
Message-ID: <a5733c67-e3a3-9cc0-0862-40ef6fc03de3@gmail.com>
References: <bbfa5208-3a04-c87a-a6e1-ee0ae73965d0@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Ben Greear <greearb@candelatech.com>,
        netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34447 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750766AbdFGAAH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 20:00:07 -0400
Received: by mail-pf0-f193.google.com with SMTP id u1so832955pfg.1
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 17:00:07 -0700 (PDT)
In-Reply-To: <bbfa5208-3a04-c87a-a6e1-ee0ae73965d0@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/6/17 3:06 PM, Ben Greear wrote:
> This bug has been around forever, and we recently got an intern and
> stuck him with
> trying to reproduce it on the latest kernel.  It is still here.  I'm not
> super excited
> about trying to fix this, but we can easily test patches if someone has a
> patch to try.

Can you try this (whitespace damaged on paste, but it is moving the lock
ahead of the fn_sernum check):

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index deea901746c8..7a44c49055c0 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -378,6 +378,7 @@ static int fib6_dump_table(struct fib6_table *table,
struct sk_buff *skb,
                        cb->args[5] = w->root->fn_sernum;
                }
        } else {
+               read_lock_bh(&table->tb6_lock);
                if (cb->args[5] != w->root->fn_sernum) {
                        /* Begin at the root if the tree changed */
                        cb->args[5] = w->root->fn_sernum;
@@ -387,7 +388,6 @@ static int fib6_dump_table(struct fib6_table *table,
struct sk_buff *skb,
                } else
                        w->skip = 0;

-               read_lock_bh(&table->tb6_lock);
                res = fib6_walk_continue(w);
                read_unlock_bh(&table->tb6_lock);
                if (res <= 0) {
