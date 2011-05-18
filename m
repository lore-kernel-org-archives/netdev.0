From: Jacek Luczak <difrost.kernel@gmail.com>
Subject: PATCH] SCTP: fix race between sctp_bind_addr_free() and sctp_bind_addr_conflict()
Date: Wed, 18 May 2011 16:36:32 +0200
Message-ID: <BANLkTimWpmFj1gx=XvvoXFVxL9q927iWfw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=bcaec520e99ba004e304a38dd0c2
Cc: Vladislav Yasevich <vladislav.yasevich@hp.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:45039 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757184Ab1EROgd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 10:36:33 -0400
Received: by pwi15 with SMTP id 15so772845pwi.19
        for <netdev@vger.kernel.org>; Wed, 18 May 2011 07:36:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--bcaec520e99ba004e304a38dd0c2
Content-Type: text/plain; charset=ISO-8859-1

During the sctp_close() call, we do not use rcu primitives to
destroy the address list attached to the endpoint.  At the same
time, we do the removal of addresses from this list before
attempting to remove the socket from the port hash

As a result, it is possible for another process to find the socket
in the port hash that is in the process of being closed.  It then
proceeds to traverse the address list to find the conflict, only
to have that address list suddenly disappear without rcu() critical
section.

Fix issue by closing address list removal inside RCU critical
section.

Race can result in a kernel crash with general protection fault or
kernel NULL pointer dereference:

kernel: general protection fault: 0000 [#1] SMP
kernel: RIP: 0010:[<ffffffffa02f3dde>]  [<ffffffffa02f3dde>]
sctp_bind_addr_conflict+0x64/0x82 [sctp]
kernel: Call Trace:
kernel:  [<ffffffffa02f415f>] ? sctp_get_port_local+0x17b/0x2a3 [sctp]
kernel:  [<ffffffffa02f3d45>] ? sctp_bind_addr_match+0x33/0x68 [sctp]
kernel:  [<ffffffffa02f4416>] ? sctp_do_bind+0xd3/0x141 [sctp]
kernel:  [<ffffffffa02f5030>] ? sctp_bindx_add+0x4d/0x8e [sctp]
kernel:  [<ffffffffa02f5183>] ? sctp_setsockopt_bindx+0x112/0x4a4 [sctp]
kernel:  [<ffffffff81089e82>] ? generic_file_aio_write+0x7f/0x9b
kernel:  [<ffffffffa02f763e>] ? sctp_setsockopt+0x14f/0xfee [sctp]
kernel:  [<ffffffff810c11fb>] ? do_sync_write+0xab/0xeb
kernel:  [<ffffffff810e82ab>] ? fsnotify+0x239/0x282
kernel:  [<ffffffff810c2462>] ? alloc_file+0x18/0xb1
kernel:  [<ffffffff8134a0b1>] ? compat_sys_setsockopt+0x1a5/0x1d9
kernel:  [<ffffffff8134aaf1>] ? compat_sys_socketcall+0x143/0x1a4
kernel:  [<ffffffff810467dc>] ? sysenter_dispatch+0x7/0x32

Signed-off-by: Jacek Luczak <luczak.jacek@gmail.com>
Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>
CC: Eric Dumazet <eric.dumazet@gmail.com>

---
 net/sctp/bind_addr.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
index faf71d1..6150ac5 100644
--- a/net/sctp/bind_addr.c
+++ b/net/sctp/bind_addr.c
@@ -140,14 +140,12 @@ void sctp_bind_addr_init(struct sctp_bind_addr
*bp, __u16 port)
 /* Dispose of the address list. */
 static void sctp_bind_addr_clean(struct sctp_bind_addr *bp)
 {
-       struct sctp_sockaddr_entry *addr;
-       struct list_head *pos, *temp;
+       struct sctp_sockaddr_entry *addr, *temp;

        /* Empty the bind address list. */
-       list_for_each_safe(pos, temp, &bp->address_list) {
-               addr = list_entry(pos, struct sctp_sockaddr_entry, list);
-               list_del(pos);
-               kfree(addr);
+       list_for_each_entry_safe(addr, temp, &bp->address_list, list) {
+               list_del_rcu(&addr->list);
+               call_rcu(&addr->rcu, sctp_local_addr_free);
                SCTP_DBG_OBJCNT_DEC(addr);
        }
 }

--bcaec520e99ba004e304a38dd0c2
Content-Type: application/octet-stream;
	name="sctp_fix_close_vs_conflict_race_in_bind_addr.patch"
Content-Disposition: attachment;
	filename="sctp_fix_close_vs_conflict_race_in_bind_addr.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gnudj3ng0

ZGlmZiAtLWdpdCBhL25ldC9zY3RwL2JpbmRfYWRkci5jIGIvbmV0L3NjdHAvYmluZF9hZGRyLmMK
aW5kZXggZmFmNzFkMS4uNjE1MGFjNSAxMDA2NDQKLS0tIGEvbmV0L3NjdHAvYmluZF9hZGRyLmMK
KysrIGIvbmV0L3NjdHAvYmluZF9hZGRyLmMKQEAgLTE0MCwxNCArMTQwLDEyIEBAIHZvaWQgc2N0
cF9iaW5kX2FkZHJfaW5pdChzdHJ1Y3Qgc2N0cF9iaW5kX2FkZHIgKmJwLCBfX3UxNiBwb3J0KQog
LyogRGlzcG9zZSBvZiB0aGUgYWRkcmVzcyBsaXN0LiAqLwogc3RhdGljIHZvaWQgc2N0cF9iaW5k
X2FkZHJfY2xlYW4oc3RydWN0IHNjdHBfYmluZF9hZGRyICpicCkKIHsKLQlzdHJ1Y3Qgc2N0cF9z
b2NrYWRkcl9lbnRyeSAqYWRkcjsKLQlzdHJ1Y3QgbGlzdF9oZWFkICpwb3MsICp0ZW1wOworCXN0
cnVjdCBzY3RwX3NvY2thZGRyX2VudHJ5ICphZGRyLCAqdGVtcDsKIAogCS8qIEVtcHR5IHRoZSBi
aW5kIGFkZHJlc3MgbGlzdC4gKi8KLQlsaXN0X2Zvcl9lYWNoX3NhZmUocG9zLCB0ZW1wLCAmYnAt
PmFkZHJlc3NfbGlzdCkgewotCQlhZGRyID0gbGlzdF9lbnRyeShwb3MsIHN0cnVjdCBzY3RwX3Nv
Y2thZGRyX2VudHJ5LCBsaXN0KTsKLQkJbGlzdF9kZWwocG9zKTsKLQkJa2ZyZWUoYWRkcik7CisJ
bGlzdF9mb3JfZWFjaF9lbnRyeV9zYWZlKGFkZHIsIHRlbXAsICZicC0+YWRkcmVzc19saXN0LCBs
aXN0KSB7CisJCWxpc3RfZGVsX3JjdSgmYWRkci0+bGlzdCk7CisJCWNhbGxfcmN1KCZhZGRyLT5y
Y3UsIHNjdHBfbG9jYWxfYWRkcl9mcmVlKTsKIAkJU0NUUF9EQkdfT0JKQ05UX0RFQyhhZGRyKTsK
IAl9CiB9Cg==
--bcaec520e99ba004e304a38dd0c2--
