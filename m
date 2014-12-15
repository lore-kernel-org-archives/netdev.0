From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: Bluetooth: Add framework for device found filtering based on UUID
Date: Mon, 15 Dec 2014 12:40:39 +0100
Message-ID: <CAMuHMdX7w0RF0Azn2-p88=maXOcy1pfXy_KHznV4Vozd9=5mfg@mail.gmail.com>
References: <20141211224808.A00526614C4@gitolite.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Marcel Holtmann <marcel@holtmann.org>,
	Johan Hedberg <johan.hedberg@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141211224808.A00526614C4@gitolite.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 11, 2014 at 11:48 PM, Linux Kernel Mailing List
<linux-kernel@vger.kernel.org> wrote:
> Gitweb:     http://git.kernel.org/linus/;a=3Dcommit;h=3Db487b9ce9340a=
6e98d7f8277399304b23b7be456
> Commit:     b487b9ce9340a6e98d7f8277399304b23b7be456
> Parent:     bda157a40077447b25a1172a17b8ef81a2905cb7
> Refname:    refs/heads/master
> Author:     Marcel Holtmann <marcel@holtmann.org>
> AuthorDate: Fri Dec 5 10:55:57 2014 +0100
> Committer:  Johan Hedberg <johan.hedberg@intel.com>
> CommitDate: Fri Dec 5 12:37:35 2014 +0200
>
>     Bluetooth: Add framework for device found filtering based on UUID
>
>     Using Start Service Discovery provides the option to specifiy a l=
ist
>     of UUID that are used to filter out device found events. This pat=
ch
>     provides the framework for hooking up the UUID filter.
>
>     Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
>     Signed-off-by: Johan Hedberg <johan.hedberg@intel.com>
> ---
>  net/bluetooth/mgmt.c | 54 ++++++++++++++++++++++++++++++++++++++++++=
++++++++--
>  1 file changed, 52 insertions(+), 2 deletions(-)
>
> diff --git a/net/bluetooth/mgmt.c b/net/bluetooth/mgmt.c
> index 1715c91..e39190a 100644
> --- a/net/bluetooth/mgmt.c
> +++ b/net/bluetooth/mgmt.c
> @@ -6802,6 +6802,11 @@ void mgmt_read_local_oob_data_complete(struct =
hci_dev *hdev, u8 *hash192,
>         mgmt_pending_remove(cmd);
>  }
>
> +static bool eir_has_uuids(u8 *eir, u16 eir_len, u16 uuid_count, u8 (=
*uuids)[16])
> +{
> +       return false;
> +}
> +
>  void mgmt_device_found(struct hci_dev *hdev, bdaddr_t *bdaddr, u8 li=
nk_type,
>                        u8 addr_type, u8 *dev_class, s8 rssi, u32 flag=
s,
>                        u8 *eir, u16 eir_len, u8 *scan_rsp, u8 scan_rs=
p_len)
> @@ -6809,6 +6814,7 @@ void mgmt_device_found(struct hci_dev *hdev, bd=
addr_t *bdaddr, u8 link_type,
>         char buf[512];
>         struct mgmt_ev_device_found *ev =3D (void *) buf;
>         size_t ev_size;
> +       bool match;

net/bluetooth/mgmt.c: In function =E2=80=98mgmt_device_found=E2=80=99:
net/bluetooth/mgmt.c:6993: warning: =E2=80=98match=E2=80=99 may be used=
 uninitialized
in this function

All tests for "match" are protected by "if (hdev->discovery.uuid_count =
> 0)",
so we only have to care about that case.

>         /* Don't send events for a non-kernel initiated discovery. Wi=
th
>          * LE one exception is if we have pend_le_reports > 0 in whic=
h
> @@ -6843,15 +6849,59 @@ void mgmt_device_found(struct hci_dev *hdev, =
bdaddr_t *bdaddr, u8 link_type,
>         ev->rssi =3D rssi;
>         ev->flags =3D cpu_to_le32(flags);
>
> -       if (eir_len > 0)
> +       if (eir_len > 0) {
> +               /* When using service discovery and a list of UUID is
> +                * provided, results with no matching UUID should be
> +                * dropped. In case there is a match the result is
> +                * kept and checking possible scan response data
> +                * will be skipped.
> +                */
> +               if (hdev->discovery.uuid_count > 0) {
> +                       match =3D eir_has_uuids(eir, eir_len,
> +                                             hdev->discovery.uuid_co=
unt,
> +                                             hdev->discovery.uuids);
> +                       if (!match)
> +                               return;
> +               }

If we get here and if (hdev->discovery.uuid_count > 0), "match" must be=
 true.

> +
> +               /* Copy EIR or advertising data into event */
>                 memcpy(ev->eir, eir, eir_len);
> +       } else {
> +               /* When using service discovery and a list of UUID is
> +                * provided, results with empty EIR or advertising da=
ta
> +                * should be dropped since they do not match any UUID=
=2E
> +                */
> +               if (hdev->discovery.uuid_count > 0)
> +                       return;

We will never get here if (hdev->discovery.uuid_count > 0).

> +       }

Hence if we get here and if (hdev->discovery.uuid_count > 0),
"match" is always true.

>         if (dev_class && !eir_has_data_type(ev->eir, eir_len, EIR_CLA=
SS_OF_DEV))
>                 eir_len =3D eir_append_data(ev->eir, eir_len, EIR_CLA=
SS_OF_DEV,
>                                           dev_class, 3);
>
> -       if (scan_rsp_len > 0)
> +       if (scan_rsp_len > 0) {
> +               /* When using service discovery and a list of UUID is
> +                * provided, results with no matching UUID should be
> +                * dropped if there is no previous match from the
> +                * advertising data.
> +                */
> +               if (hdev->discovery.uuid_count > 0) {
> +                       if (!match && !eir_has_uuids(scan_rsp, scan_r=
sp_len,

"match" is true, so this whole block is useless.

> +                                                    hdev->discovery.=
uuid_count,
> +                                                    hdev->discovery.=
uuids))
> +                               return;
> +               }
> +
> +               /* Append scan response data to event */
>                 memcpy(ev->eir + eir_len, scan_rsp, scan_rsp_len);
> +       } else {
> +               /* When using service discovery and a list of UUID is
> +                * provided, results with empty scan response and no
> +                * previous matched advertising data should be droppe=
d.
> +                */
> +               if (hdev->discovery.uuid_count > 0 && !match)

"match" is true, so this whole block is useless.

> +                       return;
> +       }
>
>         ev->eir_len =3D cpu_to_le16(eir_len + scan_rsp_len);
>         ev_size =3D sizeof(*ev) + eir_len + scan_rsp_len;

Is my analysis correct?
Am I missing something?

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
                                -- Linus Torvalds
