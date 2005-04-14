From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] IPV6_CHECKSUM socket option can corrupt kernel memory
Date: Thu, 14 Apr 2005 12:36:46 -0600
Message-ID: <OF2DA36C59.2C9530C7-ON88256FE3.00654547-88256FE3.00663E1E@us.ibm.com>
References: <E1DM3QD-00045e-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_mixed 00663E1988256FE3_="
Cc: davem@davemloft.com, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <E1DM3QD-00045e-00@gondolin.me.apana.org.au>
To: Herbert Xu <herbert@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--=_mixed 00663E1988256FE3_=
Content-Type: text/plain; charset="US-ASCII"

I'm still looking at your patch.

Below is a piece of my original patch that I've separated out to make sure
it doesn't get lost in this discussion. It's the fix for the bug that 
triggered all
of this and the real cause of the panic for the ordinary raw-socket cases, 
where
nr_frags is supposed to be "0". Attached and in-line below.

A couple comments initially on your patch: multiple packet support I don't
think is needed here (in sendmsg). I agree it's good to put it in for 
other
possible uses, but IPV6_CHECKSUM doesn't need it, as far as I can tell.

How about a loop instead of a recursive call? If the list is long enough
and the architecture eats stack a lot of stack space on function calls,
that could be a problem.

                                                +-DLS
The fix part of the patch:

Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

--- linux-2.6.11.7/net/ipv6/raw.c       2005-04-07 11:57:32.000000000 
-0700
+++ linux-2.6.11.7T1/net/ipv6/raw.c     2005-04-12 15:05:00.000000000 
-0700
@@ -771,8 +790,11 @@ back_from_confirm:
 
                if (err)
                        ip6_flush_pending_frames(sk);
-               else if (!(msg->msg_flags & MSG_MORE))
+               else if (!(msg->msg_flags & MSG_MORE)) {
                        err = rawv6_push_pending_frames(sk, &fl, rp, len);
+                       if (err)
+                               ip6_flush_pending_frames(sk);
+               }
        }
 done:
        ip6_dst_store(sk, dst,



--=_mixed 00663E1988256FE3_=
Content-Type: application/octet-stream; name="rawv6-2.patch"
Content-Disposition: attachment; filename="rawv6-2.patch"
Content-Transfer-Encoding: base64

LS0tIGxpbnV4LTIuNi4xMS43L25ldC9pcHY2L3Jhdy5jCTIwMDUtMDQtMDcgMTE6NTc6MzIuMDAw
MDAwMDAwIC0wNzAwCisrKyBsaW51eC0yLjYuMTEuN1QxL25ldC9pcHY2L3Jhdy5jCTIwMDUtMDQt
MTIgMTU6MDU6MDAuMDAwMDAwMDAwIC0wNzAwCkBAIC03NzEsOCArNzkwLDExIEBAIGJhY2tfZnJv
bV9jb25maXJtOgogCiAJCWlmIChlcnIpCiAJCQlpcDZfZmx1c2hfcGVuZGluZ19mcmFtZXMoc2sp
OwotCQllbHNlIGlmICghKG1zZy0+bXNnX2ZsYWdzICYgTVNHX01PUkUpKQorCQllbHNlIGlmICgh
KG1zZy0+bXNnX2ZsYWdzICYgTVNHX01PUkUpKSB7CiAJCQllcnIgPSByYXd2Nl9wdXNoX3BlbmRp
bmdfZnJhbWVzKHNrLCAmZmwsIHJwLCBsZW4pOworCQkJaWYgKGVycikKKwkJCQlpcDZfZmx1c2hf
cGVuZGluZ19mcmFtZXMoc2spOworCQl9CiAJfQogZG9uZToKIAlpcDZfZHN0X3N0b3JlKHNrLCBk
c3QsCg==

--=_mixed 00663E1988256FE3_=--
