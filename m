From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] udp: Introduce special NULL pointers for hlist termination
Date: Fri, 31 Oct 2008 15:37:50 +0100
Message-ID: <490B183E.3010707@cosmosbay.com>
References: <4908627C.6030001@acm.org>	<490874F2.2060306@cosmosbay.com> <49088288.6050805@acm.org>	<49088AD1.7040805@cosmosbay.com> <20081029163739.GB6732@linux.vnet.ibm.com>	<49089BE5.3090705@acm.org> <4908A134.4040705@cosmosbay.com>	<4908AB3F.1060003@acm.org> <20081029185200.GE6732@linux.vnet.ibm.com>	<4908C0CD.5050406@cosmosbay.com> <20081029201759.GF6732@linux.vnet.ibm.com>	<4908DEDE.5030706@cosmosbay.com> <4909D551.9080309@cosmosbay.com> <20081030085126.0d9b956b@extreme> <4909E0A4.7060009@acm.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000907070408060603040604"
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	paulmck@linux.vnet.ibm.com, benny+usenet@amorsen.dk,
	netdev@vger.kernel.org,
	Christoph Lameter <cl@linux-foundation.org>,
	a.p.zijlstra@chello.nl, johnpol@2ka.mipt.ru,
	Christian Bell <christian@myri.com>,
	Pavel Emelyanov <xemul@openvz.org>
To: Corey Minyard <minyard@acm.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:43723 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750978AbYJaOoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2008 10:44:54 -0400
In-Reply-To: <4909E0A4.7060009@acm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000907070408060603040604
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable

Corey Minyard a =C3=A9crit :
 =20
>=20
> It is annoying that it doesn't help the performance for multicast. =20
> However, I think the current patch will solve the DOS issue for=20
> multicast, since it switches to a normal spinlock and has a per-list lo=
ck.

About multicast, it should be possible to do something about it, if it ha=
ppens
to be an issue.

That is, do a lockless lookup and accumulate matching sockets ptr in a ta=
ble

(incrementing their refcount if not zero, checking key, adding in a local=
 stack).

If lookup must be restarted, forget all accumulated sockets (sock_put(ptr=
s))
   goto begin;

Then, send the (cloned) packet to all accumulated sockets, and
 sock_put() them to release the refcount.



Well, looking at current implementation, I found that udp_v4_mcast_next()=

doesnt take into account the 'struct net *net', so we have a bug here...

udp_v6_mcast_next() is buggy too (or at least its caller is)

David, please find a patch against net-2.6

Thanks

[PATCH] udp: multicast packets need to check namespace

Current UDP multicast delivery is not namespace aware.


Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 net/ipv4/udp.c |   14 ++++++++------
 net/ipv6/udp.c |    8 ++++----
 2 files changed, 12 insertions(+), 10 deletions(-)

--------------000907070408060603040604
Content-Type: text/plain;
 name="udp_multi.patch"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="udp_multi.patch"

ZGlmZiAtLWdpdCBhL25ldC9pcHY0L3VkcC5jIGIvbmV0L2lwdjQvdWRwLmMKaW5kZXggMjA5
NWFiYy4uNzZlM2NjNSAxMDA2NDQKLS0tIGEvbmV0L2lwdjQvdWRwLmMKKysrIGIvbmV0L2lw
djQvdWRwLmMKQEAgLTI4NCw3ICsyODQsNyBAQCBzdHJ1Y3Qgc29jayAqdWRwNF9saWJfbG9v
a3VwKHN0cnVjdCBuZXQgKm5ldCwgX19iZTMyIHNhZGRyLCBfX2JlMTYgc3BvcnQsCiB9CiBF
WFBPUlRfU1lNQk9MX0dQTCh1ZHA0X2xpYl9sb29rdXApOwogCi1zdGF0aWMgaW5saW5lIHN0
cnVjdCBzb2NrICp1ZHBfdjRfbWNhc3RfbmV4dChzdHJ1Y3Qgc29jayAqc2ssCitzdGF0aWMg
aW5saW5lIHN0cnVjdCBzb2NrICp1ZHBfdjRfbWNhc3RfbmV4dChzdHJ1Y3QgbmV0ICpuZXQs
IHN0cnVjdCBzb2NrICpzaywKIAkJCQkJICAgICBfX2JlMTYgbG9jX3BvcnQsIF9fYmUzMiBs
b2NfYWRkciwKIAkJCQkJICAgICBfX2JlMTYgcm10X3BvcnQsIF9fYmUzMiBybXRfYWRkciwK
IAkJCQkJICAgICBpbnQgZGlmKQpAQCAtMjk1LDggKzI5NSw5IEBAIHN0YXRpYyBpbmxpbmUg
c3RydWN0IHNvY2sgKnVkcF92NF9tY2FzdF9uZXh0KHN0cnVjdCBzb2NrICpzaywKIAogCXNr
X2Zvcl9lYWNoX2Zyb20ocywgbm9kZSkgewogCQlzdHJ1Y3QgaW5ldF9zb2NrICppbmV0ID0g
aW5ldF9zayhzKTsKLQotCQlpZiAocy0+c2tfaGFzaCAhPSBobnVtCQkJCQl8fAorCQorCQlp
ZiAoIW5ldF9lcShzb2NrX25ldChzKSwgbmV0KQkJCQl8fAorCQkgICAgcy0+c2tfaGFzaCAh
PSBobnVtCQkJCQl8fAogCQkgICAgKGluZXQtPmRhZGRyICYmIGluZXQtPmRhZGRyICE9IHJt
dF9hZGRyKQkJfHwKIAkJICAgIChpbmV0LT5kcG9ydCAhPSBybXRfcG9ydCAmJiBpbmV0LT5k
cG9ydCkJCXx8CiAJCSAgICAoaW5ldC0+cmN2X3NhZGRyICYmIGluZXQtPnJjdl9zYWRkciAh
PSBsb2NfYWRkcikJfHwKQEAgLTEwNzksMTUgKzEwODAsMTYgQEAgc3RhdGljIGludCBfX3Vk
cDRfbGliX21jYXN0X2RlbGl2ZXIoc3RydWN0IG5ldCAqbmV0LCBzdHJ1Y3Qgc2tfYnVmZiAq
c2tiLAogCXJlYWRfbG9jaygmdWRwX2hhc2hfbG9jayk7CiAJc2sgPSBza19oZWFkKCZ1ZHB0
YWJsZVt1ZHBfaGFzaGZuKG5ldCwgbnRvaHModWgtPmRlc3QpKV0pOwogCWRpZiA9IHNrYi0+
ZGV2LT5pZmluZGV4OwotCXNrID0gdWRwX3Y0X21jYXN0X25leHQoc2ssIHVoLT5kZXN0LCBk
YWRkciwgdWgtPnNvdXJjZSwgc2FkZHIsIGRpZik7CisJc2sgPSB1ZHBfdjRfbWNhc3RfbmV4
dChuZXQsIHNrLCB1aC0+ZGVzdCwgZGFkZHIsIHVoLT5zb3VyY2UsIHNhZGRyLCBkaWYpOwog
CWlmIChzaykgewogCQlzdHJ1Y3Qgc29jayAqc2tuZXh0ID0gTlVMTDsKIAogCQlkbyB7CiAJ
CQlzdHJ1Y3Qgc2tfYnVmZiAqc2tiMSA9IHNrYjsKIAotCQkJc2tuZXh0ID0gdWRwX3Y0X21j
YXN0X25leHQoc2tfbmV4dChzayksIHVoLT5kZXN0LCBkYWRkciwKLQkJCQkJCSAgIHVoLT5z
b3VyY2UsIHNhZGRyLCBkaWYpOworCQkJc2tuZXh0ID0gdWRwX3Y0X21jYXN0X25leHQobmV0
LCBza19uZXh0KHNrKSwgdWgtPmRlc3QsCisJCQkJCQkgICBkYWRkciwgdWgtPnNvdXJjZSwg
c2FkZHIsCisJCQkJCQkgICBkaWYpOwogCQkJaWYgKHNrbmV4dCkKIAkJCQlza2IxID0gc2ti
X2Nsb25lKHNrYiwgR0ZQX0FUT01JQyk7CiAKZGlmZiAtLWdpdCBhL25ldC9pcHY2L3VkcC5j
IGIvbmV0L2lwdjYvdWRwLmMKaW5kZXggZTUxZGE4Yy4uNzFlMjU5ZSAxMDA2NDQKLS0tIGEv
bmV0L2lwdjYvdWRwLmMKKysrIGIvbmV0L2lwdjYvdWRwLmMKQEAgLTMyOCw3ICszMjgsNyBA
QCBkcm9wOgogCXJldHVybiAtMTsKIH0KIAotc3RhdGljIHN0cnVjdCBzb2NrICp1ZHBfdjZf
bWNhc3RfbmV4dChzdHJ1Y3Qgc29jayAqc2ssCitzdGF0aWMgc3RydWN0IHNvY2sgKnVkcF92
Nl9tY2FzdF9uZXh0KHN0cnVjdCBuZXQgKm5ldCwgc3RydWN0IHNvY2sgKnNrLAogCQkJCSAg
ICAgIF9fYmUxNiBsb2NfcG9ydCwgc3RydWN0IGluNl9hZGRyICpsb2NfYWRkciwKIAkJCQkg
ICAgICBfX2JlMTYgcm10X3BvcnQsIHN0cnVjdCBpbjZfYWRkciAqcm10X2FkZHIsCiAJCQkJ
ICAgICAgaW50IGRpZikKQEAgLTM0MCw3ICszNDAsNyBAQCBzdGF0aWMgc3RydWN0IHNvY2sg
KnVkcF92Nl9tY2FzdF9uZXh0KHN0cnVjdCBzb2NrICpzaywKIAlza19mb3JfZWFjaF9mcm9t
KHMsIG5vZGUpIHsKIAkJc3RydWN0IGluZXRfc29jayAqaW5ldCA9IGluZXRfc2socyk7CiAK
LQkJaWYgKHNvY2tfbmV0KHMpICE9IHNvY2tfbmV0KHNrKSkKKwkJaWYgKCFuZXRfZXEoc29j
a19uZXQocyksIG5ldCkpCiAJCQljb250aW51ZTsKIAogCQlpZiAocy0+c2tfaGFzaCA9PSBu
dW0gJiYgcy0+c2tfZmFtaWx5ID09IFBGX0lORVQ2KSB7CkBAIC0zODMsMTQgKzM4MywxNCBA
QCBzdGF0aWMgaW50IF9fdWRwNl9saWJfbWNhc3RfZGVsaXZlcihzdHJ1Y3QgbmV0ICpuZXQs
IHN0cnVjdCBza19idWZmICpza2IsCiAJcmVhZF9sb2NrKCZ1ZHBfaGFzaF9sb2NrKTsKIAlz
ayA9IHNrX2hlYWQoJnVkcHRhYmxlW3VkcF9oYXNoZm4obmV0LCBudG9ocyh1aC0+ZGVzdCkp
XSk7CiAJZGlmID0gaW5ldDZfaWlmKHNrYik7Ci0Jc2sgPSB1ZHBfdjZfbWNhc3RfbmV4dChz
aywgdWgtPmRlc3QsIGRhZGRyLCB1aC0+c291cmNlLCBzYWRkciwgZGlmKTsKKwlzayA9IHVk
cF92Nl9tY2FzdF9uZXh0KG5ldCwgc2ssIHVoLT5kZXN0LCBkYWRkciwgdWgtPnNvdXJjZSwg
c2FkZHIsIGRpZik7CiAJaWYgKCFzaykgewogCQlrZnJlZV9za2Ioc2tiKTsKIAkJZ290byBv
dXQ7CiAJfQogCiAJc2syID0gc2s7Ci0Jd2hpbGUgKChzazIgPSB1ZHBfdjZfbWNhc3RfbmV4
dChza19uZXh0KHNrMiksIHVoLT5kZXN0LCBkYWRkciwKKwl3aGlsZSAoKHNrMiA9IHVkcF92
Nl9tY2FzdF9uZXh0KG5ldCwgc2tfbmV4dChzazIpLCB1aC0+ZGVzdCwgZGFkZHIsCiAJCQkJ
CXVoLT5zb3VyY2UsIHNhZGRyLCBkaWYpKSkgewogCQlzdHJ1Y3Qgc2tfYnVmZiAqYnVmZiA9
IHNrYl9jbG9uZShza2IsIEdGUF9BVE9NSUMpOwogCQlpZiAoYnVmZikgewo=
--------------000907070408060603040604--
