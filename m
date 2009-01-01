From: "Michael Marineau" <mike@marineau.org>
Subject: [PATCH] fix for initial link state in 2.6.28
Date: Thu, 1 Jan 2009 18:12:59 -0500
Message-ID: <c0526ddf0901011512t258978e9n2c9ecf7488a4a35f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_109320_32456033.1230851579068"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.229]:16654 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753555AbZAAXNA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jan 2009 18:13:00 -0500
Received: by rv-out-0506.google.com with SMTP id k40so5722402rvb.1
        for <netdev@vger.kernel.org>; Thu, 01 Jan 2009 15:12:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_109320_32456033.1230851579068
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Greetings,

Commit b47300168e770b60ab96c8924854c3b0eb4260eb "Do not fire linkwatch
events until the device is registered." was made as a workaround for
drivers that call netif_carrier_off before registering the device.
Unfortunately this causes these drivers to incorrectly report their
link status as IF_OPER_UNKNOWN which can falsely set the IFF_RUNNING
flag when the interface is first brought up. This issues was
previously pointed out[1] but was dismissed saying that IFF_RUNNING is
not related to the link status. From my digging IFF_RUNNING, as
reported to userspace, is based on the link state. It is set based on
__LINK_STATE_START and IF_OPER_UP or IF_OPER_UNKNOWN. See [2], [3],
and [4]. (Whether or not the kernel has IFF_RUNNING set in flags is
not reported to user space so it may well be independent of the link,
I don't know if and when it may get set.)

The end result depends slightly depending on the driver. The the two I
tested were e1000e and b44. With e1000e if the system is booted
without a network cable attached the interface will falsely report
RUNNING when it is brought up causing NetworkManager to attempt to
start it and eventually time out. With b44 when the system is booted
with a network cable attached and brought up with dhcpcd it will time
out the first time.

The attached patch that will still set the operstate variable
correctly to IF_OPER_UP/DOWN/etc when linkwatch_fire_event is called
but then return rather than skipping the linkwatch_fire_event call
entirely as the previous fix did. (sorry it isn't inline, I don't have
a patch friendly email client at the moment)

What ever the final fix for this is, it should probably be pushed into
the stable tree since this is a minor but annoying regression in
2.6.28.

[1] http://marc.info/?l=linux-netdev&m=122922534630000&w=2
[2] http://lxr.linux.no/linux+v2.6.28/net/core/dev.c#L3349
[3] http://lxr.linux.no/linux+v2.6.28/include/linux/netdevice.h#L1147
[4] http://lxr.linux.no/linux+v2.6.28/include/linux/netdevice.h#L1376

Cheers,
-- 
Michael Marineau
mike@marineau.org

------=_Part_109320_32456033.1230851579068
Content-Type: text/x-patch; name=operstate-fix.patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fpg14tin0
Content-Disposition: attachment; filename=operstate-fix.patch

ZGlmZiAtLWdpdCBhL25ldC9jb3JlL2xpbmtfd2F0Y2guYyBiL25ldC9jb3JlL2xpbmtfd2F0Y2gu
YwppbmRleCAxODNkMTgwLi4xZTQwMWUxIDEwMDY0NAotLS0gYS9uZXQvY29yZS9saW5rX3dhdGNo
LmMKKysrIGIvbmV0L2NvcmUvbGlua193YXRjaC5jCkBAIC0xNzksNyArMTc4LDYgQEAgc3RhdGlj
IHZvaWQgX19saW5rd2F0Y2hfcnVuX3F1ZXVlKGludCB1cmdlbnRfb25seSkKIAkJICovCiAJCWNs
ZWFyX2JpdChfX0xJTktfU1RBVEVfTElOS1dBVENIX1BFTkRJTkcsICZkZXYtPnN0YXRlKTsKIAot
CQlyZmMyODYzX3BvbGljeShkZXYpOwogCQlpZiAoZGV2LT5mbGFncyAmIElGRl9VUCkgewogCQkJ
aWYgKG5ldGlmX2NhcnJpZXJfb2soZGV2KSkKIAkJCQlkZXZfYWN0aXZhdGUoZGV2KTsKQEAgLTIx
Niw2ICsyMTQsMTIgQEAgdm9pZCBsaW5rd2F0Y2hfZmlyZV9ldmVudChzdHJ1Y3QgbmV0X2Rldmlj
ZSAqZGV2KQogewogCWJvb2wgdXJnZW50ID0gbGlua3dhdGNoX3VyZ2VudF9ldmVudChkZXYpOwog
CisJcmZjMjg2M19wb2xpY3koZGV2KTsKKworCS8qIFNvbWUgZHJpdmVycyBjYWxsIG5ldGlmX2Nh
cnJpZXJfb2ZmIGVhcmx5ICovCisJaWYgKGRldi0+cmVnX3N0YXRlID09IE5FVFJFR19VTklOSVRJ
QUxJWkVEKQorCQlyZXR1cm47CisKIAlpZiAoIXRlc3RfYW5kX3NldF9iaXQoX19MSU5LX1NUQVRF
X0xJTktXQVRDSF9QRU5ESU5HLCAmZGV2LT5zdGF0ZSkpIHsKIAkJZGV2X2hvbGQoZGV2KTsKIApk
aWZmIC0tZ2l0IGEvbmV0L3NjaGVkL3NjaF9nZW5lcmljLmMgYi9uZXQvc2NoZWQvc2NoX2dlbmVy
aWMuYwppbmRleCBjZGNkMTZmLi4zZWE2NzQxIDEwMDY0NAotLS0gYS9uZXQvc2NoZWQvc2NoX2dl
bmVyaWMuYworKysgYi9uZXQvc2NoZWQvc2NoX2dlbmVyaWMuYwpAQCAtMjcwLDggKzI3MCw2IEBA
IHN0YXRpYyB2b2lkIGRldl93YXRjaGRvZ19kb3duKHN0cnVjdCBuZXRfZGV2aWNlICpkZXYpCiB2
b2lkIG5ldGlmX2NhcnJpZXJfb24oc3RydWN0IG5ldF9kZXZpY2UgKmRldikKIHsKIAlpZiAodGVz
dF9hbmRfY2xlYXJfYml0KF9fTElOS19TVEFURV9OT0NBUlJJRVIsICZkZXYtPnN0YXRlKSkgewot
CQlpZiAoZGV2LT5yZWdfc3RhdGUgPT0gTkVUUkVHX1VOSU5JVElBTElaRUQpCi0JCQlyZXR1cm47
CiAJCWxpbmt3YXRjaF9maXJlX2V2ZW50KGRldik7CiAJCWlmIChuZXRpZl9ydW5uaW5nKGRldikp
CiAJCQlfX25ldGRldl93YXRjaGRvZ191cChkZXYpOwpAQCAtMjg4LDggKzI4Niw2IEBAIEVYUE9S
VF9TWU1CT0wobmV0aWZfY2Fycmllcl9vbik7CiB2b2lkIG5ldGlmX2NhcnJpZXJfb2ZmKHN0cnVj
dCBuZXRfZGV2aWNlICpkZXYpCiB7CiAJaWYgKCF0ZXN0X2FuZF9zZXRfYml0KF9fTElOS19TVEFU
RV9OT0NBUlJJRVIsICZkZXYtPnN0YXRlKSkgewotCQlpZiAoZGV2LT5yZWdfc3RhdGUgPT0gTkVU
UkVHX1VOSU5JVElBTElaRUQpCi0JCQlyZXR1cm47CiAJCWxpbmt3YXRjaF9maXJlX2V2ZW50KGRl
dik7CiAJfQogfQo=
------=_Part_109320_32456033.1230851579068--
