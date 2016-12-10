From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: netlink: GPF in sock_sndtimeo
Date: Fri, 9 Dec 2016 23:40:30 -0800
Message-ID: <CAM_iQpVcHGywXn90EpiSz-LsUDgKVqs-7BY-L7UBCu2VxkC31Q@mail.gmail.com>
References: <20161129164859.GD26673@madcap2.tricolour.ca> <CAM_iQpX_KBEpL1dCBNMgZQ-VQJM9nmsVdRPVK-Aen9k0gV3f0w@mail.gmail.com>
 <20161130045207.GE26673@madcap2.tricolour.ca> <20161209060248.GT22655@madcap2.tricolour.ca>
 <CAM_iQpWRe0tDk=wvXONG7hamH3EtE0nJuAOF1kVKJgdpMvz2DA@mail.gmail.com>
 <20161209110155.GW22655@madcap2.tricolour.ca> <CAM_iQpV2GuKhR_1tD5jjACeD+pajJLws08CLmeYAo+rsjxvB0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a113faebc590109054348fd4b
Cc: linux-audit@redhat.com, Paul Moore <pmoore@redhat.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        David Miller <davem@davemloft.net>,
        Johannes Berg <johannes.berg@intel.com>,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Richard Guy Briggs <rgb@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpV2GuKhR_1tD5jjACeD+pajJLws08CLmeYAo+rsjxvB0A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--001a113faebc590109054348fd4b
Content-Type: text/plain; charset=UTF-8

On Fri, Dec 9, 2016 at 8:13 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Fri, Dec 9, 2016 at 3:01 AM, Richard Guy Briggs <rgb@redhat.com> wrote:
>> On 2016-12-08 22:57, Cong Wang wrote:
>>> On Thu, Dec 8, 2016 at 10:02 PM, Richard Guy Briggs <rgb@redhat.com> wrote:
>>> > I also tried to extend Cong Wang's idea to attempt to proactively respond to a
>>> > NETLINK_URELEASE on the audit_sock and reset it, but ran into a locking error
>>> > stack dump using mutex_lock(&audit_cmd_mutex) in the notifier callback.
>>> > Eliminating the lock since the sock is dead anways eliminates the error.
>>> >
>>> > Is it safe?  I'll resubmit if this looks remotely sane.  Meanwhile I'll try to
>>> > get the test case to compile.
>>>
>>> It doesn't look safe, because 'audit_sock', 'audit_nlk_portid' and 'audit_pid'
>>> are updated as a whole and race between audit_receive_msg() and
>>> NETLINK_URELEASE.
>>
>> This is what I expected and why I originally added the mutex lock in the
>> callback...  The dumps I got were bare with no wrapper identifying the
>> process context or specific error, so I'm at a bit of a loss how to
>> solve this (without thinking more about it) other than instinctively
>> removing the mutex.
>
> Netlink notifier can safely be converted to blocking one, I will send
> a patch.
>
> But I seriously doubt you really need NETLINK_URELEASE here,
> it adds nothing but overhead, b/c the netlink notifier is called on
> every netlink socket in the system, but for net exit path, that is
> relatively a slow path.
>
> Also, kauditd_send_skb() needs audit_cmd_mutex too.

Please let me know what you think about the attached patch?

Thanks!

--001a113faebc590109054348fd4b
Content-Type: text/plain; charset=US-ASCII; name="audit_sock.diff"
Content-Disposition: attachment; filename="audit_sock.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_iwiwvmog0

Y29tbWl0IGExMmI0M2VlODE0NjI1OTMzZmYxNTVjMjBkYzg2M2M1OWNmY2YyNDAKQXV0aG9yOiBD
b25nIFdhbmcgPHhpeW91Lndhbmdjb25nQGdtYWlsLmNvbT4KRGF0ZTogICBGcmkgRGVjIDkgMTc6
NTY6NDIgMjAxNiAtMDgwMAoKICAgIGF1ZGl0OiBjbG9zZSBhIHJhY2UgY29uZGl0aW9uIG9uIGF1
ZGl0X3NvY2sKICAgIAogICAgU2lnbmVkLW9mZi1ieTogQ29uZyBXYW5nIDx4aXlvdS53YW5nY29u
Z0BnbWFpbC5jb20+CgpkaWZmIC0tZ2l0IGEva2VybmVsL2F1ZGl0LmMgYi9rZXJuZWwvYXVkaXQu
YwppbmRleCBmMWNhMTE2Li5hYjk0N2Q4IDEwMDY0NAotLS0gYS9rZXJuZWwvYXVkaXQuYworKysg
Yi9rZXJuZWwvYXVkaXQuYwpAQCAtNDIzLDYgKzQyMyw4IEBAIHN0YXRpYyB2b2lkIGthdWRpdGRf
c2VuZF9za2Ioc3RydWN0IHNrX2J1ZmYgKnNrYikKIAkJCQlzbnByaW50ZihzLCBzaXplb2Yocyks
ICJhdWRpdF9waWQ9JWQgcmVzZXQiLCBhdWRpdF9waWQpOwogCQkJCWF1ZGl0X2xvZ19sb3N0KHMp
OwogCQkJCWF1ZGl0X3BpZCA9IDA7CisJCQkJYXVkaXRfbmxrX3BvcnRpZCA9IDA7CisJCQkJc29j
a19wdXQoYXVkaXRfc29jayk7CiAJCQkJYXVkaXRfc29jayA9IE5VTEw7CiAJCQl9IGVsc2Ugewog
CQkJCXByX3dhcm4oInJlLXNjaGVkdWxpbmcoIyVkKSB3cml0ZSB0byBhdWRpdF9waWQ9JWRcbiIs
CkBAIC04OTksNiArOTAxLDkgQEAgc3RhdGljIGludCBhdWRpdF9yZWNlaXZlX21zZyhzdHJ1Y3Qg
c2tfYnVmZiAqc2tiLCBzdHJ1Y3Qgbmxtc2doZHIgKm5saCkKIAkJCQlhdWRpdF9sb2dfY29uZmln
X2NoYW5nZSgiYXVkaXRfcGlkIiwgbmV3X3BpZCwgYXVkaXRfcGlkLCAxKTsKIAkJCWF1ZGl0X3Bp
ZCA9IG5ld19waWQ7CiAJCQlhdWRpdF9ubGtfcG9ydGlkID0gTkVUTElOS19DQihza2IpLnBvcnRp
ZDsKKwkJCXNvY2tfaG9sZChza2ItPnNrKTsKKwkJCWlmIChhdWRpdF9zb2NrKQorCQkJCXNvY2tf
cHV0KGF1ZGl0X3NvY2spOwogCQkJYXVkaXRfc29jayA9IHNrYi0+c2s7CiAJCX0KIAkJaWYgKHMu
bWFzayAmIEFVRElUX1NUQVRVU19SQVRFX0xJTUlUKSB7CkBAIC0xMTY3LDEwICsxMTcyLDYgQEAg
c3RhdGljIHZvaWQgX19uZXRfZXhpdCBhdWRpdF9uZXRfZXhpdChzdHJ1Y3QgbmV0ICpuZXQpCiB7
CiAJc3RydWN0IGF1ZGl0X25ldCAqYXVuZXQgPSBuZXRfZ2VuZXJpYyhuZXQsIGF1ZGl0X25ldF9p
ZCk7CiAJc3RydWN0IHNvY2sgKnNvY2sgPSBhdW5ldC0+bmxzazsKLQlpZiAoc29jayA9PSBhdWRp
dF9zb2NrKSB7Ci0JCWF1ZGl0X3BpZCA9IDA7Ci0JCWF1ZGl0X3NvY2sgPSBOVUxMOwotCX0KIAog
CVJDVV9JTklUX1BPSU5URVIoYXVuZXQtPm5sc2ssIE5VTEwpOwogCXN5bmNocm9uaXplX25ldCgp
Owo=
--001a113faebc590109054348fd4b--
