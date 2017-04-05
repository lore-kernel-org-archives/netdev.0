From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net/ipv4: use-after-free in ipv4_mtu
Date: Wed, 5 Apr 2017 15:33:40 -0700
Message-ID: <CAM_iQpUk_=oeGoYLb4DGc2+mNw+3Z08mw4wVNKAaDZgsbB1i+g@mail.gmail.com>
References: <CAAeHK+zJ20r8O=MhPY69UPK7sObODp2ByK5136JXgw5U9SMofw@mail.gmail.com>
 <CANn89iKuT+VBZqbJ4=hTAgUbnhuZ0berg0PK+imd1CKuWLy1eQ@mail.gmail.com>
 <CAM_iQpUittpMt-8BpNePWv7iTDasCZuNYTEPnu=K-4sFK5qiBg@mail.gmail.com> <1491360338.10124.39.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a114b3c86284ede054c72fd92
Cc: Eric Dumazet <edumazet@google.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f174.google.com ([209.85.128.174]:33252 "EHLO
        mail-wr0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750825AbdDEWeC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 18:34:02 -0400
In-Reply-To: <1491360338.10124.39.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001a114b3c86284ede054c72fd92
Content-Type: text/plain; charset=UTF-8

On Tue, Apr 4, 2017 at 7:45 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2017-04-04 at 18:11 -0700, Cong Wang wrote:
>> On Tue, Apr 4, 2017 at 11:51 AM, Eric Dumazet <edumazet@google.com> wrote:
>> > Looking at fib->fib_metrics, I fail to understand how the following can work :
>> >
>> > dst_init_metrics(&rt->dst, fi->fib_metrics, true);
>> >
>> > In the cases fi->fib_metrics is _not_ dst_default_metrics,
>> > fi->fib_metrics can be freed when the fib is deleted,
>> > while dst(s) have still the 'read only pointer'.
>> >
>> > RCU grace period before fi->fib_metrics freeing does not help.
>> >
>> > Without refcounts, it looks like we need to copy the fib_metrics.
>>
>> The dst is obtained from sk_dst_cache which is cached for a fast
>> path where fib_info is obtained in fib_lookup() without refcnt:
>>
>>                 err = fib_table_lookup(tb, flp, res, flags | FIB_LOOKUP_NOREF);
>>
>>
>> ...
>>                         if (!(fib_flags & FIB_LOOKUP_NOREF))
>>                                 atomic_inc(&fi->fib_clntref);
>>
>>
>> This probably starts from:
>>
>> commit ebc0ffae5dfb4447e0a431ffe7fe1d467c48bbb9
>> Author: Eric Dumazet <eric.dumazet@gmail.com>
>> Date:   Tue Oct 5 10:41:36 2010 +0000
>>
>>     fib: RCU conversion of fib_lookup()
>
> Interesting. I might had too many beers tonight, but ...
>
> refcount was removed in 2860583fe840 many months later

Good find! I missed the refcnt in rt_set_nexthop() before that commit.

We need to revert that commit to restore the refcnt for fib_info.

--001a114b3c86284ede054c72fd92
Content-Type: text/plain; charset=US-ASCII; name="ipv4-fib-info.diff"
Content-Disposition: attachment; filename="ipv4-fib-info.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_j15ju5xs0

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L3JvdXRlLmggYi9pbmNsdWRlL25ldC9yb3V0ZS5oCmlu
ZGV4IGMwODc0YzguLjM5MTdkMGEgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvbmV0L3JvdXRlLmgKKysr
IGIvaW5jbHVkZS9uZXQvcm91dGUuaApAQCAtNjksNiArNjksNyBAQCBzdHJ1Y3QgcnRhYmxlIHsK
IAogCXN0cnVjdCBsaXN0X2hlYWQJcnRfdW5jYWNoZWQ7CiAJc3RydWN0IHVuY2FjaGVkX2xpc3QJ
KnJ0X3VuY2FjaGVkX2xpc3Q7CisJc3RydWN0IGZpYl9pbmZvCQkqZmk7IC8qIGZvciByZWZjbnQg
dG8gc2hhcmVkIG1ldHJpY3MgKi8KIH07CiAKIHN0YXRpYyBpbmxpbmUgYm9vbCBydF9pc19pbnB1
dF9yb3V0ZShjb25zdCBzdHJ1Y3QgcnRhYmxlICpydCkKZGlmZiAtLWdpdCBhL25ldC9pcHY0L3Jv
dXRlLmMgYi9uZXQvaXB2NC9yb3V0ZS5jCmluZGV4IDg0NzFkZDEuLjUxNGQ3ZTkgMTAwNjQ0Ci0t
LSBhL25ldC9pcHY0L3JvdXRlLmMKKysrIGIvbmV0L2lwdjQvcm91dGUuYwpAQCAtMTM5MSw2ICsx
MzkxLDExIEBAIHN0YXRpYyB2b2lkIGlwdjRfZHN0X2Rlc3Ryb3koc3RydWN0IGRzdF9lbnRyeSAq
ZHN0KQogewogCXN0cnVjdCBydGFibGUgKnJ0ID0gKHN0cnVjdCBydGFibGUgKikgZHN0OwogCisJ
aWYgKHJ0LT5maSkgeworCQlmaWJfaW5mb19wdXQocnQtPmZpKTsKKwkJcnQtPmZpID0gTlVMTDsK
Kwl9CisKIAlpZiAoIWxpc3RfZW1wdHkoJnJ0LT5ydF91bmNhY2hlZCkpIHsKIAkJc3RydWN0IHVu
Y2FjaGVkX2xpc3QgKnVsID0gcnQtPnJ0X3VuY2FjaGVkX2xpc3Q7CiAKQEAgLTE0MjgsNiArMTQz
MywxNiBAQCBzdGF0aWMgYm9vbCBydF9jYWNoZV92YWxpZChjb25zdCBzdHJ1Y3QgcnRhYmxlICpy
dCkKIAkJIXJ0X2lzX2V4cGlyZWQocnQpOwogfQogCitzdGF0aWMgdm9pZCBydF9pbml0X21ldHJp
Y3Moc3RydWN0IHJ0YWJsZSAqcnQsIHN0cnVjdCBmaWJfaW5mbyAqZmkpCit7CisJaWYgKGZpLT5m
aWJfbWV0cmljcyAhPSAodTMyICopIGRzdF9kZWZhdWx0X21ldHJpY3MpIHsKKwkJZmliX2luZm9f
aG9sZChmaSk7CisJCXJ0LT5maSA9IGZpOworCX0KKworCWRzdF9pbml0X21ldHJpY3MoJnJ0LT5k
c3QsIGZpLT5maWJfbWV0cmljcywgdHJ1ZSk7Cit9CisKIHN0YXRpYyB2b2lkIHJ0X3NldF9uZXh0
aG9wKHN0cnVjdCBydGFibGUgKnJ0LCBfX2JlMzIgZGFkZHIsCiAJCQkgICBjb25zdCBzdHJ1Y3Qg
ZmliX3Jlc3VsdCAqcmVzLAogCQkJICAgc3RydWN0IGZpYl9uaF9leGNlcHRpb24gKmZuaGUsCkBA
IC0xNDQyLDcgKzE0NTcsNyBAQCBzdGF0aWMgdm9pZCBydF9zZXRfbmV4dGhvcChzdHJ1Y3QgcnRh
YmxlICpydCwgX19iZTMyIGRhZGRyLAogCQkJcnQtPnJ0X2dhdGV3YXkgPSBuaC0+bmhfZ3c7CiAJ
CQlydC0+cnRfdXNlc19nYXRld2F5ID0gMTsKIAkJfQotCQlkc3RfaW5pdF9tZXRyaWNzKCZydC0+
ZHN0LCBmaS0+ZmliX21ldHJpY3MsIHRydWUpOworCQlydF9pbml0X21ldHJpY3MocnQsIGZpKTsK
ICNpZmRlZiBDT05GSUdfSVBfUk9VVEVfQ0xBU1NJRAogCQlydC0+ZHN0LnRjbGFzc2lkID0gbmgt
Pm5oX3RjbGFzc2lkOwogI2VuZGlmCkBAIC0xNDk0LDYgKzE1MDksNyBAQCBzdHJ1Y3QgcnRhYmxl
ICpydF9kc3RfYWxsb2Moc3RydWN0IG5ldF9kZXZpY2UgKmRldiwKIAkJcnQtPnJ0X2dhdGV3YXkg
PSAwOwogCQlydC0+cnRfdXNlc19nYXRld2F5ID0gMDsKIAkJcnQtPnJ0X3RhYmxlX2lkID0gMDsK
KwkJcnQtPmZpID0gTlVMTDsKIAkJSU5JVF9MSVNUX0hFQUQoJnJ0LT5ydF91bmNhY2hlZCk7CiAK
IAkJcnQtPmRzdC5vdXRwdXQgPSBpcF9vdXRwdXQ7Cg==
--001a114b3c86284ede054c72fd92--
