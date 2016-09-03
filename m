From: Alison Chaiken <alison@peloton-tech.com>
Subject: Re: [PATCH][RT] netpoll: Always take poll_lock when doing polling
Date: Sat, 3 Sep 2016 16:40:47 -0700
Message-ID: <CAOuSAjcSrpD=SamQMH2_SObnFeEhTnrCFBWfsVRhb8XDicLa4w@mail.gmail.com>
References: <20160526195641.6c26e979@gandalf.local.home> <20160602161235.GA12971@linutronix.de>
 <20160604071131.08d449db@grimm.local.home> <CAOuSAjfXsLQWkrcE7Y3t-k0Bv5qieqgziu8Zf-au4SK-rLvRHQ@mail.gmail.com>
 <20160607094642.GA4089@linutronix.de> <CAOuSAjeUX_tvzr9K8B4T-TdXUDcYqFxbtYTa=ke-ePhMJo5NVQ@mail.gmail.com>
 <20160609123733.GB6305@linutronix.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a11444c18f57e05053ba2f969
Cc: Steven Rostedt <rostedt@goodmis.org>,
        LKML <linux-kernel@vger.kernel.org>,
        linux-rt-users <linux-rt-users@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Peter Zijlstra <peterz@infradead.org>,
        Clark Williams <williams@redhat.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160609123733.GB6305@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--001a11444c18f57e05053ba2f969
Content-Type: text/plain; charset=UTF-8

 I asked on 2016-06-07 17:19:43 [-0700]:
>>cpsw_rx_poll() is called even when there is essentially no network
>>traffic, so I'm not sure how to tell if NAPI is working as intended.

On Thu, Jun 9, 2016 at 5:37 AM, Sebastian Andrzej Siewior
<bigeasy@linutronix.de> wrote:
> You should see an invocation of __raise_softirq_irqoff_ksoft() and then
> cpsw's poll function should run in "ksoftirqd/" context instead in the
> context of the task it runs now.

The attached patch uses a kprobe to detect when Ethernet switches to
NAPI on a Freescale i.MX6 board.   Thanks to Sebastian for the
suggestion about the method.   As expected, there are no messages when
I ping-flood the board from another host.   However, if I also spawn
multiple scp's of large files at the same time, then the messages
appear.     I tested with 4.4.4-rt11, but the virtually identical
patch is against 4.1.18-rt17.   I'm posting it here in case it's
useful to someone else.   It seems to me that if the various IRQs that
can invoke the net_rx_action() are pinned to different cores, that the
use of smp_processor_id() to identify the device that spawns the IRQ
is therefore robust.

The RT scheduling problem we had (namely, system falls over under
ping-flood) was solved by my colleague Brian Silverman, who pinned our
userspace application that ran the critical event loop and adjusted
its priority.   Doing so prevented a ping-flood from causing the event
loop to miss cycles.

Thanks again to everyone for your advice, and I hope to meet some of
you in Berlin next month.

-- Alison

--001a11444c18f57e05053ba2f969
Content-Type: text/x-patch; charset=US-ASCII;
	name="kprobes-detect-ethernet-and-CAN-NAPI.patch"
Content-Disposition: attachment;
	filename="kprobes-detect-ethernet-and-CAN-NAPI.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_isntnf550

RnJvbSAxYzgzYjRlZTVkNTcyYmMxZWRlNjMwZmM3MmQwMTIyOGZmMjMzOGUyIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBBbGlzb24gQ2hhaWtlbiA8YWxpc29uQHBlbG90b24tdGVjaC5j
b20+CkRhdGU6IFNhdCwgMyBTZXAgMjAxNiAxNTo1MTo0MSAtMDcwMApTdWJqZWN0OiBbUEFUQ0hd
IGtwcm9iZXM6IGRldGVjdCBldGhlcm5ldCBhbmQgQ0FOIE5BUEkKCkluc2VydGluZyB0aGlzIG1v
ZHVsZSB3aWxsIGluZHVjZSB0aGUgY29yZSBuZXR3b3JrIGRyaXZlciB0byBwcmludCBhCm1lc3Nh
Z2Ugd2hlbmV2ZXIgaGFuZGxpbmcgb2YgQ0FOIG9yIEV0aGVybmV0IHBhY2tldHMgaXMgcGVyZm9y
bWVkIHZpYQpOQVBJIGluIGtzb2Z0aXJxZCByYXRoZXIgdGhhbiBpbiB0aGUgY29udGV4dCBvZiB0
aGUgaW52b2tpbmcgaGFyZCBJUlEKdGhyZWFkLiAgVGVzdGVkIG9uIEJvdW5kYXJ5IERldmljZXMg
Tml0cm9nZW4gYm9hcmQgd2l0aCBpLk1YNlEgU09DCndpdGggNC40LjQtcnQxMSBrZXJuZWwuCgpT
aWduZWQtb2ZmLWJ5OiBBbGlzb24gQ2hhaWtlbiA8YWxpc29uQHNoZS1kZXZlbC5jb20+Ci0tLQog
c2FtcGxlcy9rcHJvYmVzL2twcm9iZV9leGFtcGxlLmMgfCAyNCArKysrKysrKysrKysrKysrKysr
KysrKy0KIDEgZmlsZSBjaGFuZ2VkLCAyMyBpbnNlcnRpb25zKCspLCAxIGRlbGV0aW9uKC0pCgpk
aWZmIC0tZ2l0IGEvc2FtcGxlcy9rcHJvYmVzL2twcm9iZV9leGFtcGxlLmMgYi9zYW1wbGVzL2tw
cm9iZXMva3Byb2JlX2V4YW1wbGUuYwppbmRleCAzNjZkYjFhLi5lZjNiNWVlIDEwMDY0NAotLS0g
YS9zYW1wbGVzL2twcm9iZXMva3Byb2JlX2V4YW1wbGUuYworKysgYi9zYW1wbGVzL2twcm9iZXMv
a3Byb2JlX2V4YW1wbGUuYwpAQCAtMTYsNyArMTYsOCBAQAogCiAvKiBGb3IgZWFjaCBwcm9iZSB5
b3UgbmVlZCB0byBhbGxvY2F0ZSBhIGtwcm9iZSBzdHJ1Y3R1cmUgKi8KIHN0YXRpYyBzdHJ1Y3Qg
a3Byb2JlIGtwID0gewotCS5zeW1ib2xfbmFtZQk9ICJkb19mb3JrIiwKKy8qCS5zeW1ib2xfbmFt
ZQk9ICJkb19mb3JrIiwgKi8KKwkuc3ltYm9sX25hbWUJPSAiX19yYWlzZV9zb2Z0aXJxX2lycW9m
Zl9rc29mdCIsCiB9OwogCiAvKiBrcHJvYmUgcHJlX2hhbmRsZXI6IGNhbGxlZCBqdXN0IGJlZm9y
ZSB0aGUgcHJvYmVkIGluc3RydWN0aW9uIGlzIGV4ZWN1dGVkICovCkBAIC01MSw2ICs1Miw4IEBA
IHN0YXRpYyBpbnQgaGFuZGxlcl9wcmUoc3RydWN0IGtwcm9iZSAqcCwgc3RydWN0IHB0X3JlZ3Mg
KnJlZ3MpCiBzdGF0aWMgdm9pZCBoYW5kbGVyX3Bvc3Qoc3RydWN0IGtwcm9iZSAqcCwgc3RydWN0
IHB0X3JlZ3MgKnJlZ3MsCiAJCQkJdW5zaWduZWQgbG9uZyBmbGFncykKIHsKKyAgdW5zaWduZWQg
aWQgPSBzbXBfcHJvY2Vzc29yX2lkKCk7CisKICNpZmRlZiBDT05GSUdfWDg2CiAJcHJpbnRrKEtF
Uk5fSU5GTyAicG9zdF9oYW5kbGVyOiBwLT5hZGRyID0gMHglcCwgZmxhZ3MgPSAweCVseFxuIiwK
IAkJcC0+YWRkciwgcmVncy0+ZmxhZ3MpOwpAQCAtNjcsNiArNzAsMjUgQEAgc3RhdGljIHZvaWQg
aGFuZGxlcl9wb3N0KHN0cnVjdCBrcHJvYmUgKnAsIHN0cnVjdCBwdF9yZWdzICpyZWdzLAogCXBy
aW50ayhLRVJOX0lORk8gInBvc3RfaGFuZGxlcjogcC0+YWRkciA9IDB4JXAsIGV4MSA9IDB4JWx4
XG4iLAogCQlwLT5hZGRyLCByZWdzLT5leDEpOwogI2VuZGlmCisKKwkvKiBjaGFuZ2UgaWQgdG8g
dGhhdCB3aGVyZSB0aGUgZXRoIElSUSBpcyBwaW5uZWQgKi8KKwlpZiAoaWQgPT0gMCkgeworCQlw
cl9pbmZvKCJTd2l0Y2hlZCB0byBldGhlcm5ldCBOQVBJLlxuIik7CisjaWZkZWYgQ09ORklHX0FS
TQorCQlwcl9pbmZvKCJwb3N0X2hhbmRsZXI6IHAtPmFkZHIgPSAweCVwLCBwYyA9IDB4JWx4LCIK
KwkJCSIgbHIgPSAweCVseCwgY3BzciA9IDB4JWx4XG4iLAorCQkJcC0+YWRkciwgcmVncy0+QVJN
X3BjLCByZWdzLT5BUk1fbHIsIHJlZ3MtPkFSTV9jcHNyKTsKKyNlbmRpZgorCX0KKwkvKiBjaGFu
Z2UgaWQgdG8gdGhhdCB3aGVyZSB0aGUgQ0FOIElSUSBpcyBwaW5uZWQgKi8KKwlpZiAoaWQgPT0g
MSkgeworCQlwcl9pbmZvKCJTd2l0Y2hlZCB0byBDQU4gTkFQSS5cbiIpOworI2lmZGVmIENPTkZJ
R19BUk0KKwkJcHJfaW5mbygicG9zdF9oYW5kbGVyOiBwLT5hZGRyID0gMHglcCwgcGMgPSAweCVs
eCwiCisJCQkiIGxyID0gMHglbHgsIGNwc3IgPSAweCVseFxuIiwKKwkJCXAtPmFkZHIsIHJlZ3Mt
PkFSTV9wYywgcmVncy0+QVJNX2xyLCByZWdzLT5BUk1fY3Bzcik7CisjZW5kaWYKKwl9CiB9CiAK
IC8qCi0tIAoyLjEuNAoK
--001a11444c18f57e05053ba2f969--
