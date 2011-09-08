From: Sedat Dilek <sedat.dilek@googlemail.com>
Subject: Re: [PATCH -next v2] unix stream: Fix use-after-free crashes
Date: Thu, 8 Sep 2011 09:02:43 +0200
Message-ID: <CA+icZUXEBiEYMLnZ25bw8y4i4OSZQYLxxocZZtAcMDg=UnvCGQ@mail.gmail.com>
References: <4E631032.6050606@intel.com>
	<1315326326.2576.2980.camel@schen9-DESK>
	<1315330805.2899.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1315335019.2576.3048.camel@schen9-DESK>
	<1315335660.3400.7.camel@edumazet-laptop>
	<1315337580.2576.3066.camel@schen9-DESK>
	<1315338186.3400.20.camel@edumazet-laptop>
	<1315339157.2576.3079.camel@schen9-DESK>
	<1315340388.3400.28.camel@edumazet-laptop>
	<CAAM7YAn0c0SpAD42PcT+-HDXjT9HMajhmfZD6D68_0E21i2tSQ@mail.gmail.com>
	<1315372100.3400.76.camel@edumazet-laptop>
	<4E66FF38.9000107@intel.com>
	<1315381503.3400.85.camel@edumazet-laptop>
	<1315396903.2364.23.camel@schen9-mobl>
	<CA+icZUVqJVn4ONuSDV5YdgpEcmetVMM9X=Sxt2EqM8qdegMnjQ@mail.gmail.com>
	<CA+icZUW5Biu8cMhaJcz=MwtMOVn-NFD92PTpT0-DfEDKrRmaUQ@mail.gmail.com>
	<1315406256.6287.7.camel@schen9-mobl>
	<4E680BF1.8000901@intel.com>
	<1315429583.2361.3.camel@schen9-mobl>
	<1315461572.2532.7.camel@edumazet-laptop>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=0016367f9444b899d604ac68a516
Cc: Tim Chen <tim.c.chen@linux.intel.com>,
	"Yan, Zheng" <zheng.z.yan@intel.com>,
	"Yan, Zheng" <yanzheng@21cn.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"jirislaby@gmail.com" <jirislaby@gmail.com>,
	"Shi, Alex" <alex.shi@intel.com>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f42.google.com ([209.85.216.42]:45773 "EHLO
	mail-qw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755551Ab1IHHCo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2011 03:02:44 -0400
Received: by qwi4 with SMTP id 4so419986qwi.1
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2011 00:02:43 -0700 (PDT)
In-Reply-To: <1315461572.2532.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0016367f9444b899d604ac68a516
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Thu, Sep 8, 2011 at 7:59 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote=
:
> Le mercredi 07 septembre 2011 =C3=A0 14:06 -0700, Tim Chen a =C3=A9crit :
>> On Thu, 2011-09-08 at 08:27 +0800, Yan, Zheng wrote:
>>
>> > > =C2=A0 err =3D -EPIPE;
>> > > =C2=A0out_err:
>> > > - if (skb =3D=3D NULL)
>> > > + if (!steal_refs)
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 scm_destroy(siocb->scm);
>> >
>> > I think we should call scm_release() here in the case of
>> > steal_refs =3D=3D true. Otherwise siocb->scm->fp may leak.
>>
>> Yan Zheng,
>>
>> I've updated the patch. =C2=A0If it looks good to you now, can you add y=
our
>> Signed-off-by to the patch. =C2=A0Pending Sedat's testing on this patch,
>> I think it is good to go.
>>
>> Tim
>>
>> ---
>> Commit 0856a30409 (Scm: Remove unnecessary pid & credential references
>> in Unix socket's send and receive path) introduced a use-after-free bug.
>> The sent skbs from unix_stream_sendmsg could be consumed and destructed
>> by the receive side, removing all references to the credentials,
>> before the send side has finished sending out all
>> packets. However, send side could continue to consturct new packets in t=
he
>> stream, using credentials that have lost its last reference and been
>> freed.
>>
>> In this fix, we don't steal the reference to credentials we have obtaine=
d
>> in scm_send at beginning of unix_stream_sendmsg, till we've reached
>> the last packet. =C2=A0This fixes the problem in commit 0856a30409.
>>
>> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
>> Reported-by: Jiri Slaby <jirislaby@gmail.com>
>> Tested-by: Sedat Dilek <sedat.dilek@googlemail.com>
>> Tested-by: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
>> ---
>> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
>> index 136298c..47780dc 100644
>> --- a/net/unix/af_unix.c
>> +++ b/net/unix/af_unix.c
>> @@ -1383,10 +1383,11 @@ static int unix_attach_fds(struct scm_cookie *sc=
m, struct sk_buff *skb)
>> =C2=A0}
>>
>> =C2=A0static int unix_scm_to_skb(struct scm_cookie *scm, struct sk_buff =
*skb,
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0bool send_fds, bool ref)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0bool send_fds, bool steal_refs)
>> =C2=A0{
>> =C2=A0 =C2=A0 =C2=A0 int err =3D 0;
>> - =C2=A0 =C2=A0 if (ref) {
>> +
>> + =C2=A0 =C2=A0 if (!steal_refs) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 UNIXCB(skb).pid =C2=A0=
=3D get_pid(scm->pid);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 UNIXCB(skb).cred =3D ge=
t_cred(scm->cred);
>> =C2=A0 =C2=A0 =C2=A0 } else {
>> @@ -1458,7 +1459,7 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb,=
 struct socket *sock,
>> =C2=A0 =C2=A0 =C2=A0 if (skb =3D=3D NULL)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;
>>
>> - =C2=A0 =C2=A0 err =3D unix_scm_to_skb(siocb->scm, skb, true, false);
>> + =C2=A0 =C2=A0 err =3D unix_scm_to_skb(siocb->scm, skb, true, true);
>> =C2=A0 =C2=A0 =C2=A0 if (err < 0)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out_free;
>> =C2=A0 =C2=A0 =C2=A0 max_level =3D err + 1;
>> @@ -1581,6 +1582,7 @@ static int unix_stream_sendmsg(struct kiocb *kiocb=
, struct socket *sock,
>> =C2=A0 =C2=A0 =C2=A0 int sent =3D 0;
>> =C2=A0 =C2=A0 =C2=A0 struct scm_cookie tmp_scm;
>> =C2=A0 =C2=A0 =C2=A0 bool fds_sent =3D false;
>> + =C2=A0 =C2=A0 bool steal_refs =3D false;
>> =C2=A0 =C2=A0 =C2=A0 int max_level;
>>
>> =C2=A0 =C2=A0 =C2=A0 if (NULL =3D=3D siocb->scm)
>> @@ -1642,11 +1644,14 @@ static int unix_stream_sendmsg(struct kiocb *kio=
cb, struct socket *sock,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 size =3D min_t(int, siz=
e, skb_tailroom(skb));
>>
>>
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Only send the fds and no =
ref to pid in the first buffer */
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 err =3D unix_scm_to_skb(sioc=
b->scm, skb, !fds_sent, fds_sent);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Only send the fds in firs=
t buffer
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* Last buffer can stea=
l our references to pid/cred
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 steal_refs =3D (sent + size =
>=3D len);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 err =3D unix_scm_to_skb(sioc=
b->scm, skb, !fds_sent, steal_refs);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (err < 0) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 kfree_skb(skb);
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
goto out;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
goto out_err;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 max_level =3D err + 1;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 fds_sent =3D true;
>> @@ -1654,7 +1659,7 @@ static int unix_stream_sendmsg(struct kiocb *kiocb=
, struct socket *sock,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 err =3D memcpy_fromiove=
c(skb_put(skb, size), msg->msg_iov, size);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (err) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 kfree_skb(skb);
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
goto out;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
goto out_err;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unix_state_lock(other);
>> @@ -1671,7 +1676,7 @@ static int unix_stream_sendmsg(struct kiocb *kiocb=
, struct socket *sock,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sent +=3D size;
>> =C2=A0 =C2=A0 =C2=A0 }
>>
>> - =C2=A0 =C2=A0 if (skb)
>> + =C2=A0 =C2=A0 if (steal_refs)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 scm_release(siocb->scm)=
;
>> =C2=A0 =C2=A0 =C2=A0 else
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 scm_destroy(siocb->scm)=
;
>> @@ -1687,9 +1692,10 @@ pipe_err:
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 send_sig(SIGPIPE, curre=
nt, 0);
>> =C2=A0 =C2=A0 =C2=A0 err =3D -EPIPE;
>> =C2=A0out_err:
>> - =C2=A0 =C2=A0 if (skb =3D=3D NULL)
>> + =C2=A0 =C2=A0 if (steal_refs)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 scm_release(siocb->scm);
>> + =C2=A0 =C2=A0 else
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 scm_destroy(siocb->scm)=
;
>> -out:
>> =C2=A0 =C2=A0 =C2=A0 siocb->scm =3D NULL;
>> =C2=A0 =C2=A0 =C2=A0 return sent ? : err;
>> =C2=A0}
>>
>>
>>
>
> I dont think this patch is good.
>
> Sedat traces have nothing to do with af_unix.
>
> Once unix_scm_to_skb() was called and successful, and steal_refs is true
> our refs are attached to this skb. They will be released by
> skb_free(skb). Same for fp : They either were sent in a previous skb or
> this one.
>
> This is why the "goto out;" was OK.
>

Good morning,

/me sees so many patches :-).
Yes, I guess the patch by Eric has nothing to do with seen
call-traces, adding "irqpoll" to Kernel command line seems to fix them
(my uptime: approx. 10:30, Eric's proposal patch in my last
patch-series is attached).

- Sedat -

--0016367f9444b899d604ac68a516
Content-Type: text/x-diff; charset=US-ASCII;
	name="unix-stream-Fix-use-after-free-crashes-by-edumazet.patch"
Content-Disposition: attachment;
	filename="unix-stream-Fix-use-after-free-crashes-by-edumazet.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gsbe07an0

Q29tbWl0IDA4NTZhMzA0MDkgKFNjbTogUmVtb3ZlIHVubmVjZXNzYXJ5IHBpZCAmIGNyZWRlbnRp
YWwgcmVmZXJlbmNlcwppbiBVbml4IHNvY2tldCdzIHNlbmQgYW5kIHJlY2VpdmUgcGF0aCkgaW50
cm9kdWNlZCBhIHVzZS1hZnRlci1mcmVlIGJ1Zy4KVGhlIHNlbnQgc2ticyBmcm9tIHVuaXhfc3Ry
ZWFtX3NlbmRtc2cgY291bGQgYmUgY29uc3VtZWQgYW5kIGRlc3RydWN0ZWQgCmJ5IHRoZSByZWNl
aXZlIHNpZGUsIHJlbW92aW5nIGFsbCByZWZlcmVuY2VzIHRvIHRoZSBjcmVkZW50aWFscywgCmJl
Zm9yZSB0aGUgc2VuZCBzaWRlIGhhcyBmaW5pc2hlZCBzZW5kaW5nIG91dCBhbGwgCnBhY2tldHMu
IEhvd2V2ZXIsIHNlbmQgc2lkZSBjb3VsZCBjb250aW51ZSB0byBjb25zdHVyY3QgbmV3IHBhY2tl
dHMgaW4gdGhlIApzdHJlYW0sIHVzaW5nIGNyZWRlbnRpYWxzIHRoYXQgaGF2ZSBsb3N0IGl0cyBs
YXN0IHJlZmVyZW5jZSBhbmQgYmVlbgpmcmVlZC4gIAoKSW4gdGhpcyBmaXgsIHdlIGRvbid0IHN0
ZWFsIHRoZSByZWZlcmVuY2UgdG8gY3JlZGVudGlhbHMgd2UgaGF2ZSBvYnRhaW5lZCAKaW4gc2Nt
X3NlbmQgYXQgYmVnaW5uaW5nIG9mIHVuaXhfc3RyZWFtX3NlbmRtc2csIHRpbGwgd2UndmUgcmVh
Y2hlZAp0aGUgbGFzdCBwYWNrZXQuICBUaGlzIGZpeGVzIHRoZSBwcm9ibGVtIGluIGNvbW1pdCAw
ODU2YTMwNDA5LgoKU2lnbmVkLW9mZi1ieTogVGltIENoZW4gPHRpbS5jLmNoZW5AbGludXguaW50
ZWwuY29tPgpSZXBvcnRlZC1ieTogSmlyaSBTbGFieSA8amlyaXNsYWJ5QGdtYWlsLmNvbT4KVGVz
dGVkLWJ5OiBTZWRhdCBEaWxlayA8c2VkYXQuZGlsZWtAZ29vZ2xlbWFpbC5jb20+ClRlc3RlZC1i
eTogVmFsZGlzIEtsZXRuaWVrcyA8VmFsZGlzLktsZXRuaWVrc0B2dC5lZHU+Ci0tLQoKZGlmZiAt
LWdpdCBhL25ldC91bml4L2FmX3VuaXguYyBiL25ldC91bml4L2FmX3VuaXguYwppbmRleCAxMzYy
OThjLi40YTMyNGEwIDEwMDY0NAotLS0gYS9uZXQvdW5peC9hZl91bml4LmMKKysrIGIvbmV0L3Vu
aXgvYWZfdW5peC5jCkBAIC0xMzgzLDEwICsxMzgzLDExIEBAIHN0YXRpYyBpbnQgdW5peF9hdHRh
Y2hfZmRzKHN0cnVjdCBzY21fY29va2llICpzY20sIHN0cnVjdCBza19idWZmICpza2IpCiB9CiAK
IHN0YXRpYyBpbnQgdW5peF9zY21fdG9fc2tiKHN0cnVjdCBzY21fY29va2llICpzY20sIHN0cnVj
dCBza19idWZmICpza2IsCi0JCQkgICBib29sIHNlbmRfZmRzLCBib29sIHJlZikKKwkJCSAgIGJv
b2wgc2VuZF9mZHMsIGJvb2wgc3RlYWxfcmVmcykKIHsKIAlpbnQgZXJyID0gMDsKLQlpZiAocmVm
KSB7CisKKwlpZiAoIXN0ZWFsX3JlZnMpIHsKIAkJVU5JWENCKHNrYikucGlkICA9IGdldF9waWQo
c2NtLT5waWQpOwogCQlVTklYQ0Ioc2tiKS5jcmVkID0gZ2V0X2NyZWQoc2NtLT5jcmVkKTsKIAl9
IGVsc2UgewpAQCAtMTQ1OCw3ICsxNDU5LDcgQEAgc3RhdGljIGludCB1bml4X2RncmFtX3NlbmRt
c2coc3RydWN0IGtpb2NiICpraW9jYiwgc3RydWN0IHNvY2tldCAqc29jaywKIAlpZiAoc2tiID09
IE5VTEwpCiAJCWdvdG8gb3V0OwogCi0JZXJyID0gdW5peF9zY21fdG9fc2tiKHNpb2NiLT5zY20s
IHNrYiwgdHJ1ZSwgZmFsc2UpOworCWVyciA9IHVuaXhfc2NtX3RvX3NrYihzaW9jYi0+c2NtLCBz
a2IsIHRydWUsIHRydWUpOwogCWlmIChlcnIgPCAwKQogCQlnb3RvIG91dF9mcmVlOwogCW1heF9s
ZXZlbCA9IGVyciArIDE7CkBAIC0xNTgxLDYgKzE1ODIsNyBAQCBzdGF0aWMgaW50IHVuaXhfc3Ry
ZWFtX3NlbmRtc2coc3RydWN0IGtpb2NiICpraW9jYiwgc3RydWN0IHNvY2tldCAqc29jaywKIAlp
bnQgc2VudCA9IDA7CiAJc3RydWN0IHNjbV9jb29raWUgdG1wX3NjbTsKIAlib29sIGZkc19zZW50
ID0gZmFsc2U7CisJYm9vbCBzdGVhbF9yZWZzID0gZmFsc2U7CiAJaW50IG1heF9sZXZlbDsKIAog
CWlmIChOVUxMID09IHNpb2NiLT5zY20pCkBAIC0xNjQyLDggKzE2NDQsMTEgQEAgc3RhdGljIGlu
dCB1bml4X3N0cmVhbV9zZW5kbXNnKHN0cnVjdCBraW9jYiAqa2lvY2IsIHN0cnVjdCBzb2NrZXQg
KnNvY2ssCiAJCXNpemUgPSBtaW5fdChpbnQsIHNpemUsIHNrYl90YWlscm9vbShza2IpKTsKIAog
Ci0JCS8qIE9ubHkgc2VuZCB0aGUgZmRzIGFuZCBubyByZWYgdG8gcGlkIGluIHRoZSBmaXJzdCBi
dWZmZXIgKi8KLQkJZXJyID0gdW5peF9zY21fdG9fc2tiKHNpb2NiLT5zY20sIHNrYiwgIWZkc19z
ZW50LCBmZHNfc2VudCk7CisJCS8qIE9ubHkgc2VuZCB0aGUgZmRzIGluIGZpcnN0IGJ1ZmZlcgor
CQkgKiBMYXN0IGJ1ZmZlciBjYW4gc3RlYWwgb3VyIHJlZmVyZW5jZXMgdG8gcGlkL2NyZWQKKwkJ
ICovCisJCXN0ZWFsX3JlZnMgPSAoc2VudCArIHNpemUgPj0gbGVuKTsKKwkJZXJyID0gdW5peF9z
Y21fdG9fc2tiKHNpb2NiLT5zY20sIHNrYiwgIWZkc19zZW50LCBzdGVhbF9yZWZzKTsKIAkJaWYg
KGVyciA8IDApIHsKIAkJCWtmcmVlX3NrYihza2IpOwogCQkJZ290byBvdXQ7CkBAIC0xNjcxLDcg
KzE2NzYsNyBAQCBzdGF0aWMgaW50IHVuaXhfc3RyZWFtX3NlbmRtc2coc3RydWN0IGtpb2NiICpr
aW9jYiwgc3RydWN0IHNvY2tldCAqc29jaywKIAkJc2VudCArPSBzaXplOwogCX0KIAotCWlmIChz
a2IpCisJaWYgKHN0ZWFsX3JlZnMpCiAJCXNjbV9yZWxlYXNlKHNpb2NiLT5zY20pOwogCWVsc2UK
IAkJc2NtX2Rlc3Ryb3koc2lvY2ItPnNjbSk7CgoK
--0016367f9444b899d604ac68a516--
