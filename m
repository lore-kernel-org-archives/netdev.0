From: Neal Cardwell <ncardwell@google.com>
Subject: Re: TCP fast retransmit issues
Date: Wed, 26 Jul 2017 14:38:18 -0400
Message-ID: <CADVnQynR8dUuUBDfeFR2xpL-wKzd+7TgbMv-CXe3TT-T0_PXyQ@mail.gmail.com>
References: <200d9a12e9f2f5791d4c5ce2d47a1239@vsen.dk> <1501069756.12695.11.camel@edumazet-glaptop3.roam.corp.google.com>
 <a025f5b2ed6e1f287f68b6bb5137a988@vsen.dk> <1501075881.12695.15.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170726134242.GB1737@1wt.eu> <1501079532.12695.17.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170726145059.GE1737@1wt.eu> <CADVnQymKZAc+SFD7X-FoP9UwHgB2MBCY48=dL8mH6XuKumkx4g@mail.gmail.com>
 <CADVnQykEX-LzhsqyfHNmV6fF9-d_2R0v+mOX-PnyagUhC1qQzQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="001a11c160b63e96a505553cc24b"
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Klavs Klavsen <kl@vsen.dk>,
        Netdev <netdev@vger.kernel.org>,
        Yuchung Cheng <ycheng@google.com>,
        Nandita Dukkipati <nanditad@google.com>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:33330 "EHLO
        mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750925AbdGZSit (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 14:38:49 -0400
Received: by mail-oi0-f47.google.com with SMTP id a9so87575434oih.0
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2017 11:38:49 -0700 (PDT)
In-Reply-To: <CADVnQykEX-LzhsqyfHNmV6fF9-d_2R0v+mOX-PnyagUhC1qQzQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001a11c160b63e96a505553cc24b
Content-Type: text/plain; charset="UTF-8"

On Wed, Jul 26, 2017 at 1:06 PM, Neal Cardwell <ncardwell@google.com> wrote:
> On Wed, Jul 26, 2017 at 12:43 PM, Neal Cardwell <ncardwell@google.com> wrote:
>> (2) It looks like there is a bug in the sender code where it seems to
>> be repeatedly using a TLP timer firing 211ms after every ACK is
>> received to transmit another TLP probe (a new packet in this case).
>> Somehow these weird invalid SACKs seem to be triggering a code path
>> that makes us think we can send another TLP, when we probably should
>> be firing an RTO. That's my interpretation, anyway. I will try to
>> reproduce this with packetdrill.
>
> Hmm. It looks like this might be a general issue, where any time we
> get an ACK that doesn't ACK/SACK anything new (whether because it's
> incoming data in a bi-directional flow, or a middlebox breaking the
> SACKs), then we schedule a TLP timer further out in time. Probably we
> should only push the TLP timer out if something is cumulatively ACKed.
>
> But that's not a trivial thing to do, because by the time we are
> deciding whether to schedule another TLP, we have already canceled the
> previous TLP and reinstalled an RTO. Hmm.

Yeah, it looks like I can reproduce this issue with (1) bad sacks
causing repeated TLPs, and (2) TLPs timers being pushed out to later
times due to incoming data. Scripts are attached.

neal

--001a11c160b63e96a505553cc24b
Content-Type: application/octet-stream; name="tlp-bad-sacks.pkt"
Content-Disposition: attachment; filename="tlp-bad-sacks.pkt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_j5lcs5xx0

Ly8gVGVzdCBmb3IgVExQIGJlaGF2aW9yIHdoZW4gYWxsIFNBQ0tzIHRoYXQgY29tZSBiYWNrIGFy
ZSBpbnZhbGlkCi8vIChlLmcuIGJlY2F1c2Ugb2YgYSBtaWRkbGVib3gpLgovLyAoT29wcy4uLiBp
dCBzZWVtcyBpbnZhbGlkIFNBQ0tzIGNhbiBjYXVzZSB1cyB0byBzZW5kIFRMUHMgZm9yZXZlci4p
CgovLyBTZXQgdXAgcHJvZHVjdGlvbiBjb25maWcuCmAuLi9jb21tb24vZGVmYXVsdHMuc2hgCgov
LyBFc3RhYmxpc2ggYSBjb25uZWN0aW9uLgowICAgICBzb2NrZXQoLi4uLCBTT0NLX1NUUkVBTSwg
SVBQUk9UT19UQ1ApID0gMworMCAgICBzZXRzb2Nrb3B0KDMsIFNPTF9TT0NLRVQsIFNPX1JFVVNF
QUREUiwgWzFdLCA0KSA9IDAKKzAgICAgYmluZCgzLCAuLi4sIC4uLikgPSAwCiswICAgIGxpc3Rl
bigzLCAxKSA9IDAKCiswICAgIDwgUyAwOjAoMCkgd2luIDMyNzkyIDxtc3MgMTAwMCxzYWNrT0ss
bm9wLG5vcCxub3Asd3NjYWxlIDc+CiswICAgID4gUy4gMDowKDApIGFjayAxIDxtc3MgMTQ2MCxu
b3Asbm9wLHNhY2tPSyxub3Asd3NjYWxlIDg+CisuMDIwIDwgLiAxOjEoMCkgYWNrIDEgd2luIDI1
NworMCAgICBhY2NlcHQoMywgLi4uLCAuLi4pID0gNAoKLy8gU2VuZCAxMCBNU1MuCiswICAgIHdy
aXRlKDQsIC4uLiwgMjAwMDApID0gMjAwMDAKKzAgICAgPiAuIDE6MTAwMDEoMTAwMDApIGFjayAx
CgovLyBGaXJzdCByb3VuZDoKCi8vIEFuIEFDSyBhcnJpdmVzIHdpdGggYSBib2d1cyBTQUNLLgor
LjAyMCA8IC4gMToxKDApIGFjayAxIHdpbiAyNTcgPHNhY2sgMTAwMDAwMDAwMToxMDAwMDAxMDAx
LG5vcCxub3A+CgovLyBBdCAyKlJUVCwgc2VuZCBhIFRMUCBsb3NzIHByb2JlIHRoYXQgaXMgYSBu
ZXcgcGFja2V0LgorLjA0MCA+IC4gMTAwMDE6MTEwMDEoMTAwMCkgYWNrIDEKICAgKzAgJXsKYXNz
ZXJ0IHRjcGlfc25kX2N3bmQgPT0gMTAsIHRjcGlfc25kX2N3bmQKYXNzZXJ0IHRjcGlfdW5hY2tl
ZCA9PSAxMSwgdGNwaV91bmFja2VkCn0lCgovLyBTZWNvbmQgcm91bmQgKHNhbWUgYXMgdGhlIGZp
cnN0KToKCi8vIEFuIEFDSyBhcnJpdmVzIHdpdGggYW5vdGhlciBib2d1cyBTQUNLLgorLjAyMCA8
IC4gMToxKDApIGFjayAxIHdpbiAyNTcgPHNhY2sgMTAwMDAwMDAwMToxMDAwMDAyMDAxLG5vcCxu
b3A+CgovLyBBdCAyKlJUVCwgc2VuZCBhIFRMUCBsb3NzIHByb2JlIHRoYXQgaXMgYSBuZXcgcGFj
a2V0LgorLjA0MCA+IC4gMTEwMDE6MTIwMDEoMTAwMCkgYWNrIDEKICAgKzAgJXsKYXNzZXJ0IHRj
cGlfc25kX2N3bmQgPT0gMTAsIHRjcGlfc25kX2N3bmQKYXNzZXJ0IHRjcGlfdW5hY2tlZCA9PSAx
MiwgdGNwaV91bmFja2VkCn0lCgovLyBUaGlyZCByb3VuZCAoc2FtZSBhcyB0aGUgZmlyc3QpOgoK
Ly8gQW4gQUNLIGFycml2ZXMgd2l0aCBhbm90aGVyIGJvZ3VzIFNBQ0suCisuMDIwIDwgLiAxOjEo
MCkgYWNrIDEgd2luIDI1NyA8c2FjayAxMDAwMDAwMDAxOjEwMDAwMDMwMDEsbm9wLG5vcD4KCi8v
IEF0IDIqUlRULCBzZW5kIGEgVExQIGxvc3MgcHJvYmUgdGhhdCBpcyBhIG5ldyBwYWNrZXQuCisu
MDQwID4gLiAxMjAwMToxMzAwMSgxMDAwKSBhY2sgMQogICArMCAlewphc3NlcnQgdGNwaV9zbmRf
Y3duZCA9PSAxMCwgdGNwaV9zbmRfY3duZAphc3NlcnQgdGNwaV91bmFja2VkID09IDEzLCB0Y3Bp
X3VuYWNrZWQKfSUK
--001a11c160b63e96a505553cc24b
Content-Type: application/octet-stream; name="tlp-bidirectional.pkt"
Content-Disposition: attachment; filename="tlp-bidirectional.pkt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_j5lcs9w91

Ly8gVGVzdCBmb3IgVExQIGJlaGF2aW9yIHdpdGggYmktZGlyZWN0aW9uYWwgdHJhZmZpYyAoaW5j
b21pbmcgZGF0YSkuCi8vIE1ha2Ugc3VyZSB0aGF0IGluY29taW5nIGRhdGEgZG9lcyBub3QgcHVz
aCBiYWNrIHRoZSBUTFAgdGltZXIuCi8vIChPb3BzLi4uIGN1cnJlbnRseSBpdCBkb2VzIHNlZW0g
dGhhdCBpbmNvbWluZyBkYXRhIHB1c2hlcyBiYWNrCi8vIHRoZSBUTFAgdGltZXIuKQoKLy8gU2V0
IHVwIHByb2R1Y3Rpb24gY29uZmlnLgpgLi4vY29tbW9uL2RlZmF1bHRzLnNoYAoKLy8gRXN0YWJs
aXNoIGEgY29ubmVjdGlvbi4KMCAgICAgc29ja2V0KC4uLiwgU09DS19TVFJFQU0sIElQUFJPVE9f
VENQKSA9IDMKKzAgICAgc2V0c29ja29wdCgzLCBTT0xfU09DS0VULCBTT19SRVVTRUFERFIsIFsx
XSwgNCkgPSAwCiswICAgIGJpbmQoMywgLi4uLCAuLi4pID0gMAorMCAgICBsaXN0ZW4oMywgMSkg
PSAwCgorMCAgICA8IFMgMDowKDApIHdpbiAzMjc5MiA8bXNzIDEwMDAsc2Fja09LLG5vcCxub3As
bm9wLHdzY2FsZSA3PgorMCAgICA+IFMuIDA6MCgwKSBhY2sgMSA8bXNzIDE0NjAsbm9wLG5vcCxz
YWNrT0ssbm9wLHdzY2FsZSA4PgorLjAyMCA8IC4gMToxKDApIGFjayAxIHdpbiAyNTcKKzAgICAg
YWNjZXB0KDMsIC4uLiwgLi4uKSA9IDQKCi8vIFNlbmQgMTAgTVNTLgorMCAgICB3cml0ZSg0LCAu
Li4sIDIwMDAwKSA9IDIwMDAwCiswICAgID4gLiAxOjEwMDAxKDEwMDAwKSBhY2sgMQoKLy8gSW5j
b21pbmcgZGF0YSBhcnJpdmVzCisuMDEwIDwgLiAxOjEwMDEoMTAwMCkgYWNrIDEgd2luIDI1Nwor
MCAgICA+IC4gMTAwMDE6MTAwMDEoMCkgYWNrIDEwMDEKCisuMDEwIDwgLiAxMDAxOjIwMDEoMTAw
MCkgYWNrIDEgd2luIDI1NworMCAgICA+IC4gMTAwMDE6MTAwMDEoMCkgYWNrIDIwMDEKCisuMDEw
IDwgLiAyMDAxOjMwMDEoMTAwMCkgYWNrIDEgd2luIDI1NworMCAgICA+IC4gMTAwMDE6MTAwMDEo
MCkgYWNrIDMwMDEKCisuMDEwIDwgLiAzMDAxOjQwMDEoMTAwMCkgYWNrIDEgd2luIDI1NworMCAg
ICA+IC4gMTAwMDE6MTAwMDEoMCkgYWNrIDQwMDEKCi8vIEF0IDIqUlRUIGFmdGVyIHRoZSBsYXN0
IHRyYW5zbWl0LCBzZW5kIGEgVExQIGxvc3MgcHJvYmUKLy8gdGhhdCBpcyBhIG5ldyBwYWNrZXQu
CisuMDMyID4gLiAxMDAwMToxMTAwMSgxMDAwKSBhY2sgNDAwMQogICArMCAlewphc3NlcnQgdGNw
aV9zbmRfY3duZCA9PSAxMCwgdGNwaV9zbmRfY3duZAphc3NlcnQgdGNwaV91bmFja2VkID09IDEx
LCB0Y3BpX3VuYWNrZWQKfSUK
--001a11c160b63e96a505553cc24b--
