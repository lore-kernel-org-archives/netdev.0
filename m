From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] Panic when tc_lookup_action_n finds a partially
 initialized action.
Date: Wed, 5 Oct 2016 11:01:38 -0700
Message-ID: <CAM_iQpUya1ORUUNC9-spLKHjsjNyj6xHO79kvoDGaZcWT_mEwg@mail.gmail.com>
References: <20161002031349.GB2635@templeofstupid.com> <CAM_iQpX1a1=3PmMAwMRDXpL3qjAskQ990FdxgyCg4T5p4=8G7Q@mail.gmail.com>
 <20161005065244.GA2245@templeofstupid.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a114acd4c36fe5f053e21f96d
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Krister Johansen <kjlx@templeofstupid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:34631 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752513AbcJESCA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2016 14:02:00 -0400
Received: by mail-it0-f68.google.com with SMTP id j69so12292224itb.1
        for <netdev@vger.kernel.org>; Wed, 05 Oct 2016 11:02:00 -0700 (PDT)
In-Reply-To: <20161005065244.GA2245@templeofstupid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001a114acd4c36fe5f053e21f96d
Content-Type: text/plain; charset=UTF-8

On Tue, Oct 4, 2016 at 11:52 PM, Krister Johansen
<kjlx@templeofstupid.com> wrote:
> On Mon, Oct 03, 2016 at 11:22:33AM -0700, Cong Wang wrote:
>> Please try the attached patch. I also convert the read path to RCU
>> to avoid a possible deadlock. A quick test shows no lockdep splat.
>
> I tried this patch, but it doesn't solve the problem.  I got a panic on
> my very first try:

Thanks for testing it.


> The problem here is the same as before: by using RCU the race isn't
> fixed because the module is still discoverable from act_base before the
> pernet initialization is completed.
>
> You can see from the trap frame that the first two arguments to
> tcf_hash_check were 0.  It couldn't look up the correct per-subsystem
> pointer because the id hadn't yet been registered.

I thought the problem is that we don't do pernet ops registration and
action ops registration atomically therefore chose to use mutex+RCU,
but I was wrong, the problem here is just ordering, we need to finish
the pernet initialization before making action ops visible.

If so, why not just reorder them? Does the attached patch make any
sense now? Our pernet init doesn't rely on act_base, so even we have
some race, the worst case is after we initialize the pernet netns for an
action but its ops still not visible, which seems fine (at least no crash).

Or I still miss something here?

(Sorry that I don't have the environment to reproduce your bug)

Thanks for your patience and testing!

--001a114acd4c36fe5f053e21f96d
Content-Type: text/plain; charset=US-ASCII; name="act_api_register.diff"
Content-Disposition: attachment; filename="act_api_register.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_itx7ut0x0

ZGlmZiAtLWdpdCBhL25ldC9zY2hlZC9hY3RfYXBpLmMgYi9uZXQvc2NoZWQvYWN0X2FwaS5jCmlu
ZGV4IGQwOWQwNjguLjYwMjQ5MjAgMTAwNjQ0Ci0tLSBhL25ldC9zY2hlZC9hY3RfYXBpLmMKKysr
IGIvbmV0L3NjaGVkL2FjdF9hcGkuYwpAQCAtMzQxLDIyICszNDEsMjEgQEAgaW50IHRjZl9yZWdp
c3Rlcl9hY3Rpb24oc3RydWN0IHRjX2FjdGlvbl9vcHMgKmFjdCwKIAlpZiAoIWFjdC0+YWN0IHx8
ICFhY3QtPmR1bXAgfHwgIWFjdC0+aW5pdCB8fCAhYWN0LT53YWxrIHx8ICFhY3QtPmxvb2t1cCkK
IAkJcmV0dXJuIC1FSU5WQUw7CiAKKwlyZXQgPSByZWdpc3Rlcl9wZXJuZXRfc3Vic3lzKG9wcyk7
CisJaWYgKHJldCkKKwkJcmV0dXJuIHJldDsKKwogCXdyaXRlX2xvY2soJmFjdF9tb2RfbG9jayk7
CiAJbGlzdF9mb3JfZWFjaF9lbnRyeShhLCAmYWN0X2Jhc2UsIGhlYWQpIHsKIAkJaWYgKGFjdC0+
dHlwZSA9PSBhLT50eXBlIHx8IChzdHJjbXAoYWN0LT5raW5kLCBhLT5raW5kKSA9PSAwKSkgewog
CQkJd3JpdGVfdW5sb2NrKCZhY3RfbW9kX2xvY2spOworCQkJdW5yZWdpc3Rlcl9wZXJuZXRfc3Vi
c3lzKG9wcyk7CiAJCQlyZXR1cm4gLUVFWElTVDsKIAkJfQogCX0KIAlsaXN0X2FkZF90YWlsKCZh
Y3QtPmhlYWQsICZhY3RfYmFzZSk7CiAJd3JpdGVfdW5sb2NrKCZhY3RfbW9kX2xvY2spOwogCi0J
cmV0ID0gcmVnaXN0ZXJfcGVybmV0X3N1YnN5cyhvcHMpOwotCWlmIChyZXQpIHsKLQkJdGNmX3Vu
cmVnaXN0ZXJfYWN0aW9uKGFjdCwgb3BzKTsKLQkJcmV0dXJuIHJldDsKLQl9Ci0KIAlyZXR1cm4g
MDsKIH0KIEVYUE9SVF9TWU1CT0wodGNmX3JlZ2lzdGVyX2FjdGlvbik7CkBAIC0zNjcsOCArMzY2
LDYgQEAgaW50IHRjZl91bnJlZ2lzdGVyX2FjdGlvbihzdHJ1Y3QgdGNfYWN0aW9uX29wcyAqYWN0
LAogCXN0cnVjdCB0Y19hY3Rpb25fb3BzICphOwogCWludCBlcnIgPSAtRU5PRU5UOwogCi0JdW5y
ZWdpc3Rlcl9wZXJuZXRfc3Vic3lzKG9wcyk7Ci0KIAl3cml0ZV9sb2NrKCZhY3RfbW9kX2xvY2sp
OwogCWxpc3RfZm9yX2VhY2hfZW50cnkoYSwgJmFjdF9iYXNlLCBoZWFkKSB7CiAJCWlmIChhID09
IGFjdCkgewpAQCAtMzc4LDYgKzM3NSw4IEBAIGludCB0Y2ZfdW5yZWdpc3Rlcl9hY3Rpb24oc3Ry
dWN0IHRjX2FjdGlvbl9vcHMgKmFjdCwKIAkJfQogCX0KIAl3cml0ZV91bmxvY2soJmFjdF9tb2Rf
bG9jayk7CisJaWYgKCFlcnIpCisJCXVucmVnaXN0ZXJfcGVybmV0X3N1YnN5cyhvcHMpOwogCXJl
dHVybiBlcnI7CiB9CiBFWFBPUlRfU1lNQk9MKHRjZl91bnJlZ2lzdGVyX2FjdGlvbik7Cg==
--001a114acd4c36fe5f053e21f96d--
