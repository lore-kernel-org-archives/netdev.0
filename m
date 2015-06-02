From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 2/2] Bluetooth: btusb: Add reset_resume function
Date: Tue, 2 Jun 2015 03:32:05 +0200
Message-ID: <C3A9A104-993C-4C8F-A323-93FF58F03162@holtmann.org>
References: <1433207682-15064-1-git-send-email-labbott@fedoraproject.org> <1433207682-15064-2-git-send-email-labbott@fedoraproject.org>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>, Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>,
	Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Rafael J. Wysocki" <rafael.j.wysocki-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Gustavo F. Padovan" <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	USB list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Laura Abbott <labbott-rxtnV0ftBwyoClj4AeEUq9i2O/JbrIOy@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1433207682-15064-2-git-send-email-labbott-rxtnV0ftBwyoClj4AeEUq9i2O/JbrIOy@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Laura,

> Some USB hubs may lose power across suspend/resume.
> Add a reset_resume callback to properly reset those bluetoot devices.
>=20
> Signed-off-by: Laura Abbott <labbott-rxtnV0ftBwyoClj4AeEUq9i2O/JbrIOy@public.gmane.org>
> ---
> Now the setup function is called again with the HCI_RESET_RESUME
> flag set. The various functions could then use that RESET_RESUME
> flag to determine if loading the firmware is appropriate or not.
> ---
> drivers/bluetooth/btusb.c | 16 ++++++++++++++++
> 1 file changed, 16 insertions(+)
>=20
> diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
> index 3c10d4d..34884cf 100644
> --- a/drivers/bluetooth/btusb.c
> +++ b/drivers/bluetooth/btusb.c
> @@ -3382,6 +3382,21 @@ done:
>=20
> 	return err;
> }
> +
> +static int btusb_reset_resume(struct usb_interface *intf)
> +{
> +	struct btusb_data *data =3D usb_get_intfdata(intf);
> +	struct hci_dev *hdev =3D data->hdev;
> +	int ret;
> +
> +	BT_DBG("intf %p", intf);
> +
> +	ret =3D btusb_resume(intf);
> +	if (ret)
> +		return ret;
> +
> +	return hci_reset_resume_dev(hdev);
> +}

it seems convenient to call btusb_resume, but I would really prefer if =
we didn=E2=80=99t. From what I know is that when reset_resume callback =
is called, then the device has been reset. So that means any prior tran=
sfer we have remembered is null and void. So even trying to replay any =
of it is just a lost cause.

Instead we should clear any pending transfers and clear everything and =
instead pretend that we bring the transport back to its virgin state. I=
t also means that isochronous transfers should be all killed since we w=
ill have no SCO connections after this. Remember that we are telling th=
e Bluetooth core to reset this device.

Regards

Marcel
