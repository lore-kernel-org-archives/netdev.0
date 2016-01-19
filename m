From: Marc Dionne <marc.c.dionne@gmail.com>
Subject: Crash with SO_REUSEPORT and ef456144da8ef507c8cf504284b6042e9201a05c
Date: Tue, 19 Jan 2016 11:57:54 -0400
Message-ID: <CAB9dFdugvFvdQLGAU83CQHYbwaWCMHrAm5Xk746iwMG5g94PqQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a11c1274cb4a0c40529b1ee57
Cc: eric.dumazet@google.com
To: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Craig Gallek <kraig@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:34806 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754602AbcASP5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2016 10:57:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001a11c1274cb4a0c40529b1ee57
Content-Type: text/plain; charset=UTF-8

I shared this one with Craig but I thought I'd put it out to a wider audience.

Trying to run the current kernel mainline on a test system I found
that any attempt to run many of our executables would crash the
system.  The networking code in all of these opens and listens on
multiple UDP sockets set with SO_REUSEPORT.  We also like to bind the
first socket before setting SO_REUSEPORT so we can catch some cases
where the port is actually in use by someone else (for instance a
previous incarnation of the same service).

This is easily reproduced with this sequence:
- create 2 sockets A and B
- bind socket A to an address
- set SO_REUSEPORT on socket A
- set SO_REUSEPORT on socket B
- bind socket B to the same address as A

The sk_reuseport_cb structure is only allocated at bind time if
SO_REUSEPORT is already set, so A doesn't have one.  When we bind B, A
is found as a match that has SO_REUSEPORT and reuseport_add_sock will
try to use the NULL sk_reuseport_cb structure from A, causing a crash.

Not sure what the best fix is, but seems like the structure could be
either allocated (if not already done) when setting SO_REUSEPORT, or
when we find it to be NULL in reuseport_add_sock (but locking may be
an issue there).  I was able to test that allocating sk_reuseport_cb
when setting SO_REUSEPORT makes things behave normally again; see
attached patch.  That's surely not a correct/complete fix as B (in the
scenario above) will have an unnecessary sk_reuseport_cb which will
trigger a warning and should be dealt with.

Thanks,
Marc

--001a11c1274cb4a0c40529b1ee57
Content-Type: text/x-patch; charset=US-ASCII; name="reuseport.patch"
Content-Disposition: attachment; filename="reuseport.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ijlksupc0

Y29tbWl0IDUxODEyMGY0MWFlYzMwYmRkZTM5Y2FmNTg4MThlMWU1ZDJkNmE0YTQKQXV0aG9yOiBN
YXJjIERpb25uZSA8bWFyYy5kaW9ubmVAYXVyaXN0b3IuY29tPgpEYXRlOiAgIEZyaSBKYW4gMTUg
MTY6MDI6MzIgMjAxNiAtMDQwMAoKICAgIHNvcmV1c2Vwb3J0OiBBbGxvdyBiaW5kIGJlZm9yZSBz
ZXR0aW5nIFNPX1JFVVNFUE9SVAogICAgCiAgICBJZiBhIHNvY2tldCBpcyBib3VuZCBiZWZvcmUg
dGhlIFNPX1JFVVNFUE9SVCBvcHRpb24gaXMKICAgIHNldCwgaXQgd2lsbCBoYXZlIG5vIHNrX3Jl
dXNlcG9ydF9jYiBzdHJ1Y3R1cmUgYWxsb2NhdGVkCiAgICBhbmQgYXR0YWNoZWQgdG8gaXQuICBJ
ZiB0aGVyZSBpcyB0aGVuIGFuIGF0dGVtcHQgdG8gYmluZAogICAgYSBzZWNvbmQgc29ja2V0IHRv
IHRoZSBzYW1lIHBvcnQsIHRoZSBmaXJzdCBzb2NrZXQgd2lsbAogICAgYmUgZm91bmQgYXMgbWF0
Y2hpbmcgYW5kIHJldXNlcG9ydF9hZGRfc29jayB3aWxsIGF0dGVtcHQKICAgIHRvIHVzZSB0aGUg
TlVMTCBza19yZXVzZXBvcnRfY2IgcG9pbnRlciwgcmVzdWx0aW5nIGluIGFuCiAgICBvb3BzLgog
ICAgCiAgICBBbGxvY2F0ZSBza19yZXVzZXBvcnRfY2IgaW4gc2V0c29ja29wdCBpZiBub3QgYWxy
ZWFkeSBzZXQuCiAgICBBbHNvLCBkb24ndCBwcmVjbHVkZSByZXVzaW5nIGEgcG9ydCBiZWNhdXNl
IHRoZSBzayBoYXMKICAgIHNrX3JldXNlcG9ydF9jYiBzZXQuCiAgICAKICAgIFNpZ25lZC1vZmYt
Ynk6IE1hcmMgRGlvbm5lIDxtYXJjLmRpb25uZUBhdXJpc3Rvci5jb20+CgpkaWZmIC0tZ2l0IGEv
bmV0L2NvcmUvc29jay5jIGIvbmV0L2NvcmUvc29jay5jCmluZGV4IDUxMjcwMjMuLjU4N2RlNWIg
MTAwNjQ0Ci0tLSBhL25ldC9jb3JlL3NvY2suYworKysgYi9uZXQvY29yZS9zb2NrLmMKQEAgLTcy
NCw2ICs3MjQsOCBAQCBpbnQgc29ja19zZXRzb2Nrb3B0KHN0cnVjdCBzb2NrZXQgKnNvY2ssIGlu
dCBsZXZlbCwgaW50IG9wdG5hbWUsCiAJCWJyZWFrOwogCWNhc2UgU09fUkVVU0VQT1JUOgogCQlz
ay0+c2tfcmV1c2Vwb3J0ID0gdmFsYm9vbDsKKwkJaWYgKCFyY3VfYWNjZXNzX3BvaW50ZXIoc2st
PnNrX3JldXNlcG9ydF9jYikpCisJCSAgICByZXVzZXBvcnRfYWxsb2Moc2spOwogCQlicmVhazsK
IAljYXNlIFNPX1RZUEU6CiAJY2FzZSBTT19QUk9UT0NPTDoKZGlmZiAtLWdpdCBhL25ldC9pcHY0
L3VkcC5jIGIvbmV0L2lwdjQvdWRwLmMKaW5kZXggZGM0NWI1My4uMTM4ODRiNiAxMDA2NDQKLS0t
IGEvbmV0L2lwdjQvdWRwLmMKKysrIGIvbmV0L2lwdjQvdWRwLmMKQEAgLTE1NCw3ICsxNTQsNiBA
QCBzdGF0aWMgaW50IHVkcF9saWJfbHBvcnRfaW51c2Uoc3RydWN0IG5ldCAqbmV0LCBfX3UxNiBu
dW0sCiAJCSAgICAoIXNrMi0+c2tfYm91bmRfZGV2X2lmIHx8ICFzay0+c2tfYm91bmRfZGV2X2lm
IHx8CiAJCSAgICAgc2syLT5za19ib3VuZF9kZXZfaWYgPT0gc2stPnNrX2JvdW5kX2Rldl9pZikg
JiYKIAkJICAgICghc2syLT5za19yZXVzZXBvcnQgfHwgIXNrLT5za19yZXVzZXBvcnQgfHwKLQkJ
ICAgICByY3VfYWNjZXNzX3BvaW50ZXIoc2stPnNrX3JldXNlcG9ydF9jYikgfHwKIAkJICAgICAh
dWlkX2VxKHVpZCwgc29ja19pX3VpZChzazIpKSkgJiYKIAkJICAgIHNhZGRyX2NvbXAoc2ssIHNr
MiwgdHJ1ZSkpIHsKIAkJCWlmICghYml0bWFwKQpAQCAtMTkwLDcgKzE4OSw2IEBAIHN0YXRpYyBp
bnQgdWRwX2xpYl9scG9ydF9pbnVzZTIoc3RydWN0IG5ldCAqbmV0LCBfX3UxNiBudW0sCiAJCSAg
ICAoIXNrMi0+c2tfYm91bmRfZGV2X2lmIHx8ICFzay0+c2tfYm91bmRfZGV2X2lmIHx8CiAJCSAg
ICAgc2syLT5za19ib3VuZF9kZXZfaWYgPT0gc2stPnNrX2JvdW5kX2Rldl9pZikgJiYKIAkJICAg
ICghc2syLT5za19yZXVzZXBvcnQgfHwgIXNrLT5za19yZXVzZXBvcnQgfHwKLQkJICAgICByY3Vf
YWNjZXNzX3BvaW50ZXIoc2stPnNrX3JldXNlcG9ydF9jYikgfHwKIAkJICAgICAhdWlkX2VxKHVp
ZCwgc29ja19pX3VpZChzazIpKSkgJiYKIAkJICAgIHNhZGRyX2NvbXAoc2ssIHNrMiwgdHJ1ZSkp
IHsKIAkJCXJlcyA9IDE7Cg==
--001a11c1274cb4a0c40529b1ee57--
