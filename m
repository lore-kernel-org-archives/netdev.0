From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: fs, net: deadlock between bind/splice on af_unix
Date: Thu, 19 Jan 2017 20:57:36 -0800
Message-ID: <CAM_iQpUtirzcm901Gh6918g2yROo3FFKb6Vx87Wtj7M31wE6DA@mail.gmail.com>
References: <CACT4Y+Z981V+QLHr=PnQy1Dvxrpp-nCDhQtf+5HuNAusH+Vqxw@mail.gmail.com>
 <CACT4Y+a-fTzW95ViVP3knhNTa=h6XFB0bMddcyQVeeV+LbXKHw@mail.gmail.com>
 <CAM_iQpXu+fyjmvrYRB9+VJCdSLS=7Jiet762hqWDANfsOM0XWw@mail.gmail.com>
 <20161209013208.GW1555@ZenIV.linux.org.uk> <CAM_iQpXjeG5=wZyQP-yOKcB4WRfgGRjeQ+NDHyeSWwdU50Xh5g@mail.gmail.com>
 <20161209064144.GZ1555@ZenIV.linux.org.uk> <CACT4Y+ad1s6HPdw-ocQ5YfFx7qCeWb3z1k7F9+9KsNmw6+Tszw@mail.gmail.com>
 <CAM_iQpWu+V2E_uxJLUjS+xM+94CKKR+Bv95UrFPuswUAuAGM+w@mail.gmail.com> <CACT4Y+Y_3i=PThhVzHXYnCQm_xN72VQ0eN9Ae4uXyORq_a_Z6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a1147d75a453abf05467f7ec5
Cc: Al Viro <viro@zeniv.linux.org.uk>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Rainer Weikusat <rweikusat@mobileactivedefense.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36325 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751172AbdATE56 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 23:57:58 -0500
In-Reply-To: <CACT4Y+Y_3i=PThhVzHXYnCQm_xN72VQ0eN9Ae4uXyORq_a_Z6w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001a1147d75a453abf05467f7ec5
Content-Type: text/plain; charset=UTF-8

On Wed, Jan 18, 2017 at 1:17 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Tue, Jan 17, 2017 at 10:21 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> On Mon, Jan 16, 2017 at 1:32 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
>>> On Fri, Dec 9, 2016 at 7:41 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>>>> On Thu, Dec 08, 2016 at 10:32:00PM -0800, Cong Wang wrote:
>>>>
>>>>> > Why do we do autobind there, anyway, and why is it conditional on
>>>>> > SOCK_PASSCRED?  Note that e.g. for SOCK_STREAM we can bloody well get
>>>>> > to sending stuff without autobind ever done - just use socketpair()
>>>>> > to create that sucker and we won't be going through the connect()
>>>>> > at all.
>>>>>
>>>>> In the case Dmitry reported, unix_dgram_sendmsg() calls unix_autobind(),
>>>>> not SOCK_STREAM.
>>>>
>>>> Yes, I've noticed.  What I'm asking is what in there needs autobind triggered
>>>> on sendmsg and why doesn't the same need affect the SOCK_STREAM case?
>>>>
>>>>> I guess some lock, perhaps the u->bindlock could be dropped before
>>>>> acquiring the next one (sb_writer), but I need to double check.
>>>>
>>>> Bad idea, IMO - do you *want* autobind being able to come through while
>>>> bind(2) is busy with mknod?
>>>
>>>
>>> Ping. This is still happening on HEAD.
>>>
>>
>> Thanks for your reminder. Mind to give the attached patch (compile only)
>> a try? I take another approach to fix this deadlock, which moves the
>> unix_mknod() out of unix->bindlock. Not sure if there is any unexpected
>> impact with this way.
>
>
> I instantly hit:
>

Oh, sorry about it, I forgot to initialize struct path...

Attached is the updated version, I just did a boot test, no crash at least. ;)

Thanks!

--001a1147d75a453abf05467f7ec5
Content-Type: text/plain; charset=US-ASCII; name="unix.diff"
Content-Disposition: attachment; filename="unix.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_iy5c4cw80

ZGlmZiAtLWdpdCBhL25ldC91bml4L2FmX3VuaXguYyBiL25ldC91bml4L2FmX3VuaXguYwppbmRl
eCAxMjc2NTZlLi5jZWY3OTg3IDEwMDY0NAotLS0gYS9uZXQvdW5peC9hZl91bml4LmMKKysrIGIv
bmV0L3VuaXgvYWZfdW5peC5jCkBAIC05OTUsNiArOTk1LDcgQEAgc3RhdGljIGludCB1bml4X2Jp
bmQoc3RydWN0IHNvY2tldCAqc29jaywgc3RydWN0IHNvY2thZGRyICp1YWRkciwgaW50IGFkZHJf
bGVuKQogCXVuc2lnbmVkIGludCBoYXNoOwogCXN0cnVjdCB1bml4X2FkZHJlc3MgKmFkZHI7CiAJ
c3RydWN0IGhsaXN0X2hlYWQgKmxpc3Q7CisJc3RydWN0IHBhdGggcGF0aCA9IHsgTlVMTCwgTlVM
TCB9OwogCiAJZXJyID0gLUVJTlZBTDsKIAlpZiAoc3VuYWRkci0+c3VuX2ZhbWlseSAhPSBBRl9V
TklYKQpAQCAtMTAxMCw5ICsxMDExLDIwIEBAIHN0YXRpYyBpbnQgdW5peF9iaW5kKHN0cnVjdCBz
b2NrZXQgKnNvY2ssIHN0cnVjdCBzb2NrYWRkciAqdWFkZHIsIGludCBhZGRyX2xlbikKIAkJZ290
byBvdXQ7CiAJYWRkcl9sZW4gPSBlcnI7CiAKKwlpZiAoc3VuX3BhdGhbMF0pIHsKKwkJdW1vZGVf
dCBtb2RlID0gU19JRlNPQ0sgfAorCQkgICAgICAgKFNPQ0tfSU5PREUoc29jayktPmlfbW9kZSAm
IH5jdXJyZW50X3VtYXNrKCkpOworCQllcnIgPSB1bml4X21rbm9kKHN1bl9wYXRoLCBtb2RlLCAm
cGF0aCk7CisJCWlmIChlcnIpIHsKKwkJCWlmIChlcnIgPT0gLUVFWElTVCkKKwkJCQllcnIgPSAt
RUFERFJJTlVTRTsKKwkJCWdvdG8gb3V0OworCQl9CisJfQorCiAJZXJyID0gbXV0ZXhfbG9ja19p
bnRlcnJ1cHRpYmxlKCZ1LT5iaW5kbG9jayk7CiAJaWYgKGVycikKLQkJZ290byBvdXQ7CisJCWdv
dG8gb3V0X3B1dDsKIAogCWVyciA9IC1FSU5WQUw7CiAJaWYgKHUtPmFkZHIpCkBAIC0xMDI5LDE2
ICsxMDQxLDYgQEAgc3RhdGljIGludCB1bml4X2JpbmQoc3RydWN0IHNvY2tldCAqc29jaywgc3Ry
dWN0IHNvY2thZGRyICp1YWRkciwgaW50IGFkZHJfbGVuKQogCWF0b21pY19zZXQoJmFkZHItPnJl
ZmNudCwgMSk7CiAKIAlpZiAoc3VuX3BhdGhbMF0pIHsKLQkJc3RydWN0IHBhdGggcGF0aDsKLQkJ
dW1vZGVfdCBtb2RlID0gU19JRlNPQ0sgfAotCQkgICAgICAgKFNPQ0tfSU5PREUoc29jayktPmlf
bW9kZSAmIH5jdXJyZW50X3VtYXNrKCkpOwotCQllcnIgPSB1bml4X21rbm9kKHN1bl9wYXRoLCBt
b2RlLCAmcGF0aCk7Ci0JCWlmIChlcnIpIHsKLQkJCWlmIChlcnIgPT0gLUVFWElTVCkKLQkJCQll
cnIgPSAtRUFERFJJTlVTRTsKLQkJCXVuaXhfcmVsZWFzZV9hZGRyKGFkZHIpOwotCQkJZ290byBv
dXRfdXA7Ci0JCX0KIAkJYWRkci0+aGFzaCA9IFVOSVhfSEFTSF9TSVpFOwogCQloYXNoID0gZF9i
YWNraW5nX2lub2RlKHBhdGguZGVudHJ5KS0+aV9pbm8gJiAoVU5JWF9IQVNIX1NJWkUgLSAxKTsK
IAkJc3Bpbl9sb2NrKCZ1bml4X3RhYmxlX2xvY2spOwpAQCAtMTA2NSw2ICsxMDY3LDkgQEAgc3Rh
dGljIGludCB1bml4X2JpbmQoc3RydWN0IHNvY2tldCAqc29jaywgc3RydWN0IHNvY2thZGRyICp1
YWRkciwgaW50IGFkZHJfbGVuKQogCXNwaW5fdW5sb2NrKCZ1bml4X3RhYmxlX2xvY2spOwogb3V0
X3VwOgogCW11dGV4X3VubG9jaygmdS0+YmluZGxvY2spOworb3V0X3B1dDoKKwlpZiAoZXJyKQor
CQlwYXRoX3B1dCgmcGF0aCk7CiBvdXQ6CiAJcmV0dXJuIGVycjsKIH0K
--001a1147d75a453abf05467f7ec5--
