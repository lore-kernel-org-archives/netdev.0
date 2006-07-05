From: "Angelo P. Castellani" <angelo.castellani@gmail.com>
Subject: [TCP] window update during recovery (continuing on window reduction)
Date: Wed, 5 Jul 2006 16:28:45 +0200
Message-ID: <8dd26e70607050728u240d40c7s3b27360dbe82067f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_173543_30408169.1152109725340"
Cc: "Francesco Vacirca" <francesco@net.infocom.uniroma1.it>,
	"Andrea Baiocchi" <andrea.baiocchi@uniroma1.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:32791 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S964882AbWGEO2q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jul 2006 10:28:46 -0400
Received: by nf-out-0910.google.com with SMTP id k26so954599nfc
        for <netdev@vger.kernel.org>; Wed, 05 Jul 2006 07:28:45 -0700 (PDT)
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_173543_30408169.1152109725340
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

During a recovery, we should always reduce send window if the host is
notifying a window reduction.

This is needed because in the recovery phase the host requires to
buffer the packets between the beginning of the recovery and the data
we're sending "forward" with ssthresh window and sacked_out count.

So it isn't buffering the in_flight packets, but a number of packets
that could be much higher.

If the host asks a window reduction its buffer is filling up, and if
we ignore the reduction, when the buffer is full all the packets
arriving to the host will be dropped.

When the first packet is dropped the host will begin asking for a zero
window; this request will be eventually granted, however in the
meantime we will have lost a full window of packets.

Anyway we could neither set the FLAG_WIN_UPDATE, otherwise the ack
will not be considered a DUPACK and when using Reno the sacked_out
count will not be updated.

Regards,
Angelo P. Castellani

------=_Part_173543_30408169.1152109725340
Content-Type: text/x-patch; name=silent_window_update.diff;
	charset=ISO-8859-1
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ep9scos8
Content-Disposition: attachment; filename="silent_window_update.diff"

ZGlmZiAtdXJkIGxpbnV4LTIuNi4xNi1vcmlnL25ldC9pcHY0L3RjcF9pbnB1dC5jIGxpbnV4LTIu
Ni4xNi13aW51cGRhdGUvbmV0L2lwdjQvdGNwX2lucHV0LmMKLS0tIGxpbnV4LTIuNi4xNi1vcmln
L25ldC9pcHY0L3RjcF9pbnB1dC5jCTIwMDYtMDUtMTYgMTQ6NTM6MDIuMDAwMDAwMDAwICswMjAw
CisrKyBsaW51eC0yLjYuMTYtd2ludXBkYXRlL25ldC9pcHY0L3RjcF9pbnB1dC5jCTIwMDYtMDct
MDUgMTU6Mzg6MDguMDAwMDAwMDAwICswMjAwCkBAIC0yMzY1LDEyICsyMzY1LDQ0IEBACiB7CiAJ
aW50IGZsYWcgPSAwOwogCXUzMiBud2luID0gbnRvaHMoc2tiLT5oLnRoLT53aW5kb3cpOworCXN0
cnVjdCBpbmV0X2Nvbm5lY3Rpb25fc29jayAqaWNzayA9IGluZXRfY3NrKHNrKTsKKwlpbnQgc2ls
ZW50X3VwZGF0ZSA9IDA7CiAKIAlpZiAobGlrZWx5KCFza2ItPmgudGgtPnN5bikpCiAJCW53aW4g
PDw9IHRwLT5yeF9vcHQuc25kX3dzY2FsZTsKIAotCWlmICh0Y3BfbWF5X3VwZGF0ZV93aW5kb3co
dHAsIGFjaywgYWNrX3NlcSwgbndpbikpIHsKLQkJZmxhZyB8PSBGTEFHX1dJTl9VUERBVEU7CisJ
LyoKKwkgKiBEdXJpbmcgYSByZWNvdmVyeSwgd2Ugc2hvdWxkIGFsd2F5cyByZWR1Y2Ugc2VuZCB3
aW5kb3cgaWYgdGhlIGhvc3QKKwkgKiBpcyBub3RpZnlpbmcgYSB3aW5kb3cgcmVkdWN0aW9uLgor
CSAqCisJICogVGhpcyBpcyBuZWVkZWQgYmVjYXVzZSBpbiB0aGUgcmVjb3ZlcnkgcGhhc2UgdGhl
IGhvc3QgcmVxdWlyZXMKKwkgKiB0byBidWZmZXIgdGhlIHBhY2tldHMgYmV0d2VlbiB0aGUgYmVn
aW5uaW5nIG9mIHRoZSByZWNvdmVyeQorCSAqIGFuZCB0aGUgZGF0YSB3ZSdyZSBzZW5kaW5nICJm
b3J3YXJkIiB3aXRoIHNzdGhyZXNoIHdpbmRvdyBhbmQKKwkgKiBzYWNrZWRfb3V0IGNvdW50Lgor
CSAqCisJICogU28gaXQgaXNuJ3QgYnVmZmVyaW5nIHRoZSBpbl9mbGlnaHQgcGFja2V0cywgYnV0
IGEgbnVtYmVyIG9mIHBhY2tldHMKKwkgKiB0aGF0IGNvdWxkIGJlIG11Y2ggaGlnaGVyLgorCSAq
CisJICogSWYgdGhlIGhvc3QgYXNrcyBhIHdpbmRvdyByZWR1Y3Rpb24gaXRzIGJ1ZmZlciBpcyBm
aWxsaW5nIHVwLCBhbmQgaWYgd2UKKwkgKiBpZ25vcmUgdGhlIHJlZHVjdGlvbiwgd2hlbiB0aGUg
YnVmZmVyIGlzIGZ1bGwgYWxsIHRoZSBwYWNrZXRzIGFycml2aW5nCisJICogdG8gdGhlIGhvc3Qg
d2lsbCBiZSBkcm9wcGVkLgorCSAqCisJICogV2hlbiB0aGUgZmlyc3QgcGFja2V0IGlzIGRyb3Bw
ZWQgdGhlIGhvc3Qgd2lsbCBiZWdpbiBhc2tpbmcgZm9yIGEgemVybworCSAqIHdpbmRvdzsgdGhp
cyByZXF1ZXN0IHdpbGwgYmUgZXZlbnR1YWxseSBncmFudGVkLCBob3dldmVyIGluIHRoZQorCSAq
IG1lYW50aW1lIHdlIHdpbGwgaGF2ZSBsb3N0IGEgZnVsbCB3aW5kb3cgb2YgcGFja2V0cy4KKwkg
KgorCSAqIEFueXdheSB3ZSBjb3VsZCBuZWl0aGVyIHNldCB0aGUgRkxBR19XSU5fVVBEQVRFLCBv
dGhlcndpc2UgdGhlCisJICogYWNrIHdpbGwgbm90IGJlIGNvbnNpZGVyZWQgYSBEVVBBQ0sgYW5k
IHdoZW4gdXNpbmcgUmVubyB0aGUgCisJICogc2Fja2VkX291dCBjb3VudCB3aWxsIG5vdCBiZSB1
cGRhdGVkLgorCSAqCisJICovCisJaWYgKGljc2stPmljc2tfY2Ffc3RhdGUgPT0gVENQX0NBX1Jl
Y292ZXJ5ICYmCisJCSAgICBud2luIDwgdHAtPnNuZF93bmQpCisJCXNpbGVudF91cGRhdGUgPSAx
OworCisJaWYgKHNpbGVudF91cGRhdGUgfHwgdGNwX21heV91cGRhdGVfd2luZG93KHRwLCBhY2ss
IGFja19zZXEsIG53aW4pKSB7CisJCWlmICghc2lsZW50X3VwZGF0ZSkKKwkJCWZsYWcgfD0gRkxB
R19XSU5fVVBEQVRFOwogCQl0Y3BfdXBkYXRlX3dsKHRwLCBhY2ssIGFja19zZXEpOwogCiAJCWlm
ICh0cC0+c25kX3duZCAhPSBud2luKSB7Cg==
------=_Part_173543_30408169.1152109725340--
