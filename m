From: David Stevens <dlstevens@us.ibm.com>
Subject: [PATCH] IPV6_CHECKSUM socket option can corrupt kernel memory
Date: Tue, 12 Apr 2005 17:41:25 -0600
Message-ID: <OF618A0572.CA254DA0-ON88256FE1.0080DB81-88256FE1.0082220B@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_mixed 0082220788256FE1_="
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--=_mixed 0082220788256FE1_=
Content-Type: text/plain; charset="US-ASCII"

I was doing some testing with IPV6_CHECKSUM and started getting memory
corruption (panic when the socket was closed). The bug originally 
manifested
itself as a the "csum" pointer in rawv6_push_pending_frames() pointing 
beyond
the end of the skb data and trashing skb_shinfo(skb) because it didn't 
handle
the case where nr_frags was 1 (and it was being called with an skb like 
that...).

After fixing that, I found that the reason nr_frags was nonzero was 
because
a prior sendto(), which had an invalid offset (for testing) had returned 
an error
but left the packet data in the socket buffer. Subsequent calls wouldn't 
fit in
the existing skb, so they resulted in frag buffers and an invalid csum 
pointer.

I don't know if it is possible, after the fix for the second problem, to 
get an
skb with nonzero nr_frags in rawv6_push_pending_frames() (maybe with
corking? or maybe via MSG_MORE?), but this patch includes support for
non-linear skbs as well as the missing flush on error that caused the 
problem
to begin with.

in-line with mangled whitespace, and attached for applying.

                                                +-DLS

--- linux-2.6.11.7/net/ipv6/raw.c       2005-04-07 11:57:32.000000000 
-0700
+++ linux-2.6.11.7T1/net/ipv6/raw.c     2005-04-12 15:05:00.000000000 
-0700
@@ -465,9 +465,28 @@ static int rawv6_push_pending_frames(str
        if ((skb = skb_peek(&sk->sk_write_queue)) == NULL)
                goto out;
 
-       if (rp->offset + 1 < len)
-               csum = (u16 *)(skb->h.raw + rp->offset);
-       else {
+       if (rp->offset + 1 < len) {
+               if (rp->offset < skb->tail - skb->h.raw - 1) {
+                       csum = (u16 *)(skb->h.raw + rp->offset);
+               } else if (skb_shinfo(skb)->nr_frags) {
+                       int offset = rp->offset;
+                       int i;
+
+                       offset -= skb->tail - skb->h.raw -1;
+                       for (i=0; i<skb_shinfo(skb)->nr_frags; ++i) {
+                               if (offset < 
skb_shinfo(skb)->frags[i].size)
+                                       break;
+                               offset -= skb_shinfo(skb)->frags[i].size;
+                       }
+                       csum = (u16 *)
+ (page_address(skb_shinfo(skb)->frags[i].page) +
+                               skb_shinfo(skb)->frags[i].page_offset + 
offset);
+               } else {
+                       /* "can't happen"; len already checked, but.. */
+                       err = -EINVAL;
+                       goto out;
+               }
+       } else {
                err = -EINVAL;
                goto out;
        }
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



--=_mixed 0082220788256FE1_=
Content-Type: application/octet-stream; name="rawv6.patch"
Content-Disposition: attachment; filename="rawv6.patch"
Content-Transfer-Encoding: base64

LS0tIGxpbnV4LTIuNi4xMS43L25ldC9pcHY2L3Jhdy5jCTIwMDUtMDQtMDcgMTE6NTc6MzIuMDAw
MDAwMDAwIC0wNzAwCisrKyBsaW51eC0yLjYuMTEuN1QxL25ldC9pcHY2L3Jhdy5jCTIwMDUtMDQt
MTIgMTU6MDU6MDAuMDAwMDAwMDAwIC0wNzAwCkBAIC00NjUsOSArNDY1LDI4IEBAIHN0YXRpYyBp
bnQgcmF3djZfcHVzaF9wZW5kaW5nX2ZyYW1lcyhzdHIKIAlpZiAoKHNrYiA9IHNrYl9wZWVrKCZz
ay0+c2tfd3JpdGVfcXVldWUpKSA9PSBOVUxMKQogCQlnb3RvIG91dDsKIAotCWlmIChycC0+b2Zm
c2V0ICsgMSA8IGxlbikKLQkJY3N1bSA9ICh1MTYgKikoc2tiLT5oLnJhdyArIHJwLT5vZmZzZXQp
OwotCWVsc2UgeworCWlmIChycC0+b2Zmc2V0ICsgMSA8IGxlbikgeworCQlpZiAocnAtPm9mZnNl
dCA8IHNrYi0+dGFpbCAtIHNrYi0+aC5yYXcgLSAxKSB7CisJCQljc3VtID0gKHUxNiAqKShza2It
PmgucmF3ICsgcnAtPm9mZnNldCk7CisJCX0gZWxzZSBpZiAoc2tiX3NoaW5mbyhza2IpLT5ucl9m
cmFncykgeworCQkJaW50IG9mZnNldCA9IHJwLT5vZmZzZXQ7CisJCQlpbnQgaTsKKworCQkJb2Zm
c2V0IC09IHNrYi0+dGFpbCAtIHNrYi0+aC5yYXcgLTE7CisJCQlmb3IgKGk9MDsgaTxza2Jfc2hp
bmZvKHNrYiktPm5yX2ZyYWdzOyArK2kpIHsKKwkJCQlpZiAob2Zmc2V0IDwgc2tiX3NoaW5mbyhz
a2IpLT5mcmFnc1tpXS5zaXplKQorCQkJCQlicmVhazsKKwkJCQlvZmZzZXQgLT0gc2tiX3NoaW5m
byhza2IpLT5mcmFnc1tpXS5zaXplOworCQkJfQorCQkJY3N1bSA9ICh1MTYgKikKKwkJCQkocGFn
ZV9hZGRyZXNzKHNrYl9zaGluZm8oc2tiKS0+ZnJhZ3NbaV0ucGFnZSkgKworCQkJCXNrYl9zaGlu
Zm8oc2tiKS0+ZnJhZ3NbaV0ucGFnZV9vZmZzZXQgKyBvZmZzZXQpOworCQl9IGVsc2UgeworCQkJ
LyogImNhbid0IGhhcHBlbiI7IGxlbiBhbHJlYWR5IGNoZWNrZWQsIGJ1dC4uICovCisJCQllcnIg
PSAtRUlOVkFMOworCQkJZ290byBvdXQ7CisJCX0KKwl9IGVsc2UgewogCQllcnIgPSAtRUlOVkFM
OwogCQlnb3RvIG91dDsKIAl9CkBAIC03NzEsOCArNzkwLDExIEBAIGJhY2tfZnJvbV9jb25maXJt
OgogCiAJCWlmIChlcnIpCiAJCQlpcDZfZmx1c2hfcGVuZGluZ19mcmFtZXMoc2spOwotCQllbHNl
IGlmICghKG1zZy0+bXNnX2ZsYWdzICYgTVNHX01PUkUpKQorCQllbHNlIGlmICghKG1zZy0+bXNn
X2ZsYWdzICYgTVNHX01PUkUpKSB7CiAJCQllcnIgPSByYXd2Nl9wdXNoX3BlbmRpbmdfZnJhbWVz
KHNrLCAmZmwsIHJwLCBsZW4pOworCQkJaWYgKGVycikKKwkJCQlpcDZfZmx1c2hfcGVuZGluZ19m
cmFtZXMoc2spOworCQl9CiAJfQogZG9uZToKIAlpcDZfZHN0X3N0b3JlKHNrLCBkc3QsCg==

--=_mixed 0082220788256FE1_=--
