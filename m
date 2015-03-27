From: Cong Wang <cwang@twopensource.com>
Subject: Re: [net-next PATCH 1/2] fib_trie: Fix warning on fib4_rules_exit
Date: Fri, 27 Mar 2015 15:14:24 -0700
Message-ID: <CAHA+R7McwZQ5PCWFvUh-wrktg3AP0tu7arkcp=+SFmiD5apRBQ@mail.gmail.com>
References: <20150327211416.2465.23170.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	David Miller <davem@davemloft.net>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:37739 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752310AbbC0WOZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2015 18:14:25 -0400
Received: by igcxg11 with SMTP id xg11so32229301igc.0
        for <netdev@vger.kernel.org>; Fri, 27 Mar 2015 15:14:24 -0700 (PDT)
In-Reply-To: <20150327211416.2465.23170.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 27, 2015 at 2:14 PM, Alexander Duyck
<alexander.h.duyck@redhat.com> wrote:
>
> The issue was that as a part of exiting the default rules were being
> deleted which resulted in the local trie being unmerged.  By moving the
> freeing of the FIB tables up we can avoid the unmerge since there is no
> local table left when we call the fib4_rules_exit function.
>

This literally means we no longer need to call ops->delete()
in netns unregister path.

diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 68ea695..27b6e04 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -153,8 +153,6 @@ static void fib_rules_cleanup_ops(struct fib_rules_ops *ops)

        list_for_each_entry_safe(rule, tmp, &ops->rules_list, list) {
                list_del_rcu(&rule->list);
-               if (ops->delete)
-                       ops->delete(rule);
                fib_rule_put(rule);
        }
 }
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index e5b6b05..1481b23 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -1178,6 +1178,7 @@ static void ip_fib_net_exit(struct net *net)

 #ifdef CONFIG_IP_MULTIPLE_TABLES
        fib4_rules_exit(net);
+       fib_flush_external(net); // <-------- Maybe not needed either.
 #endif

        for (i = 0; i < FIB_TABLE_HASHSZ; i++) {
