From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Soft lockup in tc_classify
Date: Mon, 19 Dec 2016 09:58:18 -0800
Message-ID: <CAM_iQpXUQYvvXonEXe0czd4osL5YxZ+G5B-PUddautcHnGOtQw@mail.gmail.com>
References: <c1c394d3-3aea-52a8-89e3-be57d4d46b8e@mellanox.com>
 <7394f89e-e8a5-5fb2-ee04-63bf1c4ef6e7@mellanox.com> <584EA60B.80803@iogearbox.net>
 <CAJ3xEMjABmvAMs6h0EqBgPH8QDDwF_x0COx01MkEw2pa+fp7LA@mail.gmail.com>
 <CAM_iQpVJ_Y5bB-RP2S2tK7sPNo6Atwcz5Ud8sG6bwDOSnq4NnA@mail.gmail.com> <18a64d65-1241-6c72-8333-47b0ae933139@mellanox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a1141de84569a35054406ab83
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Roi Dayan <roid@mellanox.com>,
        David Miller <davem@davemloft.net>,
        Jiri Pirko <jiri@mellanox.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: Shahar Klein <shahark@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:36294 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752440AbcLSR6j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2016 12:58:39 -0500
Received: by mail-qt0-f193.google.com with SMTP id n34so20027514qtb.3
        for <netdev@vger.kernel.org>; Mon, 19 Dec 2016 09:58:39 -0800 (PST)
In-Reply-To: <18a64d65-1241-6c72-8333-47b0ae933139@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001a1141de84569a35054406ab83
Content-Type: text/plain; charset=UTF-8

Hello,

On Mon, Dec 19, 2016 at 8:39 AM, Shahar Klein <shahark@mellanox.com> wrote:
>
>
> On 12/13/2016 12:51 AM, Cong Wang wrote:
>>
>> On Mon, Dec 12, 2016 at 1:18 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>>>
>>> On Mon, Dec 12, 2016 at 3:28 PM, Daniel Borkmann <daniel@iogearbox.net>
>>> wrote:
>>>
>>>> Note that there's still the RCU fix missing for the deletion race that
>>>> Cong will still send out, but you say that the only thing you do is to
>>>> add a single rule, but no other operation in involved during that test?
>>>
>>>
>>> What's missing to have the deletion race fixed? making a patch or
>>> testing to a patch which was sent?
>>
>>
>> If you think it would help for this problem, here is my patch rebased
>> on the latest net-next.
>>
>> Again, I don't see how it could help this case yet, especially I don't
>> see how we could have a loop in this singly linked list.
>>
>
> I've applied cong's patch and hit a different lockup(full log attached):


Are you sure this is really different? For me, it is still inside the loop
in tc_classify(), with only a slightly different offset.


>
> Daniel suggested I'll add a print:
>                 case RTM_DELTFILTER:
> -                   err = tp->ops->delete(tp, fh);
> +                 printk(KERN_ERR "DEBUGG:SK %s:%d\n", __func__, __LINE__);
> +                 err = tp->ops->delete(tp, fh, &last);
>                         if (err == 0) {
>
> and I couldn't see this print in the output.....

Hmm, that is odd, if this never prints, then my patch should not make any
difference.

There are still two other cases where we could change tp->next, so do you
mind to add two more printk's for debugging?

Attached is the delta patch.

Thanks!

--001a1141de84569a35054406ab83
Content-Type: text/plain; charset=US-ASCII; name="tc-filter-debug.diff"
Content-Disposition: attachment; filename="tc-filter-debug.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_iwwdwh611

ZGlmZiAtLWdpdCBhL25ldC9zY2hlZC9jbHNfYXBpLmMgYi9uZXQvc2NoZWQvY2xzX2FwaS5jCmlu
ZGV4IGY5MTc5ZTAuLjQ1YmZlOWYgMTAwNjQ0Ci0tLSBhL25ldC9zY2hlZC9jbHNfYXBpLmMKKysr
IGIvbmV0L3NjaGVkL2Nsc19hcGkuYwpAQCAtMzE3LDYgKzMxNyw4IEBAIHN0YXRpYyBpbnQgdGNf
Y3RsX3RmaWx0ZXIoc3RydWN0IHNrX2J1ZmYgKnNrYiwgc3RydWN0IG5sbXNnaGRyICpuKQogCQlp
ZiAobi0+bmxtc2dfdHlwZSA9PSBSVE1fREVMVEZJTFRFUiAmJiB0LT50Y21faGFuZGxlID09IDAp
IHsKIAkJCXN0cnVjdCB0Y2ZfcHJvdG8gKm5leHQgPSBydG5sX2RlcmVmZXJlbmNlKHRwLT5uZXh0
KTsKIAorCQkJcHJpbnRrKEtFUk5fRVJSICJERUJVR0c6U0sgZGVsZXRlIGZpbHRlciBieTogJXBm
XG4iLCB0cC0+b3BzLT5nZXQpOworCiAJCQlSQ1VfSU5JVF9QT0lOVEVSKCpiYWNrLCBuZXh0KTsK
IAogCQkJdGZpbHRlcl9ub3RpZnkobmV0LCBza2IsIG4sIHRwLCBmaCwKQEAgLTM3MCw2ICszNzIs
NyBAQCBzdGF0aWMgaW50IHRjX2N0bF90ZmlsdGVyKHN0cnVjdCBza19idWZmICpza2IsIHN0cnVj
dCBubG1zZ2hkciAqbikKIAkJCSAgICAgIG4tPm5sbXNnX2ZsYWdzICYgTkxNX0ZfQ1JFQVRFID8g
VENBX0FDVF9OT1JFUExBQ0UgOiBUQ0FfQUNUX1JFUExBQ0UpOwogCWlmIChlcnIgPT0gMCkgewog
CQlpZiAodHBfY3JlYXRlZCkgeworCQkJcHJpbnRrKEtFUk5fRVJSICJERUJVR0c6U0sgYWRkL2No
YW5nZSBmaWx0ZXIgYnk6ICVwZlxuIiwgdHAtPm9wcy0+Y2hhbmdlKTsKIAkJCVJDVV9JTklUX1BP
SU5URVIodHAtPm5leHQsIHJ0bmxfZGVyZWZlcmVuY2UoKmJhY2spKTsKIAkJCXJjdV9hc3NpZ25f
cG9pbnRlcigqYmFjaywgdHApOwogCQl9Cg==
--001a1141de84569a35054406ab83--
