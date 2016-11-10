From: Hisashi T Fujinaka <htodd@twofifty.com>
Subject: Re: [Intel-wired-lan] [PATCH] igb: use igb_adapter->io_addr instead
 of e1000_hw->hw_addr
Date: Thu, 10 Nov 2016 05:48:20 -0800 (PST)
Message-ID: <alpine.NEB.2.20.17.1611100544220.6177@chris.i8u.org>
References: <1478588780-24480-1-git-send-email-caoj.fnst@cn.fujitsu.com> <20161108164214.GF31855@calimero.vinschen.de> <alpine.NEB.2.20.17.1611080910530.6177@chris.i8u.org> <20161108183739.GA3744@calimero.vinschen.de> <CAKgT0UeaoGfOOC1=h4pGk+=FDd5EqvgRGAdk1StLuiW1-M8tVA@mail.gmail.com>
 <20161110093549.GA24351@calimero.vinschen.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="0-397275043-1478785700=:6177"
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
        Netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Cao jin <caoj.fnst@cn.fujitsu.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        =?ISO-2022-JP?Q?Izumi=2C_Taku=2F=1B$B=40t=1B=28J_=1B$BBs=1B=28J?=
        <izumi.taku@jp.fujitsu.com>
To: Corinna Vinschen <vinschen@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161110093549.GA24351@calimero.vinschen.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--0-397275043-1478785700=:6177
Content-Type: text/plain; format=flowed; charset=US-ASCII

On Thu, 10 Nov 2016, Corinna Vinschen wrote:

> On Nov  8 11:33, Alexander Duyck wrote:
...
>> The question I would have is what is reading the device when it is in
>> this state.  The watchdog and any other functions that would read the
>> device should be disabled.
>>
>> One possibility could be a race between a call to igb_close and the
>> igb_suspend function.  We have seen some of those pop up recently on
>> ixgbe and it looks like igb has the same bug.  We should probably be
>> using the rtnl_lock to guarantee that netif_device_detach and the call
>> to __igb_close are completed before igb_close could possibly be called
>> by the network stack.
>
> Do you have a pointer to the related ixgbe patch, by any chance?
...
>> The thing is that a suspended device should not be accessed at all.
>> If we are accessing it while it is suspended then that is a bug.  If
>> you could throw a WARN_ON call in igb_rd32 to capture where this is
>> being triggered that might be useful.
>>
>>> - Otherwise assume it's actually a surprise removal.  In theory that
>>>   should somehow trigger a device removal sequence, kind of like
>>>   calling igb_remove, no?
>>
>> Well a read of the MMIO region while suspended is more of a surprise
>> read since there shouldn't be anything going on.  We need to isolate
>> where that read is coming from and fix it.
>
> That would be ideal, but the problem couldn't be reproduced yet apart
> from at a customer's customer site.  It's not clear yet if we can access
> the machine for further testing.

Here's the initial patch for igb I have, but it's on hold awaiting more
changes in ixgbe regarding AER.

-- 
Hisashi T Fujinaka - htodd@twofifty.com
BSEE + BSChem + BAEnglish + MSCS + $2.50 = coffee
--0-397275043-1478785700=:6177
Content-Type: text/plain; charset=US-ASCII; name=igb.patch
Content-Transfer-Encoding: BASE64
Content-ID: <alpine.NEB.2.20.17.1611100548200.6177@chris.i8u.org>
Content-Description: 
Content-Disposition: attachment; filename=igb.patch

RnJvbSB0b2RkLmZ1amluYWthQGludGVsLmNvbSBUaHUgTm92IDEwIDA1OjQ0
OjAyIDIwMTYNCkRhdGU6IFRodSwgMTAgTm92IDIwMTYgMDU6MzY6MTMgLTA4
MDANCkZyb206IFRvZGQgRnVqaW5ha2EgPHRvZGQuZnVqaW5ha2FAaW50ZWwu
Y29tPg0KVG86IGh0b2RkQHR3b2ZpZnR5LmNvbQ0KU3ViamVjdDogW1BBVENI
XSBpZ2I6IGhhbmRsZSBjbG9zZS9zdXNwZW5kIHJhY2UgbmV0aWZfZGV2aWNl
X2RldGFjaA0KDQpTaW1pbGFyIHRvIGl4Z2JlLCB3aGVuIGFuIGludGVyZmFj
ZSBpcyBwYXJ0IG9mIGEgbmFtZXNwYWNlIGl0IGlzDQpwb3NzaWJsZSB0aGF0
IGlnYl9jbG9zZSgpIG1heSBiZSBjYWxsZWQgd2hpbGUgX19pZ2Jfc2h1dGRv
d24oKSBpcw0KcnVubmluZyBlbmRpbmcgdXAgaW4gYSBkb3VibGUgZnJlZSBX
QVJOIGFuZC9vciBhIEJVRyBpbg0KZnJlZV9tc2lfaXJxcygpLg0KDQpFeHRl
bmQgdGhlIHJ0bmxfbG9jaygpIHRvIHByb3RlY3QgdGhlIGNhbGwgdG8gbmV0
aWZfZGV2aWNlX2RldGFjaCgpIGFuZA0KaWdiX2NsZWFyX2ludGVycnVwdF9z
Y2hlbWUoKSBpbiBfX2lnYl9zaHV0ZG93bigpIGFuZCBjaGVjayBmb3INCm5l
dGlmX2RldmljZV9wcmVzZW50KCkgdG8gYXZvaWQgY2xlYXJpbmcgdGhlIGlu
dGVycnVwdHMgc2Vjb25kIHRpbWUgaW4NCmlnYl9jbG9zZSgpLg0KDQpTaWdu
ZWQtb2ZmLWJ5OiBUb2RkIEZ1amluYWthIDx0b2RkLmZ1amluYWthQGludGVs
LmNvbT4NCi0tLQ0KIGRyaXZlcnMvbmV0L2V0aGVybmV0L2ludGVsL2lnYi9p
Z2JfbWFpbi5jIHwgMjQgKysrKysrKysrKysrKysrLS0tLS0tLS0tDQogMSBm
aWxlIGNoYW5nZWQsIDE1IGluc2VydGlvbnMoKyksIDkgZGVsZXRpb25zKC0p
DQoNCmRpZmYgLS1naXQgYS9kcml2ZXJzL25ldC9ldGhlcm5ldC9pbnRlbC9p
Z2IvaWdiX21haW4uYyBiL2RyaXZlcnMvbmV0L2V0aGVybmV0L2ludGVsL2ln
Yi9pZ2JfbWFpbi5jDQppbmRleCA0ZmVjYTY5Li5jZTVhZGQ2IDEwMDY0NA0K
LS0tIGEvZHJpdmVycy9uZXQvZXRoZXJuZXQvaW50ZWwvaWdiL2lnYl9tYWlu
LmMNCisrKyBiL2RyaXZlcnMvbmV0L2V0aGVybmV0L2ludGVsL2lnYi9pZ2Jf
bWFpbi5jDQpAQCAtMzI3NSw3ICszMjc1LDEwIEBAIHN0YXRpYyBpbnQgX19p
Z2JfY2xvc2Uoc3RydWN0IG5ldF9kZXZpY2UgKm5ldGRldiwgYm9vbCBzdXNw
ZW5kaW5nKQ0KIA0KIGludCBpZ2JfY2xvc2Uoc3RydWN0IG5ldF9kZXZpY2Ug
Km5ldGRldikNCiB7DQotCXJldHVybiBfX2lnYl9jbG9zZShuZXRkZXYsIGZh
bHNlKTsNCisJaWYgKG5ldGlmX2RldmljZV9wcmVzZW50KG5ldGRldikpDQor
CQlyZXR1cm4gX19pZ2JfY2xvc2UobmV0ZGV2LCBmYWxzZSk7DQorDQorCXJl
dHVybiAwOw0KIH0NCiANCiAvKioNCkBAIC03NTM3LDYgKzc1NDAsNyBAQCBz
dGF0aWMgaW50IF9faWdiX3NodXRkb3duKHN0cnVjdCBwY2lfZGV2ICpwZGV2
LCBib29sICplbmFibGVfd2FrZSwNCiAJaW50IHJldHZhbCA9IDA7DQogI2Vu
ZGlmDQogDQorCXJ0bmxfbG9jaygpOw0KIAluZXRpZl9kZXZpY2VfZGV0YWNo
KG5ldGRldik7DQogDQogCWlmIChuZXRpZl9ydW5uaW5nKG5ldGRldikpDQpA
QCAtNzU0NSw2ICs3NTQ5LDcgQEAgc3RhdGljIGludCBfX2lnYl9zaHV0ZG93
bihzdHJ1Y3QgcGNpX2RldiAqcGRldiwgYm9vbCAqZW5hYmxlX3dha2UsDQog
CWlnYl9wdHBfc3VzcGVuZChhZGFwdGVyKTsNCiANCiAJaWdiX2NsZWFyX2lu
dGVycnVwdF9zY2hlbWUoYWRhcHRlcik7DQorCXJ0bmxfdW5sb2NrKCk7DQog
DQogI2lmZGVmIENPTkZJR19QTQ0KIAlyZXR2YWwgPSBwY2lfc2F2ZV9zdGF0
ZShwZGV2KTsNCkBAIC03NjYzLDE2ICs3NjY4LDE3IEBAIHN0YXRpYyBpbnQg
aWdiX3Jlc3VtZShzdHJ1Y3QgZGV2aWNlICpkZXYpDQogDQogCXdyMzIoRTEw
MDBfV1VTLCB+MCk7DQogDQotCWlmIChuZXRkZXYtPmZsYWdzICYgSUZGX1VQ
KSB7DQotCQlydG5sX2xvY2soKTsNCisJcnRubF9sb2NrKCk7DQorDQorCWlm
ICghZXJyICYmIG5ldGlmX3J1bm5pbmcobmV0ZGV2KSkNCiAJCWVyciA9IF9f
aWdiX29wZW4obmV0ZGV2LCB0cnVlKTsNCi0JCXJ0bmxfdW5sb2NrKCk7DQot
CQlpZiAoZXJyKQ0KLQkJCXJldHVybiBlcnI7DQotCX0NCiANCi0JbmV0aWZf
ZGV2aWNlX2F0dGFjaChuZXRkZXYpOw0KLQlyZXR1cm4gMDsNCisJaWYgKCFl
cnIpDQorCQluZXRpZl9kZXZpY2VfYXR0YWNoKG5ldGRldik7DQorDQorCXJ0
bmxfdW5sb2NrKCk7DQorDQorCXJldHVybiBlcnI7DQogfQ0KIA0KIHN0YXRp
YyBpbnQgaWdiX3J1bnRpbWVfaWRsZShzdHJ1Y3QgZGV2aWNlICpkZXYpDQot
LSANCjIuNy40DQo=

--0-397275043-1478785700=:6177--
