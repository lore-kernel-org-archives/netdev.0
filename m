From: Wei Wang <weiwan@google.com>
Subject: Re: unregister_netdevice: waiting for eth0 to become free. Usage
 count = 1
Date: Wed, 9 Aug 2017 22:41:00 -0700
Message-ID: <CAEA6p_AOcNkAWPc7NFBnr8QWi3eHdJiQ2=8D_DB_XthwSDL2+Q@mail.gmail.com>
References: <CALAqxLWVYgnTnwAwm7uNQ6P_Z8xFd96NQ+G_j1qT+h5F6habag@mail.gmail.com>
 <CALAqxLXG8X2nkLEHM63oiY=M17vcpU2+-ec7x_aBWDCqrj4U-Q@mail.gmail.com>
 <CAM_iQpW2=aKKUmWanbuhqXdZGxr_TqB5pQ+U+A0+=optuGX5-Q@mail.gmail.com>
 <CALAqxLXv60ReJu26omM6p=ZboEm-Z-3w+q0JcxLXDqqK5ohNoQ@mail.gmail.com>
 <CAEA6p_AL8uUghtZgp4OmqygcFs-Jiy286P5r6tRd+yeSWxR3KA@mail.gmail.com>
 <CALAqxLXY-kE2N__eDq514cLycR0-QRpyOCMWpdttO6fgovE2rg@mail.gmail.com> <CAEA6p_C_rEYkJhcniyy6HUHgNxWFoxWzZ-WHsaSmNDwx4D+RXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="001a1145799841d42405565fa4bd"
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        lkml <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Linux USB List <linux-usb@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Felipe Balbi <felipe.balbi@linux.intel.com>
To: John Stultz <john.stultz@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEA6p_C_rEYkJhcniyy6HUHgNxWFoxWzZ-WHsaSmNDwx4D+RXQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--001a1145799841d42405565fa4bd
Content-Type: text/plain; charset="UTF-8"

Hi John,

Is it possible to try the attached patch?
I am not sure if it actually fixes the issue. But I think it is worth a try.
Also, could you get me all the ipv6 routes when you plug in the usb
using "ip -6 route show"? (If you have multiple routing tables
configured, could you dump them all?)

Thanks a lot.
Wei

On Wed, Aug 9, 2017 at 6:36 PM, Wei Wang <weiwan@google.com> wrote:
> On Wed, Aug 9, 2017 at 6:26 PM, John Stultz <john.stultz@linaro.org> wrote:
>> On Wed, Aug 9, 2017 at 5:36 PM, Wei Wang <weiwan@google.com> wrote:
>>> On Wed, Aug 9, 2017 at 4:44 PM, John Stultz <john.stultz@linaro.org> wrote:
>>>> On Wed, Aug 9, 2017 at 4:34 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>>>>> (Cc'ing Wei whose commit was blamed)
>>>>>
>>>>> On Mon, Aug 7, 2017 at 2:15 PM, John Stultz <john.stultz@linaro.org> wrote:
>>>>>> On Mon, Aug 7, 2017 at 2:05 PM, John Stultz <john.stultz@linaro.org> wrote:
>>>>>>> So, with recent testing with my HiKey board, I've been noticing some
>>>>>>> quirky behavior with my USB eth adapter.
>>>>>>>
>>>>>>> Basically, pluging the usb eth adapter in and then removing it, when
>>>>>>> plugging it back in I often find that its not detected, and the system
>>>>>>> slowly spits out the following message over and over:
>>>>>>>   unregister_netdevice: waiting for eth0 to become free. Usage count = 1
>>>>>>
>>>>>> The other bit is that after this starts printing, the board will no
>>>>>> longer reboot (it hangs continuing to occasionally print the above
>>>>>> message), and I have to manually reset the device.
>>>>>>
>>>>>
>>>>> So this warning is not temporarily shown but lasts until a reboot,
>>>>> right? If so it is a dst refcnt leak.
>>>>
>>>> Correct, once I get into the state it lasts until a reboot.
>>>>
>>>>> How reproducible is it for you? From my reading, it seems always
>>>>> reproduced when you unplug and plug your usb eth interface?
>>>>> Is there anything else involved? For example, network namespace.
>>>>
>>>> So with 4.13-rc3/4 I seem to trigger it easily, often with the first
>>>> unplug of the USB eth adapter.
>>>>
>>>> But as I get back closer to 4.12, it seemingly becomes harder to
>>>> trigger, but sometimes still happens.
>>>>
>>>> So far, I've not been able to trigger it with 4.12.
>>>>
>>>> I don't think network namespaces are involved?  Though its out of my
>>>> area, so AOSP may be using them these days.  Is there a simple way to
>>>> check?
>>>>
>>>> I'll also do another bisection to see if the bad point moves back any further.
>>
>> So I went through another bisection around and got  9514528d92d4 ipv6:
>> call dst_dev_put() properly as the first bad commit again.
>>
>>> If you see the problem starts to happen on commit
>>> 9514528d92d4cbe086499322370155ed69f5d06c, could you try reverting all
>>> the following commits:
>>> (from new to old)
>>> 1eb04e7c9e63 net: reorder all the dst flags
>>> a4c2fd7f7891 net: remove DST_NOCACHE flag
>>> b2a9c0ed75a3 net: remove DST_NOGC flag
>>> 5b7c9a8ff828 net: remove dst gc related code
>>> db916649b5dd ipv6: get rid of icmp6 dst garbage collector
>>> 587fea741134 ipv6: mark DST_NOGC and remove the operation of dst_free()
>>> ad65a2f05695 ipv6: call dst_hold_safe() properly
>>> 9514528d92d4 ipv6: call dst_dev_put() properly
>>
>>
>> And reverting this set off of 4.13-rc4 seems to make the issue go away.
>>
>> Is there anything I can test to help narrow down the specific problem
>> with that patchset?
>>
>
> Thanks John for confirming.
> Let me spend some time on the commits and I will let you know if I
> have some debug image for you to try.
>
> Wei
>
>
>> thanks
>> -john

--001a1145799841d42405565fa4bd
Content-Type: text/x-patch; charset="US-ASCII";
	name="0001-ipv6-unregister-netdev-bug-fix.patch"
Content-Disposition: attachment;
	filename="0001-ipv6-unregister-netdev-bug-fix.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_j660aiej0

RnJvbSA5M2YyODM2Njc5YzgxOTE1YjExMGZmNTY2MTdmOWY1ZGFlMmU2OTI3IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBXZWkgV2FuZyA8d2Vpd2FuQGdvb2dsZS5jb20+CkRhdGU6IFdl
ZCwgOSBBdWcgMjAxNyAyMjoyNzozNiAtMDcwMApTdWJqZWN0OiBbUEFUQ0hdIGlwdjY6IHVucmVn
aXN0ZXIgbmV0ZGV2IGJ1ZyBmaXgKCkNoYW5nZS1JZDogSTMwZmE3Mzk5ODlhYzUwZmJjN2Y0Y2Jj
NmEwNDEzMDAwNTU4OWNjMjUKLS0tCiBpbmNsdWRlL25ldC9pcDZfcm91dGUuaCB8ICAxICsKIG5l
dC9pcHY2L2FkZHJjb25mLmMgICAgIHwgMTAgKysrKysrKy0tLQogbmV0L2lwdjYvYW55Y2FzdC5j
ICAgICAgfCAgMyArKy0KIG5ldC9pcHY2L3JvdXRlLmMgICAgICAgIHwgIDIgKy0KIDQgZmlsZXMg
Y2hhbmdlZCwgMTEgaW5zZXJ0aW9ucygrKSwgNSBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9p
bmNsdWRlL25ldC9pcDZfcm91dGUuaCBiL2luY2x1ZGUvbmV0L2lwNl9yb3V0ZS5oCmluZGV4IDkw
N2QzOWE0MmY2Yi4uZGVjMTQyNGNlNjE5IDEwMDY0NAotLS0gYS9pbmNsdWRlL25ldC9pcDZfcm91
dGUuaAorKysgYi9pbmNsdWRlL25ldC9pcDZfcm91dGUuaApAQCAtOTQsNiArOTQsNyBAQCBpbnQg
aXB2Nl9yb3V0ZV9pb2N0bChzdHJ1Y3QgbmV0ICpuZXQsIHVuc2lnbmVkIGludCBjbWQsIHZvaWQg
X191c2VyICphcmcpOwogaW50IGlwNl9yb3V0ZV9hZGQoc3RydWN0IGZpYjZfY29uZmlnICpjZmcs
IHN0cnVjdCBuZXRsaW5rX2V4dF9hY2sgKmV4dGFjayk7CiBpbnQgaXA2X2luc19ydChzdHJ1Y3Qg
cnQ2X2luZm8gKik7CiBpbnQgaXA2X2RlbF9ydChzdHJ1Y3QgcnQ2X2luZm8gKik7Cit2b2lkIHJ0
Nl91bmNhY2hlZF9saXN0X2FkZChzdHJ1Y3QgcnQ2X2luZm8gKnJ0KTsKIAogc3RhdGljIGlubGlu
ZSBpbnQgaXA2X3JvdXRlX2dldF9zYWRkcihzdHJ1Y3QgbmV0ICpuZXQsIHN0cnVjdCBydDZfaW5m
byAqcnQsCiAJCQkJICAgICAgY29uc3Qgc3RydWN0IGluNl9hZGRyICpkYWRkciwKZGlmZiAtLWdp
dCBhL25ldC9pcHY2L2FkZHJjb25mLmMgYi9uZXQvaXB2Ni9hZGRyY29uZi5jCmluZGV4IDNjNDZl
OTUxM2EzMS4uMDZhMjdhZGRiOTNjIDEwMDY0NAotLS0gYS9uZXQvaXB2Ni9hZGRyY29uZi5jCisr
KyBiL25ldC9pcHY2L2FkZHJjb25mLmMKQEAgLTMwNzksNyArMzA3OSw4IEBAIHN0YXRpYyB2b2lk
IGluaXRfbG9vcGJhY2soc3RydWN0IG5ldF9kZXZpY2UgKmRldikKIAkJCS8qIEZhaWx1cmUgY2Fz
ZXMgYXJlIGlnbm9yZWQgKi8KIAkJCWlmICghSVNfRVJSKHNwX3J0KSkgewogCQkJCXNwX2lmYS0+
cnQgPSBzcF9ydDsKLQkJCQlpcDZfaW5zX3J0KHNwX3J0KTsKKwkJCQlpZiAoaXA2X2luc19ydChz
cF9ydCkpCisJCQkJCXJ0Nl91bmNhY2hlZF9saXN0X2FkZChzcF9ydCk7CiAJCQl9CiAJCX0KIAkJ
cmVhZF91bmxvY2tfYmgoJmlkZXYtPmxvY2spOwpAQCAtMzcxMSw2ICszNzEyLDcgQEAgc3RhdGlj
IGludCBhZGRyY29uZl9pZmRvd24oc3RydWN0IG5ldF9kZXZpY2UgKmRldiwgaW50IGhvdykKIAkJ
CXJ0ID0gaWZhLT5ydDsKIAkJCWlmYS0+cnQgPSBOVUxMOwogCQl9IGVsc2UgeworCQkJcnQ2X3Vu
Y2FjaGVkX2xpc3RfYWRkKGlmYS0+cnQpOwogCQkJc3RhdGUgPSBpZmEtPnN0YXRlOwogCQkJaWZh
LT5zdGF0ZSA9IElORVQ2X0lGQUREUl9TVEFURV9ERUFEOwogCQl9CkBAIC0zODgyLDcgKzM4ODQs
OCBAQCBzdGF0aWMgdm9pZCBhZGRyY29uZl9kYWRfYmVnaW4oc3RydWN0IGluZXQ2X2lmYWRkciAq
aWZwKQogCSAqIEZyYW1lcyByaWdodCBhd2F5CiAJICovCiAJaWYgKGlmcC0+ZmxhZ3MgJiBJRkFf
Rl9PUFRJTUlTVElDKSB7Ci0JCWlwNl9pbnNfcnQoaWZwLT5ydCk7CisJCWlmIChpcDZfaW5zX3J0
KGlmcC0+cnQpKQorCQkJcnQ2X3VuY2FjaGVkX2xpc3RfYWRkKGlmcC0+cnQpOwogCQlpZiAoaXB2
Nl91c2Vfb3B0aW1pc3RpY19hZGRyKGlkZXYpKSB7CiAJCQkvKiBCZWNhdXNlIG9wdGltaXN0aWMg
bm9kZXMgY2FuIHVzZSB0aGlzIGFkZHJlc3MsCiAJCQkgKiBub3RpZnkgbGlzdGVuZXJzLiBJZiBE
QUQgZmFpbHMsIFJUTV9ERUxBRERSIGlzIHNlbnQuCkBAIC01NTU3LDcgKzU1NjAsOCBAQCBzdGF0
aWMgdm9pZCBfX2lwdjZfaWZhX25vdGlmeShpbnQgZXZlbnQsIHN0cnVjdCBpbmV0Nl9pZmFkZHIg
KmlmcCkKIAkJICogdG8gZG8gaXQgYWdhaW4KIAkJICovCiAJCWlmICghKGlmcC0+cnQtPnJ0Nmlf
bm9kZSkpCi0JCQlpcDZfaW5zX3J0KGlmcC0+cnQpOworCQkJaWYoaXA2X2luc19ydChpZnAtPnJ0
KSkKKwkJCQlydDZfdW5jYWNoZWRfbGlzdF9hZGQoaWZwLT5ydCk7CiAJCWlmIChpZnAtPmlkZXYt
PmNuZi5mb3J3YXJkaW5nKQogCQkJYWRkcmNvbmZfam9pbl9hbnljYXN0KGlmcCk7CiAJCWlmICgh
aXB2Nl9hZGRyX2FueSgmaWZwLT5wZWVyX2FkZHIpKQpkaWZmIC0tZ2l0IGEvbmV0L2lwdjYvYW55
Y2FzdC5jIGIvbmV0L2lwdjYvYW55Y2FzdC5jCmluZGV4IDBiYmFiOGE0YjVkOC4uZTIxYzJkNmQ5
Yjk1IDEwMDY0NAotLS0gYS9uZXQvaXB2Ni9hbnljYXN0LmMKKysrIGIvbmV0L2lwdjYvYW55Y2Fz
dC5jCkBAIC0yODMsNyArMjgzLDggQEAgaW50IF9faXB2Nl9kZXZfYWNfaW5jKHN0cnVjdCBpbmV0
Nl9kZXYgKmlkZXYsIGNvbnN0IHN0cnVjdCBpbjZfYWRkciAqYWRkcikKIAlhY2FfZ2V0KGFjYSk7
CiAJd3JpdGVfdW5sb2NrX2JoKCZpZGV2LT5sb2NrKTsKIAotCWlwNl9pbnNfcnQocnQpOworCWlm
ICghaXA2X2luc19ydChydCkpCisJCXJ0Nl91bmNhY2hlZF9saXN0X2FkZChydCk7CiAKIAlhZGRy
Y29uZl9qb2luX3NvbGljdChpZGV2LT5kZXYsICZhY2EtPmFjYV9hZGRyKTsKIApkaWZmIC0tZ2l0
IGEvbmV0L2lwdjYvcm91dGUuYyBiL25ldC9pcHY2L3JvdXRlLmMKaW5kZXggNGQzMGM5NmE4MTlk
Li43YTcyOTlkYTRlMDkgMTAwNjQ0Ci0tLSBhL25ldC9pcHY2L3JvdXRlLmMKKysrIGIvbmV0L2lw
djYvcm91dGUuYwpAQCAtMTI0LDcgKzEyNCw3IEBAIHN0cnVjdCB1bmNhY2hlZF9saXN0IHsKIAog
c3RhdGljIERFRklORV9QRVJfQ1BVX0FMSUdORUQoc3RydWN0IHVuY2FjaGVkX2xpc3QsIHJ0Nl91
bmNhY2hlZF9saXN0KTsKIAotc3RhdGljIHZvaWQgcnQ2X3VuY2FjaGVkX2xpc3RfYWRkKHN0cnVj
dCBydDZfaW5mbyAqcnQpCit2b2lkIHJ0Nl91bmNhY2hlZF9saXN0X2FkZChzdHJ1Y3QgcnQ2X2lu
Zm8gKnJ0KQogewogCXN0cnVjdCB1bmNhY2hlZF9saXN0ICp1bCA9IHJhd19jcHVfcHRyKCZydDZf
dW5jYWNoZWRfbGlzdCk7CiAKLS0gCjIuMTQuMC40MzQuZzk4MDk2ZmQ3YTgtZ29vZwoK
--001a1145799841d42405565fa4bd--
