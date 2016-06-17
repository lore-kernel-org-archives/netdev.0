From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [BUG] act_ife: sleeping functions called in atomic context
Date: Thu, 16 Jun 2016 20:38:31 -0400
Message-ID: <57634687.3050107@mojatatu.com>
References: <1466110219-4825-1-git-send-email-khoroshilov@ispras.ru>
 <CAM_iQpWyfmUnQkQPz8dfO1NPmbdmW3AB9yWrJk6TqXyTo_DCow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060300070900080504090708"
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, ldv-project@linuxtesting.org
To: Cong Wang <xiyou.wangcong@gmail.com>,
	Alexey Khoroshilov <khoroshilov@ispras.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpWyfmUnQkQPz8dfO1NPmbdmW3AB9yWrJk6TqXyTo_DCow@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060300070900080504090708
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

On 16-06-16 05:43 PM, Cong Wang wrote:
> On Thu, Jun 16, 2016 at 1:50 PM, Alexey Khoroshilov
> <khoroshilov@ispras.ru> wrote:
>> tcf_ife_init() contains a big chunk of code executed with
>> ife->tcf_lock spinlock held. But that code contains several calls
>> to sleeping functions:
>>    populate_metalist() and use_all_metadata()
>>      -> add_metainfo()
>>        -> find_ife_oplist(metaid)
>>          -> read_lock()
>>          -> try_module_get(o->owner)
>>        -> kzalloc(sizeof(*mi), GFP_KERNEL);
>
> Hmm, we don't need to hold that spinlock when we create a new ife action,
> since we haven't inserted it yet. We do need it when we modify an existing
> one. So I am thinking if we can refactor that code to avoid spinlock
> whenever possible.
>

Does attached (compile tested) patch help?

>>        -> ops->alloc(mi, metaval);
>>        -> module_put(ops->owner);
>>    _tcf_ife_cleanup()
>>      -> module_put()
>>
>> The same problem is actual for tcf_ife_cleanup() as well.
>>
>
> Huh? Both module_put() and kfree() should not sleep, right?
>

I dont think there is any sleeping there ;->

cheers,
jamal

--------------060300070900080504090708
Content-Type: text/plain; charset=UTF-8;
 name="patchlet1"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="patchlet1"

ZGlmZiAtLWdpdCBhL25ldC9zY2hlZC9hY3RfaWZlLmMgYi9uZXQvc2NoZWQvYWN0X2lmZS5j
CmluZGV4IDZiYmM1MTguLmUzNDFiZWYgMTAwNjQ0Ci0tLSBhL25ldC9zY2hlZC9hY3RfaWZl
LmMKKysrIGIvbmV0L3NjaGVkL2FjdF9pZmUuYwpAQCAtMzAyLDcgKzMwMiw5IEBAIHN0YXRp
YyBpbnQgYWRkX21ldGFpbmZvKHN0cnVjdCB0Y2ZfaWZlX2luZm8gKmlmZSwgdTMyIG1ldGFp
ZCwgdm9pZCAqbWV0YXZhbCwKIAkJfQogCX0KIAorCXNwaW5fbG9ja19iaCgmaWZlLT50Y2Zf
bG9jayk7CiAJbGlzdF9hZGRfdGFpbCgmbWktPm1ldGFsaXN0LCAmaWZlLT5tZXRhbGlzdCk7
CisJc3Bpbl91bmxvY2tfYmgoJmlmZS0+dGNmX2xvY2spOwogCiAJcmV0dXJuIHJldDsKIH0K
QEAgLTQ3NCw3ICs0NzYsNiBAQCBzdGF0aWMgaW50IHRjZl9pZmVfaW5pdChzdHJ1Y3QgbmV0
ICpuZXQsIHN0cnVjdCBubGF0dHIgKm5sYSwKIAkJCXNhZGRyID0gbmxhX2RhdGEodGJbVENB
X0lGRV9TTUFDXSk7CiAJfQogCi0Jc3Bpbl9sb2NrX2JoKCZpZmUtPnRjZl9sb2NrKTsKIAlp
ZmUtPnRjZl9hY3Rpb24gPSBwYXJtLT5hY3Rpb247CiAKIAlpZiAocGFybS0+ZmxhZ3MgJiBJ
RkVfRU5DT0RFKSB7CkBAIC01MDQsNyArNTA1LDYgQEAgbWV0YWRhdGFfcGFyc2VfZXJyOgog
CQkJaWYgKHJldCA9PSBBQ1RfUF9DUkVBVEVEKQogCQkJCV90Y2ZfaWZlX2NsZWFudXAoYSwg
YmluZCk7CiAKLQkJCXNwaW5fdW5sb2NrX2JoKCZpZmUtPnRjZl9sb2NrKTsKIAkJCXJldHVy
biBlcnI7CiAJCX0KIApAQCAtNTIzLDEzICs1MjMsMTAgQEAgbWV0YWRhdGFfcGFyc2VfZXJy
OgogCQkJaWYgKHJldCA9PSBBQ1RfUF9DUkVBVEVEKQogCQkJCV90Y2ZfaWZlX2NsZWFudXAo
YSwgYmluZCk7CiAKLQkJCXNwaW5fdW5sb2NrX2JoKCZpZmUtPnRjZl9sb2NrKTsKIAkJCXJl
dHVybiBlcnI7CiAJCX0KIAl9CiAKLQlzcGluX3VubG9ja19iaCgmaWZlLT50Y2ZfbG9jayk7
Ci0KIAlpZiAocmV0ID09IEFDVF9QX0NSRUFURUQpCiAJCXRjZl9oYXNoX2luc2VydCh0biwg
YSk7CiAK
--------------060300070900080504090708--
