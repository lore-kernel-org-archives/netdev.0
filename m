From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Lots of new warnings with gcc-7.1.1
Date: Tue, 11 Jul 2017 20:41:09 -0700
Message-ID: <CA+55aFx5mCk+nzDG+gGzDUqE4gzJVERL_oO+PN-PA6oKaUhCpg@mail.gmail.com>
References: <CA+55aFzXz-PxKSJP=hfHD+mfCX4M6+HMacWMkDz7KB8-3y55qw@mail.gmail.com>
 <848b3f21-9516-8a66-e4b3-9056ce38d6f6@roeck-us.net> <CA+55aFyKpezj3oHwtBShyf9x-DJNAGQhrq55iVGM42eWKQtP3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="001a1134e3fe3daab805541696fb"
Cc: Tejun Heo <tj@kernel.org>, Jean Delvare <jdelvare@suse.com>,
        Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
        Sathya Prakash <sathya.prakash@broadcom.com>,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "the arch/x86 maintainers" <x86@kernel.org>,
        xen-devel <xen-devel@lists.xenproject.org>,
        linux-block <linux-block@vger.kernel.org>,
        Linux Media Mailing List <linux-media@vger.kernel.org>,
        IDE-ML <linux-ide@vger.kernel.org>,
        "linux-fbdev@vger.kernel.org" <linux-fbdev@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:33699 "EHLO
        mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932475AbdGLDlL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2017 23:41:11 -0400
In-Reply-To: <CA+55aFyKpezj3oHwtBShyf9x-DJNAGQhrq55iVGM42eWKQtP3w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001a1134e3fe3daab805541696fb
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, Jul 11, 2017 at 8:17 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> If that's the case, I'd prefer just turning off the format-truncation
> (but not overflow) warning with '-Wno-format-trunction".

Doing

 KBUILD_CFLAGS  +=3D $(call cc-disable-warning, format-truncation)

in the main Makefile certainly cuts down on the warnings.

We still have some overflow warnings, including the crazy one where
gcc doesn't see that the number of max7315 boards is very limited.

But those could easily be converted to just snprintf() instead, and
then the truncation warning disabling takes care of it. Maybe that's
the right answer.

We also have about a bazillion

    warning: =E2=80=98*=E2=80=99 in boolean context, suggest =E2=80=98&&=E2=
=80=99 instead

warnings in drivers/ata/libata-core.c, all due to a single macro that
uses a pattern that gcc-7.1.1 doesn't like. The warning looks a bit
debatable, but I suspect the macro could easily be changed too.

Tejun, would you hate just moving the "multiply by 1000" part _into_
that EZ() macro? Something like the attached (UNTESTED!) patch?

              Linus

--001a1134e3fe3daab805541696fb
Content-Type: text/plain; charset="US-ASCII"; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_j50gjy3u0

IGRyaXZlcnMvYXRhL2xpYmF0YS1jb3JlLmMgfCAyMCArKysrKysrKysrLS0tLS0tLS0tLQogMSBm
aWxlIGNoYW5nZWQsIDEwIGluc2VydGlvbnMoKyksIDEwIGRlbGV0aW9ucygtKQoKZGlmZiAtLWdp
dCBhL2RyaXZlcnMvYXRhL2xpYmF0YS1jb3JlLmMgYi9kcml2ZXJzL2F0YS9saWJhdGEtY29yZS5j
CmluZGV4IDg0NTNmOWE0NjgyZi4uNGM3ZDVhMTM4NDk1IDEwMDY0NAotLS0gYS9kcml2ZXJzL2F0
YS9saWJhdGEtY29yZS5jCisrKyBiL2RyaXZlcnMvYXRhL2xpYmF0YS1jb3JlLmMKQEAgLTMyMzEs
MTkgKzMyMzEsMTkgQEAgc3RhdGljIGNvbnN0IHN0cnVjdCBhdGFfdGltaW5nIGF0YV90aW1pbmdb
XSA9IHsKIH07CiAKICNkZWZpbmUgRU5PVUdIKHYsIHVuaXQpCQkoKCh2KS0xKS8odW5pdCkrMSkK
LSNkZWZpbmUgRVoodiwgdW5pdCkJCSgodik/RU5PVUdIKHYsIHVuaXQpOjApCisjZGVmaW5lIEVa
KHYsIHVuaXQpCQkoKHYpP0VOT1VHSCgodikqMTAwMCwgdW5pdCk6MCkKIAogc3RhdGljIHZvaWQg
YXRhX3RpbWluZ19xdWFudGl6ZShjb25zdCBzdHJ1Y3QgYXRhX3RpbWluZyAqdCwgc3RydWN0IGF0
YV90aW1pbmcgKnEsIGludCBULCBpbnQgVVQpCiB7Ci0JcS0+c2V0dXAJPSBFWih0LT5zZXR1cCAg
ICAgICogMTAwMCwgIFQpOwotCXEtPmFjdDhiCT0gRVoodC0+YWN0OGIgICAgICAqIDEwMDAsICBU
KTsKLQlxLT5yZWM4Ygk9IEVaKHQtPnJlYzhiICAgICAgKiAxMDAwLCAgVCk7Ci0JcS0+Y3ljOGIJ
PSBFWih0LT5jeWM4YiAgICAgICogMTAwMCwgIFQpOwotCXEtPmFjdGl2ZQk9IEVaKHQtPmFjdGl2
ZSAgICAgKiAxMDAwLCAgVCk7Ci0JcS0+cmVjb3Zlcgk9IEVaKHQtPnJlY292ZXIgICAgKiAxMDAw
LCAgVCk7Ci0JcS0+ZG1hY2tfaG9sZAk9IEVaKHQtPmRtYWNrX2hvbGQgKiAxMDAwLCAgVCk7Ci0J
cS0+Y3ljbGUJPSBFWih0LT5jeWNsZSAgICAgICogMTAwMCwgIFQpOwotCXEtPnVkbWEJCT0gRVoo
dC0+dWRtYSAgICAgICAqIDEwMDAsIFVUKTsKKwlxLT5zZXR1cAk9IEVaKHQtPnNldHVwLCAgICAg
IFQpOworCXEtPmFjdDhiCT0gRVoodC0+YWN0OGIsICAgICAgVCk7CisJcS0+cmVjOGIJPSBFWih0
LT5yZWM4YiwgICAgICBUKTsKKwlxLT5jeWM4Ygk9IEVaKHQtPmN5YzhiLCAgICAgIFQpOworCXEt
PmFjdGl2ZQk9IEVaKHQtPmFjdGl2ZSwgICAgIFQpOworCXEtPnJlY292ZXIJPSBFWih0LT5yZWNv
dmVyLCAgICBUKTsKKwlxLT5kbWFja19ob2xkCT0gRVoodC0+ZG1hY2tfaG9sZCwgVCk7CisJcS0+
Y3ljbGUJPSBFWih0LT5jeWNsZSwgICAgICBUKTsKKwlxLT51ZG1hCQk9IEVaKHQtPnVkbWEsICAg
ICAgIFVUKTsKIH0KIAogdm9pZCBhdGFfdGltaW5nX21lcmdlKGNvbnN0IHN0cnVjdCBhdGFfdGlt
aW5nICphLCBjb25zdCBzdHJ1Y3QgYXRhX3RpbWluZyAqYiwK
--001a1134e3fe3daab805541696fb--
