From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Possible double-free in the usbnet driver
Date: Fri, 4 Mar 2016 14:43:38 -0800
Message-ID: <CA+55aFwxbs_hLG58Q_xSK2vpufjmwMk-xkqxTNh_5h-A8y4vbg@mail.gmail.com>
References: <CA+55aFxqwjs5gs6Fw2jmTteWM4hZTnr7Ls111ExNTieObLs82Q@mail.gmail.com>
	<CA+fCnZfS51F7WZEM1YTSPDMWSzvBTJWGf5cRWv5LrNCSOf_-qA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=047d7bd75cec989926052d40d8bb
Cc: Oliver Neukum <oneukum@suse.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Alexander Potapenko <glider@google.com>,
	USB list <linux-usb@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Andrey Konovalov <andreyknvl@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:34224 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759071AbcCDWnj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 17:43:39 -0500
In-Reply-To: <CA+fCnZfS51F7WZEM1YTSPDMWSzvBTJWGf5cRWv5LrNCSOf_-qA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--047d7bd75cec989926052d40d8bb
Content-Type: text/plain; charset=UTF-8

On Fri, Mar 4, 2016 at 2:26 PM, Andrey Konovalov <andreyknvl@gmail.com> wrote:
>
> and when I run the vm and connect the device I get:
>
> [   23.672662] cdc_ncm 1-1:1.6: bind() failure
> [   23.673447] usbnet_probe(): freeing netdev: ffff88006ab48000
> [   23.675822] usbnet_probe(): freeing netdev: ffff88006ab48000
>
> So this seems to be a double-free (or at least a double free_netdev()
> call), but the object gets freed twice from usbnet_probe() and not
> from usbnet_disconnect(), so you're right that the latter doesn't get
> called. I'm not sure how usbnet_probe() ends up being called twice.

I still don't think it's a double free. I think the probe thing is
called twice, and that's why to different allocations get free'd twice
(and the reason it's the same pointer is that the same allocation got
reused)

But I don't know that driver, really.

>> Which particular usbnet bind routine is this? There are multiple
>> sub-drivers for usbnet that all do different things.
>
> cdc_ncm_bind()

Ok, so that matches my theory.

Does this attached stupid patch make the warning go away? Because from
what I can tell, usbnet_link_change() really will start using that
"dev" that simply isn't valid - and will be free'd - if the bind
fails.

So you have usbnet_defer_kevent() getting triggered, which in turn
ends up using "usbnet->kevent"

But somebody like Oliver is really the right person to check this. For
example, it's entirely possible that we should just instead do

        cancel_work_sync(&dev->kevent);

before the "free_netdev(net)" in the "out1" label.

And there might be other things that bind() can have touched than the
kevent workqueue.

               Linus

--047d7bd75cec989926052d40d8bb
Content-Type: text/plain; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ilea3uo40

IGRyaXZlcnMvbmV0L3VzYi9jZGNfbmNtLmMgfCA0ICsrKy0KIDEgZmlsZSBjaGFuZ2VkLCAzIGlu
c2VydGlvbnMoKyksIDEgZGVsZXRpb24oLSkKCmRpZmYgLS1naXQgYS9kcml2ZXJzL25ldC91c2Iv
Y2RjX25jbS5jIGIvZHJpdmVycy9uZXQvdXNiL2NkY19uY20uYwppbmRleCBkYzAyMTJjM2NjMjgu
LjU4NzhiNTRjYzU2MyAxMDA2NDQKLS0tIGEvZHJpdmVycy9uZXQvdXNiL2NkY19uY20uYworKysg
Yi9kcml2ZXJzL25ldC91c2IvY2RjX25jbS5jCkBAIC05OTUsNiArOTk1LDggQEAgc3RhdGljIGlu
dCBjZGNfbmNtX2JpbmQoc3RydWN0IHVzYm5ldCAqZGV2LCBzdHJ1Y3QgdXNiX2ludGVyZmFjZSAq
aW50ZikKIAkgKiBwbGFjZWQgTkRQLgogCSAqLwogCXJldCA9IGNkY19uY21fYmluZF9jb21tb24o
ZGV2LCBpbnRmLCBDRENfTkNNX0RBVEFfQUxUU0VUVElOR19OQ00sIDApOworCWlmIChyZXQgPCAw
KQorCQlyZXR1cm4gcmV0OwogCiAJLyoKIAkgKiBXZSBzaG91bGQgZ2V0IGFuIGV2ZW50IHdoZW4g
bmV0d29yayBjb25uZWN0aW9uIGlzICJjb25uZWN0ZWQiIG9yCkBAIC0xMDAzLDcgKzEwMDUsNyBA
QCBzdGF0aWMgaW50IGNkY19uY21fYmluZChzdHJ1Y3QgdXNibmV0ICpkZXYsIHN0cnVjdCB1c2Jf
aW50ZXJmYWNlICppbnRmKQogCSAqIHN0YXJ0IElQdjYgbmVnb3RpYXRpb24gYW5kIG1vcmUuCiAJ
ICovCiAJdXNibmV0X2xpbmtfY2hhbmdlKGRldiwgMCwgMCk7Ci0JcmV0dXJuIHJldDsKKwlyZXR1
cm4gMDsKIH0KIAogc3RhdGljIHZvaWQgY2RjX25jbV9hbGlnbl90YWlsKHN0cnVjdCBza19idWZm
ICpza2IsIHNpemVfdCBtb2R1bHVzLCBzaXplX3QgcmVtYWluZGVyLCBzaXplX3QgbWF4KQo=
--047d7bd75cec989926052d40d8bb--
