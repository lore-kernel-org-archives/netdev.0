From: "J. K. Cliburn" <jcliburn@gmail.com>
Subject: Re: atl1 warn_on_slowpath help
Date: Wed, 29 Oct 2008 07:51:51 -0500
Message-ID: <3400f2f60810290551y39c61e0aj90ca1222b339798c@mail.gmail.com>
References: <20081029071549.GA4861@ff.dom.local> <49081AE4.9040301@trash.net>
	 <49083825.3000601@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_4399_4995691.1225284711902"
Cc: "Jarek Poplawski" <jarkao2@gmail.com>, netdev@vger.kernel.org,
	"Ramon Casellas" <ramon.casellas@cttc.es>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:18215 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752756AbYJ2Mvz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 08:51:55 -0400
Received: by nf-out-0910.google.com with SMTP id d3so1255533nfc.21
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 05:51:51 -0700 (PDT)
In-Reply-To: <49083825.3000601@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_4399_4995691.1225284711902
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

[adding bug reporter to cc list]


On Wed, Oct 29, 2008 at 5:17 AM, Patrick McHardy <kaber@trash.net> wrote:
> Patrick McHardy wrote:
>>
>> Jarek Poplawski wrote:
>>>
>>> On 29-10-2008 01:08, Jay Cliburn wrote:
>>>>
>>>> [   27.779463] ------------[ cut here ]------------
>>>> [   27.779509] WARNING: at kernel/softirq.c:136
>>>> local_bh_enable+0x37/0x81()
>>>
>>> ...
>>>>
>>>> [   27.782520]  [<c0264755>] netif_nit_deliver+0x5b/0x75
>>>> [   27.782590]  [<c02bba83>] __vlan_hwaccel_rx+0x79/0x162
>>>> [   27.782664]  [<f8851c1d>] atl1_intr+0x9a9/0xa7c [atl1]
>>>>>
>>>> warn_on_slowpath stuff well enough to know what to look for. Can someone
>>>> please take a quick look at drivers/net/atlx/atl1.c around line 2017
>>>> and see if there's an obvious error?  I'd really appreciate it.
>>>
>>> It looks to me like vlan_hwaccel_rx() is to blame: I doubt we can do
>>> netif_nit_deliver() in hard irq context. (Patrick Cc-ed.)
>>
>> Crap, I didn't think of that, all drivers I tested with support
>> NAPI. I can't think of a clean way to fix it right now, but I'll
>> look into it.
>
> This is the best I could come up with, short of simply restoring
> the old behaviour for non-polling drivers.
>
> The __vlan_hwaccel_rx function only does the device lookup and
> stores it in the cb. The remaining processing is done in a new
> function that is invoked by netif_receive_skb(), in the proper
> context. Unfortunatly this needs vlan-specific handling in
> netif_receive_skb().
>
>

Thanks Jarek and Patrick.

Ramon,

Can you please try the attached patch from Patrick and see if it fixes
your kernel warning?

Thanks,
Jay

------=_Part_4399_4995691.1225284711902
Content-Type: text/x-patch; name=01.diff
Content-Transfer-Encoding: base64
X-Attachment-Id: 0.1
Content-Disposition: attachment; filename=01.diff

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGludXgvaWZfdmxhbi5oIGIvaW5jbHVkZS9saW51eC9pZl92
bGFuLmgKaW5kZXggOWU3YjQ5Yi4uYTVjYjBjMyAxMDA2NDQKLS0tIGEvaW5jbHVkZS9saW51eC9p
Zl92bGFuLmgKKysrIGIvaW5jbHVkZS9saW51eC9pZl92bGFuLmgKQEAgLTExNCw2ICsxMTQsOCBA
QCBleHRlcm4gdTE2IHZsYW5fZGV2X3ZsYW5faWQoY29uc3Qgc3RydWN0IG5ldF9kZXZpY2UgKmRl
dik7CiAKIGV4dGVybiBpbnQgX192bGFuX2h3YWNjZWxfcngoc3RydWN0IHNrX2J1ZmYgKnNrYiwg
c3RydWN0IHZsYW5fZ3JvdXAgKmdycCwKIAkJCSAgICAgdTE2IHZsYW5fdGNpLCBpbnQgcG9sbGlu
Zyk7CitleHRlcm4gaW50IHZsYW5faHdhY2NlbF9kb19yZWNlaXZlKHN0cnVjdCBza19idWZmICpz
a2IpOworCiAjZWxzZQogc3RhdGljIGlubGluZSBzdHJ1Y3QgbmV0X2RldmljZSAqdmxhbl9kZXZf
cmVhbF9kZXYoY29uc3Qgc3RydWN0IG5ldF9kZXZpY2UgKmRldikKIHsKQEAgLTEzMyw2ICsxMzUs
MTEgQEAgc3RhdGljIGlubGluZSBpbnQgX192bGFuX2h3YWNjZWxfcngoc3RydWN0IHNrX2J1ZmYg
KnNrYiwgc3RydWN0IHZsYW5fZ3JvdXAgKmdycCwKIAlCVUcoKTsKIAlyZXR1cm4gTkVUX1hNSVRf
U1VDQ0VTUzsKIH0KKworc3RhdGljIGlubGluZSBpbnQgdmxhbl9od2FjY2VsX2RvX3JlY2VpdmUo
c3RydWN0IHNrX2J1ZmYgKnNrYikKK3sKKwlyZXR1cm4gMDsKK30KICNlbmRpZgogCiAvKioKZGlm
ZiAtLWdpdCBhL25ldC84MDIxcS92bGFuX2NvcmUuYyBiL25ldC84MDIxcS92bGFuX2NvcmUuYwpp
bmRleCA5MTYwNjFmLi42OGNlZDRiIDEwMDY0NAotLS0gYS9uZXQvODAyMXEvdmxhbl9jb3JlLmMK
KysrIGIvbmV0LzgwMjFxL3ZsYW5fY29yZS5jCkBAIC0zLDExICszLDIwIEBACiAjaW5jbHVkZSA8
bGludXgvaWZfdmxhbi5oPgogI2luY2x1ZGUgInZsYW4uaCIKIAorc3RydWN0IHZsYW5faHdhY2Nl
bF9jYiB7CisJc3RydWN0IG5ldF9kZXZpY2UJKmRldjsKK307CisKK3N0YXRpYyBpbmxpbmUgc3Ry
dWN0IHZsYW5faHdhY2NlbF9jYiAqdmxhbl9od2FjY2VsX2NiKHN0cnVjdCBza19idWZmICpza2Ip
Cit7CisJcmV0dXJuIChzdHJ1Y3Qgdmxhbl9od2FjY2VsX2NiICopc2tiLT5jYjsKK30KKwogLyog
VkxBTiByeCBodyBhY2NlbGVyYXRpb24gaGVscGVyLiAgVGhpcyBhY3RzIGxpa2UgbmV0aWZfe3J4
LHJlY2VpdmVfc2tifSgpLiAqLwogaW50IF9fdmxhbl9od2FjY2VsX3J4KHN0cnVjdCBza19idWZm
ICpza2IsIHN0cnVjdCB2bGFuX2dyb3VwICpncnAsCiAJCSAgICAgIHUxNiB2bGFuX3RjaSwgaW50
IHBvbGxpbmcpCiB7Ci0Jc3RydWN0IG5ldF9kZXZpY2Vfc3RhdHMgKnN0YXRzOworCXN0cnVjdCB2
bGFuX2h3YWNjZWxfY2IgKmNiID0gdmxhbl9od2FjY2VsX2NiKHNrYik7CiAKIAlpZiAoc2tiX2Jv
bmRfc2hvdWxkX2Ryb3Aoc2tiKSkgewogCQlkZXZfa2ZyZWVfc2tiX2FueShza2IpOwpAQCAtMTUs
MjMgKzI0LDM1IEBAIGludCBfX3ZsYW5faHdhY2NlbF9yeChzdHJ1Y3Qgc2tfYnVmZiAqc2tiLCBz
dHJ1Y3Qgdmxhbl9ncm91cCAqZ3JwLAogCX0KIAogCXNrYi0+dmxhbl90Y2kgPSB2bGFuX3RjaTsK
KwljYi0+ZGV2ID0gdmxhbl9ncm91cF9nZXRfZGV2aWNlKGdycCwgdmxhbl90Y2kgJiBWTEFOX1ZJ
RF9NQVNLKTsKKworCXJldHVybiAocG9sbGluZyA/IG5ldGlmX3JlY2VpdmVfc2tiKHNrYikgOiBu
ZXRpZl9yeChza2IpKTsKK30KK0VYUE9SVF9TWU1CT0woX192bGFuX2h3YWNjZWxfcngpOworCitp
bnQgdmxhbl9od2FjY2VsX2RvX3JlY2VpdmUoc3RydWN0IHNrX2J1ZmYgKnNrYikKK3sKKwlzdHJ1
Y3Qgdmxhbl9od2FjY2VsX2NiICpjYiA9IHZsYW5faHdhY2NlbF9jYihza2IpOworCXN0cnVjdCBu
ZXRfZGV2aWNlICpkZXYgPSBjYi0+ZGV2OworCXN0cnVjdCBuZXRfZGV2aWNlX3N0YXRzICpzdGF0
czsKKwogCW5ldGlmX25pdF9kZWxpdmVyKHNrYik7CiAKLQlza2ItPmRldiA9IHZsYW5fZ3JvdXBf
Z2V0X2RldmljZShncnAsIHZsYW5fdGNpICYgVkxBTl9WSURfTUFTSyk7Ci0JaWYgKHNrYi0+ZGV2
ID09IE5VTEwpIHsKLQkJZGV2X2tmcmVlX3NrYl9hbnkoc2tiKTsKLQkJLyogTm90IE5FVF9SWF9E
Uk9QLCB0aGlzIGlzIG5vdCBiZWluZyBkcm9wcGVkCi0JCSAqIGR1ZSB0byBjb25nZXN0aW9uLiAq
LwotCQlyZXR1cm4gTkVUX1JYX1NVQ0NFU1M7CisJaWYgKGRldiA9PSBOVUxMKSB7CisJCWtmcmVl
X3NrYihza2IpOworCQlyZXR1cm4gLTE7CiAJfQotCXNrYi0+ZGV2LT5sYXN0X3J4ID0gamlmZmll
czsKKworCXNrYi0+ZGV2ID0gZGV2OworCXNrYi0+cHJpb3JpdHkgPSB2bGFuX2dldF9pbmdyZXNz
X3ByaW9yaXR5KGRldiwgc2tiLT52bGFuX3RjaSk7CiAJc2tiLT52bGFuX3RjaSA9IDA7CiAKLQlz
dGF0cyA9ICZza2ItPmRldi0+c3RhdHM7CisJZGV2LT5sYXN0X3J4ID0gamlmZmllczsKKworCXN0
YXRzID0gJmRldi0+c3RhdHM7CiAJc3RhdHMtPnJ4X3BhY2tldHMrKzsKIAlzdGF0cy0+cnhfYnl0
ZXMgKz0gc2tiLT5sZW47CiAKLQlza2ItPnByaW9yaXR5ID0gdmxhbl9nZXRfaW5ncmVzc19wcmlv
cml0eShza2ItPmRldiwgdmxhbl90Y2kpOwogCXN3aXRjaCAoc2tiLT5wa3RfdHlwZSkgewogCWNh
c2UgUEFDS0VUX0JST0FEQ0FTVDoKIAkJYnJlYWs7CkBAIC00MywxMyArNjQsMTIgQEAgaW50IF9f
dmxhbl9od2FjY2VsX3J4KHN0cnVjdCBza19idWZmICpza2IsIHN0cnVjdCB2bGFuX2dyb3VwICpn
cnAsCiAJCSAqIFRoaXMgYWxsb3dzIHRoZSBWTEFOIHRvIGhhdmUgYSBkaWZmZXJlbnQgTUFDIHRo
YW4gdGhlCiAJCSAqIHVuZGVybHlpbmcgZGV2aWNlLCBhbmQgc3RpbGwgcm91dGUgY29ycmVjdGx5
LiAqLwogCQlpZiAoIWNvbXBhcmVfZXRoZXJfYWRkcihldGhfaGRyKHNrYiktPmhfZGVzdCwKLQkJ
CQkJc2tiLT5kZXYtPmRldl9hZGRyKSkKKwkJCQkJZGV2LT5kZXZfYWRkcikpCiAJCQlza2ItPnBr
dF90eXBlID0gUEFDS0VUX0hPU1Q7CiAJCWJyZWFrOwogCX07Ci0JcmV0dXJuIChwb2xsaW5nID8g
bmV0aWZfcmVjZWl2ZV9za2Ioc2tiKSA6IG5ldGlmX3J4KHNrYikpOworCXJldHVybiAwOwogfQot
RVhQT1JUX1NZTUJPTChfX3ZsYW5faHdhY2NlbF9yeCk7CiAKIHN0cnVjdCBuZXRfZGV2aWNlICp2
bGFuX2Rldl9yZWFsX2Rldihjb25zdCBzdHJ1Y3QgbmV0X2RldmljZSAqZGV2KQogewpkaWZmIC0t
Z2l0IGEvbmV0L2NvcmUvZGV2LmMgYi9uZXQvY29yZS9kZXYuYwppbmRleCBkOTAzOGUzLi45MTc0
Yzc3IDEwMDY0NAotLS0gYS9uZXQvY29yZS9kZXYuYworKysgYi9uZXQvY29yZS9kZXYuYwpAQCAt
MjIxOCw2ICsyMjE4LDkgQEAgaW50IG5ldGlmX3JlY2VpdmVfc2tiKHN0cnVjdCBza19idWZmICpz
a2IpCiAJaW50IHJldCA9IE5FVF9SWF9EUk9QOwogCV9fYmUxNiB0eXBlOwogCisJaWYgKHNrYi0+
dmxhbl90Y2kgJiYgdmxhbl9od2FjY2VsX2RvX3JlY2VpdmUoc2tiKSkKKwkJcmV0dXJuIE5FVF9S
WF9TVUNDRVNTOworCiAJLyogaWYgd2UndmUgZ290dGVuIGhlcmUgdGhyb3VnaCBOQVBJLCBjaGVj
ayBuZXRwb2xsICovCiAJaWYgKG5ldHBvbGxfcmVjZWl2ZV9za2Ioc2tiKSkKIAkJcmV0dXJuIE5F
VF9SWF9EUk9QOwo=
------=_Part_4399_4995691.1225284711902--
