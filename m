From: Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 5/9] rfkill: Factor rfkill_global_states[].cur assignments
Date: Tue, 9 Feb 2016 09:40:49 +1100
Message-ID: <CAGRGNgV0fFDnL25SYQv-F8oYqX3THD-PSCVs3puSX6a1vhD+fg@mail.gmail.com>
References: <1454946096-9752-1-git-send-email-jprvita@endlessm.com> <1454946096-9752-6-git-send-email-jprvita@endlessm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Darren Hart <dvhart-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	platform-driver-x86-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-6IF/jdPJHihWk0Htik3J/w@public.gmane.org,
	=?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita-6IF/jdPJHihWk0Htik3J/w@public.gmane.org>
To: =?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1454946096-9752-6-git-send-email-jprvita-6IF/jdPJHihWk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Jo=C3=A3o,

On Tue, Feb 9, 2016 at 2:41 AM, Jo=C3=A3o Paulo Rechi Vita <jprvita@gma=
il.com> wrote:
> Factor all assignments to rfkill_global_states[].cur into a single
> function rfkill_update_global_state().
>
> Signed-off-by: Jo=C3=A3o Paulo Rechi Vita <jprvita-6IF/jdPJHihWk0Htik3J/w@public.gmane.org>

Looks sane to me.

Reviewed-by: Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

> ---
>  net/rfkill/core.c | 38 +++++++++++++++++---------------------
>  1 file changed, 17 insertions(+), 21 deletions(-)
>
> diff --git a/net/rfkill/core.c b/net/rfkill/core.c
> index 56d79cb..8b96869 100644
> --- a/net/rfkill/core.c
> +++ b/net/rfkill/core.c
> @@ -302,6 +302,19 @@ static void rfkill_set_block(struct rfkill *rfki=
ll, bool blocked)
>                 rfkill_event(rfkill);
>  }
>
> +static void rfkill_update_global_state(enum rfkill_type type, bool b=
locked)
> +{
> +       int i;
> +
> +       if (type !=3D RFKILL_TYPE_ALL) {
> +               rfkill_global_states[type].cur =3D blocked;
> +               return;
> +       }
> +
> +       for (i =3D 0; i < NUM_RFKILL_TYPES; i++)
> +               rfkill_global_states[i].cur =3D blocked;
> +}
> +
>  #ifdef CONFIG_RFKILL_INPUT
>  static atomic_t rfkill_input_disabled =3D ATOMIC_INIT(0);
>
> @@ -319,15 +332,7 @@ static void __rfkill_switch_all(const enum rfkil=
l_type type, bool blocked)
>  {
>         struct rfkill *rfkill;
>
> -       if (type =3D=3D RFKILL_TYPE_ALL) {
> -               int i;
> -
> -               for (i =3D 0; i < NUM_RFKILL_TYPES; i++)
> -                       rfkill_global_states[i].cur =3D blocked;
> -       } else {
> -               rfkill_global_states[type].cur =3D blocked;
> -       }
> -
> +       rfkill_update_global_state(type, blocked);
>         list_for_each_entry(rfkill, &rfkill_list, node) {
>                 if (rfkill->type !=3D type && type !=3D RFKILL_TYPE_A=
LL)
>                         continue;
> @@ -1164,15 +1169,8 @@ static ssize_t rfkill_fop_write(struct file *f=
ile, const char __user *buf,
>
>         mutex_lock(&rfkill_global_mutex);
>
> -       if (ev.op =3D=3D RFKILL_OP_CHANGE_ALL) {
> -               if (ev.type =3D=3D RFKILL_TYPE_ALL) {
> -                       enum rfkill_type i;
> -                       for (i =3D 0; i < NUM_RFKILL_TYPES; i++)
> -                               rfkill_global_states[i].cur =3D ev.so=
ft;
> -               } else {
> -                       rfkill_global_states[ev.type].cur =3D ev.soft=
;
> -               }
> -       }
> +       if (ev.op =3D=3D RFKILL_OP_CHANGE_ALL)
> +               rfkill_update_global_state(ev.type, ev.soft);
>
>         list_for_each_entry(rfkill, &rfkill_list, node) {
>                 if (rfkill->idx !=3D ev.idx && ev.op !=3D RFKILL_OP_C=
HANGE_ALL)
> @@ -1261,10 +1259,8 @@ static struct miscdevice rfkill_miscdev =3D {
>  static int __init rfkill_init(void)
>  {
>         int error;
> -       int i;
>
> -       for (i =3D 0; i < NUM_RFKILL_TYPES; i++)
> -               rfkill_global_states[i].cur =3D !rfkill_default_state=
;
> +       rfkill_update_global_state(RFKILL_TYPE_ALL, !rfkill_default_s=
tate);
>
>         error =3D class_register(&rfkill_class);
>         if (error)
> --
> 2.5.0
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wirel=
ess" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



--=20
Julian Calaby

Email: julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Profile: http://www.google.com/profiles/julian.calaby/
