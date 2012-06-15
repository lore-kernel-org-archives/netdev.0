From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 3/3] usbnet: handle remote wakeup asap
Date: Fri, 15 Jun 2012 10:22:16 +0800
Message-ID: <CACVXFVMO0Z23kW59YRyfbVFu77vG6_yAMxAhOXk619V0dhF7Fw@mail.gmail.com>
References: <1339561217-18151-1-git-send-email-ming.lei@canonical.com>
	<1339561217-18151-4-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=e89a8ff1c3262ff48304c2797c41
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1339561217-18151-4-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--e89a8ff1c3262ff48304c2797c41
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On Wed, Jun 13, 2012 at 12:20 PM, Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> wrote:
> If usbnet is resumed by remote wakeup, generally there are
> some packets comming to be handled, so allocate and submit
> rx URBs in usbnet_resume to avoid delays introduced by tasklet.
> Otherwise, usbnet may have been runtime suspended before the
> usbnet_bh is executed to schedule Rx URBs.
>
> Without the patch, usbnet can't recieve any packets from peer
> in runtime suspend state if runtime PM is enabled and
> autosuspend_delay is set as zero.
>
> Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Signed-off-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> ---
> =A0drivers/net/usb/usbnet.c | =A0 42 ++++++++++++++++++++++++++----------=
------
> =A01 file changed, 26 insertions(+), 16 deletions(-)
>
> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index 9bfa775..4911efa 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -1201,6 +1201,21 @@ deferred:
> =A0}
> =A0EXPORT_SYMBOL_GPL(usbnet_start_xmit);
>
> +static void rx_alloc_submit(struct usbnet *dev, gfp_t flags)
> +{
> + =A0 =A0 =A0 struct urb =A0 =A0 =A0*urb;
> + =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 i;
> +
> + =A0 =A0 =A0 /* don't refill the queue all at once */
> + =A0 =A0 =A0 for (i =3D 0; i < 10 && dev->rxq.qlen < RX_QLEN(dev); i++) =
{
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 urb =3D usb_alloc_urb(0, GFP_ATOMIC);

David, sorry, the 'GFP_ATOMIC' above should be 'flags', so could
you take the fixed version from attachment? Or could you do it by
your self?

Thanks,
--
Ming Lei

--e89a8ff1c3262ff48304c2797c41
Content-Type: application/octet-stream;
	name="0003-usbnet-handle-remote-wakeup-asap.patch"
Content-Disposition: attachment;
	filename="0003-usbnet-handle-remote-wakeup-asap.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_h3gmtack0

RnJvbSAyOTE1NWU4MmVhY2FjMjNlOGZlNmMyOWYyYTY1ZDdlNDE3MGJhMDg2IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBNaW5nIExlaSA8bWluZy5sZWlAY2Fub25pY2FsLmNvbT4KRGF0
ZTogV2VkLCAxMyBKdW4gMjAxMiAxMDo0MDoxNyArMDgwMApTdWJqZWN0OiBbUEFUQ0ggMy8zXSB1
c2JuZXQ6IGhhbmRsZSByZW1vdGUgd2FrZXVwIGFzYXAKCklmIHVzYm5ldCBpcyByZXN1bWVkIGJ5
IHJlbW90ZSB3YWtldXAsIGdlbmVyYWxseSB0aGVyZSBhcmUKc29tZSBwYWNrZXRzIGNvbW1pbmcg
dG8gYmUgaGFuZGxlZCwgc28gYWxsb2NhdGUgYW5kIHN1Ym1pdApyeCBVUkJzIGluIHVzYm5ldF9y
ZXN1bWUgdG8gYXZvaWQgZGVsYXlzIGludHJvZHVjZWQgYnkgdGFza2xldC4KT3RoZXJ3aXNlLCB1
c2JuZXQgbWF5IGhhdmUgYmVlbiBydW50aW1lIHN1c3BlbmRlZCBiZWZvcmUgdGhlCnVzYm5ldF9i
aCBpcyBleGVjdXRlZCB0byBzY2hlZHVsZSBSeCBVUkJzLgoKV2l0aG91dCB0aGUgcGF0Y2gsIHVz
Ym5ldCBjYW4ndCByZWNpZXZlIGFueSBwYWNrZXRzIGZyb20gcGVlcgppbiBydW50aW1lIHN1c3Bl
bmQgc3RhdGUgaWYgcnVudGltZSBQTSBpcyBlbmFibGVkIGFuZAphdXRvc3VzcGVuZF9kZWxheSBp
cyBzZXQgYXMgemVyby4KCkNjOiBzdGFibGVAdmdlci5rZXJuZWwub3JnClNpZ25lZC1vZmYtYnk6
IE1pbmcgTGVpIDxtaW5nLmxlaUBjYW5vbmljYWwuY29tPgotLS0KIGRyaXZlcnMvbmV0L3VzYi91
c2JuZXQuYyB8ICAgNDIgKysrKysrKysrKysrKysrKysrKysrKysrKystLS0tLS0tLS0tLS0tLS0t
CiAxIGZpbGUgY2hhbmdlZCwgMjYgaW5zZXJ0aW9ucygrKSwgMTYgZGVsZXRpb25zKC0pCgpkaWZm
IC0tZ2l0IGEvZHJpdmVycy9uZXQvdXNiL3VzYm5ldC5jIGIvZHJpdmVycy9uZXQvdXNiL3VzYm5l
dC5jCmluZGV4IDliZmE3NzUuLjQ5MTFlZmEgMTAwNjQ0Ci0tLSBhL2RyaXZlcnMvbmV0L3VzYi91
c2JuZXQuYworKysgYi9kcml2ZXJzL25ldC91c2IvdXNibmV0LmMKQEAgLTEyMDEsNiArMTIwMSwy
MSBAQCBkZWZlcnJlZDoKIH0KIEVYUE9SVF9TWU1CT0xfR1BMKHVzYm5ldF9zdGFydF94bWl0KTsK
IAorc3RhdGljIHZvaWQgcnhfYWxsb2Nfc3VibWl0KHN0cnVjdCB1c2JuZXQgKmRldiwgZ2ZwX3Qg
ZmxhZ3MpCit7CisJc3RydWN0IHVyYgkqdXJiOworCWludAkJaTsKKworCS8qIGRvbid0IHJlZmls
bCB0aGUgcXVldWUgYWxsIGF0IG9uY2UgKi8KKwlmb3IgKGkgPSAwOyBpIDwgMTAgJiYgZGV2LT5y
eHEucWxlbiA8IFJYX1FMRU4oZGV2KTsgaSsrKSB7CisJCXVyYiA9IHVzYl9hbGxvY191cmIoMCwg
ZmxhZ3MpOworCQlpZiAodXJiICE9IE5VTEwpIHsKKwkJCWlmIChyeF9zdWJtaXQoZGV2LCB1cmIs
IGZsYWdzKSA9PSAtRU5PTElOSykKKwkJCQlyZXR1cm47CisJCX0KKwl9Cit9CisKIC8qLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLSovCiAKIC8vIHRhc2tsZXQgKHdvcmsgZGVmZXJyZWQgZnJvbSBjb21wbGV0aW9u
cywgaW5faXJxKSBvciB0aW1lcgpAQCAtMTI0MCwyNiArMTI1NSwxNCBAQCBzdGF0aWMgdm9pZCB1
c2JuZXRfYmggKHVuc2lnbmVkIGxvbmcgcGFyYW0pCiAJCSAgICF0aW1lcl9wZW5kaW5nICgmZGV2
LT5kZWxheSkgJiYKIAkJICAgIXRlc3RfYml0IChFVkVOVF9SWF9IQUxULCAmZGV2LT5mbGFncykp
IHsKIAkJaW50CXRlbXAgPSBkZXYtPnJ4cS5xbGVuOwotCQlpbnQJcWxlbiA9IFJYX1FMRU4gKGRl
dik7Ci0KLQkJaWYgKHRlbXAgPCBxbGVuKSB7Ci0JCQlzdHJ1Y3QgdXJiCSp1cmI7Ci0JCQlpbnQJ
CWk7Ci0KLQkJCS8vIGRvbid0IHJlZmlsbCB0aGUgcXVldWUgYWxsIGF0IG9uY2UKLQkJCWZvciAo
aSA9IDA7IGkgPCAxMCAmJiBkZXYtPnJ4cS5xbGVuIDwgcWxlbjsgaSsrKSB7Ci0JCQkJdXJiID0g
dXNiX2FsbG9jX3VyYiAoMCwgR0ZQX0FUT01JQyk7Ci0JCQkJaWYgKHVyYiAhPSBOVUxMKSB7Ci0J
CQkJCWlmIChyeF9zdWJtaXQgKGRldiwgdXJiLCBHRlBfQVRPTUlDKSA9PQotCQkJCQkgICAgLUVO
T0xJTkspCi0JCQkJCQlyZXR1cm47Ci0JCQkJfQotCQkJfQorCisJCWlmICh0ZW1wIDwgUlhfUUxF
TihkZXYpKSB7CisJCQlyeF9hbGxvY19zdWJtaXQoZGV2LCBHRlBfQVRPTUlDKTsKIAkJCWlmICh0
ZW1wICE9IGRldi0+cnhxLnFsZW4pCiAJCQkJbmV0aWZfZGJnKGRldiwgbGluaywgZGV2LT5uZXQs
CiAJCQkJCSAgInJ4cWxlbiAlZCAtLT4gJWRcbiIsCiAJCQkJCSAgdGVtcCwgZGV2LT5yeHEucWxl
bik7Ci0JCQlpZiAoZGV2LT5yeHEucWxlbiA8IHFsZW4pCisJCQlpZiAoZGV2LT5yeHEucWxlbiA8
IFJYX1FMRU4oZGV2KSkKIAkJCQl0YXNrbGV0X3NjaGVkdWxlICgmZGV2LT5iaCk7CiAJCX0KIAkJ
aWYgKGRldi0+dHhxLnFsZW4gPCBUWF9RTEVOIChkZXYpKQpAQCAtMTU2NSw2ICsxNTY4LDEzIEBA
IGludCB1c2JuZXRfcmVzdW1lIChzdHJ1Y3QgdXNiX2ludGVyZmFjZSAqaW50ZikKIAkJc3Bpbl91
bmxvY2tfaXJxKCZkZXYtPnR4cS5sb2NrKTsKIAogCQlpZiAodGVzdF9iaXQoRVZFTlRfREVWX09Q
RU4sICZkZXYtPmZsYWdzKSkgeworCQkJLyogaGFuZGxlIHJlbW90ZSB3YWtldXAgQVNBUCAqLwor
CQkJaWYgKCFkZXYtPndhaXQgJiYKKwkJCQluZXRpZl9kZXZpY2VfcHJlc2VudChkZXYtPm5ldCkg
JiYKKwkJCQkhdGltZXJfcGVuZGluZygmZGV2LT5kZWxheSkgJiYKKwkJCQkhdGVzdF9iaXQoRVZF
TlRfUlhfSEFMVCwgJmRldi0+ZmxhZ3MpKQorCQkJCQlyeF9hbGxvY19zdWJtaXQoZGV2LCBHRlBf
S0VSTkVMKTsKKwogCQkJaWYgKCEoZGV2LT50eHEucWxlbiA+PSBUWF9RTEVOKGRldikpKQogCQkJ
CW5ldGlmX3R4X3dha2VfYWxsX3F1ZXVlcyhkZXYtPm5ldCk7CiAJCQl0YXNrbGV0X3NjaGVkdWxl
ICgmZGV2LT5iaCk7Ci0tIAoxLjcuOS41Cgo=
--e89a8ff1c3262ff48304c2797c41--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
