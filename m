From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: [Linux 4.2-rc8+...v4.3-rc2] REGRESSION: ppp: circular locking
 dependency detected: [pppd] ppp_dev_uninit() | rtnl_lock()
Date: Wed, 23 Sep 2015 23:21:50 +0200
Message-ID: <CA+icZUU0rUJZRb4R+F1N98hbfb0rbmbZ0=Jf60zb30SQHKi1Ug@mail.gmail.com>
References: <CA+icZUXjsqw-C7mNHRYzha+1efjm3pT-eoU0wb5KhOtEkroF8Q@mail.gmail.com>
	<20150923103803.GC2869@alphalink.fr>
	<CA+icZUXwOa0c9A8dUkykgqh-Ctnhw-YhhGsmEPtm50zdVsTtXA@mail.gmail.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a1141664cefc86e052070b3c1
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+icZUXwOa0c9A8dUkykgqh-Ctnhw-YhhGsmEPtm50zdVsTtXA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--001a1141664cefc86e052070b3c1
Content-Type: text/plain; charset=UTF-8

On Wed, Sep 23, 2015 at 10:46 PM, Sedat Dilek <sedat.dilek@gmail.com> wrote:
> On Wed, Sep 23, 2015 at 12:38 PM, Guillaume Nault <g.nault@alphalink.fr> wrote:
>> On Wed, Sep 23, 2015 at 08:06:16AM +0200, Sedat Dilek wrote:
>>> Without reverting the below culprit ppp patch...
>>>
>>> commit/?id=8cb775bc0a34dc596837e7da03fd22c747be618b
>>> ("ppp: fix device unregistration upon netns deletion")
>>>
>>> ...I have an unstable Internet connection via Network-Manager/ModemManager.
>>>
>>> First I saw this with Linux v4.2.
>>>
>>
>> Thanks for reporting the issue. Can you test this patch ?
>>
>> ---
>> diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
>> index 0481daf..ed00446 100644
>> --- a/drivers/net/ppp/ppp_generic.c
>> +++ b/drivers/net/ppp/ppp_generic.c
>> @@ -2755,6 +2755,7 @@ static struct ppp *ppp_create_interface(struct net *net, int unit,
>>          */
>>         dev_net_set(dev, net);
>>
>> +       rtnl_lock();
>>         mutex_lock(&pn->all_ppp_mutex);
>>
>>         if (unit < 0) {
>> @@ -2785,7 +2786,7 @@ static struct ppp *ppp_create_interface(struct net *net, int unit,
>>         ppp->file.index = unit;
>>         sprintf(dev->name, "ppp%d", unit);
>>
>> -       ret = register_netdev(dev);
>> +       ret = register_netdevice(dev);
>>         if (ret != 0) {
>>                 unit_put(&pn->units_idr, unit);
>>                 netdev_err(ppp->dev, "PPP: couldn't register device %s (%d)\n",
>> @@ -2797,6 +2798,7 @@ static struct ppp *ppp_create_interface(struct net *net, int unit,
>>
>>         atomic_inc(&ppp_unit_count);
>>         mutex_unlock(&pn->all_ppp_mutex);
>> +       rtnl_unlock();
>>
>>         *retp = 0;
>>         return ppp;
>
> I have adapted your patch against Linux v4.2.1 and it fixes the issue for me.
> Testcase:
> 1. Stop network-manager and unload "PPP Deflate Compression module".
> 2. Reload module and restart NM.
> ( No call-traces pointing to ppp. )
>
> Do you mind to send a proper patch with subject-line and commit-message?
> Can you embed the Fixes-tag and give credits like Reported-by/Tested-by?
>
> Thanks.
>

Do not forget CC-stable Tag, too.

     Cc: stable@vger.kernel.org# v4.2+

See attached patch for-4.3.

- sed@ -

[1] http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/Documentation/SubmittingPatches#n187
[2] http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/Documentation/SubmittingPatches#n297

--001a1141664cefc86e052070b3c1
Content-Type: text/x-patch; charset=US-ASCII;
	name="0001-ppp-Fix-circular-locking-dependency-in-ppp_create_in.patch"
Content-Disposition: attachment;
	filename="0001-ppp-Fix-circular-locking-dependency-in-ppp_create_in.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_iexapjlg1

RnJvbSAxMTA5YzU1YjU0NzAzNDE2NTkzYmU2Mjc1YWVhYWQ5YWVmY2ZlNGIxIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBTZWRhdCBEaWxlayA8c2VkYXQuZGlsZWtAZ21haWwuY29tPgpE
YXRlOiBXZWQsIDIzIFNlcCAyMDE1IDIyOjU0OjQ4ICswMjAwClN1YmplY3Q6IFtQQVRDSF0gcHBw
OiBGaXggY2lyY3VsYXIgbG9ja2luZyBkZXBlbmRlbmN5IGluCiBwcHBfY3JlYXRlX2ludGVyZmFj
ZSgpCgpGcm9tOiBHdWlsbGF1bWUgTmF1bHQgPGcubmF1bHRAYWxwaGFsaW5rLmZyPgoKRm9yIG1v
cmUgZGV0YWlscyBzZWUgWzFdLgoKWzFdIGh0dHA6Ly9tYXJjLmluZm8vP3Q9MTQ0Mjk4ODU0MzAw
MDAxJnI9MSZ3PTIKClJlcG9ydGVkLWJ5OiBTZWRhdCBEaWxlayA8c2VkYXQuZGlsZWtAZ21haWwu
Y29tPgpUZXN0ZWQtYnk6IFNlZGF0IERpbGVrIDxzZWRhdC5kaWxla0BnbWFpbC5jb20+CkNjOiBz
dGFibGVAdmdlci5rZXJuZWwub3JnICMgdjQuMisKRml4ZXM6IDhjYjc3NWJjMGEzNCAoInBwcDog
Zml4IGRldmljZSB1bnJlZ2lzdHJhdGlvbiB1cG9uIG5ldG5zIGRlbGV0aW9uIikKQ0M6IEd1aWxs
YXVtZSBOYXVsdCA8Zy5uYXVsdEBhbHBoYWxpbmsuZnI+CkNDOiBEYXZpZCBTLiBNaWxsZXIgPGRh
dmVtQGRhdmVtbG9mdC5uZXQ+CkNDOiBuZXRkZXZAdmdlci5rZXJuZWwub3JnIiA8bmV0ZGV2QHZn
ZXIua2VybmVsLm9yZz4KLS0tCiBkcml2ZXJzL25ldC9wcHAvcHBwX2dlbmVyaWMuYyB8IDQgKysr
LQogMSBmaWxlIGNoYW5nZWQsIDMgaW5zZXJ0aW9ucygrKSwgMSBkZWxldGlvbigtKQoKZGlmZiAt
LWdpdCBhL2RyaXZlcnMvbmV0L3BwcC9wcHBfZ2VuZXJpYy5jIGIvZHJpdmVycy9uZXQvcHBwL3Bw
cF9nZW5lcmljLmMKaW5kZXggMDQ4MWRhZjkyMDFhLi5lZDAwNDQ2NzU5YjIgMTAwNjQ0Ci0tLSBh
L2RyaXZlcnMvbmV0L3BwcC9wcHBfZ2VuZXJpYy5jCisrKyBiL2RyaXZlcnMvbmV0L3BwcC9wcHBf
Z2VuZXJpYy5jCkBAIC0yNzU1LDYgKzI3NTUsNyBAQCBzdGF0aWMgc3RydWN0IHBwcCAqcHBwX2Ny
ZWF0ZV9pbnRlcmZhY2Uoc3RydWN0IG5ldCAqbmV0LCBpbnQgdW5pdCwKIAkgKi8KIAlkZXZfbmV0
X3NldChkZXYsIG5ldCk7CiAKKwlydG5sX2xvY2soKTsKIAltdXRleF9sb2NrKCZwbi0+YWxsX3Bw
cF9tdXRleCk7CiAKIAlpZiAodW5pdCA8IDApIHsKQEAgLTI3ODUsNyArMjc4Niw3IEBAIHN0YXRp
YyBzdHJ1Y3QgcHBwICpwcHBfY3JlYXRlX2ludGVyZmFjZShzdHJ1Y3QgbmV0ICpuZXQsIGludCB1
bml0LAogCXBwcC0+ZmlsZS5pbmRleCA9IHVuaXQ7CiAJc3ByaW50ZihkZXYtPm5hbWUsICJwcHAl
ZCIsIHVuaXQpOwogCi0JcmV0ID0gcmVnaXN0ZXJfbmV0ZGV2KGRldik7CisJcmV0ID0gcmVnaXN0
ZXJfbmV0ZGV2aWNlKGRldik7CiAJaWYgKHJldCAhPSAwKSB7CiAJCXVuaXRfcHV0KCZwbi0+dW5p
dHNfaWRyLCB1bml0KTsKIAkJbmV0ZGV2X2VycihwcHAtPmRldiwgIlBQUDogY291bGRuJ3QgcmVn
aXN0ZXIgZGV2aWNlICVzICglZClcbiIsCkBAIC0yNzk3LDYgKzI3OTgsNyBAQCBzdGF0aWMgc3Ry
dWN0IHBwcCAqcHBwX2NyZWF0ZV9pbnRlcmZhY2Uoc3RydWN0IG5ldCAqbmV0LCBpbnQgdW5pdCwK
IAogCWF0b21pY19pbmMoJnBwcF91bml0X2NvdW50KTsKIAltdXRleF91bmxvY2soJnBuLT5hbGxf
cHBwX211dGV4KTsKKwlydG5sX3VubG9jaygpOwogCiAJKnJldHAgPSAwOwogCXJldHVybiBwcHA7
Ci0tIAoyLjUuMwoK
--001a1141664cefc86e052070b3c1--
