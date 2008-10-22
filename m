From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Subject: RE: [E1000-devel] [RFC 2/2] igb: skb recycling
Date: Wed, 22 Oct 2008 16:53:17 -0700
Message-ID: <80769D7B14936844A23C0C43D9FBCF0F176AE5E0@orsmsx501.amr.corp.intel.com>
References: <20081021121137.5c67d338@extreme>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="_002_80769D7B14936844A23C0C43D9FBCF0F176AE5E0orsmsx501amrcor_"
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>,
	"jeffery.t.kirsher@intel.com" <jeffery.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.all
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:51307 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752889AbYJVXxg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Oct 2008 19:53:36 -0400
In-Reply-To: <20081021121137.5c67d338@extreme>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--_002_80769D7B14936844A23C0C43D9FBCF0F176AE5E0orsmsx501amrcor_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Stephen Hemminger wrote:
> This driver is multiqueue, so implement a small skb recycling queue
> per cpu. It doesn't make sense to have a global queue since then a
> lock would be required. Not sure if this is going to work; compile
> tested only, needs more evaluation

I did a bit of quick testing and found an issue in the sections of code bel=
ow.  As is the current patch generates a null pointer exception on unload b=
ecause the percpu_alloc and for_each_possible_cpu are working off of two di=
fferent CPU masks.

The simple solution is to either replace percpu_alloc with alloc_percpu and=
 use cpu_possible_map or replace for_each_possible_cpu with for_each_online=
_cpu and use the cpu_online_map.

Attached is the version I tested at my desk that used the cpu_possible_map =
solution.  I went that route since alloc_percpu seemed like a fairly clean =
macro.

Thanks,

Alex

> --- a/drivers/net/igb/igb_main.c        2008-10-21 09:39:25.000000000
> -0700 +++ b/drivers/net/igb/igb_main.c        2008-10-21
> 10:13:42.000000000 -0700 @@ -824,6 +824,11 @@ void igb_down(struct
>                 igb_adapter *adapte igb_reset(adapter);
>         igb_clean_all_tx_rings(adapter);
>         igb_clean_all_rx_rings(adapter);
> +
> +       for_each_possible_cpu(i) {
> +               struct sk_buff_head *rx_recycle =3D
> per_cpu_ptr(adapter->rx_recycle,i); +
> __skb_queue_purge(rx_recycle); +       }
>  }
>
>  void igb_reinit_locked(struct igb_adapter *adapter)
> @@ -1022,6 +1027,11 @@ static int __devinit igb_probe(struct pc
>         adapter =3D netdev_priv(netdev);
>         adapter->netdev =3D netdev;
>         adapter->pdev =3D pdev;
> +
> +       adapter->rx_recycle =3D percpu_alloc(sizeof(struct
> sk_buff_head), GFP_KERNEL); +       if (!adapter->rx_recycle)
> +               goto err_alloc_recycle;
> +
>         hw =3D &adapter->hw;
>         hw->back =3D adapter;
>         adapter->msg_enable =3D NETIF_MSG_DRV | NETIF_MSG_PROBE;


--_002_80769D7B14936844A23C0C43D9FBCF0F176AE5E0orsmsx501amrcor_
Content-Type: application/octet-stream; name="skb_recycle.diff"
Content-Description: skb_recycle.diff
Content-Disposition: attachment; filename="skb_recycle.diff"; size=3753;
	creation-date="Tue, 21 Oct 2008 13:45:54 GMT";
	modification-date="Wed, 22 Oct 2008 16:45:58 GMT"
Content-Transfer-Encoding: base64

LS0tCgogZHJpdmVycy9uZXQvaWdiL2lnYi5oICAgICAgfCAgICAxICsKIGRyaXZlcnMvbmV0L2ln
Yi9pZ2JfbWFpbi5jIHwgICA0OCArKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKy0t
LS0tLS0tLQogMiBmaWxlcyBjaGFuZ2VkLCAzOSBpbnNlcnRpb25zKCspLCAxMCBkZWxldGlvbnMo
LSkKCgpkaWZmIC0tZ2l0IGEvZHJpdmVycy9uZXQvaWdiL2lnYi5oIGIvZHJpdmVycy9uZXQvaWdi
L2lnYi5oCmluZGV4IDRmZjZmMDUuLjg0ZTgzYTMgMTAwNjQ0Ci0tLSBhL2RyaXZlcnMvbmV0L2ln
Yi9pZ2IuaAorKysgYi9kcml2ZXJzL25ldC9pZ2IvaWdiLmgKQEAgLTIzMiw2ICsyMzIsNyBAQCBz
dHJ1Y3QgaWdiX2FkYXB0ZXIgewogCiAJLyogVFggKi8KIAlzdHJ1Y3QgaWdiX3JpbmcgKnR4X3Jp
bmc7ICAgICAgLyogT25lIHBlciBhY3RpdmUgcXVldWUgKi8KKwlzdHJ1Y3Qgc2tfYnVmZl9oZWFk
ICpyeF9yZWN5Y2xlOyAvKiBPbmUgcGVyIGNwdSAqLwogCXVuc2lnbmVkIGludCByZXN0YXJ0X3F1
ZXVlOwogCXVuc2lnbmVkIGxvbmcgdHhfcXVldWVfbGVuOwogCXUzMiB0eGRfY21kOwpkaWZmIC0t
Z2l0IGEvZHJpdmVycy9uZXQvaWdiL2lnYl9tYWluLmMgYi9kcml2ZXJzL25ldC9pZ2IvaWdiX21h
aW4uYwppbmRleCA5M2QwMmVmLi44MWYzMjAwIDEwMDY0NAotLS0gYS9kcml2ZXJzL25ldC9pZ2Iv
aWdiX21haW4uYworKysgYi9kcml2ZXJzL25ldC9pZ2IvaWdiX21haW4uYwpAQCAtODI0LDYgKzgy
NCwxMSBAQCB2b2lkIGlnYl9kb3duKHN0cnVjdCBpZ2JfYWRhcHRlciAqYWRhcHRlcikKIAkJaWdi
X3Jlc2V0KGFkYXB0ZXIpOwogCWlnYl9jbGVhbl9hbGxfdHhfcmluZ3MoYWRhcHRlcik7CiAJaWdi
X2NsZWFuX2FsbF9yeF9yaW5ncyhhZGFwdGVyKTsKKworCWZvcl9lYWNoX3Bvc3NpYmxlX2NwdShp
KSB7CisJCXN0cnVjdCBza19idWZmX2hlYWQgKnJ4X3JlY3ljbGUgPSBwZXJfY3B1X3B0cihhZGFw
dGVyLT5yeF9yZWN5Y2xlLGkpOworCQlfX3NrYl9xdWV1ZV9wdXJnZShyeF9yZWN5Y2xlKTsKKwl9
CiB9CiAKIHZvaWQgaWdiX3JlaW5pdF9sb2NrZWQoc3RydWN0IGlnYl9hZGFwdGVyICphZGFwdGVy
KQpAQCAtMTAyMiw2ICsxMDI3LDExIEBAIHN0YXRpYyBpbnQgX19kZXZpbml0IGlnYl9wcm9iZShz
dHJ1Y3QgcGNpX2RldiAqcGRldiwKIAlhZGFwdGVyID0gbmV0ZGV2X3ByaXYobmV0ZGV2KTsKIAlh
ZGFwdGVyLT5uZXRkZXYgPSBuZXRkZXY7CiAJYWRhcHRlci0+cGRldiA9IHBkZXY7CisKKwlhZGFw
dGVyLT5yeF9yZWN5Y2xlID0gYWxsb2NfcGVyY3B1KHN0cnVjdCBza19idWZmX2hlYWQpOworCWlm
ICghYWRhcHRlci0+cnhfcmVjeWNsZSkKKwkJZ290byBlcnJfYWxsb2NfcmVjeWNsZTsKKwogCWh3
ID0gJmFkYXB0ZXItPmh3OwogCWh3LT5iYWNrID0gYWRhcHRlcjsKIAlhZGFwdGVyLT5tc2dfZW5h
YmxlID0gTkVUSUZfTVNHX0RSViB8IE5FVElGX01TR19QUk9CRTsKQEAgLTEyODksNiArMTI5OSw4
IEBAIGVycl9zd19pbml0OgogZXJyX2h3X2luaXQ6CiAJaW91bm1hcChody0+aHdfYWRkcik7CiBl
cnJfaW9yZW1hcDoKKwlwZXJjcHVfZnJlZShhZGFwdGVyLT5yeF9yZWN5Y2xlKTsKK2Vycl9hbGxv
Y19yZWN5Y2xlOgogCWZyZWVfbmV0ZGV2KG5ldGRldik7CiBlcnJfYWxsb2NfZXRoZXJkZXY6CiAJ
cGNpX3JlbGVhc2Vfc2VsZWN0ZWRfcmVnaW9ucyhwZGV2LCBiYXJzKTsKQEAgLTEzNTIsNiArMTM2
NCw4IEBAIHN0YXRpYyB2b2lkIF9fZGV2ZXhpdCBpZ2JfcmVtb3ZlKHN0cnVjdCBwY2lfZGV2ICpw
ZGV2KQogCQlpb3VubWFwKGFkYXB0ZXItPmh3LmZsYXNoX2FkZHJlc3MpOwogCXBjaV9yZWxlYXNl
X3NlbGVjdGVkX3JlZ2lvbnMocGRldiwgYWRhcHRlci0+YmFycyk7CiAKKwlwZXJjcHVfZnJlZShh
ZGFwdGVyLT5yeF9yZWN5Y2xlKTsKKwogCWZyZWVfbmV0ZGV2KG5ldGRldik7CiAKIAlwY2lfZGlz
YWJsZV9kZXZpY2UocGRldik7CkBAIC0xOTg5LDYgKzIwMDMsMTEgQEAgc3RhdGljIHZvaWQgaWdi
X2ZyZWVfYWxsX3R4X3Jlc291cmNlcyhzdHJ1Y3QgaWdiX2FkYXB0ZXIgKmFkYXB0ZXIpCiAJCWln
Yl9mcmVlX3R4X3Jlc291cmNlcygmYWRhcHRlci0+dHhfcmluZ1tpXSk7CiB9CiAKK3N0YXRpYyBp
bmxpbmUgdW5zaWduZWQgaW50IGlnYl9yeF9idWZzaXplKGNvbnN0IHN0cnVjdCBpZ2JfYWRhcHRl
ciAqYWRhcHRlcikKK3sKKwlyZXR1cm4gKGFkYXB0ZXItPnJ4X3BzX2hkcl9zaXplID8gOiBhZGFw
dGVyLT5yeF9idWZmZXJfbGVuKSArIE5FVF9JUF9BTElHTjsKK30KKwogc3RhdGljIHZvaWQgaWdi
X3VubWFwX2FuZF9mcmVlX3R4X3Jlc291cmNlKHN0cnVjdCBpZ2JfYWRhcHRlciAqYWRhcHRlciwK
IAkJCQkJICAgc3RydWN0IGlnYl9idWZmZXIgKmJ1ZmZlcl9pbmZvKQogewpAQCAtMjAwMCw3ICsy
MDE5LDE1IEBAIHN0YXRpYyB2b2lkIGlnYl91bm1hcF9hbmRfZnJlZV90eF9yZXNvdXJjZShzdHJ1
Y3QgaWdiX2FkYXB0ZXIgKmFkYXB0ZXIsCiAJCWJ1ZmZlcl9pbmZvLT5kbWEgPSAwOwogCX0KIAlp
ZiAoYnVmZmVyX2luZm8tPnNrYikgewotCQlkZXZfa2ZyZWVfc2tiX2FueShidWZmZXJfaW5mby0+
c2tiKTsKKwkJc3RydWN0IHNrX2J1ZmZfaGVhZCAqcnhfcmVjeWNsZQorCQkgICAgICAgID0gcGVy
X2NwdV9wdHIoYWRhcHRlci0+cnhfcmVjeWNsZSwgc21wX3Byb2Nlc3Nvcl9pZCgpKTsKKworCQlp
ZiAoc2tiX3F1ZXVlX2xlbihyeF9yZWN5Y2xlKSA8IDE2ICYmCisJCSAgICBza2JfcmVjeWNsZV9j
aGVjayhidWZmZXJfaW5mby0+c2tiLCBpZ2JfcnhfYnVmc2l6ZShhZGFwdGVyKSkpCisJCQlfX3Nr
Yl9xdWV1ZV9oZWFkKHJ4X3JlY3ljbGUsIGJ1ZmZlcl9pbmZvLT5za2IpOworCQllbHNlCisJCQlk
ZXZfa2ZyZWVfc2tiX2FueShidWZmZXJfaW5mby0+c2tiKTsKKwogCQlidWZmZXJfaW5mby0+c2ti
ID0gTlVMTDsKIAl9CiAJYnVmZmVyX2luZm8tPnRpbWVfc3RhbXAgPSAwOwpAQCAtNDAwMCwxOCAr
NDAyNywxOSBAQCBzdGF0aWMgdm9pZCBpZ2JfYWxsb2NfcnhfYnVmZmVyc19hZHYoc3RydWN0IGln
Yl9yaW5nICpyeF9yaW5nLAogCQl9CiAKIAkJaWYgKCFidWZmZXJfaW5mby0+c2tiKSB7Ci0JCQlp
bnQgYnVmc3o7CisJCQl1bnNpZ25lZCBpbnQgYnVmc3ogPSBpZ2JfcnhfYnVmc2l6ZShhZGFwdGVy
KTsKKwkJCXN0cnVjdCBza19idWZmX2hlYWQgKnJ4X3JlY3ljbGUKKwkJCQk9IHBlcl9jcHVfcHRy
KGFkYXB0ZXItPnJ4X3JlY3ljbGUsCisJCQkJICAgICAgICAgICAgICBzbXBfcHJvY2Vzc29yX2lk
KCkpOwogCi0JCQlpZiAoYWRhcHRlci0+cnhfcHNfaGRyX3NpemUpCi0JCQkJYnVmc3ogPSBhZGFw
dGVyLT5yeF9wc19oZHJfc2l6ZTsKLQkJCWVsc2UKLQkJCQlidWZzeiA9IGFkYXB0ZXItPnJ4X2J1
ZmZlcl9sZW47Ci0JCQlidWZzeiArPSBORVRfSVBfQUxJR047Ci0JCQlza2IgPSBuZXRkZXZfYWxs
b2Nfc2tiKG5ldGRldiwgYnVmc3opOworCQkJc2tiID0gX19za2JfZGVxdWV1ZShyeF9yZWN5Y2xl
KTsKIAogCQkJaWYgKCFza2IpIHsKLQkJCQlhZGFwdGVyLT5hbGxvY19yeF9idWZmX2ZhaWxlZCsr
OwotCQkJCWdvdG8gbm9fYnVmZmVyczsKKwkJCQlza2IgPSBuZXRkZXZfYWxsb2Nfc2tiKG5ldGRl
diwgYnVmc3opOworCQkJCWlmICghc2tiKSB7CisJCQkJCWFkYXB0ZXItPmFsbG9jX3J4X2J1ZmZf
ZmFpbGVkKys7CisJCQkJCWdvdG8gbm9fYnVmZmVyczsKKwkJCQl9CiAJCQl9CiAKIAkJCS8qIE1h
a2UgYnVmZmVyIGFsaWdubWVudCAyIGJleW9uZCBhIDE2IGJ5dGUgYm91bmRhcnkK

--_002_80769D7B14936844A23C0C43D9FBCF0F176AE5E0orsmsx501amrcor_--
