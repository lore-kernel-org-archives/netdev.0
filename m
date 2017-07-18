From: Wei Sun <unlcsewsun@gmail.com>
Subject: A buggy behavior for Linux TCP Reno and HTCP
Date: Tue, 18 Jul 2017 16:36:08 -0500
Message-ID: <CANdGJ5Qp1MoGfeSyAnEqYeSeEyoiH8e1j_Ut3F4PnLRBnqNNZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="94eb2c19581ab7072d05549e4d5c"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f182.google.com ([209.85.128.182]:35924 "EHLO
        mail-wr0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751470AbdGRVgK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 17:36:10 -0400
Received: by mail-wr0-f182.google.com with SMTP id y43so47463657wrd.3
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 14:36:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--94eb2c19581ab7072d05549e4d5c
Content-Type: text/plain; charset="UTF-8"

Hi there,

We find a buggy behavior when using Linux TCP Reno and HTCP in low
bandwidth or highly congested network environments.

In a simple word, their undo functions may mistakenly double the cwnd,
leading to a more aggressive behavior in a highly congested scenario.


The detailed reason:

The current reno undo function assumes cwnd halving (and thus doubles
the cwnd), but it doesn't consider a corner case condition that
ssthresh is at least 2.

e.g.,
                         cwnd              ssth
An initial state:     2                    5
A spurious loss:   1                    2
Undo:                   4                    5

Here the cwnd after undo is two times as that before undo. Attached is
a simple script to reproduce it.

A similar reason for HTCP, so we recommend to store the cwnd on loss
in .ssthresh implementation and restore it again in .undo_cwnd for TCP
Reno and HTCP implementations.

Thanks

--94eb2c19581ab7072d05549e4d5c
Content-Type: application/octet-stream; name="undo-2-1-4.pkt"
Content-Disposition: attachment; filename="undo-2-1-4.pkt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_j5a2sc7w0

LyoqKioqKioqKioqKioqKgpBIHNpbXBlIHNjcmlwdCB0byB0cmlnZ2VyIHRoZSBidWcKdXNhZ2U6
CjEuIERvd25sb2FkIHBhY2tldGRyaWxsIHRvb2wgKGh0dHBzOi8vZ2l0aHViLmNvbS9nb29nbGUv
cGFja2V0ZHJpbGwvdHJlZS9tYXN0ZXIvZ3Rlc3RzL25ldC9wYWNrZXRkcmlsbCkgYW5kIHRoZW4g
cnVuIHRoaXMgc2NyaXB0CjIuIHN1ZG8gLi9wYWNrZXRkcmlsbCB1bmRvLTItMS00LnBrdCAtLXRv
bGVyYW5jZV91c2Vjcz01MDAwMDAKCm91dHB1dDoKW0JlZm9yZSB1bmRvXSBjd25kOiAyIHNzdGg6
IDUKW0xvc3MgRGV0ZWN0aW5nXSBjd25kOiAxIHNzdGg6IDIKW0FmdGVyIHVuZG9dIGN3bmQ6IDUg
c3N0aDogNQoqKioqKioqKioqKioqKioqKi8KCgorMCBgc3lzY3RsIC1xIG5ldC5pcHY0LnRjcF9j
b25nZXN0aW9uX2NvbnRyb2w9cmVub2AKKzAgYHN5c2N0bCAtcSBuZXQuaXB2NC50Y3Bfc2Fjaz0w
YAoKLy8gRXN0YWJsaXNoIGEgY29ubmVjdGlvbi4KMC4wMDAgc29ja2V0KC4uLiwgU09DS19TVFJF
QU0sIElQUFJPVE9fVENQKSA9IDMKMC4wMDAgc2V0c29ja29wdCgzLCBTT0xfU09DS0VULCBTT19S
RVVTRUFERFIsIFsxXSwgNCkgPSAwCjAuMDAwIGJpbmQoMywgLi4uLCAuLi4pID0gMAowLjAwMCBs
aXN0ZW4oMywgMSkgPSAwCgowLjEwMCA8IFMgMDowKDApIHdpbiA0MjM0MCA8bXNzIDEwMDAsbm9w
LHdzY2FsZSA3PgowLjEwMCA+IFMuIDA6MCgwKSBhY2sgMSA8Li4uPgowLjExMCA8IC4gMToxKDAp
IGFjayAxIHdpbiAyNTcKMC4xMjAgYWNjZXB0KDMsIC4uLiwgLi4uKSA9IDQKCi8vIFNlbmQgMTAg
TVNTLgowLjEzIHdyaXRlKDQsIC4uLiwgMTAwMDApID0gMTAwMDAKCjAuMTMgPiAuIDE6MTAwMSgx
MDAwKSBhY2sgMQowLjEzID4gLiAxMDAxOjIwMDEoMTAwMCkgYWNrIDEKMC4xMyA+IC4gMjAwMToz
MDAxKDEwMDApIGFjayAxCjAuMTMgPiAuIDMwMDE6NDAwMSgxMDAwKSBhY2sgMQowLjEzID4gLiA0
MDAxOjUwMDEoMTAwMCkgYWNrIDEKMC4xMyA+IC4gNTAwMTo2MDAxKDEwMDApIGFjayAxCjAuMTMg
PiAuIDYwMDE6NzAwMSgxMDAwKSBhY2sgMQowLjEzID4gLiA3MDAxOjgwMDEoMTAwMCkgYWNrIDEK
MC4xMyA+IC4gODAwMTo5MDAxKDEwMDApIGFjayAxCjAuMTMgPiBQLiA5MDAxOjEwMDAxKDEwMDAp
IGFjayAxCgowLjQgPiAuIDE6MTAwMSgxMDAwKSBhY2sgMQowLjcgPiAuIDE6MTAwMSgxMDAwKSBh
Y2sgMQoKMC45IDwgLiAxOjEoMCkgYWNrIDEwMDEgd2luIDI1NwowLjkgJXtwcmludCAiW0JlZm9y
ZSB1bmRvXSBjd25kOiIsIHRjcGlfc25kX2N3bmQsICJzc3RoOiIsIHRjcGlfc25kX3NzdGhyZXNo
fSUKMS4wID4gLiAxMDAxOjIwMDEoMTAwMCkgYWNrIDEKMS4wID4gLiAyMDAxOjMwMDEoMTAwMCkg
YWNrIDEKCi8vIEdldCAzIGR1cGFja3MuCjEuMzAwIDwgLiAxOjEoMCkgYWNrIDEgd2luIDI1NyA8
c2FjayAyMDAxOjMwMDEsbm9wLG5vcD4KMS4zMDAgPCAuIDE6MSgwKSBhY2sgMSB3aW4gMjU3IDxz
YWNrIDIwMDE6NDAwMSxub3Asbm9wPgoxLjMwMCA8IC4gMToxKDApIGFjayAxIHdpbiAyNTcgPHNh
Y2sgMjAwMTo1MDAxLG5vcCxub3A+CgovLyBXZSd2ZSByZWNlaXZlZCAzIGR1cGxpY2F0ZSBBQ0tz
LCBzbyB3ZSBkbyBhIGZhc3QgcmV0cmFuc21pdC4KMS40MDAgPiAuIDEwMDE6MjAwMSgxMDAwKSBh
Y2sgMQoKMS40ICV7cHJpbnQgIltMb3NzIERldGVjdGluZ10gY3duZDoiLCB0Y3BpX3NuZF9jd25k
LCAic3N0aDoiLCB0Y3BpX3NuZF9zc3RocmVzaH0lCi8vIEFwcGFyZW50bHkganVzdCByZW9yZGVy
aW5nLiBSZXRyYW5zbWl0IHdhcyBzcHVyaW91cy4KLy8gT3JpZ2luYWwgQUNLcyBmb3Igc2VxdWVu
Y2UgcmFuZ2VzIHVwIHRvIDEwMDAxIGFyZSBhbGwgbG9zdC4KLy8gUmVjZWl2ZXIgc2VuZHMgRFNB
Q0sgZm9yIHJldHJhbnNtaXR0ZWQgcGFja2V0LgoxLjQgPCAuIDE6MSgwKSBhY2sgNTAwMSB3aW4g
MjU3IDxzYWNrIDEwMDE6MjAwMSxub3Asbm9wPgoxLjQwMSAle3ByaW50ICJbQWZ0ZXIgdW5kb10g
Y3duZDoiLCB0Y3BpX3NuZF9jd25kLCAic3N0aDoiLCB0Y3BpX3NuZF9zc3RocmVzaH0lCgorMCBg
c3lzY3RsIC1xIG5ldC5pcHY0LnRjcF9jb25nZXN0aW9uX2NvbnRyb2w9Y3ViaWNgCgo=
--94eb2c19581ab7072d05549e4d5c--
