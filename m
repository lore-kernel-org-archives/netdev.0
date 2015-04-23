From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: NAPI: Polling function requesting extra calls - difference between
 3.18.11 and 4.0.0
Date: Thu, 23 Apr 2015 20:18:01 +0200
Message-ID: <CACna6rzMMUA_MQemYyP93+TjP4aocL1WaYQUJFwQm3+DLNAefg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=20cf30363b93cebd050514684c9e
Cc: Felix Fietkau <nbd@openwrt.org>
To: Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:36065 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030383AbbDWSSD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 14:18:03 -0400
Received: by igblo3 with SMTP id lo3so30329694igb.1
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2015 11:18:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--20cf30363b93cebd050514684c9e
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi,

Recently Felix improved bgmac driver to be smarter in situation where
new packets were Tx/Rx-ed during bgmac_poll execution. It was handled
in:
eb64e29 bgmac: leave interrupts disabled as long as there is work to do
http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=
=3Deb64e2923a886441c7b322f138b36029f3fa6a36
With above change, after handling all skb-s in bgmac_poll, bgmac
checks if there are new sbk-s to be handled. If so, it doesn't call
napi_complete & it doesn't enable interrupts.

Above commit was merged for 4.1 kernel, but I work with OpenWrt based
on older releases, so I have all bgmac changes backported to 3.8.11
and 4.0.


With 3.8.11 Felix's change seems to be working fine, I did some debugging:

[   44.970000] [bgmac_interrupt] int_status & int_mask =3D 0x01000000

[   44.980000] [bgmac_poll] START weight:64
[   44.990000] [bgmac_poll] Read handled:0 skb-s
[   44.990000] [bgmac_poll] Read IRQ status again BGMAC_IS_TX0:0 BGMAC_IS_R=
X:0
[   45.000000] [bgmac_poll] Read skb-s < weight, calling napi_complete, en =
IRQs
[   45.010000] [bgmac_poll] END returning handled:0

[   48.040000] [bgmac_interrupt] int_status & int_mask =3D 0x01000000

[   48.050000] [bgmac_poll] START weight:64
[   48.060000] [bgmac_poll] Read handled:0 skb-s
[   48.060000] [bgmac_poll] Read IRQ status again BGMAC_IS_TX0:0 BGMAC_IS_R=
X:0
[   48.070000] [bgmac_poll] Read skb-s < weight, calling napi_complete, en =
IRQs
[   48.080000] [bgmac_poll] END returning handled:0

[   48.100000] [bgmac_poll] START weight:64
[   48.110000] [bgmac_poll] Read handled:1 skb-s
[   48.110000] [bgmac_poll] Read IRQ status again BGMAC_IS_TX0:1 BGMAC_IS_R=
X:1
[   48.120000] [bgmac_poll] END more skb-s to handle, returning handled:1

[   48.130000] [bgmac_poll] START weight:64
[   48.130000] [bgmac_poll] Read handled:1 skb-s
[   48.140000] [bgmac_poll] Read IRQ status again BGMAC_IS_TX0:0 BGMAC_IS_R=
X:0
[   48.150000] [bgmac_poll] Read skb-s < weight, calling napi_complete, en =
IRQs
[   48.160000] [bgmac_poll] END returning handled:1

Please note that at 48.120000 bgmac decided bgmac_poll should be
called again and it didn't call napi_complete & didn't enable IRQs. It
simply returned 1.
NAPI behaved just like we expected, bgmac_poll was called again a
moment later. It handled skb-s that appeared meanwhile and ended
calling napi_complete and returning 1.


Now, it fails badly for me at all when using kernel 4.0.0:

[   52.800000] [bgmac_interrupt] int_status & int_mask =3D 0x01000000

[   52.800000] [bgmac_poll] START weight:64
[   52.810000] [bgmac_poll] Read handled:0 skb-s
[   52.810000] [bgmac_poll] Read IRQ status again BGMAC_IS_TX0:0 BGMAC_IS_R=
X:0
[   52.820000] [bgmac_poll] Read skb-s < weight, calling napi_complete, en =
IRQs
[   52.830000] [bgmac_poll] END returning handled:0

[   54.610000] [bgmac_interrupt] int_status & int_mask =3D 0x01000000

[   54.620000] [bgmac_poll] START weight:64
[   54.630000] [bgmac_poll] Read handled:0 skb-s
[   54.630000] [bgmac_poll] Read IRQ status again BGMAC_IS_TX0:0 BGMAC_IS_R=
X:0
[   54.640000] [bgmac_poll] Read skb-s < weight, calling napi_complete, en =
IRQs
[   54.650000] [bgmac_poll] END returning handled:0

[   55.900000] [bgmac_interrupt] int_status & int_mask =3D 0x01000000

[   55.910000] [bgmac_poll] START weight:64
[   55.920000] [bgmac_poll] Read handled:1 skb-s
[   55.920000] [bgmac_poll] Read IRQ status again BGMAC_IS_TX0:1 BGMAC_IS_R=
X:1
[   55.930000] [bgmac_poll] END more skb-s to handle, returning handled:1

As you can see, at 55.930000 bgmac also decided bgmac_poll should be
called again. It didn't call napi_complete, didn't enable IRQs. It
simply returned 1. Just like with kernel 3.8.11.
It this case however, NAPI never called bgmac_poll again. It resulted
in bgmac hanging (IRQs are off, bgmac expects bgmac_poll to be
called).


Can you help us with this, please? Does bgmac use NAPI incorrectly?
Were there some important changes in 3.19 or 4.0?

--=20
Rafa=C5=82

--20cf30363b93cebd050514684c9e
Content-Type: text/plain; charset=US-ASCII; name="tmp.diff"
Content-Disposition: attachment; filename="tmp.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_i8uhkp7s0

ZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L2V0aGVybmV0L2Jyb2FkY29tL2JnbWFjLmMgYi9kcml2
ZXJzL25ldC9ldGhlcm5ldC9icm9hZGNvbS9iZ21hYy5jCmluZGV4IDQ5Mjk5MzIuLjQwY2UzNGQg
MTAwNjQ0Ci0tLSBhL2RyaXZlcnMvbmV0L2V0aGVybmV0L2Jyb2FkY29tL2JnbWFjLmMKKysrIGIv
ZHJpdmVycy9uZXQvZXRoZXJuZXQvYnJvYWRjb20vYmdtYWMuYwpAQCAtMTIxOSw2ICsxMjE5LDcg
QEAgc3RhdGljIGlycXJldHVybl90IGJnbWFjX2ludGVycnVwdChpbnQgaXJxLCB2b2lkICpkZXZf
aWQpCiAJc3RydWN0IGJnbWFjICpiZ21hYyA9IG5ldGRldl9wcml2KGRldl9pZCk7CiAKIAl1MzIg
aW50X3N0YXR1cyA9IGJnbWFjX3JlYWQoYmdtYWMsIEJHTUFDX0lOVF9TVEFUVVMpOworCXByX2lu
Zm8oIlslc10gaW50X3N0YXR1czoweCUwOHggJiBpbnRfbWFzazoweCUwOHggPSAweCUwOHhcbiIs
IF9fRlVOQ1RJT05fXywgaW50X3N0YXR1cywgYmdtYWMtPmludF9tYXNrLCBpbnRfc3RhdHVzICYg
YmdtYWMtPmludF9tYXNrKTsKIAlpbnRfc3RhdHVzICY9IGJnbWFjLT5pbnRfbWFzazsKIAogCWlm
ICghaW50X3N0YXR1cykKQEAgLTEyNDAsMjIgKzEyNDEsMzEgQEAgc3RhdGljIGludCBiZ21hY19w
b2xsKHN0cnVjdCBuYXBpX3N0cnVjdCAqbmFwaSwgaW50IHdlaWdodCkKIHsKIAlzdHJ1Y3QgYmdt
YWMgKmJnbWFjID0gY29udGFpbmVyX29mKG5hcGksIHN0cnVjdCBiZ21hYywgbmFwaSk7CiAJaW50
IGhhbmRsZWQgPSAwOworCXUzMiBpbnRfc3RhdHVzOwogCisJcHJfaW5mbygiWyVzXSBTVEFSVCB3
ZWlnaHQ6JWRcbiIsIF9fRlVOQ1RJT05fXywgd2VpZ2h0KTsKIAkvKiBBY2sgKi8KIAliZ21hY193
cml0ZShiZ21hYywgQkdNQUNfSU5UX1NUQVRVUywgfjApOwogCiAJYmdtYWNfZG1hX3R4X2ZyZWUo
YmdtYWMsICZiZ21hYy0+dHhfcmluZ1swXSk7CiAJaGFuZGxlZCArPSBiZ21hY19kbWFfcnhfcmVh
ZChiZ21hYywgJmJnbWFjLT5yeF9yaW5nWzBdLCB3ZWlnaHQpOworCXByX2luZm8oIlslc10gUmVh
ZCBoYW5kbGVkOiVkIHNrYi1zXG4iLCBfX0ZVTkNUSU9OX18sIGhhbmRsZWQpOwogCiAJLyogUG9s
bCBhZ2FpbiBpZiBtb3JlIGV2ZW50cyBhcnJpdmVkIGluIHRoZSBtZWFudGltZSAqLwotCWlmIChi
Z21hY19yZWFkKGJnbWFjLCBCR01BQ19JTlRfU1RBVFVTKSAmIChCR01BQ19JU19UWDAgfCBCR01B
Q19JU19SWCkpCisJaW50X3N0YXR1cyA9IGJnbWFjX3JlYWQoYmdtYWMsIEJHTUFDX0lOVF9TVEFU
VVMpOworCXByX2luZm8oIlslc10gUmVhZCBJUlEgc3RhdHVzIGFnYWluIEJHTUFDX0lTX1RYMDol
ZCBCR01BQ19JU19SWDolZFxuIiwgX19GVU5DVElPTl9fLCAhIShpbnRfc3RhdHVzICYgQkdNQUNf
SVNfVFgwKSwgISEoaW50X3N0YXR1cyAmIEJHTUFDX0lTX1JYKSk7CisJaWYgKGludF9zdGF0dXMg
JiAoQkdNQUNfSVNfVFgwIHwgQkdNQUNfSVNfUlgpKSB7CisJCXByX2luZm8oIlslc10gRU5EIG1v
cmUgc2tiLXMgdG8gaGFuZGxlLCByZXR1cm5pbmcgaGFuZGxlZDolZFxuIiwgX19GVU5DVElPTl9f
LCBoYW5kbGVkKTsKIAkJcmV0dXJuIGhhbmRsZWQ7CisJfQogCiAJaWYgKGhhbmRsZWQgPCB3ZWln
aHQpIHsKKwkJcHJfaW5mbygiWyVzXSBSZWFkIHNrYi1zIDwgd2VpZ2h0LCBjYWxsaW5nIG5hcGlf
Y29tcGxldGUsIGVuIElSUXNcbiIsIF9fRlVOQ1RJT05fXyk7CiAJCW5hcGlfY29tcGxldGUobmFw
aSk7CiAJCWJnbWFjX2NoaXBfaW50cnNfb24oYmdtYWMpOwogCX0KIAorCXByX2luZm8oIlslc10g
RU5EIHJldHVybmluZyBoYW5kbGVkOiVkXG4iLCBfX0ZVTkNUSU9OX18sIGhhbmRsZWQpOwogCXJl
dHVybiBoYW5kbGVkOwogfQogCg==
--20cf30363b93cebd050514684c9e--
