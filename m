From: Patrick McHardy <kaber@trash.net>
Subject: Re: iproute u32 filter - server hang
Date: Wed, 31 Mar 2010 11:34:41 +0200
Message-ID: <4BB31731.9060104@trash.net>
References: <4BB3116F.803@itcare.pl>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050209010608080709050204"
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58295 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933058Ab0CaJeo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 05:34:44 -0400
In-Reply-To: <4BB3116F.803@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050209010608080709050204
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

Paweł Staszewski wrote:
> I find some problem with iproute2 and u32 filters
> 
> To reproduce the problem (need to make one mistake in filter parent
> declaration 1:101):
> 
> ...
> tc filter add dev eth0 protocol ip parent 1:101 u32 match ip protocol 1
> 0xff flowid 1:101
> 
> ping 212.77.100.101
> And after this server will stop responding to anything - without any
> error (hang).

This is caused by hfsc_classify() looping endlessly since the filter
points to the originating class. hfsc_bind_tcf() is actually supposed
to prevent this, but it only prevents resolving the filter immediately
and we still run into the loop at runtime.

This patch (based on how CBQ handles this) should abort classification
and fall back to the default class. It would be better to simply catch
this at configuration time, but that looks a bit more involved. I'll try
to look into it this weekend.



--------------050209010608080709050204
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="x"

ZGlmZiAtLWdpdCBhL25ldC9zY2hlZC9zY2hfaGZzYy5jIGIvbmV0L3NjaGVkL3NjaF9oZnNj
LmMKaW5kZXggYjM4YjM5Yy4uYTQzNWNmMSAxMDA2NDQKLS0tIGEvbmV0L3NjaGVkL3NjaF9o
ZnNjLmMKKysrIGIvbmV0L3NjaGVkL3NjaF9oZnNjLmMKQEAgLTExNTUsNyArMTE1NSw3IEBA
IHN0YXRpYyBzdHJ1Y3QgaGZzY19jbGFzcyAqCiBoZnNjX2NsYXNzaWZ5KHN0cnVjdCBza19i
dWZmICpza2IsIHN0cnVjdCBRZGlzYyAqc2NoLCBpbnQgKnFlcnIpCiB7CiAJc3RydWN0IGhm
c2Nfc2NoZWQgKnEgPSBxZGlzY19wcml2KHNjaCk7Ci0Jc3RydWN0IGhmc2NfY2xhc3MgKmNs
OworCXN0cnVjdCBoZnNjX2NsYXNzICpoZWFkLCAqY2w7CiAJc3RydWN0IHRjZl9yZXN1bHQg
cmVzOwogCXN0cnVjdCB0Y2ZfcHJvdG8gKnRjZjsKIAlpbnQgcmVzdWx0OwpAQCAtMTE2Niw2
ICsxMTY2LDcgQEAgaGZzY19jbGFzc2lmeShzdHJ1Y3Qgc2tfYnVmZiAqc2tiLCBzdHJ1Y3Qg
UWRpc2MgKnNjaCwgaW50ICpxZXJyKQogCQkJcmV0dXJuIGNsOwogCiAJKnFlcnIgPSBORVRf
WE1JVF9TVUNDRVNTIHwgX19ORVRfWE1JVF9CWVBBU1M7CisJaGVhZCA9ICZxLT5yb290Owog
CXRjZiA9IHEtPnJvb3QuZmlsdGVyX2xpc3Q7CiAJd2hpbGUgKHRjZiAmJiAocmVzdWx0ID0g
dGNfY2xhc3NpZnkoc2tiLCB0Y2YsICZyZXMpKSA+PSAwKSB7CiAjaWZkZWYgQ09ORklHX05F
VF9DTFNfQUNUCkBAIC0xMTgwLDYgKzExODEsOCBAQCBoZnNjX2NsYXNzaWZ5KHN0cnVjdCBz
a19idWZmICpza2IsIHN0cnVjdCBRZGlzYyAqc2NoLCBpbnQgKnFlcnIpCiAJCWlmICgoY2wg
PSAoc3RydWN0IGhmc2NfY2xhc3MgKilyZXMuY2xhc3MpID09IE5VTEwpIHsKIAkJCWlmICgo
Y2wgPSBoZnNjX2ZpbmRfY2xhc3MocmVzLmNsYXNzaWQsIHNjaCkpID09IE5VTEwpCiAJCQkJ
YnJlYWs7IC8qIGZpbHRlciBzZWxlY3RlZCBpbnZhbGlkIGNsYXNzaWQgKi8KKwkJCWlmIChj
bC0+bGV2ZWwgPj0gaGVhZC0+bGV2ZWwpCisJCQkJYnJlYWs7IC8qIGZpbHRlciBtYXkgb25s
eSBwb2ludCBkb3dud2FyZHMgKi8KIAkJfQogCiAJCWlmIChjbC0+bGV2ZWwgPT0gMCkKQEAg
LTExODcsNiArMTE5MCw3IEBAIGhmc2NfY2xhc3NpZnkoc3RydWN0IHNrX2J1ZmYgKnNrYiwg
c3RydWN0IFFkaXNjICpzY2gsIGludCAqcWVycikKIAogCQkvKiBhcHBseSBpbm5lciBmaWx0
ZXIgY2hhaW4gKi8KIAkJdGNmID0gY2wtPmZpbHRlcl9saXN0OworCQloZWFkID0gY2w7CiAJ
fQogCiAJLyogY2xhc3NpZmljYXRpb24gZmFpbGVkLCB0cnkgZGVmYXVsdCBjbGFzcyAqLwo=
--------------050209010608080709050204--
