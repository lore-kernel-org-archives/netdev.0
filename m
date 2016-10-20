From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] net: saving irq context for peernet2id()
Date: Thu, 20 Oct 2016 16:35:53 -0700
Message-ID: <CAM_iQpVFWzUm2BJZUs+-LWpKA8kubuKhzyE01_V69TEsrFnm-Q@mail.gmail.com>
References: <1476946352-15770-1-git-send-email-xiyou.wangcong@gmail.com>
 <2707c52d-88ec-7b93-f96e-eeaffc952c9c@tycho.nsa.gov> <CAM_iQpWD3WiX1ZX+3LJ8vbJc42K1jZcZ4-f6MO5kzZY-+Szkqw@mail.gmail.com>
 <CAHC9VhSronk914-0QZd7cPBEAOvSzN++Umc=_aueeCuOB9iG8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=94eb2c0590f036a536053f54644f
Cc: Stephen Smalley <sds@tycho.nsa.gov>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Elad Raz <e@eladraz.com>, Richard Guy Briggs <rgb@redhat.com>
To: Paul Moore <paul@paul-moore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34501 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752170AbcJTXgP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 19:36:15 -0400
Received: by mail-it0-f67.google.com with SMTP id e203so8566089itc.1
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 16:36:15 -0700 (PDT)
In-Reply-To: <CAHC9VhSronk914-0QZd7cPBEAOvSzN++Umc=_aueeCuOB9iG8Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--94eb2c0590f036a536053f54644f
Content-Type: text/plain; charset=UTF-8

On Thu, Oct 20, 2016 at 12:07 PM, Paul Moore <paul@paul-moore.com> wrote:
> On Thu, Oct 20, 2016 at 2:29 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> On Thu, Oct 20, 2016 at 7:58 AM, Stephen Smalley <sds@tycho.nsa.gov> wrote:
>>> On 10/20/2016 02:52 AM, Cong Wang wrote:
>>>> A kernel warning inside __local_bh_enable_ip() was reported by people
>>>> running SELinux, this is caused due to some SELinux functions
>>>> (indirectly) call peernet2id() with IRQ disabled in process context,
>>>> when we re-enable BH with IRQ disabled kernel complains. Shut up this
>>>> warning by saving IRQ context in peernet2id(), BH is still implicitly
>>>> disabled.
>>>
>>> Not sure this suffices; kill_fasync() -> send_sigio() ->
>>> send_sigio_to_task() -> sigio_perm() -> security_file_send_sigiotask()
>>> -> selinux_file_send_sigiotask() -> ... -> audit_log() -> ... ->
>>> peernet2id()
>>
>> Oh, this is a new one. kill_fasync() is called in IRQ handler, so we actually
>> do multicast in IRQ context.... It makes no sense, netlink multicast could
>> be very expensive if we have many listeners.
>
> I'm sure there are a few others I don't know about, but I believe the
> only commonly used audit multicast listener is systemd.

But user-space is free to listen to this group, right? If so this is just open
for a potential DDOS attack.

>
>> I am Cc'ing Richard who added that multicast in audit_log_end(). It seems
>> not easy to just move the multicast to a workqueue, since the skb is copied
>> from audit_buffer which is freed immediately after that, probably need another
>> queue like audit_skb_queue.
>
> This approach would double the queue size which is something I want to
> avoid.  I would suggest sticking with a single queue and dealing with
> the netlink message link fixup and multicast send in the existing
> netlink unicast thread; basically we would just be moving the
> multicast code from audit_log_end() into kauditd_thread().  This is
> the same approach I mentioned earlier off-list.

This is what I did in the follow up patch. I attach the updated version
in this email for you to review, I still can't make selinux-testsuites working
on my Fedora even though I have SELinux=enforcing, anyhow I don't
see any kernel warning in my dmesg at least.

>
> However, that isn't something I want to mess with as a regression fix,
> mostly because I really want to see this regression gone by -rc2 as it
> is making SELinux testing a real pain.  If the patch posted at the top
> of this thread isn't a suitable fix, we really should revert the
> original patch.

Since you want to test SELinux anyway, please test the attached one.

Thanks.

--94eb2c0590f036a536053f54644f
Content-Type: text/plain; charset=US-ASCII; name="audit-v2.diff"
Content-Disposition: attachment; filename="audit-v2.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_iuizij6y0

ZGlmZiAtLWdpdCBhL2tlcm5lbC9hdWRpdC5jIGIva2VybmVsL2F1ZGl0LmMKaW5kZXggZjFjYTEx
Ni4uY2RjNWE5MSAxMDA2NDQKLS0tIGEva2VybmVsL2F1ZGl0LmMKKysrIGIva2VybmVsL2F1ZGl0
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
CiB9CiAKIC8qCkBAIC01MDksNiArNTExLDI2IEBAIHN0YXRpYyB2b2lkIGZsdXNoX2hvbGRfcXVl
dWUodm9pZCkKIAljb25zdW1lX3NrYihza2IpOwogfQogCitzdGF0aWMgdm9pZCBmbHVzaF9tdWx0
aWNhc3RfcXVldWUodm9pZCkKK3sKKwlzdHJ1Y3QgYXVkaXRfbmV0ICphdW5ldCA9IG5ldF9nZW5l
cmljKCZpbml0X25ldCwgYXVkaXRfbmV0X2lkKTsKKwlzdHJ1Y3Qgc29jayAqc29jayA9IGF1bmV0
LT5ubHNrOworCXN0cnVjdCBza19idWZmICpza2IgPSBza2JfZGVxdWV1ZSgmYXVkaXRfc2tiX211
bHRpY2FzdF9xdWV1ZSk7CisKKwlpZiAoIW5ldGxpbmtfaGFzX2xpc3RlbmVycyhzb2NrLCBBVURJ
VF9OTEdSUF9SRUFETE9HKSkgeworCQl3aGlsZSAoc2tiKSB7CisJCQljb25zdW1lX3NrYihza2Ip
OworCQkJc2tiID0gc2tiX2RlcXVldWUoJmF1ZGl0X3NrYl9tdWx0aWNhc3RfcXVldWUpOworCQl9
CisJCXJldHVybjsKKwl9CisKKwl3aGlsZSAoc2tiKSB7CisJCW5sbXNnX211bHRpY2FzdChzb2Nr
LCBza2IsIDAsIEFVRElUX05MR1JQX1JFQURMT0csIEdGUF9LRVJORUwpOworCQlza2IgPSBza2Jf
ZGVxdWV1ZSgmYXVkaXRfc2tiX211bHRpY2FzdF9xdWV1ZSk7CisJfQorfQorCiBzdGF0aWMgaW50
IGthdWRpdGRfdGhyZWFkKHZvaWQgKmR1bW15KQogewogCXNldF9mcmVlemFibGUoKTsKQEAgLTUx
Nyw2ICs1MzksOCBAQCBzdGF0aWMgaW50IGthdWRpdGRfdGhyZWFkKHZvaWQgKmR1bW15KQogCiAJ
CWZsdXNoX2hvbGRfcXVldWUoKTsKIAorCQlmbHVzaF9tdWx0aWNhc3RfcXVldWUoKTsKKwogCQlz
a2IgPSBza2JfZGVxdWV1ZSgmYXVkaXRfc2tiX3F1ZXVlKTsKIAogCQlpZiAoc2tiKSB7CkBAIC01
MzAsNyArNTU0LDggQEAgc3RhdGljIGludCBrYXVkaXRkX3RocmVhZCh2b2lkICpkdW1teSkKIAkJ
CWNvbnRpbnVlOwogCQl9CiAKLQkJd2FpdF9ldmVudF9mcmVlemFibGUoa2F1ZGl0ZF93YWl0LCBz
a2JfcXVldWVfbGVuKCZhdWRpdF9za2JfcXVldWUpKTsKKwkJd2FpdF9ldmVudF9mcmVlemFibGUo
a2F1ZGl0ZF93YWl0LCBza2JfcXVldWVfbGVuKCZhdWRpdF9za2JfcXVldWUpCisJCQkJCQkgICB8
fCBza2JfcXVldWVfbGVuKCZhdWRpdF9za2JfbXVsdGljYXN0X3F1ZXVlKSk7CiAJfQogCXJldHVy
biAwOwogfQpAQCAtMTE5Nyw2ICsxMjIyLDcgQEAgc3RhdGljIGludCBfX2luaXQgYXVkaXRfaW5p
dCh2b2lkKQogCXJlZ2lzdGVyX3Blcm5ldF9zdWJzeXMoJmF1ZGl0X25ldF9vcHMpOwogCiAJc2ti
X3F1ZXVlX2hlYWRfaW5pdCgmYXVkaXRfc2tiX3F1ZXVlKTsKKwlza2JfcXVldWVfaGVhZF9pbml0
KCZhdWRpdF9za2JfbXVsdGljYXN0X3F1ZXVlKTsKIAlza2JfcXVldWVfaGVhZF9pbml0KCZhdWRp
dF9za2JfaG9sZF9xdWV1ZSk7CiAJYXVkaXRfaW5pdGlhbGl6ZWQgPSBBVURJVF9JTklUSUFMSVpF
RDsKIAlhdWRpdF9lbmFibGVkID0gYXVkaXRfZGVmYXVsdDsK
--94eb2c0590f036a536053f54644f--
