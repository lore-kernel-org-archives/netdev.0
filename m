From: Arthur Kepner <akepner@sgi.com>
Subject: [PATCH] "lockless loopback" patch for 2.6.6
Date: Fri, 21 May 2004 14:04:09 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.SGI.4.56.0405211356440.8333289@neteng.engr.sgi.com>
References: <Pine.SGI.4.56.0405111251080.7038576@neteng.engr.sgi.com>
 <20040512120810.464aaee6.davem@redhat.com> <Pine.SGI.4.56.0405121256510.7328714@neteng.engr.sgi.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1072017398-1885880095-1085173449=:8333289"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <Pine.SGI.4.56.0405121256510.7328714@neteng.engr.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

---1072017398-1885880095-1085173449=:8333289
Content-Type: TEXT/PLAIN; charset=US-ASCII


Lock contention on the loopback device can lead to poor
performance, even an essentially hung system, on systems
with many processors.

For the loopback device, the only purpose that locking serves
is to protect the device statistics. The attached patch
keeps per-cpu statistics for the loopback device and removes
all locking. The patch is against 2.6.6.


Worst-case loopback lock contention (2.4 kernel)
================================================

The following 'lockstat' data was taken with a 2.4 kernel
(though I expect similar results with 2.6).

The test scenario is that N transmitters simultaneously send
to N receivers, via the loopback, on an N cpu system. (This
was an attempt to simulate a hang seen at a customer site on
a large system.)

N   SPINLOCKS         HOLD            WAIT
      UTIL  CON    MEAN(  MAX )   MEAN(  MAX )(% CPU) NOWAIT SPIN NAME
------------------------------------------------------------------------------
2   6.0%  3.9%   48us(1397us)   74us(1172us)(0.18%)   96.1%  3.9% loopback_dev+0x1c0
8   17.0% 19.3%  137us( 117ms)  841us( 118ms)( 2.5%)  80.7% 19.3% loopback_dev+0x1c0
31* 72.2% 88.4% 1262us(  73ms)   25ms( 814ms)(39.7%)  11.6% 88.4% loopback_dev+0x1c0
64  74.7% 89.9% 2814us(1068ms)   85ms(4925ms)(31.5%)  10.1% 89.9% loopback_dev+0x1c0

(* yes, 31, one processor was down on a 32p system)

In the 64p case, the system is essentially unusable for
interactive processes when running this test case.

Throughput on the loopback device also scales very poorly.
In fact, if more than approximately 16 processors are used,
throughput decreases as more processors are added.

With (the 2.4 version of) the patch, the system remains quite
usable during the same test scenario and throughput scales
much better.

--

Arthur

---1072017398-1885880095-1085173449=:8333289
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="lockless_loopback.patch"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.SGI.4.56.0405211404090.8333289@neteng.engr.sgi.com>
Content-Description: lockless loopback patch
Content-Disposition: attachment; filename="lockless_loopback.patch"

ZGlmZiAtTmF1ciBsaW51eC5vcmlnL2RyaXZlcnMvbmV0L2xvb3BiYWNrLmMg
bGludXgvZHJpdmVycy9uZXQvbG9vcGJhY2suYw0KLS0tIGxpbnV4Lm9yaWcv
ZHJpdmVycy9uZXQvbG9vcGJhY2suYwkyMDA0LTA1LTIxIDExOjAwOjI0LjAw
MDAwMDAwMCAtMDcwMA0KKysrIGxpbnV4L2RyaXZlcnMvbmV0L2xvb3BiYWNr
LmMJMjAwNC0wNS0yMSAxMTowNDowMC4wMDAwMDAwMDAgLTA3MDANCkBAIC0x
MjMsNyArMTIzLDkgQEANCiAgKi8NCiBzdGF0aWMgaW50IGxvb3BiYWNrX3ht
aXQoc3RydWN0IHNrX2J1ZmYgKnNrYiwgc3RydWN0IG5ldF9kZXZpY2UgKmRl
dikNCiB7DQotCXN0cnVjdCBuZXRfZGV2aWNlX3N0YXRzICpzdGF0cyA9IGRl
di0+cHJpdjsNCisJc3RydWN0IG5ldF9kZXZpY2Vfc3RhdHMgKmdsb2JhbF9z
dGF0cyA9IGRldi0+cHJpdjsNCisJc3RydWN0IG5ldF9kZXZpY2Vfc3RhdHMg
KnBlcmNwdV9zdGF0cyA9IDA7DQorCXN0cnVjdCBuZXRfZGV2aWNlX3N0YXRz
ICpsb2NhbF9zdGF0cyAgPSAwOw0KIA0KIAlza2Jfb3JwaGFuKHNrYik7DQog
DQpAQCAtMTQyLDExICsxNDQsMTMgQEANCiAJfQ0KIA0KIAlkZXYtPmxhc3Rf
cnggPSBqaWZmaWVzOw0KLQlpZiAobGlrZWx5KHN0YXRzKSkgew0KLQkJc3Rh
dHMtPnJ4X2J5dGVzKz1za2ItPmxlbjsNCi0JCXN0YXRzLT50eF9ieXRlcys9
c2tiLT5sZW47DQotCQlzdGF0cy0+cnhfcGFja2V0cysrOw0KLQkJc3RhdHMt
PnR4X3BhY2tldHMrKzsNCisJaWYgKGxpa2VseShnbG9iYWxfc3RhdHMpKSB7
DQorCQlwZXJjcHVfc3RhdHMgPSBnbG9iYWxfc3RhdHMgKyAxOw0KKwkJbG9j
YWxfc3RhdHMgID0gJnBlcmNwdV9zdGF0c1tzbXBfcHJvY2Vzc29yX2lkKCld
Ow0KKwkJbG9jYWxfc3RhdHMtPnJ4X2J5dGVzKz1za2ItPmxlbjsNCisJCWxv
Y2FsX3N0YXRzLT50eF9ieXRlcys9c2tiLT5sZW47DQorCQlsb2NhbF9zdGF0
cy0+cnhfcGFja2V0cysrOw0KKwkJbG9jYWxfc3RhdHMtPnR4X3BhY2tldHMr
KzsNCiAJfQ0KIA0KIAluZXRpZl9yeChza2IpOw0KQEAgLTE1Niw3ICsxNjAs
MjIgQEANCiANCiBzdGF0aWMgc3RydWN0IG5ldF9kZXZpY2Vfc3RhdHMgKmdl
dF9zdGF0cyhzdHJ1Y3QgbmV0X2RldmljZSAqZGV2KQ0KIHsNCi0JcmV0dXJu
IChzdHJ1Y3QgbmV0X2RldmljZV9zdGF0cyAqKWRldi0+cHJpdjsNCisJaW50
IGk7DQorCXN0cnVjdCBuZXRfZGV2aWNlX3N0YXRzICpnbG9iYWxfc3RhdHMg
PSBkZXYtPnByaXY7DQorCXN0cnVjdCBuZXRfZGV2aWNlX3N0YXRzICpwZXJj
cHVfc3RhdHMgPSAwOw0KKw0KKwlpZiAoZ2xvYmFsX3N0YXRzKSB7DQorCQlw
ZXJjcHVfc3RhdHMgPSBnbG9iYWxfc3RhdHMgKyAxOw0KKwkJLyogemVybyB0
aGUgc3lzdGVtLXdpZGUgc3RhdHMgKi8NCisJCW1lbXNldChnbG9iYWxfc3Rh
dHMsIDAsIHNpemVvZihzdHJ1Y3QgbmV0X2RldmljZV9zdGF0cykpOw0KKwkJ
Zm9yICggaSA9IDA7IGkgPCBOUl9DUFVTOyBpKysgKSB7DQorCQkJZ2xvYmFs
X3N0YXRzLT5yeF9ieXRlcyAgICs9IHBlcmNwdV9zdGF0c1tpXS5yeF9ieXRl
czsNCisJCQlnbG9iYWxfc3RhdHMtPnR4X2J5dGVzICAgKz0gcGVyY3B1X3N0
YXRzW2ldLnR4X2J5dGVzOw0KKwkJCWdsb2JhbF9zdGF0cy0+cnhfcGFja2V0
cyArPSBwZXJjcHVfc3RhdHNbaV0ucnhfcGFja2V0czsNCisJCQlnbG9iYWxf
c3RhdHMtPnR4X3BhY2tldHMgKz0gcGVyY3B1X3N0YXRzW2ldLnR4X3BhY2tl
dHM7DQorCQl9DQorCX0NCisJcmV0dXJuIGdsb2JhbF9zdGF0czsNCiB9DQog
DQogc3RydWN0IG5ldF9kZXZpY2UgbG9vcGJhY2tfZGV2ID0gew0KQEAgLTE4
MSwxMyArMjAwLDE5IEBADQogew0KIAlzdHJ1Y3QgbmV0X2RldmljZV9zdGF0
cyAqc3RhdHM7DQogDQorI2RlZmluZSBOUl9MT09QX1NUQVRTIChOUl9DUFVT
ICsgMSkNCisJLyogdGhlIGZpcnN0IG5ldF9kZXZpY2Vfc3RhdHMgc3RydWN0
dXJlIGlzIGZvciB0aGUgd2hvbGUgc3lzdGVtLCB0aGUgDQorCSAqIHJlbWFp
bmluZyBOUl9DUFVTIG9mIHRoZW0gYXJlIGZvciBlYWNoIGNwdSAqLw0KKw0K
IAkvKiBDYW4gc3Vydml2ZSB3aXRob3V0IHN0YXRpc3RpY3MgKi8NCi0Jc3Rh
dHMgPSBrbWFsbG9jKHNpemVvZihzdHJ1Y3QgbmV0X2RldmljZV9zdGF0cyks
IEdGUF9LRVJORUwpOw0KKwlzdGF0cyA9IGttYWxsb2MoTlJfTE9PUF9TVEFU
UyAqIHNpemVvZihzdHJ1Y3QgbmV0X2RldmljZV9zdGF0cyksIEdGUF9LRVJO
RUwpOw0KKw0KIAlpZiAoc3RhdHMpIHsNCi0JCW1lbXNldChzdGF0cywgMCwg
c2l6ZW9mKHN0cnVjdCBuZXRfZGV2aWNlX3N0YXRzKSk7DQorCQltZW1zZXQo
c3RhdHMsIDAsIE5SX0xPT1BfU1RBVFMgKiBzaXplb2Yoc3RydWN0IG5ldF9k
ZXZpY2Vfc3RhdHMpKTsNCiAJCWxvb3BiYWNrX2Rldi5wcml2ID0gc3RhdHM7
DQogCQlsb29wYmFja19kZXYuZ2V0X3N0YXRzID0gJmdldF9zdGF0czsNCiAJ
fQ0KKyN1bmRlZiAgTlJfTE9PUF9TVEFUUw0KIAkNCiAJcmV0dXJuIHJlZ2lz
dGVyX25ldGRldigmbG9vcGJhY2tfZGV2KTsNCiB9Ow0KZGlmZiAtTmF1ciBs
aW51eC5vcmlnL25ldC9jb3JlL2Rldi5jIGxpbnV4L25ldC9jb3JlL2Rldi5j
DQotLS0gbGludXgub3JpZy9uZXQvY29yZS9kZXYuYwkyMDA0LTA1LTIxIDEx
OjAxOjAxLjAwMDAwMDAwMCAtMDcwMA0KKysrIGxpbnV4L25ldC9jb3JlL2Rl
di5jCTIwMDQtMDUtMjEgMTE6MDM6NDQuMDAwMDAwMDAwIC0wNzAwDQpAQCAt
MTI5NSw2ICsxMjk1LDcgQEANCiAJc3RydWN0IG5ldF9kZXZpY2UgKmRldiA9
IHNrYi0+ZGV2Ow0KIAlzdHJ1Y3QgUWRpc2MgKnE7DQogCWludCByYyA9IC1F
Tk9NRU07DQorCWludCBsb29wYmFjayA9IGRldi0+ZmxhZ3MgJiBJRkZfTE9P
UEJBQ0s7DQogDQogCWlmIChza2Jfc2hpbmZvKHNrYiktPmZyYWdfbGlzdCAm
Jg0KIAkgICAgIShkZXYtPmZlYXR1cmVzICYgTkVUSUZfRl9GUkFHTElTVCkg
JiYNCkBAIC0xMzIyLDE3ICsxMzIzLDE5IEBADQogCX0NCiANCiAJLyogR3Jh
YiBkZXZpY2UgcXVldWUgKi8NCi0Jc3Bpbl9sb2NrX2JoKCZkZXYtPnF1ZXVl
X2xvY2spOw0KLQlxID0gZGV2LT5xZGlzYzsNCi0JaWYgKHEtPmVucXVldWUp
IHsNCi0JCXJjID0gcS0+ZW5xdWV1ZShza2IsIHEpOw0KKwlpZiAoIWxvb3Bi
YWNrKSB7DQorCQlzcGluX2xvY2tfYmgoJmRldi0+cXVldWVfbG9jayk7DQor
CQlxID0gZGV2LT5xZGlzYzsNCisJCWlmIChxLT5lbnF1ZXVlKSB7DQorCQkJ
cmMgPSBxLT5lbnF1ZXVlKHNrYiwgcSk7DQogDQotCQlxZGlzY19ydW4oZGV2
KTsNCisJCQlxZGlzY19ydW4oZGV2KTsNCiANCi0JCXNwaW5fdW5sb2NrX2Jo
KCZkZXYtPnF1ZXVlX2xvY2spOw0KLQkJcmMgPSByYyA9PSBORVRfWE1JVF9C
WVBBU1MgPyBORVRfWE1JVF9TVUNDRVNTIDogcmM7DQotCQlnb3RvIG91dDsN
Ci0JfQ0KKwkJCXNwaW5fdW5sb2NrX2JoKCZkZXYtPnF1ZXVlX2xvY2spOw0K
KwkJCXJjID0gcmMgPT0gTkVUX1hNSVRfQllQQVNTID8gTkVUX1hNSVRfU1VD
Q0VTUyA6IHJjOw0KKwkJCWdvdG8gb3V0Ow0KKwkJfQ0KKwl9IC8qICFsb29w
YmFjayAqLw0KIA0KIAkvKiBUaGUgZGV2aWNlIGhhcyBubyBxdWV1ZS4gQ29t
bW9uIGNhc2UgZm9yIHNvZnR3YXJlIGRldmljZXM6DQogCSAgIGxvb3BiYWNr
LCBhbGwgdGhlIHNvcnRzIG9mIHR1bm5lbHMuLi4NCkBAIC0xMzU0LDExICsx
MzU3LDEzIEBADQogCQkJICogVGhlIHNwaW5fbG9jayBlZmZlY3Rpdmx5IGRv
ZXMgYSBwcmVlbXB0IGxvY2ssIGJ1dCANCiAJCQkgKiB3ZSBhcmUgYWJvdXQg
dG8gZHJvcCB0aGF0Li4uDQogCQkJICovDQotCQkJcHJlZW1wdF9kaXNhYmxl
KCk7DQotCQkJc3Bpbl91bmxvY2soJmRldi0+cXVldWVfbG9jayk7DQotCQkJ
c3Bpbl9sb2NrKCZkZXYtPnhtaXRfbG9jayk7DQotCQkJZGV2LT54bWl0X2xv
Y2tfb3duZXIgPSBjcHU7DQotCQkJcHJlZW1wdF9lbmFibGUoKTsNCisJCQlp
ZiAoIWxvb3BiYWNrKSB7DQorCQkJCXByZWVtcHRfZGlzYWJsZSgpOw0KKwkJ
CQlzcGluX3VubG9jaygmZGV2LT5xdWV1ZV9sb2NrKTsNCisJCQkJc3Bpbl9s
b2NrKCZkZXYtPnhtaXRfbG9jayk7DQorCQkJCWRldi0+eG1pdF9sb2NrX293
bmVyID0gY3B1Ow0KKwkJCQlwcmVlbXB0X2VuYWJsZSgpOw0KKwkJCX0NCiAN
CiAJCQlpZiAoIW5ldGlmX3F1ZXVlX3N0b3BwZWQoZGV2KSkgew0KIAkJCQlp
ZiAobmV0ZGV2X25pdCkNCkBAIC0xMzY2LDEzICsxMzcxLDE3IEBADQogDQog
CQkJCXJjID0gMDsNCiAJCQkJaWYgKCFkZXYtPmhhcmRfc3RhcnRfeG1pdChz
a2IsIGRldikpIHsNCi0JCQkJCWRldi0+eG1pdF9sb2NrX293bmVyID0gLTE7
DQotCQkJCQlzcGluX3VubG9ja19iaCgmZGV2LT54bWl0X2xvY2spOw0KKwkJ
CQkJaWYgKCFsb29wYmFjaykgew0KKwkJCQkJCWRldi0+eG1pdF9sb2NrX293
bmVyID0gLTE7DQorCQkJCQkJc3Bpbl91bmxvY2tfYmgoJmRldi0+eG1pdF9s
b2NrKTsNCisJCQkJCX0NCiAJCQkJCWdvdG8gb3V0Ow0KIAkJCQl9DQogCQkJ
fQ0KLQkJCWRldi0+eG1pdF9sb2NrX293bmVyID0gLTE7DQotCQkJc3Bpbl91
bmxvY2tfYmgoJmRldi0+eG1pdF9sb2NrKTsNCisJCQlpZiAoIWxvb3BiYWNr
KSB7DQorCQkJCWRldi0+eG1pdF9sb2NrX293bmVyID0gLTE7DQorCQkJCXNw
aW5fdW5sb2NrX2JoKCZkZXYtPnhtaXRfbG9jayk7DQorCQkJfQ0KIAkJCWlm
IChuZXRfcmF0ZWxpbWl0KCkpDQogCQkJCXByaW50ayhLRVJOX0NSSVQgIlZp
cnR1YWwgZGV2aWNlICVzIGFza3MgdG8gIg0KIAkJCQkgICAgICAgInF1ZXVl
IHBhY2tldCFcbiIsIGRldi0+bmFtZSk7DQpAQCAtMTM4NSw3ICsxMzk0LDgg
QEANCiAJCQkJICAgICAgICIlcywgZml4IGl0IHVyZ2VudGx5IVxuIiwgZGV2
LT5uYW1lKTsNCiAJCX0NCiAJfQ0KLQlzcGluX3VubG9ja19iaCgmZGV2LT5x
dWV1ZV9sb2NrKTsNCisJaWYgKCFsb29wYmFjaykNCisJCXNwaW5fdW5sb2Nr
X2JoKCZkZXYtPnF1ZXVlX2xvY2spOw0KIG91dF9lbmV0ZG93bjoNCiAJcmMg
PSAtRU5FVERPV047DQogb3V0X2tmcmVlX3NrYjoNCg==

---1072017398-1885880095-1085173449=:8333289--
