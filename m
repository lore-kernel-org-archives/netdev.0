From: Wei Sun <wsun@cse.unl.edu>
Subject: A bug report for Linux TCP congestion control algorithms
Date: Fri, 26 May 2017 01:08:34 -0500
Message-ID: <CAMN46fP_a_Jti_rcLze=7yoaDroQ7qn8kek9HMKtFEQpbm7R3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="94eb2c0550aeec439c0550672a1b"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:33557 "EHLO
        mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030445AbdEZGIg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 02:08:36 -0400
Received: by mail-qk0-f177.google.com with SMTP id y201so898773qka.0
        for <netdev@vger.kernel.org>; Thu, 25 May 2017 23:08:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--94eb2c0550aeec439c0550672a1b
Content-Type: text/plain; charset="UTF-8"

Hi there,

we find a special case for Linux TCP undo operations where
tp->snd_cwnd could be extremely large (e.g., 4294967294) by two
consecutive cwnd undo operations when using
reno/veno/vegas/highspeed/HTCP/yeah/westwood/hybla/illinois/scalable/lp
congestion control algorithms in the latest long-term kernel 4.9.

e.g., a simple trace for sender-side tcp state variables
cwnd               ssthresh              ca_state
10                   2147483647            0
10                   2147483647            0
1                           5                        4
11                    2147483647           4                   first
undo operation
4294967294    2147483647           0                   second undo operation
4294967294    2147483647           0


By debugging the code, we find that the second undo operation was
triggered by F-RTO mechanism without checking current tp->undo_marker.

The case should be existing for all kernel versions depending on F-RTO
internals (i.e., this bug exists for kernels 4.10 and earlier)

Just Let you know in case of some vulnerabilities as it is not hard to
trigger this specific case.

Attached is a simple Google's packetdrill script to trigger it and a
possible patch to fix it. Thanks

--94eb2c0550aeec439c0550672a1b
Content-Type: text/plain; charset="US-ASCII"; name="path.diff"
Content-Disposition: attachment; filename="path.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_j35g20gf0

ZGlmZiAtLWdpdCBhL25ldC9pcHY0L3RjcF9pbnB1dC5jIGIvbmV0L2lwdjQvdGNwX2lucHV0LmMK
aW5kZXggNzcyN2ZmZS4uZGEyMzIyMSAxMDA2NDQKLS0tIGEvbmV0L2lwdjQvdGNwX2lucHV0LmMK
KysrIGIvbmV0L2lwdjQvdGNwX2lucHV0LmMKQEAgLTI3MzMsNyArMjczMyw3IEBAIHN0YXRpYyB2
b2lkIHRjcF9wcm9jZXNzX2xvc3Moc3RydWN0IHNvY2sgKnNrLCBpbnQgZmxhZywgYm9vbCBpc19k
dXBhY2ssCiAJCSAqIGxvc3QsIGkuZS4sIG5ldmVyLXJldHJhbnNtaXR0ZWQgZGF0YSBhcmUgKHMp
YWNrZWQuCiAJCSAqLwogCQlpZiAoKGZsYWcgJiBGTEFHX09SSUdfU0FDS19BQ0tFRCkgJiYKLQkJ
ICAgIHRjcF90cnlfdW5kb19sb3NzKHNrLCB0cnVlKSkKKwkJICAgIHRjcF90cnlfdW5kb19sb3Nz
KHNrLCB0cC0+dW5kb19tYXJrZXIpKQogCQkJcmV0dXJuOwogCiAJCWlmIChhZnRlcih0cC0+c25k
X254dCwgdHAtPmhpZ2hfc2VxKSkgewo=
--94eb2c0550aeec439c0550672a1b
Content-Type: application/octet-stream; name="reproduce.pkt"
Content-Disposition: attachment; filename="reproduce.pkt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_j35g20go1

LyoqKioqKioqKioqKioqKgpBIHNpbXBlIHNjcmlwdCB0byB0cmlnZ2VyIHRoZSBidWcKdXNhZ2U6
CjEuIERvd25sb2FkIHBhY2tldGRyaWxsIHRvb2wgKGh0dHBzOi8vZ2l0aHViLmNvbS9nb29nbGUv
cGFja2V0ZHJpbGwvdHJlZS9tYXN0ZXIvZ3Rlc3RzL25ldC9wYWNrZXRkcmlsbCkgYW5kIHRoZW4g
cnVuIHRoaXMgc2NyaXB0CjIuIHN1ZG8gLi9wYWNrZXRkcmlsbCByZXByb2R1Y2UucGt0IC0tdG9s
ZXJhbmNlX3VzZWNzPTEwMDAwMAoKb3V0cHV0OgoxMCAyMTQ3NDgzNjQ3IDAKMTAgMjE0NzQ4MzY0
NyAwCjEgNSA0CjExIDIxNDc0ODM2NDcgNAo0Mjk0OTY3Mjk0IDIxNDc0ODM2NDcgMAo0Mjk0OTY3
Mjk0IDIxNDc0ODM2NDcgMAoqKioqKioqKioqKioqKioqKi8KCgorMCBgc3lzY3RsIC1xIG5ldC5p
cHY0LnRjcF9jb25nZXN0aW9uX2NvbnRyb2w9cmVub2AgIC8vIGFsc28gZm9yIHZlbm8vdmVnYXMv
aGlnaHNwZWVkL0hUQ1AveWVhaC93ZXN0d29vZC9oeWJsYS9pbGxpbm9pcy9zY2FsYWJsZSBpbiBs
cCBpbiBrZXJuZWxzIDQuMTAob25seSByZW5vIGFuZCBodGNwKSBhbmQgZWFybGllcihhbGwpCisw
IGBzeXNjdGwgLXEgbmV0LmlwdjQudGNwX2ZydG89MWAgLy8gZGVmYXVsdDogdGNwX2ZydG8gPSAx
IChpLmUuLCB0aGUgYnVnIGV4aXN0cyB3aGVuIGVuYWJsaW5nIGZydG8pCiswIGBldGh0b29sIC1L
IHR1bjAgZ3NvIG9mZiB0c28gb2ZmYCAvLyBjb25maWd1cmVkIGZvciBwYWNrZXRkcmlsbCB1c2UK
Ci8vIEVzdGFibGlzaCBhIGNvbm5lY3Rpb24uCjAuMDAwIHNvY2tldCguLi4sIFNPQ0tfU1RSRUFN
LCBJUFBST1RPX1RDUCkgPSAzCjAuMDAwIHNldHNvY2tvcHQoMywgU09MX1NPQ0tFVCwgU09fUkVV
U0VBRERSLCBbMV0sIDQpID0gMAowLjAwMCBiaW5kKDMsIC4uLiwgLi4uKSA9IDAKMC4wMDAgbGlz
dGVuKDMsIDEpID0gMAoKMC4xMDAgPCBTIDA6MCgwKSB3aW4gNDIzNDAgPG1zcyAxNDYwLG5vcCxu
b3AsVFMgdmFsIDEwMCBlY3IgMCxub3Asd3NjYWxlIDEyPgowLjEwMCA+IFMuIDA6MCgwKSBhY2sg
MSA8bXNzIDE0NjAgLG5vcCxub3AsVFMgdmFsIDEwMCBlY3IgMTAwLCBub3AsIHdzY2FsZSA3Pgow
LjExMCA8IC4gMToxKDApIGFjayAxICB3aW4gMTEwMCA8bm9wLG5vcCxUUyB2YWwgMTEwIGVjciAx
MDA+IAowLjEyMCBhY2NlcHQoMywgLi4uLCAuLi4pID0gNAowLjEzICV7IHByaW50IHRjcGlfc25k
X2N3bmQsdGNwaV9zbmRfc3N0aHJlc2gsIHRjcGlfY2Ffc3RhdGV9JQoKLy8gU2VuZCAxMCBNU1Mu
CjAuMjAwIHdyaXRlKDQsIC4uLiwgMTQ2MDApID0gMTQ2MDAKMC4yMDAgPiAuIDE6MTQ0OSgxNDQ4
KSBhY2sgMSA8bm9wLG5vcCxUUyB2YWwgMTIwIGVjciAxMTA+CjAuMjAwICAleyBwcmludCB0Y3Bp
X3NuZF9jd25kLHRjcGlfc25kX3NzdGhyZXNoLCB0Y3BpX2NhX3N0YXRlfSUKCjAuNjAgICV7IHBy
aW50IHRjcGlfc25kX2N3bmQsdGNwaV9zbmRfc3N0aHJlc2gsIHRjcGlfY2Ffc3RhdGV9JQowLjYw
IDwgLiAxOjEoMCkgYWNrIDE0NDkgd2luIDExIDxub3Asbm9wLFRTIHZhbCA2MDAgZWNyIDEyMD4K
MC42MCAgJXsgcHJpbnQgdGNwaV9zbmRfY3duZCx0Y3BpX3NuZF9zc3RocmVzaCwgdGNwaV9jYV9z
dGF0ZX0lCjAuNzAgPCAuIDE6MSgwKSBhY2sgMjg5NyB3aW4gMTEgPG5vcCxub3AsVFMgdmFsIDcw
MCBlY3IgMTIwPgowLjcwICV7IHByaW50IHRjcGlfc25kX2N3bmQsdGNwaV9zbmRfc3N0aHJlc2gs
IHRjcGlfY2Ffc3RhdGV9JQowLjgwIDwgLiAxOjEoMCkgYWNrIDQzNDYgd2luIDExIDxub3Asbm9w
LFRTIHZhbCA4MDAgZWNyIDEyMD4KMC44MCAleyBwcmludCB0Y3BpX3NuZF9jd25kLHRjcGlfc25k
X3NzdGhyZXNoLCB0Y3BpX2NhX3N0YXRlfSUKCjEuMCBgc3lzY3RsIC1xIG5ldC5pcHY0LnRjcF9j
b25nZXN0aW9uX2NvbnRyb2w9Y3ViaWNgLy8gY2hhbmdlIHRvIGRlZmF1bHQgdmFsdWUgYWdpYW4K
--94eb2c0550aeec439c0550672a1b--
