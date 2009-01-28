From: <Shyam_Iyer@Dell.com>
Subject: RE: [PANIC] lro + iscsi or lro + skb text search causes panic
Date: Wed, 28 Jan 2009 18:06:57 +0530
Message-ID: <46A00B48CC54E4468EF6911F877AC4CA01EF2BDB@blrx3m10.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----_=_NextPart_001_01C98145.1BCE662A"
Cc: <davem@davemloft.net>, <jesse.brandeburg@intel.com>,
	<netdev@vger.kernel.org>, <olaf.kirch@oracle.com>, <tgraf@suug.ch>,
	<kkeil@suse.de>
To: <michaelc@cs.wisc.edu>, <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60pc101.us.dell.com ([143.166.85.206]:9433 "EHLO
	ausc60pc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740AbZA1Mu1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 07:50:27 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.

------_=_NextPart_001_01C98145.1BCE662A
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable



Mike Christie wrote:
> Herbert Xu wrote:
>> On Sun, Jan 25, 2009 at 09:32:22PM -0800, David Miller wrote:
>>> From: Mike Christie <michaelc@cs.wisc.edu>
>>> Date: Thu, 22 Jan 2009 18:04:11 -0600
>>>
>>>> With the patch running against linus's git tree, my box locks up.=20
>>>> You cannot ping it. I do not get a oops or anything in the logs,
and=20
>>>> the keyboard does not respond. I will try to get some oops output=20
>>>> and more info.
>>> Herbert, any idea offhand?
>>=20
>> Yeah, I missed an offset update in there :) Here's a better version.
>>=20
>> net: Fix frag_list handling in skb_seq_read
>>=20
>> The frag_list handling was broken in skb_seq_read:
>>=20
>> 1) We didn't add the stepped offset when looking at the head are of=20
>> fragments other than the first.
>>=20
>> 2) We didn't take the stepped offset away when setting the data=20
>> pointer in the head area.
>>=20
>> 3) The frag index wasn't reset.
>>=20
>> This patch fixes both issues.
>>=20

>It oopsd for me in skb_seq_read. addr2line said it was
linux-2.6/net/core/skbuff.c:2228, which is this line:


>while (st->frag_idx < skb_shinfo(st->cur_skb)->nr_frags) {


>I added some printks in there and it looks like we hit this:

>         } else if (st->root_skb =3D=3D st->cur_skb &&
>                   skb_shinfo(st->root_skb)->frag_list) {
>                 st->cur_skb =3D skb_shinfo(st->root_skb)->frag_list;
>                 st->frag_idx =3D 0;
>                 goto next_skb;
>        }



Actually I did some testing and added a few printks and found that the
st->cur_skb->data was 0 and hence the ptr used by iscsi_tcp was null.
This caused the kernel panic.

 	if (abs_offset < block_limit) {
-		*data =3D st->cur_skb->data + abs_offset;
+		*data =3D st->cur_skb->data + (abs_offset -
st->stepped_offset);

 I enabled the debug_tcp and with a few printks found that the code in
my scenario did not go to the next_skb label as described by Mike and
could find that the sequence being followed was this -

It hit this if condition -
 if (st->cur_skb->next) {
                st->cur_skb =3D st->cur_skb->next;
                st->frag_idx =3D 0;
                goto next_skb;

And so, now the st pointer is shifted to the next skb whereas actually
it should have hit the second else if first since the data is in the
frag_list.

else if (st->root_skb =3D=3D st->cur_skb &&
                   skb_shinfo(st->root_skb)->frag_list) {
                st->cur_skb =3D skb_shinfo(st->root_skb)->frag_list;
                goto next_skb;
        }


Reversing the two conditions the attached patch fixes the issue for me
on top of Herbert's patches.  I have done the testing on the ixgbe
adapter itself and verified the fix using some amount of data transfer
as well.

Signed-off-by: Shyam Iyer <shyam_iyer@dell.com>

--- skbuff.c.orig	2009-01-29 01:12:03.000000000 +0530
+++ skbuff.c	2009-01-29 01:34:57.000000000 +0530
@@ -2039,15 +2039,15 @@
 		st->frag_data =3D NULL;
 	}
=20
-	if (st->cur_skb->next) {
-		st->cur_skb =3D st->cur_skb->next;
-		st->frag_idx =3D 0;
-		goto next_skb;
-	} else if (st->root_skb =3D=3D st->cur_skb &&
+	if (st->root_skb =3D=3D st->cur_skb &&
 		   skb_shinfo(st->root_skb)->frag_list) {
 		st->cur_skb =3D skb_shinfo(st->root_skb)->frag_list;
 		st->frag_idx=3D0;
 		goto next_skb;
+	} else if (st->cur_skb->next) {
+		st->cur_skb =3D st->cur_skb->next;
+		st->frag_idx =3D 0;
+		goto next_skb;
 	}
=20
 	return 0;


=20
P.S: Currently sending through an email client that can't do proper
patch formatting so please excuse the patch in an attachement.


------_=_NextPart_001_01C98145.1BCE662A
Content-Type: application/octet-stream;
	name="skbuff_patch"
Content-Transfer-Encoding: base64
Content-Description: skbuff_patch
Content-Disposition: attachment;
	filename="skbuff_patch"

LS0tIHNrYnVmZi5jLm9yaWcJMjAwOS0wMS0yOSAwMToxMjowMy4wMDAwMDAwMDAgKzA1MzAKKysr
IHNrYnVmZi5jCTIwMDktMDEtMjkgMDE6MzQ6NTcuMDAwMDAwMDAwICswNTMwCkBAIC0yMDM5LDE1
ICsyMDM5LDE1IEBACiAJCXN0LT5mcmFnX2RhdGEgPSBOVUxMOwogCX0KIAotCWlmIChzdC0+Y3Vy
X3NrYi0+bmV4dCkgewotCQlzdC0+Y3VyX3NrYiA9IHN0LT5jdXJfc2tiLT5uZXh0OwotCQlzdC0+
ZnJhZ19pZHggPSAwOwotCQlnb3RvIG5leHRfc2tiOwotCX0gZWxzZSBpZiAoc3QtPnJvb3Rfc2ti
ID09IHN0LT5jdXJfc2tiICYmCisJaWYgKHN0LT5yb290X3NrYiA9PSBzdC0+Y3VyX3NrYiAmJgog
CQkgICBza2Jfc2hpbmZvKHN0LT5yb290X3NrYiktPmZyYWdfbGlzdCkgewogCQlzdC0+Y3VyX3Nr
YiA9IHNrYl9zaGluZm8oc3QtPnJvb3Rfc2tiKS0+ZnJhZ19saXN0OwogCQlzdC0+ZnJhZ19pZHg9
MDsKIAkJZ290byBuZXh0X3NrYjsKKwl9IGVsc2UgaWYgKHN0LT5jdXJfc2tiLT5uZXh0KSB7CisJ
CXN0LT5jdXJfc2tiID0gc3QtPmN1cl9za2ItPm5leHQ7CisJCXN0LT5mcmFnX2lkeCA9IDA7CisJ
CWdvdG8gbmV4dF9za2I7CiAJfQogCiAJcmV0dXJuIDA7Cg==

------_=_NextPart_001_01C98145.1BCE662A--
