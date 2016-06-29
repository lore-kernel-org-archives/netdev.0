From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next v3] tcp: use RFC6298 compliant TCP RTO calculation
Date: Wed, 29 Jun 2016 00:06:16 -0700
Message-ID: <CAK6E8=dx0Yt7y2g6JBi4JWM5Z8ARQPSsAYioEOPS5DiGkTU1yw@mail.gmail.com>
References: <CAK6E8=eeso8OEN_0-znqkuEyVTqzP1mTvwktk4QOsrLJXmuj9Q@mail.gmail.com>
 <20160615180003.28970-1-dmetz@mytum.de> <20160617.113235.1099766688971255047.davem@davemloft.net>
 <CAK6E8=eQNkSyAujuqF9hiE1iFk03O4T6op_-g=y87+UQUrS4=Q@mail.gmail.com> <CAK6E8=cyrog=2UmVpwP3jzCtFAR9LxxtS+g01R42H9jk=_cZ2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a113f86701e7d37053665667b
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	David Miller <davem@davemloft.net>
To: Daniel Metz <dmetz@mytum.de>, Hagen Paul Pfeifer <hagen@jauu.net>,
	Daniel Metz <Daniel.Metz@rohde-schwarz.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f43.google.com ([209.85.214.43]:35800 "EHLO
	mail-it0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750873AbcF2HHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 03:07:25 -0400
Received: by mail-it0-f43.google.com with SMTP id g127so110306976ith.0
        for <netdev@vger.kernel.org>; Wed, 29 Jun 2016 00:06:57 -0700 (PDT)
In-Reply-To: <CAK6E8=cyrog=2UmVpwP3jzCtFAR9LxxtS+g01R42H9jk=_cZ2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001a113f86701e7d37053665667b
Content-Type: text/plain; charset=UTF-8

On Tue, Jun 21, 2016 at 10:53 PM, Yuchung Cheng <ycheng@google.com> wrote:
>
> On Fri, Jun 17, 2016 at 11:56 AM, Yuchung Cheng <ycheng@google.com> wrote:
> >
> > On Fri, Jun 17, 2016 at 11:32 AM, David Miller <davem@davemloft.net> wrote:
> > >
> > > From: Daniel Metz <dmetz@mytum.de>
> > > Date: Wed, 15 Jun 2016 20:00:03 +0200
> > >
> > > > This patch adjusts Linux RTO calculation to be RFC6298 Standard
> > > > compliant. MinRTO is no longer added to the computed RTO, RTO damping
> > > > and overestimation are decreased.
> > >  ...
> > >
> > > Yuchung, I assume I am waiting for you to do the testing you said
> > > you would do for this patch, right?
> > Yes I spent the last two days resolving some unrelated glitches to
> > start my testing on Web servers. I should be able to get some results
> > over the weekend.
> >
> > I will test
> > 0) current Linux
> > 1) this patch
> > 2) RFC6298 with min_RTO=1sec
> > 3) RFC6298 with minimum RTTVAR of 200ms (so it is more like current
> > Linux style of min RTO which only applies to RTTVAR)
> >
> > and collect the TCP latency (how long to send an HTTP response) and
> > (spurious) timeout & retransmission stats.
> >
> Thanks for the patience. I've collected data from some Google Web
> servers. They serve both a mix of US and SouthAm users using
> HTTP1 and HTTP2. The traffic is Web browsing (e.g., search, maps,
> gmails, etc but not Youtube videos). The mean RTT is about 100ms.
>
> The user connections were split into 4 groups of different TCP RTO
> configs. Each group has many millions of connections but the
> size variation among groups is well under 1%.
>
> B: baseline Linux
> D: this patch
> R: change RTTYAR averaging as in D, but bound RTO to 1sec per RFC6298
> Y: change RTTVAR averaging as in D, but bound RTTVAR to 200ms instead (like B)
>
> For mean TCP latency of HTTP responses (first byte sent to last byte
> acked), B < R < Y < D. But the differences are so insignificant (<1%).
> The median, 95pctl, and 99pctl has similar indifference. In summary
> there's hardly visible impact on latency. I also look at only response
> less than 4KB but do not see a different picture.
>
> The main difference is the retransmission rate where R =~ Y < B =~D.
> R and Y are ~20% lower than B and D. Parsing the SNMP stats reveal
> more interesting details. The table shows the deltas in percentage to
> the baseline B.
>
>                 D      R     Y
> ------------------------------
> Timeout      +12%   -16%  -16%
> TailLossProb +28%    -7%   -7%
> DSACK_rcvd   +37%    -7%   -7%
> Cwnd-undo    +16%   -29%  -29%
>
> RTO change affects TLP because TLP will use the min of RTO and TLP
> timer value to arm the probe timer.
>
> The stats indicate that the main culprit of spurious timeouts / rtx is
> the RTO lower-bound. But they also show the RFC RTTVAR averaging is as
> good as current Linux approach.
>
> Given that I would recommend we revise this patch to use the RFC
> averaging but keep existing lower-bound (of RTTVAR to 200ms). We can
> further experiment the lower-bound and change that in a separate
> patch.
Hi I have some update.

I instrumented the kernel to capture the time spent in recovery
(attached). The latency measurement starts when TCP goes into
recovery, triggered by either ACKs or RTOs.  The start time is the
(original) sent time of the first unacked packet. The end time is when
the ACK covers the highest sent sequence when recovery started. The
total latency in usec and count are recorded in MIB_TCPRECOVLAT and
MIB_TCPRECOVCNT. If the connection times out or closes while the
sender was still in recovery, the total latency and count are stored
in MIB_TCPRECOVLAT2 and MIB_TCPRECOVCNT2. This second bucket is to
capture long recovery that led to eventual connection aborts.

Since network stat is usually power distribution, the mean of such
distribution is gonna be dominated by the tail. but the new metrics
still shows very interesting impact of different RTOs. Using the same
table format like my previous email. This table shows the difference
in percentage to the baseline.

                                      B        D      R     Y
------------------------------------------------------------------------------
mean TCPRecovLat      3s      -7%   +39% +38%
mean TCPRecovLat2    52s     +1%   -11%  -11%

The new metrics show that lower-bounding RTO to 200ms (D) indeed
lowers the latency. But by my previous analysis, D has a lot more
spurious rtx and TLPs (which the collateral damage on latency is not
captured by these metrics). And note that TLP timer uses the min of
RTO and TLP timeout, so TLP fires 28% more often in (D). Therefore the
latency may be mainly benefited from a faster TLP timer. Nevertheless
the significant impacts on recovery latency do not show up on the
response latency we measured earlier. My conjecture is that only a
small fraction of flows experience losses so even a 40% increase on
average on loss recovery does not move the needle, or the latency
reduction was cancelled by the latency increase of spurious timeouts
and CC reactions.

hmm it almost seen that the current code is the right balance. We may
need more investigation.

Daniel and Hagen, could you try my instrumentation patch on your testbed?

--001a113f86701e7d37053665667b
Content-Type: application/octet-stream;
	name="0001-tcp-instrument-recovery-latency.patch"
Content-Disposition: attachment;
	filename="0001-tcp-instrument-recovery-latency.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_iq0jeoqm0

RnJvbSA3NjkyZDg3YWYxNzE1MTRlNGU0YjVmYjMxNjMxZmFmNmQ0ZjYwNGQ2IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBZdWNodW5nIENoZW5nIDx5Y2hlbmdAZ29vZ2xlLmNvbT4KRGF0
ZTogTW9uLCAyNyBKdW4gMjAxNiAxODoxNjoxMSAtMDcwMApTdWJqZWN0OiBbUEFUQ0hdIHRjcDog
aW5zdHJ1bWVudCByZWNvdmVyeSBsYXRlbmN5CgpBZGRpbmcgZm91ciBTTk1QIHN0YXRzIGZvciBy
ZWNvdmVyeSBsYXRlbmN5LiBUaGUgbGF0ZW5jeSBtZWFzdXJlbWVudApzdGFydHMgd2hlbiBUQ1Ag
Z29lcyBpbnRvIHJlY292ZXJ5LCB0cmlnZ2VyZWQgYnkgZWl0aGVyIEFDS3MKb3IgUlRPcy4gIFRo
ZSBzdGFydCB0aW1lIGlzIHRoZSAob3JpZ2luYWwpIHNlbnQgdGltZSBvZiB0aGUgZmlyc3QKdW5h
Y2tlZCBwYWNrZXQuIFRoZSBlbmQgdGltZSBpcyB3aGVuIHRoZSBBQ0sgY292ZXJzIHRoZSBoaWdo
ZXN0CnNlbnQgc2VxdWVuY2Ugd2hlbiByZWNvdmVyeSBzdGFydGVkLiBUaGUgdG90YWwgbGF0ZW5j
eSBpbiB1c2VjIGFuZApjb3VudCBhcmUgcmVjb3JkZWQgaW4gTUlCX1RDUFJFQ09WTEFUIGFuZCBN
SUJfVENQUkVDT1ZDTlQuCgpJZiB0aGUgY29ubmVjdGlvbiB0aW1lcyBvdXQgb3IgY2xvc2VzIHdo
aWxlIHdlIHdlcmUgaW4gcmVjb3ZlcnksCnRoZSB0b3RhbCBsYXRlbmN5IGFuZCBjb3VudCBhcmUg
c3RvcmVkIGluIE1JQl9UQ1BSRUNPVkxBVDIgYW5kCk1JQl9UQ1BSRUNPVkNOVDIuCi0tLQogaW5j
bHVkZS9saW51eC90Y3AuaCAgICAgICB8ICAzICsrKwogaW5jbHVkZS9uZXQvdGNwLmggICAgICAg
ICB8ICA3ICsrKysrKysKIGluY2x1ZGUvdWFwaS9saW51eC9zbm1wLmggfCAgNCArKysrCiBuZXQv
aXB2NC9wcm9jLmMgICAgICAgICAgIHwgIDQgKysrKwogbmV0L2lwdjQvdGNwLmMgICAgICAgICAg
ICB8ICAxICsKIG5ldC9pcHY0L3RjcF9pbnB1dC5jICAgICAgfCAgNyArKysrKysrCiBuZXQvaXB2
NC90Y3BfcmVjb3ZlcnkuYyAgIHwgMzEgKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKwog
bmV0L2lwdjQvdGNwX3RpbWVyLmMgICAgICB8ICAxICsKIDggZmlsZXMgY2hhbmdlZCwgNTggaW5z
ZXJ0aW9ucygrKQoKZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGludXgvdGNwLmggYi9pbmNsdWRlL2xp
bnV4L3RjcC5oCmluZGV4IDdiZTliMTIuLmM2ZDYxODkgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvbGlu
dXgvdGNwLmgKKysrIGIvaW5jbHVkZS9saW51eC90Y3AuaApAQCAtMzU1LDYgKzM1NSw3IEBAIHN0
cnVjdCB0Y3Bfc29jayB7CiAJICovCiAJc3RydWN0IHJlcXVlc3Rfc29jayAqZmFzdG9wZW5fcnNr
OwogCXUzMgkqc2F2ZWRfc3luOworCXN0cnVjdCBza2JfbXN0YW1wIHJlY292X3N0YXJ0OwogfTsK
IAogZW51bSB0c3FfZmxhZ3MgewpAQCAtMzg4LDYgKzM4OSw4IEBAIHN0cnVjdCB0Y3BfdGltZXdh
aXRfc29jayB7CiAjaWZkZWYgQ09ORklHX1RDUF9NRDVTSUcKIAlzdHJ1Y3QgdGNwX21kNXNpZ19r
ZXkJICAqdHdfbWQ1X2tleTsKICNlbmRpZgorCisJc3RydWN0IHNrYl9tc3RhbXAgcmVjb3Zfc3Rh
cnQ7CiB9OwogCiBzdGF0aWMgaW5saW5lIHN0cnVjdCB0Y3BfdGltZXdhaXRfc29jayAqdGNwX3R3
c2soY29uc3Qgc3RydWN0IHNvY2sgKnNrKQpkaWZmIC0tZ2l0IGEvaW5jbHVkZS9uZXQvdGNwLmgg
Yi9pbmNsdWRlL25ldC90Y3AuaAppbmRleCBhNzk4OTRiLi44NWMzOGZhIDEwMDY0NAotLS0gYS9p
bmNsdWRlL25ldC90Y3AuaAorKysgYi9pbmNsdWRlL25ldC90Y3AuaApAQCAtMTg2Miw2ICsxODYy
LDEzIEBAIHN0YXRpYyBpbmxpbmUgdm9pZCB0Y3Bfc2Vnc19pbihzdHJ1Y3QgdGNwX3NvY2sgKnRw
LCBjb25zdCBzdHJ1Y3Qgc2tfYnVmZiAqc2tiKQogCQl0cC0+ZGF0YV9zZWdzX2luICs9IHNlZ3Nf
aW47CiB9CiAKK3N0YXRpYyBpbmxpbmUgdm9pZCB0Y3BfcmVzZXRfcmVjb3ZlcnlfbGF0ZW5jeShz
dHJ1Y3QgdGNwX3NvY2sgKnRwKQoreworCXRwLT5yZWNvdl9zdGFydC52NjQgPSAwOworfQordm9p
ZCB0Y3Bfc3RhcnRfcmVjb3ZlcnlfbGF0ZW5jeShzdHJ1Y3Qgc29jayAqc2spOwordm9pZCB0Y3Bf
ZW5kX3JlY292ZXJ5X2xhdGVuY3koc3RydWN0IHNvY2sgKnNrLCBib29sIGFja2VkKTsKKwogLyoK
ICAqIFRDUCBsaXN0ZW4gcGF0aCBydW5zIGxvY2tsZXNzLgogICogV2UgZm9yY2VkICJzdHJ1Y3Qg
c29jayIgdG8gYmUgY29uc3QgcXVhbGlmaWVkIHRvIG1ha2Ugc3VyZQpkaWZmIC0tZ2l0IGEvaW5j
bHVkZS91YXBpL2xpbnV4L3NubXAuaCBiL2luY2x1ZGUvdWFwaS9saW51eC9zbm1wLmgKaW5kZXgg
MjVhOWFkOC4uNjIyOGJmOSAxMDA2NDQKLS0tIGEvaW5jbHVkZS91YXBpL2xpbnV4L3NubXAuaAor
KysgYi9pbmNsdWRlL3VhcGkvbGludXgvc25tcC5oCkBAIC0yODAsNiArMjgwLDEwIEBAIGVudW0K
IAlMSU5VWF9NSUJfVENQS0VFUEFMSVZFLAkJCS8qIFRDUEtlZXBBbGl2ZSAqLwogCUxJTlVYX01J
Ql9UQ1BNVFVQRkFJTCwJCQkvKiBUQ1BNVFVQRmFpbCAqLwogCUxJTlVYX01JQl9UQ1BNVFVQU1VD
Q0VTUywJCS8qIFRDUE1UVVBTdWNjZXNzICovCisJTElOVVhfTUlCX1RDUFJFQ09WTEFULAorCUxJ
TlVYX01JQl9UQ1BSRUNPVkNOVCwKKwlMSU5VWF9NSUJfVENQUkVDT1ZMQVQyLAorCUxJTlVYX01J
Ql9UQ1BSRUNPVkNOVDIsCiAJX19MSU5VWF9NSUJfTUFYCiB9OwogCmRpZmYgLS1naXQgYS9uZXQv
aXB2NC9wcm9jLmMgYi9uZXQvaXB2NC9wcm9jLmMKaW5kZXggOWY2NjViNi4uMDAyOTQyOSAxMDA2
NDQKLS0tIGEvbmV0L2lwdjQvcHJvYy5jCisrKyBiL25ldC9pcHY0L3Byb2MuYwpAQCAtMzAyLDYg
KzMwMiwxMCBAQCBzdGF0aWMgY29uc3Qgc3RydWN0IHNubXBfbWliIHNubXA0X25ldF9saXN0W10g
PSB7CiAJU05NUF9NSUJfSVRFTSgiVENQS2VlcEFsaXZlIiwgTElOVVhfTUlCX1RDUEtFRVBBTElW
RSksCiAJU05NUF9NSUJfSVRFTSgiVENQTVRVUEZhaWwiLCBMSU5VWF9NSUJfVENQTVRVUEZBSUwp
LAogCVNOTVBfTUlCX0lURU0oIlRDUE1UVVBTdWNjZXNzIiwgTElOVVhfTUlCX1RDUE1UVVBTVUND
RVNTKSwKKwlTTk1QX01JQl9JVEVNKCJUQ1BSZWNvdkxhdCIsIExJTlVYX01JQl9UQ1BSRUNPVkxB
VCksCisJU05NUF9NSUJfSVRFTSgiVENQUmVjb3ZDbnQiLCBMSU5VWF9NSUJfVENQUkVDT1ZDTlQp
LAorCVNOTVBfTUlCX0lURU0oIlRDUFJlY292TGF0MiIsIExJTlVYX01JQl9UQ1BSRUNPVkxBVDIp
LAorCVNOTVBfTUlCX0lURU0oIlRDUFJlY292Q250MiIsIExJTlVYX01JQl9UQ1BSRUNPVkNOVDIp
LAogCVNOTVBfTUlCX1NFTlRJTkVMCiB9OwogCmRpZmYgLS1naXQgYS9uZXQvaXB2NC90Y3AuYyBi
L25ldC9pcHY0L3RjcC5jCmluZGV4IDVjN2VkMTQuLjNkZTQ2NDkgMTAwNjQ0Ci0tLSBhL25ldC9p
cHY0L3RjcC5jCisrKyBiL25ldC9pcHY0L3RjcC5jCkBAIC0yMTExLDYgKzIxMTEsNyBAQCB2b2lk
IHRjcF9jbG9zZShzdHJ1Y3Qgc29jayAqc2ssIGxvbmcgdGltZW91dCkKIAkJICovCiAJCXRjcF9z
ZW5kX2Zpbihzayk7CiAJfQorCXRjcF9lbmRfcmVjb3ZlcnlfbGF0ZW5jeShzaywgZmFsc2UpOwog
CiAJc2tfc3RyZWFtX3dhaXRfY2xvc2Uoc2ssIHRpbWVvdXQpOwogCmRpZmYgLS1naXQgYS9uZXQv
aXB2NC90Y3BfaW5wdXQuYyBiL25ldC9pcHY0L3RjcF9pbnB1dC5jCmluZGV4IDk0ZDRhZmYuLjEx
NjkxODMgMTAwNjQ0Ci0tLSBhL25ldC9pcHY0L3RjcF9pbnB1dC5jCisrKyBiL25ldC9pcHY0L3Rj
cF9pbnB1dC5jCkBAIC0xOTUxLDYgKzE5NTEsOCBAQCB2b2lkIHRjcF9lbnRlcl9sb3NzKHN0cnVj
dCBzb2NrICpzaykKIAl0cC0+ZnJ0byA9IHN5c2N0bF90Y3BfZnJ0byAmJgogCQkgICAobmV3X3Jl
Y292ZXJ5IHx8IGljc2stPmljc2tfcmV0cmFuc21pdHMpICYmCiAJCSAgICFpbmV0X2Nzayhzaykt
Pmljc2tfbXR1cC5wcm9iZV9zaXplOworCisJdGNwX3N0YXJ0X3JlY292ZXJ5X2xhdGVuY3koc2sp
OwogfQogCiAvKiBJZiBBQ0sgYXJyaXZlZCBwb2ludGluZyB0byBhIHJlbWVtYmVyZWQgU0FDSywg
aXQgbWVhbnMgdGhhdCBvdXIKQEAgLTIzNzQsNiArMjM3Niw3IEBAIHN0YXRpYyB2b2lkIHRjcF91
bmRvX2N3bmRfcmVkdWN0aW9uKHN0cnVjdCBzb2NrICpzaywgYm9vbCB1bm1hcmtfbG9zcykKIAl9
CiAJdHAtPnNuZF9jd25kX3N0YW1wID0gdGNwX3RpbWVfc3RhbXA7CiAJdHAtPnVuZG9fbWFya2Vy
ID0gMDsKKwl0Y3BfcmVzZXRfcmVjb3ZlcnlfbGF0ZW5jeSh0cCk7IC8qIFNwdXJpb3VzIHJlY292
ZXJ5ICovCiB9CiAKIHN0YXRpYyBpbmxpbmUgYm9vbCB0Y3BfbWF5X3VuZG8oY29uc3Qgc3RydWN0
IHRjcF9zb2NrICp0cCkKQEAgLTI2NTgsNiArMjY2MSw4IEBAIHN0YXRpYyB2b2lkIHRjcF9lbnRl
cl9yZWNvdmVyeShzdHJ1Y3Qgc29jayAqc2ssIGJvb2wgZWNlX2FjaykKIAkJdGNwX2luaXRfY3du
ZF9yZWR1Y3Rpb24oc2spOwogCX0KIAl0Y3Bfc2V0X2NhX3N0YXRlKHNrLCBUQ1BfQ0FfUmVjb3Zl
cnkpOworCisJdGNwX3N0YXJ0X3JlY292ZXJ5X2xhdGVuY3koc2spOwogfQogCiAvKiBQcm9jZXNz
IGFuIEFDSyBpbiBDQV9Mb3NzIHN0YXRlLiBNb3ZlIHRvIENBX09wZW4gaWYgbG9zdCBkYXRhIGFy
ZQpAQCAtMjc5MCw2ICsyNzk1LDcgQEAgc3RhdGljIHZvaWQgdGNwX2Zhc3RyZXRyYW5zX2FsZXJ0
KHN0cnVjdCBzb2NrICpzaywgY29uc3QgaW50IGFja2VkLAogCWlmIChpY3NrLT5pY3NrX2NhX3N0
YXRlID09IFRDUF9DQV9PcGVuKSB7CiAJCVdBUk5fT04odHAtPnJldHJhbnNfb3V0ICE9IDApOwog
CQl0cC0+cmV0cmFuc19zdGFtcCA9IDA7CisJCXRjcF9yZXNldF9yZWNvdmVyeV9sYXRlbmN5KHRw
KTsgLyogUGFyYW5vaWQgcmVzZXQgKi8KIAl9IGVsc2UgaWYgKCFiZWZvcmUodHAtPnNuZF91bmEs
IHRwLT5oaWdoX3NlcSkpIHsKIAkJc3dpdGNoIChpY3NrLT5pY3NrX2NhX3N0YXRlKSB7CiAJCWNh
c2UgVENQX0NBX0NXUjoKQEAgLTI4MDksNiArMjgxNSw3IEBAIHN0YXRpYyB2b2lkIHRjcF9mYXN0
cmV0cmFuc19hbGVydChzdHJ1Y3Qgc29jayAqc2ssIGNvbnN0IGludCBhY2tlZCwKIAkJCXRjcF9l
bmRfY3duZF9yZWR1Y3Rpb24oc2spOwogCQkJYnJlYWs7CiAJCX0KKwkJdGNwX2VuZF9yZWNvdmVy
eV9sYXRlbmN5KHNrLCB0cnVlKTsKIAl9CiAKIAkvKiBVc2UgUkFDSyB0byBkZXRlY3QgbG9zcyAq
LwpkaWZmIC0tZ2l0IGEvbmV0L2lwdjQvdGNwX3JlY292ZXJ5LmMgYi9uZXQvaXB2NC90Y3BfcmVj
b3ZlcnkuYwppbmRleCBlMzZkZjRmLi40NjA5M2E1IDEwMDY0NAotLS0gYS9uZXQvaXB2NC90Y3Bf
cmVjb3ZlcnkuYworKysgYi9uZXQvaXB2NC90Y3BfcmVjb3ZlcnkuYwpAQCAtMTA3LDMgKzEwNywz
NCBAQCB2b2lkIHRjcF9yYWNrX2FkdmFuY2Uoc3RydWN0IHRjcF9zb2NrICp0cCwKIAl0cC0+cmFj
ay5tc3RhbXAgPSAqeG1pdF90aW1lOwogCXRwLT5yYWNrLmFkdmFuY2VkID0gMTsKIH0KKworLyog
Q2FsbGVyIG11c3QgY2hlY2sgd3JpdGUgcXVldWUgaXMgbm90IGVtcHR5ICovCit2b2lkIHRjcF9z
dGFydF9yZWNvdmVyeV9sYXRlbmN5KHN0cnVjdCBzb2NrICpzaykKK3sKKwlzdHJ1Y3QgdGNwX3Nv
Y2sgKnRwID0gdGNwX3NrKHNrKTsKKworCWlmICghdHAtPnJlY292X3N0YXJ0LnY2NCkKKwkJdHAt
PnJlY292X3N0YXJ0ID0gdGNwX3dyaXRlX3F1ZXVlX2hlYWQoc2spLT5za2JfbXN0YW1wOworfQor
Cit2b2lkIHRjcF9lbmRfcmVjb3ZlcnlfbGF0ZW5jeShzdHJ1Y3Qgc29jayAqc2ssIGJvb2wgYWNr
ZWQpCit7CisJc3RydWN0IHRjcF9zb2NrICp0cCA9IHRjcF9zayhzayk7CisJc3RydWN0IG5ldCAq
bmV0ID0gc29ja19uZXQoc2spOworCXN0cnVjdCBza2JfbXN0YW1wIG5vdzsKKworCWlmICghdHAt
PnJlY292X3N0YXJ0LnY2NCkKKwkJcmV0dXJuOworCisJc2tiX21zdGFtcF9nZXQoJm5vdyk7CisJ
aWYgKGFja2VkKSB7CisJCU5FVF9BRERfU1RBVFMobmV0LCBMSU5VWF9NSUJfVENQUkVDT1ZMQVQs
CisJCQkgICAgICBza2JfbXN0YW1wX3VzX2RlbHRhKCZub3csICZ0cC0+cmVjb3Zfc3RhcnQpKTsK
KwkJTkVUX0lOQ19TVEFUUyhuZXQsIExJTlVYX01JQl9UQ1BSRUNPVkNOVCk7CisJfSBlbHNlIHsK
KwkJTkVUX0FERF9TVEFUUyhuZXQsIExJTlVYX01JQl9UQ1BSRUNPVkxBVDIsCisJCQkgICAgICBz
a2JfbXN0YW1wX3VzX2RlbHRhKCZub3csICZ0cC0+cmVjb3Zfc3RhcnQpKTsKKwkJTkVUX0lOQ19T
VEFUUyhuZXQsIExJTlVYX01JQl9UQ1BSRUNPVkNOVDIpOworCX0KKwl0cC0+cmVjb3Zfc3RhcnQu
djY0ID0gMDsKK30KZGlmZiAtLWdpdCBhL25ldC9pcHY0L3RjcF90aW1lci5jIGIvbmV0L2lwdjQv
dGNwX3RpbWVyLmMKaW5kZXggZGViZGQ4Yi4uN2VkYzA1OSAxMDA2NDQKLS0tIGEvbmV0L2lwdjQv
dGNwX3RpbWVyLmMKKysrIGIvbmV0L2lwdjQvdGNwX3RpbWVyLmMKQEAgLTI5LDYgKzI5LDcgQEAg
c3RhdGljIHZvaWQgdGNwX3dyaXRlX2VycihzdHJ1Y3Qgc29jayAqc2spCiAJc2stPnNrX2VyciA9
IHNrLT5za19lcnJfc29mdCA/IDogRVRJTUVET1VUOwogCXNrLT5za19lcnJvcl9yZXBvcnQoc2sp
OwogCisJdGNwX2VuZF9yZWNvdmVyeV9sYXRlbmN5KHNrLCBmYWxzZSk7CiAJdGNwX2RvbmUoc2sp
OwogCV9fTkVUX0lOQ19TVEFUUyhzb2NrX25ldChzayksIExJTlVYX01JQl9UQ1BBQk9SVE9OVElN
RU9VVCk7CiB9Ci0tIAoyLjguMC5yYzMuMjI2LmczOWQ0MDIwCgo=
--001a113f86701e7d37053665667b--
