From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] net_namespace: fixed net_device reference leak
Date: Sat, 10 Sep 2016 10:12:45 -0600
Message-ID: <6f78dadc-9fdc-7f37-7a2a-037b778c4366@cumulusnetworks.com>
References: <1473373012.18970.13.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAJD3hpUMdSt6UXEFjU9OnU4K7qiET50xo8AQ194+4vpX2CfOUA@mail.gmail.com>
 <CAJD3hpUDTZiJQ4YMiCizcYBKw=GD6jZoww3GxYjmajSdn6CE=g@mail.gmail.com>
 <20160908.170443.533565891486140434.davem@davemloft.net>
 <CAJD3hpVDo+WVVM0cvcD2z8LzXrsyBPvPC1E72ETN_yG2rNaeLw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------15380C235CBA31142FB5459E"
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Jojy Varghese <jojy.varghese@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:32951 "EHLO
        mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754821AbcIJQMx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Sep 2016 12:12:53 -0400
Received: by mail-pa0-f43.google.com with SMTP id cm16so37921767pac.0
        for <netdev@vger.kernel.org>; Sat, 10 Sep 2016 09:12:53 -0700 (PDT)
In-Reply-To: <CAJD3hpVDo+WVVM0cvcD2z8LzXrsyBPvPC1E72ETN_yG2rNaeLw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------15380C235CBA31142FB5459E
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

On 9/8/16 6:35 PM, Jojy Varghese wrote:
> Thanks for the feedback guys. I appreciate it.
> 
> I am working with 4.4.3 kernel.  I will try to reproduce the issue
> with the kernel tree at
> https://git.kernel.org/cgit/linux/kernel/git/davem/net.git.
> 
> In the meantime, the only data I have now is :
> -  "dst-ifdown"  does not look correct since it will never release
> reference to loopback device.
> -  One way to fix might be to assign the 'dst''s net device to the
> init net device. I thought adding reference to init net device's
> loopback might be safe.
> 
> Any suggestion on debugging further is much appreciated.
> 

Last 2 times I chased down netdev refcnts I used the attach patch. It adds tracepoints to dev_hold and dev_put.

perf record -e net:dev_hold,net:dev_put -a -g -- <run your test>

You probably will need to increase memory for perf buffers (e.g., -m 8192).

It will dump a lot of data but you will find the missing put; you just have to be patient wading through the data and matching up hold and put references. python/perl script with perf script can make that easier.

---

Have you looked at whether there are open sockets? e.g., perhaps a dst reference is cached on a socket


--------------15380C235CBA31142FB5459E
Content-Type: text/plain; charset=UTF-8; x-mac-type="0"; x-mac-creator="0";
 name="0001-Add-tracepoints-to-dev_hold-and-dev_put.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="0001-Add-tracepoints-to-dev_hold-and-dev_put.patch"

RnJvbSAwNjhiMWI4MzYyZWM1ZmQxYjlkZmZkYmQ2ZTg0NDc0YWRhMmViODI5IE1vbiBTZXAg
MTcgMDA6MDA6MDAgMjAwMQpGcm9tOiBEYXZpZCBBaGVybiA8ZHNhQGN1bXVsdXNuZXR3b3Jr
cy5jb20+CkRhdGU6IFRodSwgMTEgRmViIDIwMTYgMDI6NDA6MTIgLTA4MDAKU3ViamVjdDog
W1BBVENIXSBBZGQgdHJhY2Vwb2ludHMgdG8gZGV2X2hvbGQgYW5kIGRldl9wdXQKClNpZ25l
ZC1vZmYtYnk6IERhdmlkIEFoZXJuIDxkc2FAY3VtdWx1c25ldHdvcmtzLmNvbT4KLS0tCiBp
bmNsdWRlL2xpbnV4L25ldGRldmljZS5oICB8ICA2ICsrKysrKwogaW5jbHVkZS90cmFjZS9l
dmVudHMvbmV0LmggfCAzOCArKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysr
KwogbmV0L2NvcmUvZGV2LmMgICAgICAgICAgICAgfCAyMSArKysrKysrKysrKysrKysrKysr
KysKIDMgZmlsZXMgY2hhbmdlZCwgNjUgaW5zZXJ0aW9ucygrKQoKZGlmZiAtLWdpdCBhL2lu
Y2x1ZGUvbGludXgvbmV0ZGV2aWNlLmggYi9pbmNsdWRlL2xpbnV4L25ldGRldmljZS5oCmlu
ZGV4IDIxOWY1M2MzMGNiMy4uN2VmNmZjNjcyZGZiIDEwMDY0NAotLS0gYS9pbmNsdWRlL2xp
bnV4L25ldGRldmljZS5oCisrKyBiL2luY2x1ZGUvbGludXgvbmV0ZGV2aWNlLmgKQEAgLTMx
OTMsNiArMzE5Myw3IEBAIGV4dGVybiBpbnQJCW5ldGRldl9idWRnZXQ7CiAvKiBDYWxsZWQg
YnkgcnRuZXRsaW5rLmM6cnRubF91bmxvY2soKSAqLwogdm9pZCBuZXRkZXZfcnVuX3RvZG8o
dm9pZCk7CiAKKyNpZiAwCiAvKioKICAqCWRldl9wdXQgLSByZWxlYXNlIHJlZmVyZW5jZSB0
byBkZXZpY2UKICAqCUBkZXY6IG5ldHdvcmsgZGV2aWNlCkBAIC0zMjE0LDYgKzMyMTUsMTEg
QEAgc3RhdGljIGlubGluZSB2b2lkIGRldl9ob2xkKHN0cnVjdCBuZXRfZGV2aWNlICpkZXYp
CiB7CiAJdGhpc19jcHVfaW5jKCpkZXYtPnBjcHVfcmVmY250KTsKIH0KKyNlbHNlCit2b2lk
IGRldl9wdXQoc3RydWN0IG5ldF9kZXZpY2UgKmRldik7Cit2b2lkIGRldl9ob2xkKHN0cnVj
dCBuZXRfZGV2aWNlICpkZXYpOworCisjZW5kaWYKIAogLyogQ2FycmllciBsb3NzIGRldGVj
dGlvbiwgZGlhbCBvbiBkZW1hbmQuIFRoZSBmdW5jdGlvbnMgbmV0aWZfY2Fycmllcl9vbgog
ICogYW5kIF9vZmYgbWF5IGJlIGNhbGxlZCBmcm9tIElSUSBjb250ZXh0LCBidXQgaXQgaXMg
Y2FsbGVyCmRpZmYgLS1naXQgYS9pbmNsdWRlL3RyYWNlL2V2ZW50cy9uZXQuaCBiL2luY2x1
ZGUvdHJhY2UvZXZlbnRzL25ldC5oCmluZGV4IDQ5Y2M3YzNkZTI1Mi4uOWVkNzNkZmU5ZDA5
IDEwMDY0NAotLS0gYS9pbmNsdWRlL3RyYWNlL2V2ZW50cy9uZXQuaAorKysgYi9pbmNsdWRl
L3RyYWNlL2V2ZW50cy9uZXQuaApAQCAtMjM2LDYgKzIzNiw0NCBAQCBERUZJTkVfRVZFTlQo
bmV0X2Rldl9yeF92ZXJib3NlX3RlbXBsYXRlLCBuZXRpZl9yeF9uaV9lbnRyeSwKIAlUUF9B
UkdTKHNrYikKICk7CiAKK1RSQUNFX0VWRU5UKGRldl9wdXQsCisKKwlUUF9QUk9UTyhzdHJ1
Y3QgbmV0X2RldmljZSAqZGV2KSwKKworCVRQX0FSR1MoZGV2KSwKKworCVRQX1NUUlVDVF9f
ZW50cnkoCisJCV9fc3RyaW5nKAluYW1lLAkJZGV2LT5uYW1lCSkKKwkJX19maWVsZCgJaW50
LAkJcmVmY250ICkKKwkpLAorCisJVFBfZmFzdF9hc3NpZ24oCisJCV9fYXNzaWduX3N0cihu
YW1lLCBkZXYtPm5hbWUpOworCQlfX2VudHJ5LT5yZWZjbnQgPSBuZXRkZXZfcmVmY250X3Jl
YWQoZGV2KTsKKwkpLAorCisJVFBfcHJpbnRrKCJkZXY9JXMgcmVmY250ICVkIiwgX19nZXRf
c3RyKG5hbWUpLCBfX2VudHJ5LT5yZWZjbnQpCispOworCitUUkFDRV9FVkVOVChkZXZfaG9s
ZCwKKworCVRQX1BST1RPKHN0cnVjdCBuZXRfZGV2aWNlICpkZXYpLAorCisJVFBfQVJHUyhk
ZXYpLAorCisJVFBfU1RSVUNUX19lbnRyeSgKKwkJX19zdHJpbmcoCW5hbWUsCQlkZXYtPm5h
bWUJKQorCQlfX2ZpZWxkKAlpbnQsCQlyZWZjbnQgKQorCSksCisKKwlUUF9mYXN0X2Fzc2ln
bigKKwkJX19hc3NpZ25fc3RyKG5hbWUsIGRldi0+bmFtZSk7CisJCV9fZW50cnktPnJlZmNu
dCA9IG5ldGRldl9yZWZjbnRfcmVhZChkZXYpOworCSksCisKKwlUUF9wcmludGsoImRldj0l
cyByZWZjbnQgJWQiLCBfX2dldF9zdHIobmFtZSksIF9fZW50cnktPnJlZmNudCkKKyk7CisK
ICNlbmRpZiAvKiBfVFJBQ0VfTkVUX0ggKi8KIAogLyogVGhpcyBwYXJ0IG11c3QgYmUgb3V0
c2lkZSBwcm90ZWN0aW9uICovCmRpZmYgLS1naXQgYS9uZXQvY29yZS9kZXYuYyBiL25ldC9j
b3JlL2Rldi5jCmluZGV4IGYxMjg0ODM1YjhjOS4uOTlhYzA2N2FmZDE4IDEwMDY0NAotLS0g
YS9uZXQvY29yZS9kZXYuYworKysgYi9uZXQvY29yZS9kZXYuYwpAQCAtODExNywzICs4MTE3
LDI0IEBAIHN0YXRpYyBpbnQgX19pbml0IG5ldF9kZXZfaW5pdCh2b2lkKQogfQogCiBzdWJz
eXNfaW5pdGNhbGwobmV0X2Rldl9pbml0KTsKKworCit2b2lkIGRldl9wdXQoc3RydWN0IG5l
dF9kZXZpY2UgKmRldikKK3sKKwl0aGlzX2NwdV9kZWMoKmRldi0+cGNwdV9yZWZjbnQpOwor
CXRyYWNlX2Rldl9wdXQoZGV2KTsKK30KK0VYUE9SVF9TWU1CT0woZGV2X3B1dCk7CisKKy8q
KgorICogICAgICBkZXZfaG9sZCAtIGdldCByZWZlcmVuY2UgdG8gZGV2aWNlCisgKiAgICAg
IEBkZXY6IG5ldHdvcmsgZGV2aWNlCisgKgorICogSG9sZCByZWZlcmVuY2UgdG8gZGV2aWNl
IHRvIGtlZXAgaXQgZnJvbSBiZWluZyBmcmVlZC4KKyAqLwordm9pZCBkZXZfaG9sZChzdHJ1
Y3QgbmV0X2RldmljZSAqZGV2KQoreworCXRoaXNfY3B1X2luYygqZGV2LT5wY3B1X3JlZmNu
dCk7CisJdHJhY2VfZGV2X2hvbGQoZGV2KTsKK30KK0VYUE9SVF9TWU1CT0woZGV2X2hvbGQp
OwotLSAKMi4xLjQKCg==
--------------15380C235CBA31142FB5459E--
