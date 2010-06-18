From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Subject: RE: [RFC PATCH v7 01/19] Add a new structure for skb buffer from
	external.
Date: Fri, 18 Jun 2010 13:26:49 +0800
Message-ID: <F2E9EB7348B8264F86B6AB8151CE2D7915089FE4CC@shsmsx502.ccr.corp.intel.com>
References: <1275732899-5423-1-git-send-email-xiaohui.xin@intel.com>
 <20100606161348.427822fb@nehalam>
 <20100608052744.GA21547@gondor.apana.org.au>
 <F2E9EB7348B8264F86B6AB8151CE2D791100848F9F@shsmsx502.ccr.corp.intel.com>
 <20100611052112.GA25649@gondor.apana.org.au>
 <F2E9EB7348B8264F86B6AB8151CE2D791210AA4475@shsmsx502.ccr.corp.intel.com>
 <F2E9EB7348B8264F86B6AB8151CE2D79134F9AA999@shsmsx502.ccr.corp.intel.com>
 <20100617112119.GB1515@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="_002_F2E9EB7348B8264F86B6AB8151CE2D7915089FE4CCshsmsx502ccrc_"
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mst@redhat.com" <mst@redhat.com>, "mingo@elte.hu" <mingo@elte.hu>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100617112119.GB1515@gondor.apana.org.au>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--_002_F2E9EB7348B8264F86B6AB8151CE2D7915089FE4CCshsmsx502ccrc_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

>-----Original Message-----
>From: Herbert Xu [mailto:herbert@gondor.apana.org.au]
>Sent: Thursday, June 17, 2010 7:21 PM
>To: Xin, Xiaohui
>Cc: Stephen Hemminger; netdev@vger.kernel.org; kvm@vger.kernel.org;
>linux-kernel@vger.kernel.org; mst@redhat.com; mingo@elte.hu; davem@davemlo=
ft.net;
>jdike@linux.intel.com
>Subject: Re: [RFC PATCH v7 01/19] Add a new structure for skb buffer from =
external.
>
>On Sun, Jun 13, 2010 at 04:58:36PM +0800, Xin, Xiaohui wrote:
>>
>> Herbert,
>> In this way, I think we should create 3 functions at least in drivers to=
 allocate rx buffer, to
>receive the rx buffers, and to clean the rx buffers.
>>
>> We can also have another way here. We can provide a function to only sub=
stitute
>> alloc_page(), and a function to release the pages when cleaning the rx b=
uffers.
>
>Yes that's exactly what I had in mind.
>
Herbert,
I have questions about the idea above:
1) Since netdev_alloc_skb() is still there, and we only modify alloc_page()=
,=20
then we don't need napi_gro_frags() any more, the driver's original receivi=
ng=20
function is ok. Right?

2) Is napi_gro_frags() only suitable for TCP protocol packet?=20
I have done a small test for ixgbe driver to let it only allocate paged buf=
fers=20
and found kernel hangs when napi_gro_frags() receives an ARP packet.

3) As I have mentioned above, with this idea, netdev_alloc_skb() will alloc=
ate=20
as usual, the data pointed by skb->data will be copied into the first guest=
 buffer.=20
That means we should reserve sufficient room in guest buffer. For PS mode=20
supported driver (for example ixgbe), the room will be more than 128. After=
 128bytes,=20
we will put the first frag data. Look into virtio-net.c the function page_t=
o_skb() =20
and receive_mergeable(), that means we should modify guest virtio-net drive=
r to=20
compute the offset as the parameter for skb_set_frag().

How do you think about this? Attached is a patch to how to modify the guest=
 driver.
I reserve 512 bytes as an example, and transfer the header len of the skb i=
n hdr->hdr_len.

Thanks
Xiaohui
>Cheers,
>--
>Visit Openswan at http://www.openswan.org/
>Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
>Home Page: http://gondor.apana.org.au/~herbert/
>PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--_002_F2E9EB7348B8264F86B6AB8151CE2D7915089FE4CCshsmsx502ccrc_
Content-Type: application/octet-stream; name="mod-guest.diff"
Content-Description: mod-guest.diff
Content-Disposition: attachment; filename="mod-guest.diff"; size=2031;
	creation-date="Fri, 18 Jun 2010 10:46:31 GMT";
	modification-date="Fri, 18 Jun 2010 10:46:31 GMT"
Content-Transfer-Encoding: base64

ZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L3ZpcnRpb19uZXQuYyBiL2RyaXZlcnMvbmV0L3ZpcnRp
b19uZXQuYwppbmRleCBiMDU3N2RkLi5hNGU2OTg4IDEwMDY0NAotLS0gYS9kcml2ZXJzL25ldC92
aXJ0aW9fbmV0LmMKKysrIGIvZHJpdmVycy9uZXQvdmlydGlvX25ldC5jCkBAIC0zNiw3ICszNiw5
IEBAIG1vZHVsZV9wYXJhbShnc28sIGJvb2wsIDA0NDQpOwogCiAvKiBGSVhNRTogTVRVIGluIGNv
bmZpZy4gKi8KICNkZWZpbmUgTUFYX1BBQ0tFVF9MRU4gKEVUSF9ITEVOICsgVkxBTl9ITEVOICsg
RVRIX0RBVEFfTEVOKQotI2RlZmluZSBHT09EX0NPUFlfTEVOCTEyOAorI2RlZmluZSBHT09EX0NP
UFlfTEVOIAk1MTIJCiAKICNkZWZpbmUgVklSVE5FVF9TRU5EX0NPTU1BTkRfU0dfTUFYICAgIDIK
IApAQCAtMTQ3LDExICsxNDksMTIgQEAgc3RhdGljIHN0cnVjdCBza19idWZmICpwYWdlX3RvX3Nr
YihzdHJ1Y3QgdmlydG5ldF9pbmZvICp2aSwKIHsKIAlzdHJ1Y3Qgc2tfYnVmZiAqc2tiOwogCXN0
cnVjdCBza2Jfdm5ldF9oZHIgKmhkcjsKLQl1bnNpZ25lZCBpbnQgY29weSwgaGRyX2xlbiwgb2Zm
c2V0OworCXVuc2lnbmVkIGludCBjb3B5LCBoZHJfbGVuLCBvZmZzZXQsIGVuZDsKIAljaGFyICpw
OwogCiAJcCA9IHBhZ2VfYWRkcmVzcyhwYWdlKTsKQEAgLTE3MiwxNCArMTc1LDI1IEBAIHN0YXRp
YyBzdHJ1Y3Qgc2tfYnVmZiAqcGFnZV90b19za2Ioc3RydWN0IHZpcnRuZXRfaW5mbyAqdmksCiAJ
bGVuIC09IGhkcl9sZW47CiAJcCArPSBvZmZzZXQ7CiAKLQljb3B5ID0gbGVuOworCWlmICghaGRy
LT5oZHIuaGRyX2xlbikKKwkJY29weSA9IGxlbjsKKwllbHNlIHsKKwkJY29weSA9IGhkci0+aGRy
Lmhkcl9sZW47CisJCWVuZCA9IHNrYl90YWlscm9vbShza2IpOworCQlwcmludGsoS0VSTl9JTkZP
ICJjICVkLCBlICVkXG4iLCBjb3B5LCBlbmQpOworCX0KKwogCWlmIChjb3B5ID4gc2tiX3RhaWxy
b29tKHNrYikpCiAJCWNvcHkgPSBza2JfdGFpbHJvb20oc2tiKTsKIAltZW1jcHkoc2tiX3B1dChz
a2IsIGNvcHkpLCBwLCBjb3B5KTsKIAogCWxlbiAtPSBjb3B5OwotCW9mZnNldCArPSBjb3B5Owor
CWlmICghaGRyLT5oZHIuaGRyX2xlbikKKwkJb2Zmc2V0ICs9IGNvcHk7CisJZWxzZQorCQlvZmZz
ZXQgPSBlbmQ7CiAKKwlwcmludGsoS0VSTl9JTkZPICJvZmYgJWRcbiIsIG9mZnNldCk7CiAJd2hp
bGUgKGxlbikgewogCQlzZXRfc2tiX2ZyYWcoc2tiLCBwYWdlLCBvZmZzZXQsICZsZW4pOwogCQlw
YWdlID0gKHN0cnVjdCBwYWdlICopcGFnZS0+cHJpdmF0ZTsKQEAgLTIxOCw3ICsyMzgsMTIgQEAg
c3RhdGljIGludCByZWNlaXZlX21lcmdlYWJsZShzdHJ1Y3QgdmlydG5ldF9pbmZvICp2aSwgc3Ry
dWN0IHNrX2J1ZmYgKnNrYikKIAkJCWxlbiA9IFBBR0VfU0laRTsKIAogCQlzZXRfc2tiX2ZyYWco
c2tiLCBwYWdlLCAwLCAmbGVuKTsKLQorCQlpZiAoaGRyLT5oZHIuaGRyX2xlbikKKwkJCXNldF9z
a2JfZnJhZyhza2IsIHBhZ2UsIDU0MiwgJmxlbik7CisJCWVsc2UKKwkJCXNldF9za2JfZnJhZyhz
a2IsIHBhZ2UsIDAsICZsZW4pOwogCQktLXZpLT5udW07CiAJfQogCXJldHVybiAwOwpAQCAtMzEx
LDcgKzM0MCwxNSBAQCBzdGF0aWMgdm9pZCByZWNlaXZlX2J1ZihzdHJ1Y3QgbmV0X2RldmljZSAq
ZGV2LCB2b2lkICpidWYsIHVuc2lnbmVkIGludCBsZW4pCiAJCXNrYl9zaGluZm8oc2tiKS0+Z3Nv
X3R5cGUgfD0gU0tCX0dTT19ET0RHWTsKIAkJc2tiX3NoaW5mbyhza2IpLT5nc29fc2VncyA9IDA7
CiAJfQotCisJc2tiLT5pcF9zdW1tZWQgPSAxOwogCW5ldGlmX3JlY2VpdmVfc2tiKHNrYik7CiAJ
cmV0dXJuOwogCkBAIC00NzksNyArNTE2LDggQEAgYWdhaW46CiAJCXJlY2VpdmVkKys7CiAJfQog
Ci0JaWYgKHZpLT5udW0gPCB2aS0+bWF4IC8gMikgeworCWlmICh2aS0+bnVtIDwgdmktPm1heCAt
IDEwKSB7CiAJCWlmICghdHJ5X2ZpbGxfcmVjdih2aSwgR0ZQX0FUT01JQykpCiAJCQlzY2hlZHVs
ZV9kZWxheWVkX3dvcmsoJnZpLT5yZWZpbGwsIDApOwogCX0K

--_002_F2E9EB7348B8264F86B6AB8151CE2D7915089FE4CCshsmsx502ccrc_--
