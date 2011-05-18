From: Jacek Luczak <difrost.kernel@gmail.com>
Subject: [PATCH] SCTP: fix race between sctp_bind_addr_free() and sctp_bind_addr_conflict()
Date: Wed, 18 May 2011 09:01:00 +0200
Message-ID: <BANLkTikeWzuE-384uT6RhZR6Wn=DBK+CNQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=bcaec520eea378ccb304a387736c
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:51124 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754316Ab1ERHBA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 03:01:00 -0400
Received: by pvg12 with SMTP id 12so577358pvg.19
        for <netdev@vger.kernel.org>; Wed, 18 May 2011 00:01:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--bcaec520eea378ccb304a387736c
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

This can result in a kernel crash with general protection fault or
kernel NULL pointer dereference.

Fix issue by closing address list removal inside RCU critical
section.

Signed-off-by: Jacek Luczak <luczak.jacek@gmail.com>
Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>

---
 bind_addr.c |   12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
index faf71d1..19d1329 100644
--- a/net/sctp/bind_addr.c
+++ b/net/sctp/bind_addr.c
@@ -155,8 +155,16 @@ static void sctp_bind_addr_clean(struct sctp_bind_addr *bp)
 /* Dispose of an SCTP_bind_addr structure  */
 void sctp_bind_addr_free(struct sctp_bind_addr *bp)
 {
-       /* Empty the bind address list. */
-       sctp_bind_addr_clean(bp);
+       struct sctp_sockaddr_entry *addr;
+
+       /* Empty the bind address list inside RCU section. */
+       rcu_read_lock();
+       list_for_each_entry_rcu(addr, &bp->address_list, list) {
+               list_del_rcu(&addr->list);
+               call_rcu(&addr->rcu, sctp_local_addr_free);
+               SCTP_DBG_OBJCNT_DEC(addr);
+       }
+       rcu_read_unlock();

        if (bp->malloced) {
                kfree(bp);

--bcaec520eea378ccb304a387736c
Content-Type: application/octet-stream;
	name="sctp_fix_close_vs_conflict_race_in_bind_addr.patch"
Content-Disposition: attachment;
	filename="sctp_fix_close_vs_conflict_race_in_bind_addr.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gntxahy70

ZGlmZiAtLWdpdCBhL25ldC9zY3RwL2JpbmRfYWRkci5jIGIvbmV0L3NjdHAvYmluZF9hZGRyLmMK
aW5kZXggZmFmNzFkMS4uMTlkMTMyOSAxMDA2NDQKLS0tIGEvbmV0L3NjdHAvYmluZF9hZGRyLmMK
KysrIGIvbmV0L3NjdHAvYmluZF9hZGRyLmMKQEAgLTE1NSw4ICsxNTUsMTYgQEAgc3RhdGljIHZv
aWQgc2N0cF9iaW5kX2FkZHJfY2xlYW4oc3RydWN0IHNjdHBfYmluZF9hZGRyICpicCkKIC8qIERp
c3Bvc2Ugb2YgYW4gU0NUUF9iaW5kX2FkZHIgc3RydWN0dXJlICAqLwogdm9pZCBzY3RwX2JpbmRf
YWRkcl9mcmVlKHN0cnVjdCBzY3RwX2JpbmRfYWRkciAqYnApCiB7Ci0JLyogRW1wdHkgdGhlIGJp
bmQgYWRkcmVzcyBsaXN0LiAqLwotCXNjdHBfYmluZF9hZGRyX2NsZWFuKGJwKTsKKwlzdHJ1Y3Qg
c2N0cF9zb2NrYWRkcl9lbnRyeSAqYWRkcjsKKworCS8qIEVtcHR5IHRoZSBiaW5kIGFkZHJlc3Mg
bGlzdCBpbnNpZGUgUkNVIHNlY3Rpb24uICovCisJcmN1X3JlYWRfbG9jaygpOworCWxpc3RfZm9y
X2VhY2hfZW50cnlfcmN1KGFkZHIsICZicC0+YWRkcmVzc19saXN0LCBsaXN0KSB7CisJCWxpc3Rf
ZGVsX3JjdSgmYWRkci0+bGlzdCk7CisJCWNhbGxfcmN1KCZhZGRyLT5yY3UsIHNjdHBfbG9jYWxf
YWRkcl9mcmVlKTsKKwkJU0NUUF9EQkdfT0JKQ05UX0RFQyhhZGRyKTsKKwl9CisJcmN1X3JlYWRf
dW5sb2NrKCk7CiAKIAlpZiAoYnAtPm1hbGxvY2VkKSB7CiAJCWtmcmVlKGJwKTsK
--bcaec520eea378ccb304a387736c--
