From: David Ahern <dsahern@gmail.com>
Subject: Re: Long stalls creating a new netns after a netns with a SMB client
 exits
Date: Fri, 28 Jul 2017 13:16:54 -0600
Message-ID: <4a56fd38-11f6-4824-bdab-d0f2d46cdf51@gmail.com>
References: <CA+pO-2cm7bz861KvPMpugP8rVwf6rU8QYrVq7PVO-ZXx2kh1fw@mail.gmail.com>
 <CAM_iQpW+gSgCDWdGoHvN0wObda_g40FcyCBem5VVJ4XLHNMRaQ@mail.gmail.com>
 <CA+pO-2cUUy=_Krwnvt5GL-DUsu+oBOHwhF-TE8sqW=7PFMBrbA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------D2A19D865A3A81058042CB46"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Rolf Neugebauer <rolf.neugebauer@docker.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33692 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752385AbdG1TQ4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 15:16:56 -0400
Received: by mail-pf0-f176.google.com with SMTP id d67so31201383pfc.0
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 12:16:56 -0700 (PDT)
In-Reply-To: <CA+pO-2cUUy=_Krwnvt5GL-DUsu+oBOHwhF-TE8sqW=7PFMBrbA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------D2A19D865A3A81058042CB46
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

On 7/28/17 12:58 PM, Rolf Neugebauer wrote:
>>> I can readily reproduce this on 4.9.39, 4.11.12 and another user
>>> repro-ed it on 4.12.3. It seems to happen every time. At least one
>>> user reported issues with NFS mounts as well, but we were not able to
>>> reproduce it. It's not clear to me if this is directly related to
>>> 'mount.cifs' or if that just happens to reliably repro it.
>>
>> OK, so commit d747a7a51b00984127a88113c does not help this case
>> either.
> 
> d747a7a51b009("tcp: reset sk_rx_dst in tcp_disconnect()") indeed seems
> a different issue. As I understand that actually caused the ref count
> never to get decremented, while here eventually some cleanup kicks in
> after a long timeout.

It could be a dst is cached on a socket and does not get cleared until
the socket time outs are done.

Test that theory by something like this for IPv4 TCP (similar change for
UDP if the client is UDP based):

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 3a19ea28339f..37db087b6c97 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1855,7 +1855,7 @@ void inet_sk_rx_dst_set(struct sock *sk, const
struct sk_buff *skb)
 {
        struct dst_entry *dst = skb_dst(skb);

-       if (dst && dst_hold_safe(dst)) {
+       if (0 && dst && dst_hold_safe(dst)) {
                sk->sk_rx_dst = dst;
                inet_sk(sk)->rx_dst_ifindex = skb->skb_iif;
        }

> 
> I'll also try if I can get some traces out of dev_hold()/dev_put().


Attached patch puts tracepoints in dev_hold / dev_put; very useful for
debugging cases like this. Use perf record and perf script.

--------------D2A19D865A3A81058042CB46
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
dF9kZXZpY2UgKmRldikKK3sKKwl0cmFjZV9kZXZfcHV0KGRldik7CisJdGhpc19jcHVfZGVj
KCpkZXYtPnBjcHVfcmVmY250KTsKK30KK0VYUE9SVF9TWU1CT0woZGV2X3B1dCk7CisKKy8q
KgorICogICAgICBkZXZfaG9sZCAtIGdldCByZWZlcmVuY2UgdG8gZGV2aWNlCisgKiAgICAg
IEBkZXY6IG5ldHdvcmsgZGV2aWNlCisgKgorICogSG9sZCByZWZlcmVuY2UgdG8gZGV2aWNl
IHRvIGtlZXAgaXQgZnJvbSBiZWluZyBmcmVlZC4KKyAqLwordm9pZCBkZXZfaG9sZChzdHJ1
Y3QgbmV0X2RldmljZSAqZGV2KQoreworCXRyYWNlX2Rldl9ob2xkKGRldik7CisJdGhpc19j
cHVfaW5jKCpkZXYtPnBjcHVfcmVmY250KTsKK30KK0VYUE9SVF9TWU1CT0woZGV2X2hvbGQp
OwotLSAKMi4xLjQKCg==
--------------D2A19D865A3A81058042CB46--
