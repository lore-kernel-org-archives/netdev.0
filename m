From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net: suspicious RCU usage in nf_hook
Date: Wed, 1 Feb 2017 15:29:54 -0800
Message-ID: <CAM_iQpWSpgNnEOn+euZAMEmdQCfDVcgk9EO=k5-kVEkB+EJrpg@mail.gmail.com>
References: <CACT4Y+bpmwj1WH7g6inQBm+7PvHepv9tTmYBUqkJYFvquGDYCQ@mail.gmail.com>
 <1485560124.6360.74.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpVvBPhP4q=Egsaoqf8ym-73jLZow8xDMbOq9RhYmL5XAQ@mail.gmail.com>
 <1485567090.6360.92.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpXiQMH1zMJM6sYFNUySUYjaHnLZ3T2d34GwCMQ9u6RkwQ@mail.gmail.com>
 <1485877498.6360.115.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpWnJbN=65D8PAxe7B_kBf7+Ay2M59T8brF0aXkfEbgnPg@mail.gmail.com> <1485983770.6360.158.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a1146ee9e473a960547806e7e
Cc: Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Eric Dumazet <edumazet@google.com>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        netfilter-devel@vger.kernel.org,
        syzkaller <syzkaller@googlegroups.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1485983770.6360.158.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--001a1146ee9e473a960547806e7e
Content-Type: text/plain; charset=UTF-8

On Wed, Feb 1, 2017 at 1:16 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2017-02-01 at 12:51 -0800, Cong Wang wrote:
>> On Tue, Jan 31, 2017 at 7:44 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > On Mon, 2017-01-30 at 22:19 -0800, Cong Wang wrote:
>> >
>> >>
>> >> The context is process context (TX path before hitting qdisc), and
>> >> BH is not disabled, so in_interrupt() doesn't catch it. Hmm, this
>> >> makes me thinking maybe we really need to disable BH in this
>> >> case for nf_hook()? But it is called in RX path too, and BH is
>> >> already disabled there.
>> >
>> > ipt_do_table() and similar netfilter entry points disable BH.
>> >
>> > Maybe it is done too late.
>>
>> I think we need a fix like the following one for minimum impact.
>>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 727b6fd..eee7d63 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -1720,12 +1720,10 @@ EXPORT_SYMBOL(net_enable_timestamp);
>>  void net_disable_timestamp(void)
>>  {
>>  #ifdef HAVE_JUMP_LABEL
>> -       if (in_interrupt()) {
>> -               atomic_inc(&netstamp_needed_deferred);
>> -               return;
>> -       }
>> -#endif
>> +       atomic_inc(&netstamp_needed_deferred);
>> +#else
>>         static_key_slow_dec(&netstamp_needed);
>> +#endif
>>  }
>>  EXPORT_SYMBOL(net_disable_timestamp);
>
> This would permanently leave the kernel in the netstamp_needed state.
>
> I would prefer the patch using a process context to perform the
> cleanup ? Note there is a race window, but probably not a big deal.

Not sure if it is better. The difference is caught up in net_enable_timestamp(),
which is called setsockopt() path and sk_clone() path, so we could be
in netstamp_needed state for a long time too until user-space exercises
these paths.

I am feeling we probably need to get rid of netstamp_needed_deferred,
and simply defer the whole static_key_slow_dec(), like the attached patch
(compile only).

What do you think?

--001a1146ee9e473a960547806e7e
Content-Type: text/plain; charset=US-ASCII; name="net-timestamp.diff"
Content-Disposition: attachment; filename="net-timestamp.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_iynl4oub0

ZGlmZiAtLWdpdCBhL25ldC9jb3JlL2Rldi5jIGIvbmV0L2NvcmUvZGV2LmMKaW5kZXggNzI3YjZm
ZC4uMGVmMTczNCAxMDA2NDQKLS0tIGEvbmV0L2NvcmUvZGV2LmMKKysrIGIvbmV0L2NvcmUvZGV2
LmMKQEAgLTE2OTQsMzggKzE2OTQsMjggQEAgRVhQT1JUX1NZTUJPTF9HUEwobmV0X2RlY19lZ3Jl
c3NfcXVldWUpOwogI2VuZGlmCiAKIHN0YXRpYyBzdHJ1Y3Qgc3RhdGljX2tleSBuZXRzdGFtcF9u
ZWVkZWQgX19yZWFkX21vc3RseTsKLSNpZmRlZiBIQVZFX0pVTVBfTEFCRUwKLS8qIFdlIGFyZSBu
b3QgYWxsb3dlZCB0byBjYWxsIHN0YXRpY19rZXlfc2xvd19kZWMoKSBmcm9tIGlycSBjb250ZXh0
Ci0gKiBJZiBuZXRfZGlzYWJsZV90aW1lc3RhbXAoKSBpcyBjYWxsZWQgZnJvbSBpcnEgY29udGV4
dCwgZGVmZXIgdGhlCi0gKiBzdGF0aWNfa2V5X3Nsb3dfZGVjKCkgY2FsbHMuCi0gKi8KLXN0YXRp
YyBhdG9taWNfdCBuZXRzdGFtcF9uZWVkZWRfZGVmZXJyZWQ7Ci0jZW5kaWYKIAotdm9pZCBuZXRf
ZW5hYmxlX3RpbWVzdGFtcCh2b2lkKQorc3RhdGljIHZvaWQgbmV0c3RhbXBfY2xlYXIoc3RydWN0
IHdvcmtfc3RydWN0ICp3b3JrKQogewotI2lmZGVmIEhBVkVfSlVNUF9MQUJFTAotCWludCBkZWZl
cnJlZCA9IGF0b21pY194Y2hnKCZuZXRzdGFtcF9uZWVkZWRfZGVmZXJyZWQsIDApOworCXN0YXRp
Y19rZXlfc2xvd19kZWMoJm5ldHN0YW1wX25lZWRlZCk7Cit9CiAKLQlpZiAoZGVmZXJyZWQpIHsK
LQkJd2hpbGUgKC0tZGVmZXJyZWQpCi0JCQlzdGF0aWNfa2V5X3Nsb3dfZGVjKCZuZXRzdGFtcF9u
ZWVkZWQpOwotCQlyZXR1cm47Ci0JfQotI2VuZGlmCitzdGF0aWMgREVDTEFSRV9XT1JLKG5ldHN0
YW1wX3dvcmssIG5ldHN0YW1wX2NsZWFyKTsKKwordm9pZCBuZXRfZW5hYmxlX3RpbWVzdGFtcCh2
b2lkKQoreworCWZsdXNoX3dvcmsoJm5ldHN0YW1wX3dvcmspOwogCXN0YXRpY19rZXlfc2xvd19p
bmMoJm5ldHN0YW1wX25lZWRlZCk7CiB9CiBFWFBPUlRfU1lNQk9MKG5ldF9lbmFibGVfdGltZXN0
YW1wKTsKIAogdm9pZCBuZXRfZGlzYWJsZV90aW1lc3RhbXAodm9pZCkKIHsKLSNpZmRlZiBIQVZF
X0pVTVBfTEFCRUwKLQlpZiAoaW5faW50ZXJydXB0KCkpIHsKLQkJYXRvbWljX2luYygmbmV0c3Rh
bXBfbmVlZGVkX2RlZmVycmVkKTsKLQkJcmV0dXJuOwotCX0KLSNlbmRpZgotCXN0YXRpY19rZXlf
c2xvd19kZWMoJm5ldHN0YW1wX25lZWRlZCk7CisJLyogV2UgYXJlIG5vdCBhbGxvd2VkIHRvIGNh
bGwgc3RhdGljX2tleV9zbG93X2RlYygpIGZyb20gaXJxIGNvbnRleHQKKwkgKiBJZiBuZXRfZGlz
YWJsZV90aW1lc3RhbXAoKSBpcyBjYWxsZWQgZnJvbSBpcnEgY29udGV4dCwgZGVmZXIgdGhlCisJ
ICogc3RhdGljX2tleV9zbG93X2RlYygpIGNhbGxzLgorCSAqLworCXNjaGVkdWxlX3dvcmsoJm5l
dHN0YW1wX3dvcmspOwogfQogRVhQT1JUX1NZTUJPTChuZXRfZGlzYWJsZV90aW1lc3RhbXApOwog
Cg==
--001a1146ee9e473a960547806e7e--
