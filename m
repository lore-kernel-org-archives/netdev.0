From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: fs, net: deadlock between bind/splice on af_unix
Date: Tue, 17 Jan 2017 13:21:48 -0800
Message-ID: <CAM_iQpWu+V2E_uxJLUjS+xM+94CKKR+Bv95UrFPuswUAuAGM+w@mail.gmail.com>
References: <CACT4Y+Z981V+QLHr=PnQy1Dvxrpp-nCDhQtf+5HuNAusH+Vqxw@mail.gmail.com>
 <CACT4Y+a-fTzW95ViVP3knhNTa=h6XFB0bMddcyQVeeV+LbXKHw@mail.gmail.com>
 <CAM_iQpXu+fyjmvrYRB9+VJCdSLS=7Jiet762hqWDANfsOM0XWw@mail.gmail.com>
 <20161209013208.GW1555@ZenIV.linux.org.uk> <CAM_iQpXjeG5=wZyQP-yOKcB4WRfgGRjeQ+NDHyeSWwdU50Xh5g@mail.gmail.com>
 <20161209064144.GZ1555@ZenIV.linux.org.uk> <CACT4Y+ad1s6HPdw-ocQ5YfFx7qCeWb3z1k7F9+9KsNmw6+Tszw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a114b9db08da50c054650e463
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+ad1s6HPdw-ocQ5YfFx7qCeWb3z1k7F9+9KsNmw6+Tszw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--001a114b9db08da50c054650e463
Content-Type: text/plain; charset=UTF-8

On Mon, Jan 16, 2017 at 1:32 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Fri, Dec 9, 2016 at 7:41 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>> On Thu, Dec 08, 2016 at 10:32:00PM -0800, Cong Wang wrote:
>>
>>> > Why do we do autobind there, anyway, and why is it conditional on
>>> > SOCK_PASSCRED?  Note that e.g. for SOCK_STREAM we can bloody well get
>>> > to sending stuff without autobind ever done - just use socketpair()
>>> > to create that sucker and we won't be going through the connect()
>>> > at all.
>>>
>>> In the case Dmitry reported, unix_dgram_sendmsg() calls unix_autobind(),
>>> not SOCK_STREAM.
>>
>> Yes, I've noticed.  What I'm asking is what in there needs autobind triggered
>> on sendmsg and why doesn't the same need affect the SOCK_STREAM case?
>>
>>> I guess some lock, perhaps the u->bindlock could be dropped before
>>> acquiring the next one (sb_writer), but I need to double check.
>>
>> Bad idea, IMO - do you *want* autobind being able to come through while
>> bind(2) is busy with mknod?
>
>
> Ping. This is still happening on HEAD.
>

Thanks for your reminder. Mind to give the attached patch (compile only)
a try? I take another approach to fix this deadlock, which moves the
unix_mknod() out of unix->bindlock. Not sure if there is any unexpected
impact with this way.

Thanks.

--001a114b9db08da50c054650e463
Content-Type: text/plain; charset=US-ASCII; name="unix.diff"
Content-Disposition: attachment; filename="unix.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_iy20ypnl0

ZGlmZiAtLWdpdCBhL25ldC91bml4L2FmX3VuaXguYyBiL25ldC91bml4L2FmX3VuaXguYwppbmRl
eCAxMjc2NTZlLi41ZDRiNGQxIDEwMDY0NAotLS0gYS9uZXQvdW5peC9hZl91bml4LmMKKysrIGIv
bmV0L3VuaXgvYWZfdW5peC5jCkBAIC05OTUsNiArOTk1LDcgQEAgc3RhdGljIGludCB1bml4X2Jp
bmQoc3RydWN0IHNvY2tldCAqc29jaywgc3RydWN0IHNvY2thZGRyICp1YWRkciwgaW50IGFkZHJf
bGVuKQogCXVuc2lnbmVkIGludCBoYXNoOwogCXN0cnVjdCB1bml4X2FkZHJlc3MgKmFkZHI7CiAJ
c3RydWN0IGhsaXN0X2hlYWQgKmxpc3Q7CisJc3RydWN0IHBhdGggcGF0aDsKIAogCWVyciA9IC1F
SU5WQUw7CiAJaWYgKHN1bmFkZHItPnN1bl9mYW1pbHkgIT0gQUZfVU5JWCkKQEAgLTEwMTAsOSAr
MTAxMSwyMCBAQCBzdGF0aWMgaW50IHVuaXhfYmluZChzdHJ1Y3Qgc29ja2V0ICpzb2NrLCBzdHJ1
Y3Qgc29ja2FkZHIgKnVhZGRyLCBpbnQgYWRkcl9sZW4pCiAJCWdvdG8gb3V0OwogCWFkZHJfbGVu
ID0gZXJyOwogCisJaWYgKHN1bl9wYXRoWzBdKSB7CisJCXVtb2RlX3QgbW9kZSA9IFNfSUZTT0NL
IHwKKwkJICAgICAgIChTT0NLX0lOT0RFKHNvY2spLT5pX21vZGUgJiB+Y3VycmVudF91bWFzaygp
KTsKKwkJZXJyID0gdW5peF9ta25vZChzdW5fcGF0aCwgbW9kZSwgJnBhdGgpOworCQlpZiAoZXJy
KSB7CisJCQlpZiAoZXJyID09IC1FRVhJU1QpCisJCQkJZXJyID0gLUVBRERSSU5VU0U7CisJCQln
b3RvIG91dDsKKwkJfQorCX0KKwogCWVyciA9IG11dGV4X2xvY2tfaW50ZXJydXB0aWJsZSgmdS0+
YmluZGxvY2spOwogCWlmIChlcnIpCi0JCWdvdG8gb3V0OworCQlnb3RvIG91dF9wdXQ7CiAKIAll
cnIgPSAtRUlOVkFMOwogCWlmICh1LT5hZGRyKQpAQCAtMTAyOSwxNiArMTA0MSw2IEBAIHN0YXRp
YyBpbnQgdW5peF9iaW5kKHN0cnVjdCBzb2NrZXQgKnNvY2ssIHN0cnVjdCBzb2NrYWRkciAqdWFk
ZHIsIGludCBhZGRyX2xlbikKIAlhdG9taWNfc2V0KCZhZGRyLT5yZWZjbnQsIDEpOwogCiAJaWYg
KHN1bl9wYXRoWzBdKSB7Ci0JCXN0cnVjdCBwYXRoIHBhdGg7Ci0JCXVtb2RlX3QgbW9kZSA9IFNf
SUZTT0NLIHwKLQkJICAgICAgIChTT0NLX0lOT0RFKHNvY2spLT5pX21vZGUgJiB+Y3VycmVudF91
bWFzaygpKTsKLQkJZXJyID0gdW5peF9ta25vZChzdW5fcGF0aCwgbW9kZSwgJnBhdGgpOwotCQlp
ZiAoZXJyKSB7Ci0JCQlpZiAoZXJyID09IC1FRVhJU1QpCi0JCQkJZXJyID0gLUVBRERSSU5VU0U7
Ci0JCQl1bml4X3JlbGVhc2VfYWRkcihhZGRyKTsKLQkJCWdvdG8gb3V0X3VwOwotCQl9CiAJCWFk
ZHItPmhhc2ggPSBVTklYX0hBU0hfU0laRTsKIAkJaGFzaCA9IGRfYmFja2luZ19pbm9kZShwYXRo
LmRlbnRyeSktPmlfaW5vICYgKFVOSVhfSEFTSF9TSVpFIC0gMSk7CiAJCXNwaW5fbG9jaygmdW5p
eF90YWJsZV9sb2NrKTsKQEAgLTEwNjUsNiArMTA2Nyw5IEBAIHN0YXRpYyBpbnQgdW5peF9iaW5k
KHN0cnVjdCBzb2NrZXQgKnNvY2ssIHN0cnVjdCBzb2NrYWRkciAqdWFkZHIsIGludCBhZGRyX2xl
bikKIAlzcGluX3VubG9jaygmdW5peF90YWJsZV9sb2NrKTsKIG91dF91cDoKIAltdXRleF91bmxv
Y2soJnUtPmJpbmRsb2NrKTsKK291dF9wdXQ6CisJaWYgKGVycikKKwkJcGF0aF9wdXQoJnBhdGgp
Owogb3V0OgogCXJldHVybiBlcnI7CiB9Cg==
--001a114b9db08da50c054650e463--
