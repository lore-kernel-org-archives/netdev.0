From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] net: saving irq context for peernet2id()
Date: Thu, 20 Oct 2016 12:04:49 -0700
Message-ID: <CAM_iQpX-2M4Q+drzf0_ncnDhLESmbG869Wuac1WujKwbkfQZiw@mail.gmail.com>
References: <1476946352-15770-1-git-send-email-xiyou.wangcong@gmail.com>
 <2707c52d-88ec-7b93-f96e-eeaffc952c9c@tycho.nsa.gov> <CAM_iQpWD3WiX1ZX+3LJ8vbJc42K1jZcZ4-f6MO5kzZY-+Szkqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a114face6ca6b6d053f509abe
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Elad Raz <e@eladraz.com>, Paul Moore <paul@paul-moore.com>,
        Richard Guy Briggs <rgb@redhat.com>
To: Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33578 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754732AbcJTTXf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 15:23:35 -0400
Received: by mail-it0-f66.google.com with SMTP id k64so7615982itb.0
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 12:23:34 -0700 (PDT)
In-Reply-To: <CAM_iQpWD3WiX1ZX+3LJ8vbJc42K1jZcZ4-f6MO5kzZY-+Szkqw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001a114face6ca6b6d053f509abe
Content-Type: text/plain; charset=UTF-8

On Thu, Oct 20, 2016 at 11:29 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Thu, Oct 20, 2016 at 7:58 AM, Stephen Smalley <sds@tycho.nsa.gov> wrote:
>> On 10/20/2016 02:52 AM, Cong Wang wrote:
>>> A kernel warning inside __local_bh_enable_ip() was reported by people
>>> running SELinux, this is caused due to some SELinux functions
>>> (indirectly) call peernet2id() with IRQ disabled in process context,
>>> when we re-enable BH with IRQ disabled kernel complains. Shut up this
>>> warning by saving IRQ context in peernet2id(), BH is still implicitly
>>> disabled.
>>
>> Not sure this suffices; kill_fasync() -> send_sigio() ->
>> send_sigio_to_task() -> sigio_perm() -> security_file_send_sigiotask()
>> -> selinux_file_send_sigiotask() -> ... -> audit_log() -> ... ->
>> peernet2id()
>
> Oh, this is a new one. kill_fasync() is called in IRQ handler, so we actually
> do multicast in IRQ context.... It makes no sense, netlink multicast could
> be very expensive if we have many listeners.
>
> I am Cc'ing Richard who added that multicast in audit_log_end(). It seems
> not easy to just move the multicast to a workqueue, since the skb is copied
> from audit_buffer which is freed immediately after that, probably need another
> queue like audit_skb_queue.

Please let me know if the attached patch makes any sense to you, before
I give it a serious test.

Thanks!

--001a114face6ca6b6d053f509abe
Content-Type: text/plain; charset=US-ASCII; name="audit.diff"
Content-Disposition: attachment; filename="audit.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_iuipvdgt0

ZGlmZiAtLWdpdCBhL2tlcm5lbC9hdWRpdC5jIGIva2VybmVsL2F1ZGl0LmMKaW5kZXggZjFjYTEx
Ni4uY2IyYjMxYiAxMDA2NDQKLS0tIGEva2VybmVsL2F1ZGl0LmMKKysrIGIva2VybmVsL2F1ZGl0
LmMKQEAgLTEzOSw2ICsxMzksNyBAQCBzdGF0aWMgaW50CSAgIGF1ZGl0X2ZyZWVsaXN0X2NvdW50
Owogc3RhdGljIExJU1RfSEVBRChhdWRpdF9mcmVlbGlzdCk7CiAKIHN0YXRpYyBzdHJ1Y3Qgc2tf
YnVmZl9oZWFkIGF1ZGl0X3NrYl9xdWV1ZTsKK3N0YXRpYyBzdHJ1Y3Qgc2tfYnVmZl9oZWFkIGF1
ZGl0X3NrYl9tdWx0aWNhc3RfcXVldWU7CiAvKiBxdWV1ZSBvZiBza2JzIHRvIHNlbmQgdG8gYXVk
aXRkIHdoZW4vaWYgaXQgY29tZXMgYmFjayAqLwogc3RhdGljIHN0cnVjdCBza19idWZmX2hlYWQg
YXVkaXRfc2tiX2hvbGRfcXVldWU7CiBzdGF0aWMgc3RydWN0IHRhc2tfc3RydWN0ICprYXVkaXRk
X3Rhc2s7CkBAIC00NjgsNyArNDY5LDggQEAgc3RhdGljIHZvaWQga2F1ZGl0ZF9zZW5kX211bHRp
Y2FzdF9za2Ioc3RydWN0IHNrX2J1ZmYgKnNrYiwgZ2ZwX3QgZ2ZwX21hc2spCiAJaWYgKCFjb3B5
KQogCQlyZXR1cm47CiAKLQlubG1zZ19tdWx0aWNhc3Qoc29jaywgY29weSwgMCwgQVVESVRfTkxH
UlBfUkVBRExPRywgZ2ZwX21hc2spOworCXNrYl9xdWV1ZV90YWlsKCZhdWRpdF9za2JfbXVsdGlj
YXN0X3F1ZXVlLCBjb3B5KTsKKwl3YWtlX3VwX2ludGVycnVwdGlibGUoJmthdWRpdGRfd2FpdCk7
CiB9CiAKIC8qCkBAIC01MDksNiArNTExLDI1IEBAIHN0YXRpYyB2b2lkIGZsdXNoX2hvbGRfcXVl
dWUodm9pZCkKIAljb25zdW1lX3NrYihza2IpOwogfQogCitzdGF0aWMgdm9pZCBmbHVzaF9tdWx0
aWNhc3RfcXVldWUodm9pZCkKK3sKKwlzdHJ1Y3QgYXVkaXRfbmV0ICphdW5ldCA9IG5ldF9nZW5l
cmljKCZpbml0X25ldCwgYXVkaXRfbmV0X2lkKTsKKwlzdHJ1Y3Qgc29jayAqc29jayA9IGF1bmV0
LT5ubHNrOworCXN0cnVjdCBza19idWZmICpza2I7CisKKwlpZiAoIW5ldGxpbmtfaGFzX2xpc3Rl
bmVycyhzb2NrLCBBVURJVF9OTEdSUF9SRUFETE9HKSkKKwkJcmV0dXJuOworCisJc2tiID0gc2ti
X2RlcXVldWUoJmF1ZGl0X3NrYl9tdWx0aWNhc3RfcXVldWUpOworCWlmIChsaWtlbHkoIXNrYikp
CisJCXJldHVybjsKKworCXdoaWxlIChza2IpIHsKKwkJbmxtc2dfbXVsdGljYXN0KHNvY2ssIHNr
YiwgMCwgQVVESVRfTkxHUlBfUkVBRExPRywgR0ZQX0tFUk5FTCk7CisJCXNrYiA9IHNrYl9kZXF1
ZXVlKCZhdWRpdF9za2JfbXVsdGljYXN0X3F1ZXVlKTsKKwl9Cit9CisKIHN0YXRpYyBpbnQga2F1
ZGl0ZF90aHJlYWQodm9pZCAqZHVtbXkpCiB7CiAJc2V0X2ZyZWV6YWJsZSgpOwpAQCAtNTE3LDYg
KzUzOCw4IEBAIHN0YXRpYyBpbnQga2F1ZGl0ZF90aHJlYWQodm9pZCAqZHVtbXkpCiAKIAkJZmx1
c2hfaG9sZF9xdWV1ZSgpOwogCisJCWZsdXNoX211bHRpY2FzdF9xdWV1ZSgpOworCiAJCXNrYiA9
IHNrYl9kZXF1ZXVlKCZhdWRpdF9za2JfcXVldWUpOwogCiAJCWlmIChza2IpIHsKQEAgLTUzMCw3
ICs1NTMsOCBAQCBzdGF0aWMgaW50IGthdWRpdGRfdGhyZWFkKHZvaWQgKmR1bW15KQogCQkJY29u
dGludWU7CiAJCX0KIAotCQl3YWl0X2V2ZW50X2ZyZWV6YWJsZShrYXVkaXRkX3dhaXQsIHNrYl9x
dWV1ZV9sZW4oJmF1ZGl0X3NrYl9xdWV1ZSkpOworCQl3YWl0X2V2ZW50X2ZyZWV6YWJsZShrYXVk
aXRkX3dhaXQsIHNrYl9xdWV1ZV9sZW4oJmF1ZGl0X3NrYl9xdWV1ZSkKKwkJCQkJCSAgIHx8IHNr
Yl9xdWV1ZV9sZW4oJmF1ZGl0X3NrYl9tdWx0aWNhc3RfcXVldWUpKTsKIAl9CiAJcmV0dXJuIDA7
CiB9Cg==
--001a114face6ca6b6d053f509abe--
