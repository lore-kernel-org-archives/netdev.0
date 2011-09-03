From: Sedat Dilek <sedat.dilek@googlemail.com>
Subject: Re: [next] unix stream crashes
Date: Sat, 3 Sep 2011 15:47:32 +0200
Message-ID: <CA+icZUXULisfr6_EOrj8+q36UMo2mudcoJu3z0SX4T3x_OZQSg@mail.gmail.com>
References: <4E5FEF28.60406@gmail.com>
	<3179.1314924559@turing-police.cc.vt.edu>
	<1314927645.2576.2939.camel@schen9-DESK>
	<6805.1314979936@turing-police.cc.vt.edu>
	<1315007703.2576.2965.camel@schen9-DESK>
	<6043.1315028115@turing-police.cc.vt.edu>
	<CA+icZUVuJWpLquLk4kHJzmMKtPw24oxud=u3Na0U0HhSYqwV1w@mail.gmail.com>
	<4E61C7F2.3090902@gmail.com>
	<CAAM7YAkB3VVNMmBMVuvEZuV6oGZeyog37_sjFGUunu+15apvZA@mail.gmail.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=0016e652f4283e1cda04ac09b8b2
Cc: Jiri Slaby <jirislaby@gmail.com>, Valdis.Kletnieks@vt.edu,
	Tim Chen <tim.c.chen@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	ML netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>
To: "Yan, Zheng" <yanzheng@21cn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:33916 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751636Ab1ICNrf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Sep 2011 09:47:35 -0400
In-Reply-To: <CAAM7YAkB3VVNMmBMVuvEZuV6oGZeyog37_sjFGUunu+15apvZA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0016e652f4283e1cda04ac09b8b2
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Sat, Sep 3, 2011 at 2:30 PM, Yan, Zheng <yanzheng@21cn.com> wrote:
> The skb can be destructed before the while loop in unix_stream_sendmsg st=
ops.
> please try below patch.
>
> ---
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index e6d9d10..f6d7ed7 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -1577,6 +1577,7 @@ static int unix_stream_sendmsg(struct kiocb
> *kiocb, struct socket *sock,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int sent =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct scm_cookie tmp_scm;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0bool fds_sent =3D false;
> + =C2=A0 =C2=A0 =C2=A0 bool scm_ref =3D true;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int max_level;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (NULL =3D=3D siocb->scm)
> @@ -1637,12 +1638,19 @@ static int unix_stream_sendmsg(struct kiocb
> *kiocb, struct socket *sock,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0size =3D min_t(int=
, size, skb_tailroom(skb));
>
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* pass the scm r=
eference to the skb if a single skb is large
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* enough to hold=
 all data.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!fds_sent && sent =
+ size >=3D len)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 scm_ref =3D false;
>
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Only send the fds a=
nd no ref to pid in the first buffer */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 err =3D unix_scm_to_sk=
b(siocb->scm, skb, !fds_sent, fds_sent);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Only send the fds i=
n the first buffer */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 err =3D unix_scm_to_sk=
b(siocb->scm, skb, !fds_sent,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 fds_sent || =
scm_ref);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (err < 0) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0kfree_skb(skb);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 goto out;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 goto out_err;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0max_level =3D err =
+ 1;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0fds_sent =3D true;
> @@ -1650,7 +1658,7 @@ static int unix_stream_sendmsg(struct kiocb
> *kiocb, struct socket *sock,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0err =3D memcpy_fro=
miovec(skb_put(skb, size), msg->msg_iov, size);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (err) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0kfree_skb(skb);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 goto out;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 goto out_err;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unix_state_lock(ot=
her);
> @@ -1667,10 +1675,10 @@ static int unix_stream_sendmsg(struct kiocb
> *kiocb, struct socket *sock,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0sent +=3D size;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> - =C2=A0 =C2=A0 =C2=A0 if (skb)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 scm_release(siocb->scm=
);
> - =C2=A0 =C2=A0 =C2=A0 else
> + =C2=A0 =C2=A0 =C2=A0 if (scm_ref)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0scm_destroy(siocb-=
>scm);
> + =C2=A0 =C2=A0 =C2=A0 else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 scm_release(siocb->scm=
);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0siocb->scm =3D NULL;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return sent;
> @@ -1683,9 +1691,10 @@ pipe_err:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0send_sig(SIGPIPE, =
current, 0);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0err =3D -EPIPE;
> =C2=A0out_err:
> - =C2=A0 =C2=A0 =C2=A0 if (skb =3D=3D NULL)
> + =C2=A0 =C2=A0 =C2=A0 if (scm_ref)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0scm_destroy(siocb-=
>scm);
> -out:
> + =C2=A0 =C2=A0 =C2=A0 else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 scm_release(siocb->scm=
);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0siocb->scm =3D NULL;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return sent ? : err;
> =C2=A0}
>
>

I have tested your patch on i386 against:

1. linux-next/patch-v3.1-rc3-next-20110826
2. scm-fix/0001-Revert-Scm-Remove-unnecessary-pid-credential-referen.patch
3. scm-fix-2/scm_send.patch
4. scm-fix-3/0001-Fix-unix-stream-crashes.patch

So the BROKEN scm-send path seems to be fixed, now!

As the patch arrived "malformed" in my mbox I git-am-ed it on top of
linux-next (next-20110826) GIT repository (patch attached).

After confirmation of Valdis (x86_64) and ACK-by Tim, I would
appreciate a proper patch with all Reported-by/Tested-by/S-o-b etc.
In my case I bisected the issue, I recall that there is sth. like
Bisected-by, so feel free to do so.

Doing now a 2nd run with:

1. linux-next/patch-v3.1-rc3-next-20110826
2. scm-fix-3/0001-Fix-unix-stream-crashes.patch

- Sedat -

> On Sat, Sep 3, 2011 at 2:23 PM, Jiri Slaby <jirislaby@gmail.com> wrote:
>> On 09/03/2011 07:54 AM, Sedat Dilek wrote:
>>>
>>> I saw similiar call-traces with put_cred_rcu() - besides with
>>> kmem_cache_alloc_trace().
>>> My post-it says:
>>> Kernel panic - not syncing: CRED: put_cred_rcu sees f67ac0c0 with usage
>>> -43
>>
>> Hm, Tim, it looks like you put a pid which you did not get?
>>
>> regards,
>> --
>> js
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" =
in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at =C2=A0http://www.tux.org/lkml/
>>
>

--0016e652f4283e1cda04ac09b8b2
Content-Type: text/x-diff; charset=US-ASCII; name="0001-Fix-unix-stream-crashes.patch"
Content-Disposition: attachment;
	filename="0001-Fix-unix-stream-crashes.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gs4n7cct0

RnJvbSA1NGQ4YTVjNTkwYzA2ZjA3MGQ5YWRiZmZmYmEwYjMyMjQ2ZDcyN2UyIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiAiWWFuLCBaaGVuZyIgPHlhbnpoZW5nQDIxY24uY29tPgpEYXRl
OiBTYXQsIDMgU2VwIDIwMTEgMTQ6MzA6MTkgKzAyMDAKU3ViamVjdDogW1BBVENIXSBGaXggdW5p
eCBzdHJlYW0gY3Jhc2hlcwoKVGhlIHNrYiBjYW4gYmUgZGVzdHJ1Y3RlZCBiZWZvcmUgdGhlIHdo
aWxlIGxvb3AgaW4gdW5peF9zdHJlYW1fc2VuZG1zZyBzdG9wcy4KcGxlYXNlIHRyeSBiZWxvdyBw
YXRjaC4KLS0tCiBuZXQvdW5peC9hZl91bml4LmMgfCAgIDI3ICsrKysrKysrKysrKysrKysrKy0t
LS0tLS0tLQogMSBmaWxlcyBjaGFuZ2VkLCAxOCBpbnNlcnRpb25zKCspLCA5IGRlbGV0aW9ucygt
KQoKZGlmZiAtLWdpdCBhL25ldC91bml4L2FmX3VuaXguYyBiL25ldC91bml4L2FmX3VuaXguYwpp
bmRleCBlNmQ5ZDEwLi5mNmQ3ZWQ3IDEwMDY0NAotLS0gYS9uZXQvdW5peC9hZl91bml4LmMKKysr
IGIvbmV0L3VuaXgvYWZfdW5peC5jCkBAIC0xNTc3LDYgKzE1NzcsNyBAQCBzdGF0aWMgaW50IHVu
aXhfc3RyZWFtX3NlbmRtc2coc3RydWN0IGtpb2NiICpraW9jYiwgc3RydWN0IHNvY2tldCAqc29j
aywKIAlpbnQgc2VudCA9IDA7CiAJc3RydWN0IHNjbV9jb29raWUgdG1wX3NjbTsKIAlib29sIGZk
c19zZW50ID0gZmFsc2U7CisJYm9vbCBzY21fcmVmID0gdHJ1ZTsKIAlpbnQgbWF4X2xldmVsOwog
CiAJaWYgKE5VTEwgPT0gc2lvY2ItPnNjbSkKQEAgLTE2MzcsMTIgKzE2MzgsMTkgQEAgc3RhdGlj
IGludCB1bml4X3N0cmVhbV9zZW5kbXNnKHN0cnVjdCBraW9jYiAqa2lvY2IsIHN0cnVjdCBzb2Nr
ZXQgKnNvY2ssCiAJCSAqLwogCQlzaXplID0gbWluX3QoaW50LCBzaXplLCBza2JfdGFpbHJvb20o
c2tiKSk7CiAKKwkJLyoKKwkJICogcGFzcyB0aGUgc2NtIHJlZmVyZW5jZSB0byB0aGUgc2tiIGlm
IGEgc2luZ2xlIHNrYiBpcyBsYXJnZQorCQkgKiBlbm91Z2ggdG8gaG9sZCBhbGwgZGF0YS4KKwkJ
ICovCisJCWlmICghZmRzX3NlbnQgJiYgc2VudCArIHNpemUgPj0gbGVuKQorCQkJc2NtX3JlZiA9
IGZhbHNlOwogCi0JCS8qIE9ubHkgc2VuZCB0aGUgZmRzIGFuZCBubyByZWYgdG8gcGlkIGluIHRo
ZSBmaXJzdCBidWZmZXIgKi8KLQkJZXJyID0gdW5peF9zY21fdG9fc2tiKHNpb2NiLT5zY20sIHNr
YiwgIWZkc19zZW50LCBmZHNfc2VudCk7CisJCS8qIE9ubHkgc2VuZCB0aGUgZmRzIGluIHRoZSBm
aXJzdCBidWZmZXIgKi8KKwkJZXJyID0gdW5peF9zY21fdG9fc2tiKHNpb2NiLT5zY20sIHNrYiwg
IWZkc19zZW50LAorCQkJCQlmZHNfc2VudCB8fCBzY21fcmVmKTsKIAkJaWYgKGVyciA8IDApIHsK
IAkJCWtmcmVlX3NrYihza2IpOwotCQkJZ290byBvdXQ7CisJCQlnb3RvIG91dF9lcnI7CiAJCX0K
IAkJbWF4X2xldmVsID0gZXJyICsgMTsKIAkJZmRzX3NlbnQgPSB0cnVlOwpAQCAtMTY1MCw3ICsx
NjU4LDcgQEAgc3RhdGljIGludCB1bml4X3N0cmVhbV9zZW5kbXNnKHN0cnVjdCBraW9jYiAqa2lv
Y2IsIHN0cnVjdCBzb2NrZXQgKnNvY2ssCiAJCWVyciA9IG1lbWNweV9mcm9taW92ZWMoc2tiX3B1
dChza2IsIHNpemUpLCBtc2ctPm1zZ19pb3YsIHNpemUpOwogCQlpZiAoZXJyKSB7CiAJCQlrZnJl
ZV9za2Ioc2tiKTsKLQkJCWdvdG8gb3V0OworCQkJZ290byBvdXRfZXJyOwogCQl9CiAKIAkJdW5p
eF9zdGF0ZV9sb2NrKG90aGVyKTsKQEAgLTE2NjcsMTAgKzE2NzUsMTAgQEAgc3RhdGljIGludCB1
bml4X3N0cmVhbV9zZW5kbXNnKHN0cnVjdCBraW9jYiAqa2lvY2IsIHN0cnVjdCBzb2NrZXQgKnNv
Y2ssCiAJCXNlbnQgKz0gc2l6ZTsKIAl9CiAKLQlpZiAoc2tiKQotCQlzY21fcmVsZWFzZShzaW9j
Yi0+c2NtKTsKLQllbHNlCisJaWYgKHNjbV9yZWYpCiAJCXNjbV9kZXN0cm95KHNpb2NiLT5zY20p
OworCWVsc2UKKwkJc2NtX3JlbGVhc2Uoc2lvY2ItPnNjbSk7CiAJc2lvY2ItPnNjbSA9IE5VTEw7
CiAKIAlyZXR1cm4gc2VudDsKQEAgLTE2ODMsOSArMTY5MSwxMCBAQCBwaXBlX2VycjoKIAkJc2Vu
ZF9zaWcoU0lHUElQRSwgY3VycmVudCwgMCk7CiAJZXJyID0gLUVQSVBFOwogb3V0X2VycjoKLQlp
ZiAoc2tiID09IE5VTEwpCisJaWYgKHNjbV9yZWYpCiAJCXNjbV9kZXN0cm95KHNpb2NiLT5zY20p
Owotb3V0OgorCWVsc2UKKwkJc2NtX3JlbGVhc2Uoc2lvY2ItPnNjbSk7CiAJc2lvY2ItPnNjbSA9
IE5VTEw7CiAJcmV0dXJuIHNlbnQgPyA6IGVycjsKIH0KLS0gCjEuNy42Cgo=
--0016e652f4283e1cda04ac09b8b2--
