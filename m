From: Andrey Ulanov <andreyu@google.com>
Subject: [PATCH] net: unix: properly re-increment inflight counter of GC discarded candidates
Date: Tue, 14 Mar 2017 20:16:42 -0700
Message-ID: <20170315031642.19576-1-andreyu@google.com>
Content-Type: multipart/signed; protocol="application/pkcs7-signature"; micalg=sha-256;
        boundary="94eb2c0ae5f48706c4054abc61b8"
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, andreyu@google.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:35247 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750774AbdCODRP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 23:17:15 -0400
Received: by mail-pg0-f43.google.com with SMTP id b129so2685087pgc.2
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 20:17:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--94eb2c0ae5f48706c4054abc61b8

Dmitry has reported that a BUG_ON() condition in unix_notinflight()
may be triggered by a simple code that forwards unix socket in an
SCM_RIGHTS message.
That is caused by incorrect unix socket GC implementation in unix_gc().

The GC first collects list of candidates, then (a) decrements their
"children's" inflight counter, (b) checks which inflight counters are
now 0, and then (c) increments all inflight counters back.
(a) and (c) are done by calling scan_children() with inc_inflight or
dec_inflight as the second argument.

Commit 6209344f5a37 ("net: unix: fix inflight counting bug in garbage
collector") changed scan_children() such that it no longer considers
sockets that do not have UNIX_GC_CANDIDATE flag. It also added a block
of code that that unsets this flag _before_ invoking
scan_children(, dec_iflight, ). This may lead to incorrect inflight
counters for some sockets.

This change fixes this bug by changing order of operations:
UNIX_GC_CANDIDATE is now unset only after all inflight counters are
restored to the original state.

  kernel BUG at net/unix/garbage.c:149!
  RIP: 0010:[<ffffffff8717ebf4>]  [<ffffffff8717ebf4>]
  unix_notinflight+0x3b4/0x490 net/unix/garbage.c:149
  Call Trace:
   [<ffffffff8716cfbf>] unix_detach_fds.isra.19+0xff/0x170 net/unix/af_unix.c:1487
   [<ffffffff8716f6a9>] unix_destruct_scm+0xf9/0x210 net/unix/af_unix.c:1496
   [<ffffffff86a90a01>] skb_release_head_state+0x101/0x200 net/core/skbuff.c:655
   [<ffffffff86a9808a>] skb_release_all+0x1a/0x60 net/core/skbuff.c:668
   [<ffffffff86a980ea>] __kfree_skb+0x1a/0x30 net/core/skbuff.c:684
   [<ffffffff86a98284>] kfree_skb+0x184/0x570 net/core/skbuff.c:705
   [<ffffffff871789d5>] unix_release_sock+0x5b5/0xbd0 net/unix/af_unix.c:559
   [<ffffffff87179039>] unix_release+0x49/0x90 net/unix/af_unix.c:836
   [<ffffffff86a694b2>] sock_release+0x92/0x1f0 net/socket.c:570
   [<ffffffff86a6962b>] sock_close+0x1b/0x20 net/socket.c:1017
   [<ffffffff81a76b8e>] __fput+0x34e/0x910 fs/file_table.c:208
   [<ffffffff81a771da>] ____fput+0x1a/0x20 fs/file_table.c:244
   [<ffffffff81483ab0>] task_work_run+0x1a0/0x280 kernel/task_work.c:116
   [<     inline     >] exit_task_work include/linux/task_work.h:21
   [<ffffffff8141287a>] do_exit+0x183a/0x2640 kernel/exit.c:828
   [<ffffffff8141383e>] do_group_exit+0x14e/0x420 kernel/exit.c:931
   [<ffffffff814429d3>] get_signal+0x663/0x1880 kernel/signal.c:2307
   [<ffffffff81239b45>] do_signal+0xc5/0x2190 arch/x86/kernel/signal.c:807
   [<ffffffff8100666a>] exit_to_usermode_loop+0x1ea/0x2d0
  arch/x86/entry/common.c:156
   [<     inline     >] prepare_exit_to_usermode arch/x86/entry/common.c:190
   [<ffffffff81009693>] syscall_return_slowpath+0x4d3/0x570
  arch/x86/entry/common.c:259
   [<ffffffff881478e6>] entry_SYSCALL_64_fastpath+0xc4/0xc6

Link: https://lkml.org/lkml/2017/3/6/252
Signed-off-by: Andrey Ulanov <andreyu@google.com>
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Fixes: 6209344 ("net: unix: fix inflight counting bug in garbage collector")
---
 net/unix/garbage.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/net/unix/garbage.c b/net/unix/garbage.c
index 6a0d48525fcf..c36757e72844 100644
--- a/net/unix/garbage.c
+++ b/net/unix/garbage.c
@@ -146,6 +146,7 @@ void unix_notinflight(struct user_struct *user, struct file *fp)
 	if (s) {
 		struct unix_sock *u = unix_sk(s);
 
+		BUG_ON(!atomic_long_read(&u->inflight));
 		BUG_ON(list_empty(&u->link));
 
 		if (atomic_long_dec_and_test(&u->inflight))
@@ -341,6 +342,14 @@ void unix_gc(void)
 	}
 	list_del(&cursor);
 
+	/* Now gc_candidates contains only garbage.  Restore original
+	 * inflight counters for these as well, and remove the skbuffs
+	 * which are creating the cycle(s).
+	 */
+	skb_queue_head_init(&hitlist);
+	list_for_each_entry(u, &gc_candidates, link)
+		scan_children(&u->sk, inc_inflight, &hitlist);
+
 	/* not_cycle_list contains those sockets which do not make up a
 	 * cycle.  Restore these to the inflight list.
 	 */
@@ -350,14 +359,6 @@ void unix_gc(void)
 		list_move_tail(&u->link, &gc_inflight_list);
 	}
 
-	/* Now gc_candidates contains only garbage.  Restore original
-	 * inflight counters for these as well, and remove the skbuffs
-	 * which are creating the cycle(s).
-	 */
-	skb_queue_head_init(&hitlist);
-	list_for_each_entry(u, &gc_candidates, link)
-	scan_children(&u->sk, inc_inflight, &hitlist);
-
 	spin_unlock(&unix_gc_lock);
 
 	/* Here we are. Hitlist is filled. Die. */
-- 
2.12.0.367.g23dc2f6d3c-goog


--94eb2c0ae5f48706c4054abc61b8
Content-Type: application/pkcs7-signature; name="smime.p7s"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"
Content-Description: S/MIME Cryptographic Signature

MIIS6QYJKoZIhvcNAQcCoIIS2jCCEtYCAQExDzANBglghkgBZQMEAgEFADALBgkqhkiG9w0BBwGg
ghBPMIIEXDCCA0SgAwIBAgIOSBtqDm4P/739RPqw/wcwDQYJKoZIhvcNAQELBQAwZDELMAkGA1UE
BhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExOjA4BgNVBAMTMUdsb2JhbFNpZ24gUGVy
c29uYWxTaWduIFBhcnRuZXJzIENBIC0gU0hBMjU2IC0gRzIwHhcNMTYwNjE1MDAwMDAwWhcNMjEw
NjE1MDAwMDAwWjBMMQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFsU2lnbiBudi1zYTEiMCAG
A1UEAxMZR2xvYmFsU2lnbiBIViBTL01JTUUgQ0EgMTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCC
AQoCggEBALR23lKtjlZW/17kthzYcMHHKFgywfc4vLIjfq42NmMWbXkNUabIgS8KX4PnIFsTlD6F
GO2fqnsTygvYPFBSMX4OCFtJXoikP2CQlEvO7WooyE94tqmqD+w0YtyP2IB5j4KvOIeNv1Gbnnes
BIUWLFxs1ERvYDhmk+OrvW7Vd8ZfpRJj71Rb+QQsUpkyTySaqALXnyztTDp1L5d1bABJN/bJbEU3
Hf5FLrANmognIu+Npty6GrA6p3yKELzTsilOFmYNWg7L838NS2JbFOndl+ce89gM36CW7vyhszi6
6LqqzJL8MsmkP53GGhf11YMP9EkmawYouMDP/PwQYhIiUO0CAwEAAaOCASIwggEeMA4GA1UdDwEB
/wQEAwIBBjAdBgNVHSUEFjAUBggrBgEFBQcDAgYIKwYBBQUHAwQwEgYDVR0TAQH/BAgwBgEB/wIB
ADAdBgNVHQ4EFgQUyzgSsMeZwHiSjLMhleb0JmLA4D8wHwYDVR0jBBgwFoAUJiSSix/TRK+xsBtt
r+500ox4AAMwSwYDVR0fBEQwQjBAoD6gPIY6aHR0cDovL2NybC5nbG9iYWxzaWduLmNvbS9ncy9n
c3BlcnNvbmFsc2lnbnB0bnJzc2hhMmcyLmNybDBMBgNVHSAERTBDMEEGCSsGAQQBoDIBKDA0MDIG
CCsGAQUFBwIBFiZodHRwczovL3d3dy5nbG9iYWxzaWduLmNvbS9yZXBvc2l0b3J5LzANBgkqhkiG
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
BgEFBQcwAoY0aHR0cDovL3NlY3VyZS5nbG9iYWxzaWduLmNvbS9jYWNlcnQvZ3NodnNtaW1lY2Ex
LmNydDAdBgNVHQ4EFgQUQu+kQ6KFWZq3CE20ivdO98ph7wQwHwYDVR0jBBgwFoAUyzgSsMeZwHiS
jLMhleb0JmLA4D8wTAYDVR0gBEUwQzBBBgkrBgEEAaAyASgwNDAyBggrBgEFBQcCARYmaHR0cHM6
Ly93d3cuZ2xvYmFsc2lnbi5jb20vcmVwb3NpdG9yeS8wOwYDVR0fBDQwMjAwoC6gLIYqaHR0cDov
L2NybC5nbG9iYWxzaWduLmNvbS9nc2h2c21pbWVjYTEuY3JsMA4GA1UdDwEB/wQEAwIFoDAdBgNV
HSUEFjAUBggrBgEFBQcDAgYIKwYBBQUHAwQwDQYJKoZIhvcNAQELBQADggEBAF3iGtc++nw6rd/r
A0BIpljw1mIT3fR9FP2qDxipm1fLH8yOE4y1HtU3KBk6fGdMT/feRD3GYqCTgGFCltis/wC78Jak
PCjByCB+TG9SyjTdRZrFnI9bInGOInl46U7CuRYgCXPzYkOGfUo0kzMW9SKDOLm952U0uJEHYi24
x3C70bylqsuEBmRVdYTLzp0ezIio8gCGhJsuxooq+DmKqC5OKAD5tGBlC6HsNW2zXx72zheS4wim
Cxr+7qX8rFOz9XX+XmftOLxr6negJ22+VC3Lex4TduMKH487FL5CxMG0FAdtVh6enEzdsyGHOPb5
Z9/lEqnln8kUZ33Sh2F71UMxggJeMIICWgIBATBcMEwxCzAJBgNVBAYTAkJFMRkwFwYDVQQKExBH
bG9iYWxTaWduIG52LXNhMSIwIAYDVQQDExlHbG9iYWxTaWduIEhWIFMvTUlNRSBDQSAxAgwDYq0y
y5NLJ4AGHJowDQYJYIZIAWUDBAIBBQCggdQwLwYJKoZIhvcNAQkEMSIEIH9WmKD736hPdYStCzUA
P1TE9PCkQmwU6htboLEGEGNvMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkF
MQ8XDTE3MDMxNTAzMTcxNFowaQYJKoZIhvcNAQkPMVwwWjALBglghkgBZQMEASowCwYJYIZIAWUD
BAEWMAsGCWCGSAFlAwQBAjAKBggqhkiG9w0DBzALBgkqhkiG9w0BAQowCwYJKoZIhvcNAQEHMAsG
CWCGSAFlAwQCATANBgkqhkiG9w0BAQEFAASCAQBx5nzRq2mARVK55WxJoJ1N9KpR1VjqbE8J6v8o
wUBzKO9SCbnKyl3yKTpEFjSqCbX3hBpN4kceQVxEunsCm3UhCkLvzSed9Yz2255b9GcqPdItS6Zf
3ZVk+xXYiYREv3nwvEquLWGRuViifjojWsAVitRdxBQ5hGmmGgKTioEv0vz2rH7SVj6TiibXPqPi
If590JDe3ktzkDIlk/KX2FHSj0yQcEhfSGQJ28ghLXGOy2oKNHh44dldvU9/U2G+bF1rTD+FruUJ
BrIdehzAp/6czzebbjThlLIPQRp1NjEEeeyqZpO5xEffH66hOrBAplKoEHN+s6Q2axK+qA2sV/xz
--94eb2c0ae5f48706c4054abc61b8--
