From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [Security] TIPC security issues
Date: Thu, 28 Oct 2010 08:32:37 -0700
Message-ID: <AANLkTikdh-kqroCDA5EsjSMTLjViqe_U=hxM1L6U4Ppb@mail.gmail.com>
References: <20101027.105047.183059900.davem@davemloft.net>
 <1288203979.1836.2.camel@dan> <AANLkTikKZdq9u0+Nkd4wtEcAZMT3YCPaXMv6FZaafetc@mail.gmail.com>
 <20101027.122757.98903207.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=00151750d9fc6c312e0493af0e75
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	drosenberg@vsecurity.com, security@kernel.org,
	allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>,
	Andy Grover <andy.grover@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:34261 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759241Ab0J1Pdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 11:33:46 -0400
Received: from mail-gy0-f174.google.com (mail-gy0-f174.google.com [209.85.160.174])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id o9SFX2DM003480
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 08:33:13 -0700
Received: by gyg4 with SMTP id 4so1291203gyg.19
        for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 08:32:57 -0700 (PDT)
In-Reply-To: <20101027.122757.98903207.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--00151750d9fc6c312e0493af0e75
Content-Type: text/plain; charset=ISO-8859-1

Heh. We apparently have _another_ iovec overflow in networking. This time rds.

Reported by Thomas Pollet <thomas.pollet@gmail.com>: look at
net/rds/rdma.c around line 490. It doesn't use the regular iovec code,
instead it cooks its own, and has a few problems with overflow.

It gathers the number of pages into an "unsigned int", and for each
entry in its own rds_iovec it will check that the size is < UINT_MAX,
and then generate the number of pages for that entry. With the whole
"unaligned address adds one" logic, it means that each entry can get
(UINT_MAX >> PAGE_SHIFT)+1 pages.

And how many entries can we have? Apparently that is capped to
UINT_MAX too. So add all those up, and they can easily overflow the
unsigned int page counter.

So this time fixing verify_iovec() doesn't help, because rds just
cooks its own, and this is using a totally different interface: it
seems to hook into sendmsg, but it looks like it uses the ancillary
data objects and passes in its own magical iovec rather than use any
"normal" iovec thing. I don't know the code, I may be totally off.

Attached is a half-arsed patch. I say "half-arsed" because I think it
fixes one thing, but I haven't looked at any other use. And quite
frankly, even the one thing it fixes is totally broken: the iovec is
left in user space, so there are all those crazy race-conditions where
another thread in user space can _change_ the rds_iovec after we have
counted the pages, and now the page count is totally wrong.

So the code is just an unmitigated disaster from any standpoint. My
patch - if it works - makes it slightly better. But I'd suggest
disabling RDS in any sane setup.

This was the same subsystem that totally didn't check the user
addresses at all, after all. So there are probably tons of other bugs
lurking.

Btw: patch is totally untested. I haven't even compiled it. So take it
with a pinch of salt.

                                                 Linus

--00151750d9fc6c312e0493af0e75
Content-Type: text/x-patch; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gftsk9es0

RnJvbTogTGludXMgVG9ydmFsZHMgPHRvcnZhbGRzQGxpbnV4LWZvdW5kYXRpb24ub3JnPgpTdWJq
ZWN0OiBuZXQ6IGZpeCByZHNfaW92ZWMgcGFnZSBjb3VudCBvdmVyZmxvdwoKQXMgcmVwb3J0ZWQg
YnkgVGhvbWFzIFBvbGxldCwgdGhlIHJkbWEgcGFnZSBjb3VudGluZyBjYW4gb3ZlcmZsb3cuICBX
ZQpnZXQgdGhlIHJkbWEgc2l6ZXMgaW4gNjQtYml0IHVuc2lnbmVkIGVudGl0aWVzLCBidXQgdGhl
biBsaW1pdCBpdCB0bwpVSU5UX01BWCBieXRlcyBhbmQgc2hpZnQgdGhlbSBkb3duIHRvIHBhZ2Vz
IChzbyB3aXRoIGEgcG9zc2libGUgIisxIiBmb3IKYW4gdW5hbGlnbmVkIGFkZHJlc3MpLiAKClNv
IGVhY2ggaW5kaXZpZHVhbCBwYWdlIGNvdW50IGZpdHMgY29tZm9ydGFibHkgaW4gYW4gJ3Vuc2ln
bmVkIGludCcgKG5vdApldmVuIGNsb3NlIHRvIG92ZXJmbG93aW5nIGludG8gc2lnbmVkKSwgYnV0
IGFzIHRoZXkgYXJlIGFkZGVkIHVwLCB0aGV5Cm1pZ2h0IGVuZCB1cCByZXN1bHRpbmcgaW4gYSBz
aWduZWQgcmV0dXJuIHZhbHVlLiBXaGljaCB3b3VsZCBiZSB3cm9uZy4KCkNhdGNoIHRoZSBjYXNl
IG9mIHRvdF9wYWdlcyB0dXJuaW5nIG5lZ2F0aXZlLCBhbmQgcmV0dXJuIHRoZSBhcHByb3ByaWF0
ZQplcnJvciBjb2RlLiAKClJlcG9ydGVkLWJ5OiBUaG9tYXMgUG9sbGV0IDx0aG9tYXMucG9sbGV0
QGdtYWlsLmNvbT4KU2lnbmVkLW9mZi1ieTogTGludXMgVG9ydmFsZHMgPHRvcnZhbGRzQGxpbnV4
LWZvdW5kYXRpb24ub3JnPgotLS0KIG5ldC9yZHMvcmRtYS5jIHwgICAgNyArKysrKysrCiAxIGZp
bGVzIGNoYW5nZWQsIDcgaW5zZXJ0aW9ucygrKSwgMCBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQg
YS9uZXQvcmRzL3JkbWEuYyBiL25ldC9yZHMvcmRtYS5jCmluZGV4IDFhNDFkZWIuLjBkZjAyYzgg
MTAwNjQ0Ci0tLSBhL25ldC9yZHMvcmRtYS5jCisrKyBiL25ldC9yZHMvcmRtYS5jCkBAIC01MDIs
NiArNTAyLDEzIEBAIHN0YXRpYyBpbnQgcmRzX3JkbWFfcGFnZXMoc3RydWN0IHJkc19yZG1hX2Fy
Z3MgKmFyZ3MpCiAJCQlyZXR1cm4gLUVJTlZBTDsKIAogCQl0b3RfcGFnZXMgKz0gbnJfcGFnZXM7
CisKKwkJLyoKKwkJICogbnJfcGFnZXMgZm9yIG9uZSBlbnRyeSBpcyBsaW1pdGVkIHRvIChVSU5U
X01BWD4+UEFHRV9TSElGVCkrMSwKKwkJICogc28gdG90X3BhZ2VzIGNhbm5vdCBvdmVyZmxvdyB3
aXRob3V0IGZpcnN0IGdvaW5nIG5lZ2F0aXZlLgorCQkgKi8KKwkJaWYgKChpbnQpdG90X3BhZ2Vz
IDwgMCkKKwkJCXJldHVybiAtRUlOVkFMOwogCX0KIAogCXJldHVybiB0b3RfcGFnZXM7Cg==
--00151750d9fc6c312e0493af0e75--
