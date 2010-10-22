From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [Security] TIPC security issues
Date: Thu, 21 Oct 2010 17:31:12 -0700
Message-ID: <AANLkTi=V93A660+YS8C2TvC13kGUcJpFgjPHUvONd_WW@mail.gmail.com>
References: <1287704752.11051.79.camel@Dan>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=0022152d6729b1b862049329c3d6
Cc: jon.maloy@ericsson.com, allan.stephens@windriver.com,
	netdev@vger.kernel.org, security@kernel.org
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:34139 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752211Ab0JVAbm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 20:31:42 -0400
Received: from mail-iw0-f174.google.com (mail-iw0-f174.google.com [209.85.214.174])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id o9M0VXcM013186
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 17:31:41 -0700
Received: by iwn34 with SMTP id 34so202758iwn.19
        for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 17:31:33 -0700 (PDT)
In-Reply-To: <1287704752.11051.79.camel@Dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0022152d6729b1b862049329c3d6
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Thu, Oct 21, 2010 at 4:45 PM, Dan Rosenberg <drosenberg@vsecurity.com> w=
rote:
>
> 1. The tipc_msg_calc_data_size() function is almost totally broken. =A0It
> sums together size_t values (iov_lens), but returns an integer. =A0Two
> things can go wrong - the total value can wrap around, or on 64-bit
> platforms, iov_len values greater than UINT_MAX will be truncated.

Hmm. I actually think that this is a problem with "verify_iovec()". We
should just make that one stricter, I think.

We already (long ago) decided that POSIX.1 compatibility be damned,
and that reading and writing more than 2GB in a single system call is
bogus: so normal write calls will actually limit size_t arguments to
MAX_INT, exactly so that various filesystems don't have to worry about
overflow and can keep length arguments in an "int".

And we probably should just do the same in verify[_compat]_iovec(). We
do 99% of the necessary work there already - adding a few simple
checks would get us there all the way. And then silly things like this
wouldn't matter.

Something simple like:
  if an iovec has a total length that is > MAX_INT, then limit that
entry to MAX_INT, and clear out the rest

Something like the appended UNTESTED patch. NOTE! it actually makes
"verify_iovec()" *change* the iovec if it grows too big.

Also note that not only is it untested, it also doesn't do this for
the verify_compat_iovec() function, so this is really more of a "look,
we could do this" patch - to get discussion started.

                       Linus

--0022152d6729b1b862049329c3d6
Content-Type: text/x-patch; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gfkbru440

IG5ldC9jb3JlL2lvdmVjLmMgfCAgIDE3ICsrKysrKysrLS0tLS0tLS0tCiAxIGZpbGVzIGNoYW5n
ZWQsIDggaW5zZXJ0aW9ucygrKSwgOSBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9uZXQvY29y
ZS9pb3ZlYy5jIGIvbmV0L2NvcmUvaW92ZWMuYwppbmRleCBlNmIxMzNiLi5iNDg5ZmQ2IDEwMDY0
NAotLS0gYS9uZXQvY29yZS9pb3ZlYy5jCisrKyBiL25ldC9jb3JlL2lvdmVjLmMKQEAgLTM4LDcg
KzM4LDcgQEAKIGxvbmcgdmVyaWZ5X2lvdmVjKHN0cnVjdCBtc2doZHIgKm0sIHN0cnVjdCBpb3Zl
YyAqaW92LCBzdHJ1Y3Qgc29ja2FkZHIgKmFkZHJlc3MsIGludCBtb2RlKQogewogCWludCBzaXpl
LCBjdDsKLQlsb25nIGVycjsKKwlzaXplX3QgZXJyOwogCiAJaWYgKG0tPm1zZ19uYW1lbGVuKSB7
CiAJCWlmIChtb2RlID09IFZFUklGWV9SRUFEKSB7CkBAIC02MCwxNCArNjAsMTMgQEAgbG9uZyB2
ZXJpZnlfaW92ZWMoc3RydWN0IG1zZ2hkciAqbSwgc3RydWN0IGlvdmVjICppb3YsIHN0cnVjdCBz
b2NrYWRkciAqYWRkcmVzcywKIAllcnIgPSAwOwogCiAJZm9yIChjdCA9IDA7IGN0IDwgbS0+bXNn
X2lvdmxlbjsgY3QrKykgewotCQllcnIgKz0gaW92W2N0XS5pb3ZfbGVuOwotCQkvKgotCQkgKiBH
b2FsIGlzIG5vdCB0byB2ZXJpZnkgdXNlciBkYXRhLCBidXQgdG8gcHJldmVudCByZXR1cm5pbmcK
LQkJICogbmVnYXRpdmUgdmFsdWUsIHdoaWNoIGlzIGludGVycHJldGVkIGFzIGVycm5vLgotCQkg
KiBPdmVyZmxvdyBpcyBzdGlsbCBwb3NzaWJsZSwgYnV0IGl0IGlzIGhhcm1sZXNzLgotCQkgKi8K
LQkJaWYgKGVyciA8IDApCi0JCQlyZXR1cm4gLUVNU0dTSVpFOworCQlzaXplX3QgbGVuID0gaW92
W2N0XS5pb3ZfbGVuOworCisJCWlmIChsZW4gPiBJTlRfTUFYIC0gZXJyKSB7CisJCQlsZW4gPSBJ
TlRfTUFYIC0gZXJyOworCQkJaW92W2N0XS5pb3ZfbGVuID0gbGVuOworCQl9CisJCWVyciArPSBs
ZW47CiAJfQogCiAJcmV0dXJuIGVycjsK
--0022152d6729b1b862049329c3d6--
