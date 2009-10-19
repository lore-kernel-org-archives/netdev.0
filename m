From: Michal Ostrowski <mostrows@gmail.com>
Subject: Re: kernel panic in latest vanilla stable, while using nameif with
	"alive" pppoe interfaces
Date: Mon, 19 Oct 2009 15:54:20 -0500
Message-ID: <e6d1cecd0910191354o16d023d2lbe2761a97e88acea@mail.gmail.com>
References: <200910190002.39937.denys@visp.net.lb>
	 <e6d1cecd0910182034t9d24859mc6f392875b36ad17@mail.gmail.com>
	 <4ADC5D3B.8010006@gmail.com>
	 <e6d1cecd0910190619t3e009e1by49cc8f7307eb7cdb@mail.gmail.com>
	 <20091019155034.GA5233@lenovo>
	 <e6d1cecd0910190905x382bfc23w2987c84aa0837609@mail.gmail.com>
	 <4ADC9DE2.5010308@gmail.com>
	 <e6d1cecd0910191107h899a4ffs588f2413093dfb4b@mail.gmail.com>
	 <4ADCB3A4.8060408@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=000e0cd211f2236f5804764ff33c
Cc: Cyrill Gorcunov <gorcunov@gmail.com>,
	Denys Fedoryschenko <denys@visp.net.lb>,
	netdev <netdev@vger.kernel.org>, linux-ppp@vger.kernel.org,
	paulus@samba.org, mostrows@earthlink.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f188.google.com ([209.85.222.188]:63145 "EHLO
	mail-pz0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757206AbZJSUyQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2009 16:54:16 -0400
In-Reply-To: <4ADCB3A4.8060408@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--000e0cd211f2236f5804764ff33c
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Access of po->pppoe_dev is guarded by sk->sk_state & PPPOX_CONNECTED,
and all use cases now rely on the socket lock.  Because of this, the
ref-count on the namespace held by the socket object suffices to hold
the namespace in existence and so we don't need to ref-count the
namespace in PPPoE. The flush_lock is gone.

--
Michal Ostrowski
mostrows@gmail.com



On Mon, Oct 19, 2009 at 1:44 PM, Eric Dumazet <eric.dumazet@gmail.com> wrot=
e:
> Michal Ostrowski a =E9crit :
>> On Mon, Oct 19, 2009 at 12:12 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
>>> Michal Ostrowski a =E9crit :
>>>> Here's a bigger patch that just gets rid of flush_lock altogether.
>>>>
>>>> We were seeing oopses due to net namespaces going away while we were u=
sing
>>>> them, which turns out is simply due to the fact that pppoew wasn't cla=
iming ref
>>>> counts properly.
>>>>
>>>> Fixing this requires that adding and removing entries to the per-net h=
ash-table
>>>> requires incrementing and decrementing the ref count. =A0This also all=
ows us to
>>>> get rid of the flush_lock since we can now depend on the existence of
>>>> "pn->hash_lock".
>>>>
>>>> We also have to be careful when flushing devices that removal of a has=
h table
>>>> entry may bring the net namespace refcount to 0.
>>>>
>>> Your patch is mangled (tabulation -> white spaces),
>>
>> Patch mangling was due to mailer interactions, I'll attach a clean
>> version here, no more inlining.
>>
>>> and I dont believe namespace refcount can reach 0 inside pppoe_flush_de=
v(),
>>> it would be a bug from core network code.
>>>
>>
>> From the original oops I was able to deduce that the namespace somehow
>> managed to get destroyed during the interval where we dropped locks.
>> If that's not due to the release_sock() call in pppoe_flush_dev()
>> triggering a cleanup then I'd have to assume that that it's due to a
>> secondary actor closing the socket in parallel, but that in turn would
>> point to issues with the flush_lock. =A0Having said that the thrust of
>> this patch remains valid; it just means I don't need to inc the ref
>> count in pppoe_flush_dev().
>>
>> Do you agree?
>>
>
> Not really :)
>
> I dont believe you should care of namespace, and/or mess with its refcoun=
t at all.
>
> Please dont use maybe_get_net() : This function should not ever be used i=
n drivers/net
>
> You can add a BUG_ON(dev_net(xxxx)->count <=3D 0) if you really want, but=
 if this
> assertion is false, this is not because of pppoe.
>
>
> =A0 =A0 =A0 =A0lock_sock(sk);
> @@ -653,10 +642,12 @@ static int pppoe_connect(struct socket *sock, struc=
t sockaddr *uservaddr,
> =A0 =A0 =A0 =A0if (stage_session(po->pppoe_pa.sid)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pppox_unbind_sock(sk);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (po->pppoe_dev) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pn =3D pppoe_pernet(dev_net=
(po->pppoe_dev));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct net *old =3D dev_net=
(po->pppoe_dev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pn =3D pppoe_pernet(old);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0delete_item(pn, po->pppoe_=
pa.sid,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0po->pppoe_=
pa.remote, po->pppoe_ifindex);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_put(po->pppoe_dev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_net(old);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0memset(sk_pppox(po) + 1, 0,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sizeof(struct pppox_sock) - s=
izeof(struct sock));
>
>
> There is still a race here, since you do a dev_put(po->ppoe_dev); without=
 any lock held
>
> So pppoe_flush_dev() can run concurently and dev_put(po->ppoe_dev) at sam=
e time.
>
> In fact pppoe_flush_dev() can change po->ppoe_dev anytime, so you should =
check
> all occurences of po->ppoe_dev use in the code and check if appropriate l=
ocking is done.
>
> pppoe_rcv_core() is not safe
> pppoe_ioctl() is not safe
> pppoe_sendmsg() is not safe
> __pppoe_xmit() is not safe
>
>

--000e0cd211f2236f5804764ff33c
Content-Type: application/octet-stream;
	name="0001-PPPoE-Fix-flush-close-races.patch"
Content-Disposition: attachment;
	filename="0001-PPPoE-Fix-flush-close-races.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_g0zpeux30

ZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L3BwcG9lLmMgYi9kcml2ZXJzL25ldC9wcHBvZS5jCmlu
ZGV4IDdjYmY2ZjkuLjFkMGI1NjkgMTAwNjQ0Ci0tLSBhL2RyaXZlcnMvbmV0L3BwcG9lLmMKKysr
IGIvZHJpdmVycy9uZXQvcHBwb2UuYwpAQCAtMTExLDkgKzExMSw2IEBAIHN0cnVjdCBwcHBvZV9u
ZXQgewogCXJ3bG9ja190IGhhc2hfbG9jazsKIH07CiAKLS8qIHRvIGVsaW1pbmF0ZSBhIHJhY2Ug
YnR3IHBwcG9lX2ZsdXNoX2RldiBhbmQgcHBwb2VfcmVsZWFzZSAqLwotc3RhdGljIERFRklORV9T
UElOTE9DSyhmbHVzaF9sb2NrKTsKLQogLyoKICAqIFBQUG9FIGNvdWxkIGJlIGluIHRoZSBmb2xs
b3dpbmcgc3RhZ2VzOgogICogMSkgRGlzY292ZXJ5IHN0YWdlICh0byBvYnRhaW4gcmVtb3RlIE1B
QyBhbmQgU2Vzc2lvbiBJRCkKQEAgLTMwMyw0OCArMzAwLDQ2IEBAIHN0YXRpYyB2b2lkIHBwcG9l
X2ZsdXNoX2RldihzdHJ1Y3QgbmV0X2RldmljZSAqZGV2KQogCXdyaXRlX2xvY2tfYmgoJnBuLT5o
YXNoX2xvY2spOwogCWZvciAoaSA9IDA7IGkgPCBQUFBPRV9IQVNIX1NJWkU7IGkrKykgewogCQlz
dHJ1Y3QgcHBwb3hfc29jayAqcG8gPSBwbi0+aGFzaF90YWJsZVtpXTsKKwkJc3RydWN0IHNvY2sg
KnNrOwogCi0JCXdoaWxlIChwbyAhPSBOVUxMKSB7Ci0JCQlzdHJ1Y3Qgc29jayAqc2s7Ci0JCQlp
ZiAocG8tPnBwcG9lX2RldiAhPSBkZXYpIHsKLQkJCQlwbyA9IHBvLT5uZXh0OwotCQkJCWNvbnRp
bnVlOwotCQkJfQotCQkJc2sgPSBza19wcHBveChwbyk7Ci0JCQlzcGluX2xvY2soJmZsdXNoX2xv
Y2spOwotCQkJcG8tPnBwcG9lX2RldiA9IE5VTEw7Ci0JCQlzcGluX3VubG9jaygmZmx1c2hfbG9j
ayk7Ci0JCQlkZXZfcHV0KGRldik7Ci0KLQkJCS8qIFdlIGFsd2F5cyBncmFiIHRoZSBzb2NrZXQg
bG9jaywgZm9sbG93ZWQgYnkgdGhlCi0JCQkgKiBoYXNoX2xvY2ssIGluIHRoYXQgb3JkZXIuICBT
aW5jZSB3ZSBzaG91bGQKLQkJCSAqIGhvbGQgdGhlIHNvY2sgbG9jayB3aGlsZSBkb2luZyBhbnkg
dW5iaW5kaW5nLAotCQkJICogd2UgbmVlZCB0byByZWxlYXNlIHRoZSBsb2NrIHdlJ3JlIGhvbGRp
bmcuCi0JCQkgKiBIb2xkIGEgcmVmZXJlbmNlIHRvIHRoZSBzb2NrIHNvIGl0IGRvZXNuJ3QgZGlz
YXBwZWFyCi0JCQkgKiBhcyB3ZSdyZSBqdW1waW5nIGJldHdlZW4gbG9ja3MuCi0JCQkgKi8KKwkJ
d2hpbGUgKHBvICYmIHBvLT5wcHBvZV9kZXYgIT0gZGV2KSB7CisJCQlwbyA9IHBvLT5uZXh0Owor
CQl9CiAKLQkJCXNvY2tfaG9sZChzayk7CisJCWlmIChwbyA9PSBOVUxMKSB7CisJCQljb250aW51
ZTsKKwkJfQogCi0JCQl3cml0ZV91bmxvY2tfYmgoJnBuLT5oYXNoX2xvY2spOwotCQkJbG9ja19z
b2NrKHNrKTsKKwkJc2sgPSBza19wcHBveChwbyk7CiAKLQkJCWlmIChzay0+c2tfc3RhdGUgJiAo
UFBQT1hfQ09OTkVDVEVEIHwgUFBQT1hfQk9VTkQpKSB7Ci0JCQkJcHBwb3hfdW5iaW5kX3NvY2so
c2spOwotCQkJCXNrLT5za19zdGF0ZSA9IFBQUE9YX1pPTUJJRTsKLQkJCQlzay0+c2tfc3RhdGVf
Y2hhbmdlKHNrKTsKLQkJCX0KKwkJLyogV2UgYWx3YXlzIGdyYWIgdGhlIHNvY2tldCBsb2NrLCBm
b2xsb3dlZCBieSB0aGUgaGFzaF9sb2NrLAorCQkgKiBpbiB0aGF0IG9yZGVyLiAgU2luY2Ugd2Ug
c2hvdWxkIGhvbGQgdGhlIHNvY2sgbG9jayB3aGlsZQorCQkgKiBkb2luZyBhbnkgdW5iaW5kaW5n
LCB3ZSBuZWVkIHRvIHJlbGVhc2UgdGhlIGxvY2sgd2UncmUKKwkJICogaG9sZGluZy4gIEhvbGQg
YSByZWZlcmVuY2UgdG8gdGhlIHNvY2sgc28gaXQgZG9lc24ndAorCQkgKiBkaXNhcHBlYXIgYXMg
d2UncmUganVtcGluZyBiZXR3ZWVuIGxvY2tzLgorCQkgKi8KIAotCQkJcmVsZWFzZV9zb2NrKHNr
KTsKLQkJCXNvY2tfcHV0KHNrKTsKKwkJc29ja19ob2xkKHNrKTsKKwkJd3JpdGVfdW5sb2NrX2Jo
KCZwbi0+aGFzaF9sb2NrKTsKKwkJbG9ja19zb2NrKHNrKTsKIAotCQkJLyogUmVzdGFydCBzY2Fu
IGF0IHRoZSBiZWdpbm5pbmcgb2YgdGhpcyBoYXNoIGNoYWluLgotCQkJICogV2hpbGUgdGhlIGxv
Y2sgd2FzIGRyb3BwZWQgdGhlIGNoYWluIGNvbnRlbnRzIG1heQotCQkJICogaGF2ZSBjaGFuZ2Vk
LgotCQkJICovCi0JCQl3cml0ZV9sb2NrX2JoKCZwbi0+aGFzaF9sb2NrKTsKLQkJCXBvID0gcG4t
Pmhhc2hfdGFibGVbaV07CisJCWlmIChzay0+c2tfc3RhdGUgJiAoUFBQT1hfQ09OTkVDVEVEIHwg
UFBQT1hfQk9VTkQpKSB7CisJCQlwcHBveF91bmJpbmRfc29jayhzayk7CisJCQlzay0+c2tfc3Rh
dGUgPSBQUFBPWF9aT01CSUU7CisJCQlzay0+c2tfc3RhdGVfY2hhbmdlKHNrKTsKKwkJCXBvLT5w
cHBvZV9kZXYgPSBOVUxMOworCQkJZGV2X3B1dChkZXYpOwogCQl9CisKKwkJcmVsZWFzZV9zb2Nr
KHNrKTsKKwkJc29ja19wdXQoc2spOworCisJCS8qIFJlc3RhcnQgdGhlIHByb2Nlc3MgZnJvbSB0
aGUgc3RhcnQgb2YgdGhlIGN1cnJlbnQgaGFzaAorCQkgKiBjaGFpbi4gV2UgZHJvcHBlZCBsb2Nr
cyBzbyB0aGUgd29ybGQgbWF5IGhhdmUgY2hhbmdlIGZyb20KKwkJICogdW5kZXJuZWF0aCB1cy4K
KwkJICovCisJCXdyaXRlX2xvY2tfYmgoJnBuLT5oYXNoX2xvY2spOworCQlwbyA9IHBuLT5oYXNo
X3RhYmxlW2ldOwogCX0KIAl3cml0ZV91bmxvY2tfYmgoJnBuLT5oYXNoX2xvY2spOwogfQpAQCAt
MzkxLDggKzM4Niw4IEBAIHN0YXRpYyBpbnQgcHBwb2VfcmN2X2NvcmUoc3RydWN0IHNvY2sgKnNr
LCBzdHJ1Y3Qgc2tfYnVmZiAqc2tiKQogCWlmIChzay0+c2tfc3RhdGUgJiBQUFBPWF9CT1VORCkg
ewogCQlwcHBfaW5wdXQoJnBvLT5jaGFuLCBza2IpOwogCX0gZWxzZSBpZiAoc2stPnNrX3N0YXRl
ICYgUFBQT1hfUkVMQVkpIHsKLQkJcmVsYXlfcG8gPSBnZXRfaXRlbV9ieV9hZGRyKGRldl9uZXQo
cG8tPnBwcG9lX2RldiksCi0JCQkJCQkmcG8tPnBwcG9lX3JlbGF5KTsKKwkJcmVsYXlfcG8gPSBn
ZXRfaXRlbV9ieV9hZGRyKHNvY2tfbmV0KHNrKSwKKwkJCQkJICAgICZwby0+cHBwb2VfcmVsYXkp
OwogCQlpZiAocmVsYXlfcG8gPT0gTlVMTCkKIAkJCWdvdG8gYWJvcnRfa2ZyZWU7CiAKQEAgLTU2
MSw2ICs1NTYsNyBAQCBzdGF0aWMgaW50IHBwcG9lX3JlbGVhc2Uoc3RydWN0IHNvY2tldCAqc29j
aykKIAlzdHJ1Y3Qgc29jayAqc2sgPSBzb2NrLT5zazsKIAlzdHJ1Y3QgcHBwb3hfc29jayAqcG87
CiAJc3RydWN0IHBwcG9lX25ldCAqcG47CisJc3RydWN0IG5ldCAqbmV0ID0gTlVMTDsKIAogCWlm
ICghc2spCiAJCXJldHVybiAwOwpAQCAtNTcxLDI0ICs1NjcsMTkgQEAgc3RhdGljIGludCBwcHBv
ZV9yZWxlYXNlKHN0cnVjdCBzb2NrZXQgKnNvY2spCiAJCXJldHVybiAtRUJBREY7CiAJfQogCisJ
cG8gPSBwcHBveF9zayhzayk7CisKKwlpZiAoc2stPnNrX3N0YXRlICYgKFBQUE9YX0NPTk5FQ1RF
RCB8IFBQUE9YX0JPVU5EKSkgeworCQlkZXZfcHV0KHBvLT5wcHBvZV9kZXYpOworCX0KKwogCXBw
cG94X3VuYmluZF9zb2NrKHNrKTsKIAogCS8qIFNpZ25hbCB0aGUgZGVhdGggb2YgdGhlIHNvY2tl
dC4gKi8KIAlzay0+c2tfc3RhdGUgPSBQUFBPWF9ERUFEOwogCi0JLyoKLQkgKiBwcHBvZV9mbHVz
aF9kZXYgY291bGQgbGVhZCB0byBhIHJhY2Ugd2l0aAotCSAqIHRoaXMgcm91dGluZSBzbyB3ZSB1
c2UgZmx1c2hfbG9jayB0byBlbGltaW5hdGUKLQkgKiBzdWNoIGEgY2FzZSAod2Ugb25seSBuZWVk
IHBlci1uZXQgc3BlY2lmaWMgZGF0YSkKLQkgKi8KLQlzcGluX2xvY2soJmZsdXNoX2xvY2spOwot
CXBvID0gcHBwb3hfc2soc2spOwotCWlmICghcG8tPnBwcG9lX2RldikgewotCQlzcGluX3VubG9j
aygmZmx1c2hfbG9jayk7Ci0JCWdvdG8gb3V0OwotCX0KLQlwbiA9IHBwcG9lX3Blcm5ldChkZXZf
bmV0KHBvLT5wcHBvZV9kZXYpKTsKLQlzcGluX3VubG9jaygmZmx1c2hfbG9jayk7CisJbmV0ID0g
c29ja19uZXQoc2spOworCXBuID0gcHBwb2VfcGVybmV0KG5ldCk7CiAKIAkvKgogCSAqIHByb3Rl
Y3QgInBvIiBmcm9tIGNvbmN1cnJlbnQgdXBkYXRlcwpAQCAtNTk2LDE5ICs1ODcsMTIgQEAgc3Rh
dGljIGludCBwcHBvZV9yZWxlYXNlKHN0cnVjdCBzb2NrZXQgKnNvY2spCiAJICovCiAJd3JpdGVf
bG9ja19iaCgmcG4tPmhhc2hfbG9jayk7CiAKLQlwbyA9IHBwcG94X3NrKHNrKTsKIAlpZiAoc3Rh
Z2Vfc2Vzc2lvbihwby0+cHBwb2VfcGEuc2lkKSkKIAkJX19kZWxldGVfaXRlbShwbiwgcG8tPnBw
cG9lX3BhLnNpZCwgcG8tPnBwcG9lX3BhLnJlbW90ZSwKIAkJCQlwby0+cHBwb2VfaWZpbmRleCk7
CiAKLQlpZiAocG8tPnBwcG9lX2RldikgewotCQlkZXZfcHV0KHBvLT5wcHBvZV9kZXYpOwotCQlw
by0+cHBwb2VfZGV2ID0gTlVMTDsKLQl9Ci0KIAl3cml0ZV91bmxvY2tfYmgoJnBuLT5oYXNoX2xv
Y2spOwogCi1vdXQ6CiAJc29ja19vcnBoYW4oc2spOwogCXNvY2stPnNrID0gTlVMTDsKIApAQCAt
NjI1LDggKzYwOSw5IEBAIHN0YXRpYyBpbnQgcHBwb2VfY29ubmVjdChzdHJ1Y3Qgc29ja2V0ICpz
b2NrLCBzdHJ1Y3Qgc29ja2FkZHIgKnVzZXJ2YWRkciwKIAlzdHJ1Y3Qgc29jayAqc2sgPSBzb2Nr
LT5zazsKIAlzdHJ1Y3Qgc29ja2FkZHJfcHBwb3ggKnNwID0gKHN0cnVjdCBzb2NrYWRkcl9wcHBv
eCAqKXVzZXJ2YWRkcjsKIAlzdHJ1Y3QgcHBwb3hfc29jayAqcG8gPSBwcHBveF9zayhzayk7Ci0J
c3RydWN0IG5ldF9kZXZpY2UgKmRldjsKIAlzdHJ1Y3QgcHBwb2VfbmV0ICpwbjsKKwlzdHJ1Y3Qg
bmV0X2RldmljZSAqZGV2ID0gTlVMTDsKKwlzdHJ1Y3QgbmV0ICpuZXQgPSBOVUxMOwogCWludCBl
cnJvcjsKIAogCWxvY2tfc29jayhzayk7CkBAIC02NTMsMTAgKzYzOCwxMiBAQCBzdGF0aWMgaW50
IHBwcG9lX2Nvbm5lY3Qoc3RydWN0IHNvY2tldCAqc29jaywgc3RydWN0IHNvY2thZGRyICp1c2Vy
dmFkZHIsCiAJaWYgKHN0YWdlX3Nlc3Npb24ocG8tPnBwcG9lX3BhLnNpZCkpIHsKIAkJcHBwb3hf
dW5iaW5kX3NvY2soc2spOwogCQlpZiAocG8tPnBwcG9lX2RldikgewotCQkJcG4gPSBwcHBvZV9w
ZXJuZXQoZGV2X25ldChwby0+cHBwb2VfZGV2KSk7CisJCQlzdHJ1Y3QgbmV0ICpvbGQgPSBkZXZf
bmV0KHBvLT5wcHBvZV9kZXYpOworCQkJcG4gPSBwcHBvZV9wZXJuZXQob2xkKTsKIAkJCWRlbGV0
ZV9pdGVtKHBuLCBwby0+cHBwb2VfcGEuc2lkLAogCQkJCXBvLT5wcHBvZV9wYS5yZW1vdGUsIHBv
LT5wcHBvZV9pZmluZGV4KTsKIAkJCWRldl9wdXQocG8tPnBwcG9lX2Rldik7CisJCQlwby0+cHBw
b2VfZGV2ID0gTlVMTDsKIAkJfQogCQltZW1zZXQoc2tfcHBwb3gocG8pICsgMSwgMCwKIAkJICAg
ICAgIHNpemVvZihzdHJ1Y3QgcHBwb3hfc29jaykgLSBzaXplb2Yoc3RydWN0IHNvY2spKTsKQEAg
LTY2NiwxMyArNjUzLDE0IEBAIHN0YXRpYyBpbnQgcHBwb2VfY29ubmVjdChzdHJ1Y3Qgc29ja2V0
ICpzb2NrLCBzdHJ1Y3Qgc29ja2FkZHIgKnVzZXJ2YWRkciwKIAkvKiBSZS1iaW5kIGluIHNlc3Np
b24gc3RhZ2Ugb25seSAqLwogCWlmIChzdGFnZV9zZXNzaW9uKHNwLT5zYV9hZGRyLnBwcG9lLnNp
ZCkpIHsKIAkJZXJyb3IgPSAtRU5PREVWOwotCQlkZXYgPSBkZXZfZ2V0X2J5X25hbWUoc29ja19u
ZXQoc2spLCBzcC0+c2FfYWRkci5wcHBvZS5kZXYpOworCQluZXQgPSBzb2NrX25ldChzayk7CisJ
CWRldiA9IGRldl9nZXRfYnlfbmFtZShuZXQsIHNwLT5zYV9hZGRyLnBwcG9lLmRldik7CiAJCWlm
ICghZGV2KQotCQkJZ290byBlbmQ7CisJCQlnb3RvIGVycl9wdXQ7CiAKIAkJcG8tPnBwcG9lX2Rl
diA9IGRldjsKIAkJcG8tPnBwcG9lX2lmaW5kZXggPSBkZXYtPmlmaW5kZXg7Ci0JCXBuID0gcHBw
b2VfcGVybmV0KGRldl9uZXQoZGV2KSk7CisJCXBuID0gcHBwb2VfcGVybmV0KG5ldCk7CiAJCXdy
aXRlX2xvY2tfYmgoJnBuLT5oYXNoX2xvY2spOwogCQlpZiAoIShkZXYtPmZsYWdzICYgSUZGX1VQ
KSkgewogCQkJd3JpdGVfdW5sb2NrX2JoKCZwbi0+aGFzaF9sb2NrKTsKQEAgLTkxNSw2ICs5MDMs
OCBAQCBzdGF0aWMgaW50IF9fcHBwb2VfeG1pdChzdHJ1Y3Qgc29jayAqc2ssIHN0cnVjdCBza19i
dWZmICpza2IpCiAJc3RydWN0IHBwcG9lX2hkciAqcGg7CiAJaW50IGRhdGFfbGVuID0gc2tiLT5s
ZW47CiAKKwlsb2NrX3NvY2soc2spOworCiAJaWYgKHNvY2tfZmxhZyhzaywgU09DS19ERUFEKSB8
fCAhKHNrLT5za19zdGF0ZSAmIFBQUE9YX0NPTk5FQ1RFRCkpCiAJCWdvdG8gYWJvcnQ7CiAKQEAg
LTk0NCwxMCArOTM0LDExIEBAIHN0YXRpYyBpbnQgX19wcHBvZV94bWl0KHN0cnVjdCBzb2NrICpz
aywgc3RydWN0IHNrX2J1ZmYgKnNrYikKIAkJCXBvLT5wcHBvZV9wYS5yZW1vdGUsIE5VTEwsIGRh
dGFfbGVuKTsKIAogCWRldl9xdWV1ZV94bWl0KHNrYik7Ci0KKwlyZWxlYXNlX3NvY2soc2spOwog
CXJldHVybiAxOwogCiBhYm9ydDoKKwlyZWxlYXNlX3NvY2soc2spOwogCWtmcmVlX3NrYihza2Ip
OwogCXJldHVybiAxOwogfQo=
--000e0cd211f2236f5804764ff33c--
