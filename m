From: "Ilia K." <mail4ilia@gmail.com>
Subject: [PATCH] add vif using local interface index instead of IP
Date: Wed, 16 Sep 2009 18:53:07 +0300
Message-ID: <1b9338490909160853u4d90093fg56453ffff5a67ced@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001636025dae29d9eb0473b3e5ab
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:64345 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754748AbZIPPxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2009 11:53:06 -0400
Received: by fxm17 with SMTP id 17so2380146fxm.37
        for <netdev@vger.kernel.org>; Wed, 16 Sep 2009 08:53:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001636025dae29d9eb0473b3e5ab
Content-Type: text/plain; charset=ISO-8859-1

When routing daemon wants to enable forwarding of multicast traffic it
performs something like:

       struct vifctl vc = {
               .vifc_vifi  = 1,
               .vifc_flags = 0,
               .vifc_threshold = 1,
               .vifc_rate_limit = 0,
               .vifc_lcl_addr = ip, /* <--- ip address of physical
interface, e.g. eth0 */
               .vifc_rmt_addr.s_addr = htonl(INADDR_ANY),
         };
       setsockopt(fd, IPPROTO_IP, MRT_ADD_VIF, &vc, sizeof(vc));

This leads (in the kernel) to calling  vif_add() function call which
search the (physical) device using assigned IP address:
       dev = ip_dev_find(net, vifc->vifc_lcl_addr.s_addr);

The current API (struct vifctl) does not allow to specify an
interface other way than using it's IP, and if there are more than a
single interface with specified IP only the first one will be found.

The attached patch (against 2.6.30.4) allows to specify an interface
by its index, instead of IP address:

       struct vifctl vc = {
               .vifc_vifi  = 1,
               .vifc_flags = VIFF_USE_IFINDEX,   /* NEW */
               .vifc_threshold = 1,
               .vifc_rate_limit = 0,
               .vifc_lcl_ifindex = if_nametoindex("eth0"),   /* NEW */
               .vifc_rmt_addr.s_addr = htonl(INADDR_ANY),
         };
       setsockopt(fd, IPPROTO_IP, MRT_ADD_VIF, &vc, sizeof(vc));


Signed-off-by: Ilia K. <mail4ilia@gmail.com>

--001636025dae29d9eb0473b3e5ab
Content-Type: text/x-diff; charset=US-ASCII; name="vif_add.patch"
Content-Disposition: attachment; filename="vif_add.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fzo928ww0

PT09IG1vZGlmaWVkIGZpbGUgJ2luY2x1ZGUvbGludXgvbXJvdXRlLmgnCi0tLSBvbGQvaW5jbHVk
ZS9saW51eC9tcm91dGUuaAkyMDA5LTA4LTEwIDExOjE3OjMyICswMDAwCisrKyBuZXcvaW5jbHVk
ZS9saW51eC9tcm91dGUuaAkyMDA5LTA5LTA4IDA2OjU4OjQ2ICswMDAwCkBAIC01OSwxMyArNTks
MTggQEAKIAl1bnNpZ25lZCBjaGFyIHZpZmNfZmxhZ3M7CS8qIFZJRkZfIGZsYWdzICovCiAJdW5z
aWduZWQgY2hhciB2aWZjX3RocmVzaG9sZDsJLyogdHRsIGxpbWl0ICovCiAJdW5zaWduZWQgaW50
IHZpZmNfcmF0ZV9saW1pdDsJLyogUmF0ZSBsaW1pdGVyIHZhbHVlcyAoTkkpICovCi0Jc3RydWN0
IGluX2FkZHIgdmlmY19sY2xfYWRkcjsJLyogT3VyIGFkZHJlc3MgKi8KKwl1bmlvbiB7CisJCXN0
cnVjdCBpbl9hZGRyIHZpZmNfbGNsX2FkZHI7ICAgICAvKiBMb2NhbCBpbnRlcmZhY2UgYWRkcmVz
cyAqLworCQlpbnQgICAgICAgICAgICB2aWZjX2xjbF9pZmluZGV4OyAgLyogTG9jYWwgaW50ZXJm
YWNlIGluZGV4ICAgKi8KKwl9OwogCXN0cnVjdCBpbl9hZGRyIHZpZmNfcm10X2FkZHI7CS8qIElQ
SVAgdHVubmVsIGFkZHIgKi8KIH07CiAKLSNkZWZpbmUgVklGRl9UVU5ORUwJMHgxCS8qIElQSVAg
dHVubmVsICovCi0jZGVmaW5lIFZJRkZfU1JDUlQJMHgyCS8qIE5JICovCi0jZGVmaW5lIFZJRkZf
UkVHSVNURVIJMHg0CS8qIHJlZ2lzdGVyIHZpZgkqLworI2RlZmluZSBWSUZGX1RVTk5FTAkJMHgx
CS8qIElQSVAgdHVubmVsICovCisjZGVmaW5lIFZJRkZfU1JDUlQJCTB4MgkvKiBOSSAqLworI2Rl
ZmluZSBWSUZGX1JFR0lTVEVSCQkweDQJLyogcmVnaXN0ZXIgdmlmCSovCisjZGVmaW5lIFZJRkZf
VVNFX0lGSU5ERVgJMHg4CS8qIHVzZSB2aWZjX2xjbF9pZmluZGV4IGluc3RlYWQgb2YKKwkJCQkJ
ICAgdmlmY19sY2xfYWRkciB0byBmaW5kIGFuIGludGVyZmFjZSAqLwogCiAvKgogICoJQ2FjaGUg
bWFuaXB1bGF0aW9uIHN0cnVjdHVyZXMgZm9yIG1yb3V0ZWQgYW5kIFBJTWQKCj09PSBtb2RpZmll
ZCBmaWxlICduZXQvaXB2NC9pcG1yLmMnCi0tLSBvbGQvbmV0L2lwdjQvaXBtci5jCTIwMDktMDgt
MTAgMTE6MTc6MzIgKzAwMDAKKysrIG5ldy9uZXQvaXB2NC9pcG1yLmMJMjAwOS0wOS0wOCAwNjoz
NDoyMSArMDAwMApAQCAtNDcwLDggKzQ3MCwxOCBAQAogCQkJcmV0dXJuIGVycjsKIAkJfQogCQli
cmVhazsKKworCWNhc2UgVklGRl9VU0VfSUZJTkRFWDoKIAljYXNlIDA6Ci0JCWRldiA9IGlwX2Rl
dl9maW5kKG5ldCwgdmlmYy0+dmlmY19sY2xfYWRkci5zX2FkZHIpOworCQlpZiAodmlmYy0+dmlm
Y19mbGFncyA9PSBWSUZGX1VTRV9JRklOREVYKSB7CisJCQlkZXYgPSBkZXZfZ2V0X2J5X2luZGV4
KG5ldCwgdmlmYy0+dmlmY19sY2xfaWZpbmRleCk7CisJCQlpZiAoZGV2ICYmIGRldi0+aXBfcHRy
ID09IE5VTEwpIHsKKwkJCQlkZXZfcHV0KGRldik7CisJCQkJcmV0dXJuIC1FQUREUk5PVEFWQUlM
OworCQkJfQorCQl9IGVsc2UKKwkJCWRldiA9IGlwX2Rldl9maW5kKG5ldCwgdmlmYy0+dmlmY19s
Y2xfYWRkci5zX2FkZHIpOworCiAJCWlmICghZGV2KQogCQkJcmV0dXJuIC1FQUREUk5PVEFWQUlM
OwogCQllcnIgPSBkZXZfc2V0X2FsbG11bHRpKGRldiwgMSk7Cgo=
--001636025dae29d9eb0473b3e5ab--
