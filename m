From: "John Heffner" <johnwheffner@gmail.com>
Subject: Re: Socket buffer sizes with autotuning
Date: Mon, 28 Apr 2008 12:21:53 -0700
Message-ID: <1e41a3230804281221s11442a82j55c363116988a5cb@mail.gmail.com>
References: <d1c2719f0804231629p4536e98do668b812e34d2b92c@mail.gmail.com>
	 <1e41a3230804240932u510609beh8fb577baaadeb9bd@mail.gmail.com>
	 <d1c2719f0804241749p2c0dd7daofd343bc37a916247@mail.gmail.com>
	 <20080424.234628.170849475.davem@davemloft.net>
	 <d1c2719f0804281130n7b0aaab8t54b2a585cff53a99@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_12476_31689569.1209410513984"
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	rick.jones2@hp.com
To: "Jerry Chu" <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.177]:24503 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934545AbYD1TWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 15:22:17 -0400
Received: by el-out-1112.google.com with SMTP id n30so1650386elf.21
        for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 12:22:16 -0700 (PDT)
In-Reply-To: <d1c2719f0804281130n7b0aaab8t54b2a585cff53a99@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_12476_31689569.1209410513984
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Mon, Apr 28, 2008 at 11:30 AM, Jerry Chu <hkchu@google.com> wrote:
>  Correct, but its counterpart doesn't exist in tcp_is_cwnd_limited(). So
>  cwnd will continue to grow when left < cwnd/sysctl_tcp_tso_win_divisor,
>  which can be very large when cwnd is large.
>
>  If I change tcp_tso_win_divisor to 0, cwnd max out at 695 rather than 1037,
>  exactly off by 1/3. I tried to add the same check to tcp_is_cwnd_limited():
>
>  diff -c /tmp/tcp.h.old tcp.h
>  *** /tmp/tcp.h.old      Mon Apr 28 11:00:44 2008
>  --- tcp.h       Mon Apr 28 10:54:10 2008
>  ***************
>  *** 828,833 ****
>  --- 828,835 ----
>                 return 0;
>
>         left = tp->snd_cwnd - in_flight;
>  +       if (left >= 65536)
>  +               return 0;
>         if (sysctl_tcp_tso_win_divisor)
>                 return left * sysctl_tcp_tso_win_divisor < tp->snd_cwnd;
>         else
>
>  >
>
>  But it doesn't seem to help (cwnd still grows to 1037).

Cwnd is in packets, not bytes.

Try this series of patches, against net-next.

  -John

------=_Part_12476_31689569.1209410513984
Content-Type: text/x-diff;
 name=0001-NET-Allow-send-limited-cwnd-to-grow-up-to-max_bur.patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fflfryuu0
Content-Disposition: attachment;
 filename=0001-NET-Allow-send-limited-cwnd-to-grow-up-to-max_bur.patch

RnJvbSA1NzAzOWNmYzQ4NmFlNGRlYWMzYjFmZWNhYTIzOGI1NDgzYzAzNGRmIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBKb2huIEhlZmZuZXIgPGpvaG53aGVmZm5lckBnbWFpbC5jb20+
CkRhdGU6IE1vbiwgMjggQXByIDIwMDggMTI6MTc6NDkgLTA3MDAKU3ViamVjdDogW1BBVENIIDEv
Ml0gW05FVF06IEFsbG93IHNlbmQtbGltaXRlZCBjd25kIHRvIGdyb3cgdXAgdG8gbWF4X2J1cnN0
IHdoZW4gZ3NvIGRpc2FibGVkCgpUaGlzIGNoYW5nZXMgdGhlIGxvZ2ljIGluIHRjcF9pc19jd25k
X2xpbWl0ZWQoKSBzbyB0aGF0IGN3bmQgbWF5IGdyb3cKdXAgdG8gdGNwX21heF9idXJzdCgpIGV2
ZW4gd2hlbiBza19jYW5fZ3NvKCkgaXMgZmFsc2UsIG9yIHdoZW4Kc3lzY3RsX3RjcF90c29fd2lu
X2Rpdmlzb3IgIT0gMC4KClNpZ25lZC1vZmYtYnk6IEpvaG4gSGVmZm5lciA8am9obndoZWZmbmVy
QGdtYWlsLmNvbT4KLS0tCiBuZXQvaXB2NC90Y3BfY29uZy5jIHwgICAxMSArKysrLS0tLS0tLQog
MSBmaWxlcyBjaGFuZ2VkLCA0IGluc2VydGlvbnMoKyksIDcgZGVsZXRpb25zKC0pCgpkaWZmIC0t
Z2l0IGEvbmV0L2lwdjQvdGNwX2NvbmcuYyBiL25ldC9pcHY0L3RjcF9jb25nLmMKaW5kZXggM2E2
YmUyMy4uYmZiMTk5NiAxMDA2NDQKLS0tIGEvbmV0L2lwdjQvdGNwX2NvbmcuYworKysgYi9uZXQv
aXB2NC90Y3BfY29uZy5jCkBAIC0yODUsMTQgKzI4NSwxMSBAQCBpbnQgdGNwX2lzX2N3bmRfbGlt
aXRlZChjb25zdCBzdHJ1Y3Qgc29jayAqc2ssIHUzMiBpbl9mbGlnaHQpCiAJaWYgKGluX2ZsaWdo
dCA+PSB0cC0+c25kX2N3bmQpCiAJCXJldHVybiAxOwogCi0JaWYgKCFza19jYW5fZ3NvKHNrKSkK
LQkJcmV0dXJuIDA7Ci0KIAlsZWZ0ID0gdHAtPnNuZF9jd25kIC0gaW5fZmxpZ2h0OwotCWlmIChz
eXNjdGxfdGNwX3Rzb193aW5fZGl2aXNvcikKLQkJcmV0dXJuIGxlZnQgKiBzeXNjdGxfdGNwX3Rz
b193aW5fZGl2aXNvciA8IHRwLT5zbmRfY3duZDsKLQllbHNlCi0JCXJldHVybiBsZWZ0IDw9IHRj
cF9tYXhfYnVyc3QodHApOworCWlmIChza19jYW5fZ3NvKHNrKSAmJgorCSAgICBsZWZ0ICogc3lz
Y3RsX3RjcF90c29fd2luX2Rpdmlzb3IgPCB0cC0+c25kX2N3bmQpCisJCXJldHVybiAxOworCXJl
dHVybiBsZWZ0IDw9IHRjcF9tYXhfYnVyc3QodHApOwogfQogRVhQT1JUX1NZTUJPTF9HUEwodGNw
X2lzX2N3bmRfbGltaXRlZCk7CiAKLS0gCjEuNS4yLjUKCg==
------=_Part_12476_31689569.1209410513984
Content-Type: text/x-diff;
 name=0002-NET-Limit-cwnd-growth-when-deferring-for-GSO.patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fflfs9u51
Content-Disposition: attachment;
 filename=0002-NET-Limit-cwnd-growth-when-deferring-for-GSO.patch

RnJvbSBmYzFkOWZlOTk3NDhmMzgxMWEwYTViOWQ5MzQ2M2NmMGU0Nzg4ZjU2IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBKb2huIEhlZmZuZXIgPGpvaG53aGVmZm5lckBnbWFpbC5jb20+
CkRhdGU6IE1vbiwgMjggQXByIDIwMDggMTI6MTk6MjIgLTA3MDAKU3ViamVjdDogW1BBVENIIDIv
Ml0gW05FVF06IExpbWl0IGN3bmQgZ3Jvd3RoIHdoZW4gZGVmZXJyaW5nIGZvciBHU08KClRoaXMg
Zml4ZXMgaW5hcHByb3ByaWF0ZWx5IGxhcmdlIGN3bmQgZ3Jvd3RoIG9uIHNlbmRlci1saW1pdGVk
IGZsb3dzCndoZW4gR1NPIGlzIGVuYWJsZWQsIGxpbWl0aW5nIGN3bmQgZ3Jvd3RoIHRvIDY0ay4K
ClNpZ25lZC1vZmYtYnk6IEpvaG4gSGVmZm5lciA8am9obndoZWZmbmVyQGdtYWlsLmNvbT4KLS0t
CiBuZXQvaXB2NC90Y3BfY29uZy5jIHwgICAgMyArKy0KIDEgZmlsZXMgY2hhbmdlZCwgMiBpbnNl
cnRpb25zKCspLCAxIGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL25ldC9pcHY0L3RjcF9jb25n
LmMgYi9uZXQvaXB2NC90Y3BfY29uZy5jCmluZGV4IGJmYjE5OTYuLjZhMjUwODIgMTAwNjQ0Ci0t
LSBhL25ldC9pcHY0L3RjcF9jb25nLmMKKysrIGIvbmV0L2lwdjQvdGNwX2NvbmcuYwpAQCAtMjg3
LDcgKzI4Nyw4IEBAIGludCB0Y3BfaXNfY3duZF9saW1pdGVkKGNvbnN0IHN0cnVjdCBzb2NrICpz
aywgdTMyIGluX2ZsaWdodCkKIAogCWxlZnQgPSB0cC0+c25kX2N3bmQgLSBpbl9mbGlnaHQ7CiAJ
aWYgKHNrX2Nhbl9nc28oc2spICYmCi0JICAgIGxlZnQgKiBzeXNjdGxfdGNwX3Rzb193aW5fZGl2
aXNvciA8IHRwLT5zbmRfY3duZCkKKwkgICAgbGVmdCAqIHN5c2N0bF90Y3BfdHNvX3dpbl9kaXZp
c29yIDwgdHAtPnNuZF9jd25kICYmCisJICAgIGxlZnQgKiB0cC0+bXNzX2NhY2hlIDwgc2stPnNr
X2dzb19tYXhfc2l6ZSkKIAkJcmV0dXJuIDE7CiAJcmV0dXJuIGxlZnQgPD0gdGNwX21heF9idXJz
dCh0cCk7CiB9Ci0tIAoxLjUuMi41Cgo=
------=_Part_12476_31689569.1209410513984--
