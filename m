From: Luiz Augusto von Dentz <luiz.dentz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC] Bluetooth: Keep master role when SCO or eSCO is active
Date: Wed, 28 May 2014 11:45:13 +0300
Message-ID: <CABBYNZLn7Uw=Jcu_haMEczmfgY5pnfz=jwktwKDqmQ29JXk+GA@mail.gmail.com>
References: <1401256588-1467-1-git-send-email-kiran.kumar@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"hyungseoung.yoo" <hyungseoung.yoo-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>,
	Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
	Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"open list:BLUETOOTH SUBSYSTEM" <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"open list:NETWORKING [GENERAL]" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Android Kernel Team <kernel-team-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>,
	John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Jaikumar Ganesh <jaikumarg-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
To: Kiran Kumar Raparthy <kiran.kumar-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1401256588-1467-1-git-send-email-kiran.kumar-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

On Wed, May 28, 2014 at 8:56 AM, Kiran Kumar Raparthy
<kiran.kumar-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org> wrote:
> From: "hyungseoung.yoo" <hyungseoung.yoo-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
>
> Preserve the master role when SCO or eSCO is active
> as this improves compatability with lots of
> headset and chipset combinations.
>
> This is one of the number of patches from the Android AOSP
> common.git tree, which is used on almost all Android devices.
> It looks like it would improve support for compatibility with
> lot of headset,so I wanted to submit it for review to see
> if it should go upstream.
>
> Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org> (maintainer:BLUETOOTH SUBSYSTEM)
> Cc: Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org> (maintainer:BLUETOOTH SUBSYSTEM)
> Cc: Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (maintainer:BLUETOOTH SUBSYSTEM)
> Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> (maintainer:NETWORKING [GENERAL])
> Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list:BLUETOOTH SUBSYSTEM)
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list:NETWORKING [GENERAL])
> Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list)
> Cc: Android Kernel Team <kernel-team-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
> Cc: John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> Signed-off-by: hyungseoung.yoo <hyungseoung.yoo-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
> Signed-off-by: Jaikumar Ganesh <jaikumarg-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
> [kiran: Added context to commit message]
> Signed-off-by: Kiran Raparthy <kiran.kumar-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> ---
>  net/bluetooth/hci_event.c | 12 +++++++++++-
>  1 file changed, 11 insertions(+), 1 deletion(-)
>
> diff --git a/net/bluetooth/hci_event.c b/net/bluetooth/hci_event.c
> index 15010a2..6f944d5 100644
> --- a/net/bluetooth/hci_event.c
> +++ b/net/bluetooth/hci_event.c
> @@ -1915,6 +1915,15 @@ unlock:
>         hci_conn_check_pending(hdev);
>  }
>
> +static inline bool is_sco_active(struct hci_dev *hdev)
> +{
> +       if (hci_conn_hash_lookup_state(hdev, SCO_LINK, BT_CONNECTED) ||
> +                       (hci_conn_hash_lookup_state(hdev, ESCO_LINK,
> +                                                   BT_CONNECTED)))
> +               return true;
> +       return false;
> +}
> +
>  static void hci_conn_request_evt(struct hci_dev *hdev, struct sk_buff *skb)
>  {
>         struct hci_ev_conn_request *ev = (void *) skb->data;
> @@ -1961,7 +1970,8 @@ static void hci_conn_request_evt(struct hci_dev *hdev, struct sk_buff *skb)
>
>                         bacpy(&cp.bdaddr, &ev->bdaddr);
>
> -                       if (lmp_rswitch_capable(hdev) && (mask & HCI_LM_MASTER))
> +                       if (lmp_rswitch_capable(hdev) && ((mask & HCI_LM_MASTER)
> +                                               || is_sco_active(hdev)))
>                                 cp.role = 0x00; /* Become master */
>                         else
>                                 cp.role = 0x01; /* Remain slave */
> --
> 1.8.2.1

I guess the real issue is the possibility of creating a scatternet if
you have more than one connection, I will send a patch for scatternet
shortly but that does not guarantee the remote device wont reject it.


-- 
Luiz Augusto von Dentz
