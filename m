From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: [Linux 4.2-rc8+...v4.3-rc2] REGRESSION: ppp: circular locking
 dependency detected: [pppd] ppp_dev_uninit() | rtnl_lock()
Date: Wed, 23 Sep 2015 22:46:00 +0200
Message-ID: <CA+icZUXwOa0c9A8dUkykgqh-Ctnhw-YhhGsmEPtm50zdVsTtXA@mail.gmail.com>
References: <CA+icZUXjsqw-C7mNHRYzha+1efjm3pT-eoU0wb5KhOtEkroF8Q@mail.gmail.com>
	<20150923103803.GC2869@alphalink.fr>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a11425ed6c6894405207033cb
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150923103803.GC2869@alphalink.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--001a11425ed6c6894405207033cb
Content-Type: text/plain; charset=UTF-8

On Wed, Sep 23, 2015 at 12:38 PM, Guillaume Nault <g.nault@alphalink.fr> wrote:
> On Wed, Sep 23, 2015 at 08:06:16AM +0200, Sedat Dilek wrote:
>> Without reverting the below culprit ppp patch...
>>
>> commit/?id=8cb775bc0a34dc596837e7da03fd22c747be618b
>> ("ppp: fix device unregistration upon netns deletion")
>>
>> ...I have an unstable Internet connection via Network-Manager/ModemManager.
>>
>> First I saw this with Linux v4.2.
>>
>
> Thanks for reporting the issue. Can you test this patch ?
>
> ---
> diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
> index 0481daf..ed00446 100644
> --- a/drivers/net/ppp/ppp_generic.c
> +++ b/drivers/net/ppp/ppp_generic.c
> @@ -2755,6 +2755,7 @@ static struct ppp *ppp_create_interface(struct net *net, int unit,
>          */
>         dev_net_set(dev, net);
>
> +       rtnl_lock();
>         mutex_lock(&pn->all_ppp_mutex);
>
>         if (unit < 0) {
> @@ -2785,7 +2786,7 @@ static struct ppp *ppp_create_interface(struct net *net, int unit,
>         ppp->file.index = unit;
>         sprintf(dev->name, "ppp%d", unit);
>
> -       ret = register_netdev(dev);
> +       ret = register_netdevice(dev);
>         if (ret != 0) {
>                 unit_put(&pn->units_idr, unit);
>                 netdev_err(ppp->dev, "PPP: couldn't register device %s (%d)\n",
> @@ -2797,6 +2798,7 @@ static struct ppp *ppp_create_interface(struct net *net, int unit,
>
>         atomic_inc(&ppp_unit_count);
>         mutex_unlock(&pn->all_ppp_mutex);
> +       rtnl_unlock();
>
>         *retp = 0;
>         return ppp;

I have adapted your patch against Linux v4.2.1 and it fixes the issue for me.
Testcase:
1. Stop network-manager and unload "PPP Deflate Compression module".
2. Reload module and restart NM.
( No call-traces pointing to ppp. )

Do you mind to send a proper patch with subject-line and commit-message?
Can you embed the Fixes-tag and give credits like Reported-by/Tested-by?

Thanks.

- Sedat -

--001a11425ed6c6894405207033cb
Content-Type: text/x-patch; charset=US-ASCII;
	name="0001-ppp-Fix-circular-locking-dependency-linux-4-2-1.patch"
Content-Disposition: attachment;
	filename="0001-ppp-Fix-circular-locking-dependency-linux-4-2-1.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_iex9bfib0

RnJvbSBkNGFjZTNlMDAxMjk2ODdiNjgwOTc3ZWNjNWVhNGM5YTAzZTM1YjYzIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBTZWRhdCBEaWxlayA8c2VkYXQuZGlsZWtAZ21haWwuY29tPgpE
YXRlOiBXZWQsIDIzIFNlcCAyMDE1IDIyOjMzOjMxICswMjAwClN1YmplY3Q6IFtQQVRDSF0gcHBw
OiBGaXggY2lyY3VsYXIgbG9ja2luZyBkZXBlbmRlbmN5CgotLS0KIGRyaXZlcnMvbmV0L3BwcC9w
cHBfZ2VuZXJpYy5jIHwgNCArKystCiAxIGZpbGUgY2hhbmdlZCwgMyBpbnNlcnRpb25zKCspLCAx
IGRlbGV0aW9uKC0pCgpkaWZmIC0tZ2l0IGEvZHJpdmVycy9uZXQvcHBwL3BwcF9nZW5lcmljLmMg
Yi9kcml2ZXJzL25ldC9wcHAvcHBwX2dlbmVyaWMuYwppbmRleCBmYThmNTA0NmFmZTkuLjQ4N2Jl
MjBiNmIxMiAxMDA2NDQKLS0tIGEvZHJpdmVycy9uZXQvcHBwL3BwcF9nZW5lcmljLmMKKysrIGIv
ZHJpdmVycy9uZXQvcHBwL3BwcF9nZW5lcmljLmMKQEAgLTI3NDIsNiArMjc0Miw3IEBAIHN0YXRp
YyBzdHJ1Y3QgcHBwICpwcHBfY3JlYXRlX2ludGVyZmFjZShzdHJ1Y3QgbmV0ICpuZXQsIGludCB1
bml0LAogCSAqLwogCWRldl9uZXRfc2V0KGRldiwgbmV0KTsKIAorCXJ0bmxfbG9jaygpOwogCW11
dGV4X2xvY2soJnBuLT5hbGxfcHBwX211dGV4KTsKIAogCWlmICh1bml0IDwgMCkgewpAQCAtMjc3
Miw3ICsyNzczLDcgQEAgc3RhdGljIHN0cnVjdCBwcHAgKnBwcF9jcmVhdGVfaW50ZXJmYWNlKHN0
cnVjdCBuZXQgKm5ldCwgaW50IHVuaXQsCiAJcHBwLT5maWxlLmluZGV4ID0gdW5pdDsKIAlzcHJp
bnRmKGRldi0+bmFtZSwgInBwcCVkIiwgdW5pdCk7CiAKLQlyZXQgPSByZWdpc3Rlcl9uZXRkZXYo
ZGV2KTsKKwlyZXQgPSByZWdpc3Rlcl9uZXRkZXZpY2UoZGV2KTsKIAlpZiAocmV0ICE9IDApIHsK
IAkJdW5pdF9wdXQoJnBuLT51bml0c19pZHIsIHVuaXQpOwogCQluZXRkZXZfZXJyKHBwcC0+ZGV2
LCAiUFBQOiBjb3VsZG4ndCByZWdpc3RlciBkZXZpY2UgJXMgKCVkKVxuIiwKQEAgLTI3ODQsNiAr
Mjc4NSw3IEBAIHN0YXRpYyBzdHJ1Y3QgcHBwICpwcHBfY3JlYXRlX2ludGVyZmFjZShzdHJ1Y3Qg
bmV0ICpuZXQsIGludCB1bml0LAogCiAJYXRvbWljX2luYygmcHBwX3VuaXRfY291bnQpOwogCW11
dGV4X3VubG9jaygmcG4tPmFsbF9wcHBfbXV0ZXgpOworCXJ0bmxfdW5sb2NrKCk7CiAKIAkqcmV0
cCA9IDA7CiAJcmV0dXJuIHBwcDsKLS0gCjIuNS4zCgo=
--001a11425ed6c6894405207033cb--
