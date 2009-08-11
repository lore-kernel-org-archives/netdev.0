From: "Ilia K." <mail4ilia@gmail.com>
Subject: multicast routing and multiple interfaces with same IP
Date: Wed, 12 Aug 2009 02:26:21 +0300
Message-ID: <1b9338490908111626j55b49177q71b8a373b6e6381b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=000e0cd24766b691960470e607b4
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:48776 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754089AbZHKX0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2009 19:26:21 -0400
Received: by fg-out-1718.google.com with SMTP id e12so709143fga.17
        for <netdev@vger.kernel.org>; Tue, 11 Aug 2009 16:26:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--000e0cd24766b691960470e607b4
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi All,
When routing daemon wants to enable forwarding of multicast traffic it
performs something like:

	struct vifctl vc = {
		.vifc_vifi  = 1,
		.vifc_flags = 0,
		.vifc_threshold = 1,
		.vifc_rate_limit = 0,
		.vifc_lcl_addr = ip, /* <--- ip address of physical interface, e.g. eth0 */
		.vifc_rmt_addr.s_addr = htonl(INADDR_ANY),
	  };
	setsockopt(fd, IPPROTO_IP, MRT_ADD_VIF, &vc, sizeof(vc));

This leads (in the kernel) to call to vif_add() function call which
search the (physical) device using assigned IP address:
	dev = ip_dev_find(net, vifc->vifc_lcl_addr.s_addr);

It seems like API (struct vifctl) does not allow to specify an
interface other way than using it's IP, and if there are more than a
single interface with specified IP only the first one will be found
(for example it makes problems when tunnel is configured using the
same IP as underlying interface).

Am I correct in identifying the problem?
I can propose the attached patch against 2.6.30.4.

Regards,
Ilia.

--000e0cd24766b691960470e607b4
Content-Type: text/x-diff; charset=US-ASCII; name="vif_add.patch"
Content-Disposition: attachment; filename="vif_add.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fy995xwx0

PT09IG1vZGlmaWVkIGZpbGUgJ2luY2x1ZGUvbGludXgvbXJvdXRlLmgnCi0tLSBvbGQvaW5jbHVk
ZS9saW51eC9tcm91dGUuaAkyMDA5LTA4LTEwIDExOjE3OjMyICswMDAwCisrKyBuZXcvaW5jbHVk
ZS9saW51eC9tcm91dGUuaAkyMDA5LTA4LTExIDIwOjM5OjE0ICswMDAwCkBAIC02MSwxMSArNjEs
MTMgQEAKIAl1bnNpZ25lZCBpbnQgdmlmY19yYXRlX2xpbWl0OwkvKiBSYXRlIGxpbWl0ZXIgdmFs
dWVzIChOSSkgKi8KIAlzdHJ1Y3QgaW5fYWRkciB2aWZjX2xjbF9hZGRyOwkvKiBPdXIgYWRkcmVz
cyAqLwogCXN0cnVjdCBpbl9hZGRyIHZpZmNfcm10X2FkZHI7CS8qIElQSVAgdHVubmVsIGFkZHIg
Ki8KKwlpbnQgaWZpbmRleDsJCQkvKiBMb2NhbCBpbnRlcmZhY2UgaW5kZXggKi8KIH07CiAKICNk
ZWZpbmUgVklGRl9UVU5ORUwJMHgxCS8qIElQSVAgdHVubmVsICovCiAjZGVmaW5lIFZJRkZfU1JD
UlQJMHgyCS8qIE5JICovCiAjZGVmaW5lIFZJRkZfUkVHSVNURVIJMHg0CS8qIHJlZ2lzdGVyIHZp
ZgkqLworI2RlZmluZSBWSUZGX1VTRV9JRklOREVYCTB4OAkvKiB1c2UgaWZpbmRleCB0byBmaW5k
IGFuIGludGVyZmFjZSAqLwogCiAvKgogICoJQ2FjaGUgbWFuaXB1bGF0aW9uIHN0cnVjdHVyZXMg
Zm9yIG1yb3V0ZWQgYW5kIFBJTWQKCj09PSBtb2RpZmllZCBmaWxlICduZXQvaXB2NC9pcG1yLmMn
Ci0tLSBvbGQvbmV0L2lwdjQvaXBtci5jCTIwMDktMDgtMTAgMTE6MTc6MzIgKzAwMDAKKysrIG5l
dy9uZXQvaXB2NC9pcG1yLmMJMjAwOS0wOC0xMSAyMjoxNToyNCArMDAwMApAQCAtNDcwLDYgKzQ3
MCwxOCBAQAogCQkJcmV0dXJuIGVycjsKIAkJfQogCQlicmVhazsKKwljYXNlIFZJRkZfVVNFX0lG
SU5ERVg6CisJCWRldiA9IGRldl9nZXRfYnlfaW5kZXgobmV0LCB2aWZjLT5pZmluZGV4KTsKKwkJ
aWYgKCFkZXYpCisJCQlyZXR1cm4gLUVOT0RFVjsKKwkJaWYgKGRldi0+aXBfcHRyID09IE5VTEwp
CisJCQlyZXR1cm4gLUVBRERSTk9UQVZBSUw7CisJCWVyciA9IGRldl9zZXRfYWxsbXVsdGkoZGV2
LCAxKTsKKwkJaWYgKGVycikgeworCQkJZGV2X3B1dChkZXYpOworCQkJcmV0dXJuIGVycjsKKwkJ
fQorCQlicmVhazsKIAljYXNlIDA6CiAJCWRldiA9IGlwX2Rldl9maW5kKG5ldCwgdmlmYy0+dmlm
Y19sY2xfYWRkci5zX2FkZHIpOwogCQlpZiAoIWRldikKCg==
--000e0cd24766b691960470e607b4--
