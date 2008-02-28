From: Nebojsa Miljanovic <neb@alcatel-lucent.com>
Subject: SO_REUSEADDR not allowing server and client to use same port
Date: Thu, 28 Feb 2008 13:00:43 -0600
Message-ID: <47C704DB.2090101@alcatel-lucent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Kittlitz, Edward (Ned)" <nkittlitz@alcatel-lucent.com>,
	"Sweeney, Andrew (Andrew)" <asweeney@alcatel-lucent.com>,
	"Polhemus, William (Bart)" <bpolhemus@alcatel-lucent.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ihemail4.lucent.com ([135.245.0.39]:35669 "EHLO
	ihemail4.lucent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751600AbYB1TOy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2008 14:14:54 -0500
Received: from ihmail.ih.lucent.com (h135-1-218-70.lucent.com [135.1.218.70])
	by ihemail4.lucent.com (8.13.8/IER-o) with ESMTP id m1SJ0ix7017115
	for <netdev@vger.kernel.org>; Thu, 28 Feb 2008 13:00:44 -0600 (CST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,
I have seen similar complaints about this issue before in the list archive, but
I have not seen any resolution. So, I am posting the question again in hope of
getting some replies.

Currently, Linux does not allow reuse of same local port for both TCP server and
TCP client. I understand that there may be a need to prevent two servers from
binding to the same local port, but having 1 server and 1 outgoing client use it
should be allowed. Other Unix like operating systems do allow it. Further more,
Linux SCTP socket API allows for this to happen. And, I can't imagine why this
restriction would exists for TCP and not for SCTP.

This issue is caused by tcp_v4_get_port() function (same check is in IPV6
version of this function). It does does not allow for "tb->fastreuse" bit to be
set when passed socket is in listening state. Suggested code change below would
allow for port reuse by a single listening socket and multiple client sockets.

[neb@mvista ipv4]$ cvs diff -u20 -p -w -b tcp_ipv4.c
Index: tcp_ipv4.c
===================================================================
RCS file:
/cvs/cvsroot/Repository/TelicaRoot/components/mvlinux/cge/devkit/lsp/7xx/linux/net/ipv4/tcp_ipv4.c,v
retrieving revision 1.1.1.2
diff -u -2 -0 -p -w -b -r1.1.1.2 tcp_ipv4.c
--- tcp_ipv4.c  27 Apr 2007 12:34:39 -0000      1.1.1.2
+++ tcp_ipv4.c  28 Feb 2008 18:10:16 -0000
@@ -258,46 +258,54 @@ static int tcp_v4_get_port(struct sock *
        tb = NULL;
        goto tb_not_found;
 tb_found:
        if (!hlist_empty(&tb->owners)) {
                if (sk->sk_reuse > 1)
                        goto success;
                if (tb->fastreuse > 0 &&
                    sk->sk_reuse && sk->sk_state != TCP_LISTEN) {
                        goto success;
                } else {
                        ret = 1;
                        if (tcp_bind_conflict(sk, tb))
                                goto fail_unlock;
                }
        }
 tb_not_found:
        ret = 1;
        if (!tb && (tb = tcp_bucket_create(head, snum)) == NULL)
                goto fail_unlock;
        if (hlist_empty(&tb->owners)) {
+#if 1 /* Do not check for TCP_LISTEN state */
+               if (sk->sk_reuse)
+#else
                if (sk->sk_reuse && sk->sk_state != TCP_LISTEN)
+#endif
                        tb->fastreuse = 1;
                else
                        tb->fastreuse = 0;
        } else if (tb->fastreuse &&
+#if 1 /* Do not check for TCP_LISTEN state */
+                  (!sk->sk_reuse))
+#else
                   (!sk->sk_reuse || sk->sk_state == TCP_LISTEN))
+#endif
                tb->fastreuse = 0;
 success:
        if (!tcp_sk(sk)->bind_hash)
                tcp_bind_hash(sk, tb, snum);
        BUG_TRAP(tcp_sk(sk)->bind_hash == tb);
        ret = 0;

 fail_unlock:
        spin_unlock(&head->lock);
 fail:
        local_bh_enable();
        return ret;
 }


Thanks,
Neb Miljanovic

Alcatel-Lucent


