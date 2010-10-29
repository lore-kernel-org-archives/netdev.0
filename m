From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Fri, 29 Oct 2010 14:41:03 -0700
Message-ID: <AANLkTinR6XH30dHwPS23=sGYOJU8rO4+kwz+Uv_XRB-b@mail.gmail.com>
References: <20101029.125920.189692530.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=20cf303dd828e76cc30493c851f6
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:42796 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755194Ab0J2VlZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 17:41:25 -0400
In-Reply-To: <20101029.125920.189692530.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--20cf303dd828e76cc30493c851f6
Content-Type: text/plain; charset=ISO-8859-1

On Fri, Oct 29, 2010 at 12:59 PM, David Miller <davem@davemloft.net> wrote:
>
> This has the verify_iovec() INT_MAX limiter change as well as:

I think you'd want this as well, to make sure that sendto/recvfrom
don't generate invalid iovecs.

Feel free to add my sign-off (or just commit it as yourself) after
giving it some testing.

NOTE! On thing that struck me is that the VFS layer does the
"access_ok()" on the pre-truncated size and pointer pair, and I think
that is the correct thing to do. However, the socket layer (and this
patch) just truncates the size, so even if the copy is then done
correctly with the proper user access checking, it will not check that
the whole original buffer was valid - only that the buffer it fills in
is valid.

Now, this is not a security issue (since we're just not checking stuff
that isn't getting filled in), but I think it's a QoI issue - it
allows users to successfully pass in bogus buffers with huge sizes,
and then if the thing only reads a few bytes it will all be ok.

That's not a new thing: the old code may not have truncated the sizes,
but if you pass in a 2GB buffer size, 99.999% of all socket read calls
obviously won't ever fill that 2GB, but will happily return with
whatever is there in the socket now (especially with nonblocking IO
etc). But I do wonder if we shouldn't do the access_ok() on the whole
buffer, as a way to keep user code honest.

                  Linus

--20cf303dd828e76cc30493c851f6
Content-Type: text/x-patch; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gfvknyzj0

IG5ldC9zb2NrZXQuYyB8ICAgIDQgKysrKwogMSBmaWxlcyBjaGFuZ2VkLCA0IGluc2VydGlvbnMo
KyksIDAgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvbmV0L3NvY2tldC5jIGIvbmV0L3NvY2tl
dC5jCmluZGV4IDUyNDdhZTEuLjNjYTJmZDkgMTAwNjQ0Ci0tLSBhL25ldC9zb2NrZXQuYworKysg
Yi9uZXQvc29ja2V0LmMKQEAgLTE2NTIsNiArMTY1Miw4IEBAIFNZU0NBTExfREVGSU5FNihzZW5k
dG8sIGludCwgZmQsIHZvaWQgX191c2VyICosIGJ1ZmYsIHNpemVfdCwgbGVuLAogCXN0cnVjdCBp
b3ZlYyBpb3Y7CiAJaW50IGZwdXRfbmVlZGVkOwogCisJaWYgKGxlbiA+IElOVF9NQVgpCisJCWxl
biA9IElOVF9NQVg7CiAJc29jayA9IHNvY2tmZF9sb29rdXBfbGlnaHQoZmQsICZlcnIsICZmcHV0
X25lZWRlZCk7CiAJaWYgKCFzb2NrKQogCQlnb3RvIG91dDsKQEAgLTE3MDksNiArMTcxMSw4IEBA
IFNZU0NBTExfREVGSU5FNihyZWN2ZnJvbSwgaW50LCBmZCwgdm9pZCBfX3VzZXIgKiwgdWJ1Ziwg
c2l6ZV90LCBzaXplLAogCWludCBlcnIsIGVycjI7CiAJaW50IGZwdXRfbmVlZGVkOwogCisJaWYg
KHNpemUgPiBJTlRfTUFYKQorCQlzaXplID0gSU5UX01BWDsKIAlzb2NrID0gc29ja2ZkX2xvb2t1
cF9saWdodChmZCwgJmVyciwgJmZwdXRfbmVlZGVkKTsKIAlpZiAoIXNvY2spCiAJCWdvdG8gb3V0
Owo=
--20cf303dd828e76cc30493c851f6--
