From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 8/9] rfkill: Userspace control for airplane mode
Date: Thu, 18 Feb 2016 21:12:44 +0100
Message-ID: <1455826364.2084.22.camel@sipsolutions.net>
References: <1454946096-9752-1-git-send-email-jprvita@endlessm.com>
	 <1454946096-9752-9-git-send-email-jprvita@endlessm.com>
	 (sfid-20160208_164148_881936_346879EA)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Darren Hart <dvhart@infradead.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	platform-driver-x86@vger.kernel.org, linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux@endlessm.com,
	=?ISO-8859-1?Q?Jo=E3o?= Paulo Rechi Vita
	<jprvita@endlessm.com>
To: =?ISO-8859-1?Q?Jo=E3o?= Paulo Rechi Vita <jprvita@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454946096-9752-9-git-send-email-jprvita@endlessm.com> (sfid-20160208_164148_881936_346879EA)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Sorry for the delay reviewing this.



On Mon, 2016-02-08 at 10:41 -0500, Jo=C3=A3o Paulo Rechi Vita wrote:
> Provide an interface for the airplane-mode indicator be controlled
> from
> userspace. User has to first acquire the control through
> RFKILL_OP_AIRPLANE_MODE_ACQUIRE and keep the fd open for the whole
> time
> it wants to be in control of the indicator. Closing the fd or using
> RFKILL_OP_AIRPLANE_MODE_RELEASE restores the default policy.

I've come to the conclusion that the new ops are probably the best
thing to do here.

> +Userspace can also override the default airplane-mode indicator
> policy through
> +/dev/rfkill. Control of the airplane mode indicator has to be
> acquired first,
> +using RFKILL_OP_AIRPLANE_MODE_ACQUIRE, and is only available for one
> userspace
> +application at a time. Closing the fd or using
> RFKILL_OP_AIRPLANE_MODE_RELEASE
> +reverts the airplane-mode indicator back to the default kernel
> policy and makes
> +it available for other applications to take control. Changes to the
> +airplane-mode indicator state can be made using
> RFKILL_OP_AIRPLANE_MODE_CHANGE,
> +passing the new value in the 'soft' field of 'struct rfkill_event'.

I don't really see any value in _RELEASE, since an application can just
close the fd? I'd prefer not having the duplicate functionality
and=C2=A0force us to exercise the single code path every time.

> =C2=A0For further details consult Documentation/ABI/stable/sysfs-clas=
s-
> rfkill.
> diff --git a/include/uapi/linux/rfkill.h
> b/include/uapi/linux/rfkill.h
> index 2e00dce..9cb999b 100644
> --- a/include/uapi/linux/rfkill.h
> +++ b/include/uapi/linux/rfkill.h
> @@ -67,6 +67,9 @@ enum rfkill_operation {
> =C2=A0	RFKILL_OP_DEL,
> =C2=A0	RFKILL_OP_CHANGE,
> =C2=A0	RFKILL_OP_CHANGE_ALL,
> +	RFKILL_OP_AIRPLANE_MODE_ACQUIRE,
> +	RFKILL_OP_AIRPLANE_MODE_RELEASE,
> +	RFKILL_OP_AIRPLANE_MODE_CHANGE,
> =C2=A0};
=C2=A0
> @@ -1199,7 +1202,7 @@ static ssize_t rfkill_fop_write(struct file
> *file, const char __user *buf,
> =C2=A0	if (copy_from_user(&ev, buf, count))
> =C2=A0		return -EFAULT;
> =C2=A0
> -	if (ev.op !=3D RFKILL_OP_CHANGE && ev.op !=3D
> RFKILL_OP_CHANGE_ALL)
> +	if (ev.op < RFKILL_OP_CHANGE)
> =C2=A0		return -EINVAL;

You need to also reject invalid high values, like 27.

> =C2=A0	mutex_lock(&rfkill_global_mutex);
> =C2=A0
> +	if (ev.op =3D=3D RFKILL_OP_AIRPLANE_MODE_ACQUIRE) {
> +		if (rfkill_apm_owned && !data->is_apm_owner) {
> +			count =3D -EACCES;
> +		} else {
> +			rfkill_apm_owned =3D true;
> +			data->is_apm_owner =3D true;
> +		}
> +	}
> +
> +	if (ev.op =3D=3D RFKILL_OP_AIRPLANE_MODE_RELEASE) {

It would probably be better to simply use "switch (ev.op)" and make the
default case do a reject.

> =C2=A0	if (ev.op =3D=3D RFKILL_OP_CHANGE_ALL)
> =C2=A0		rfkill_update_global_state(ev.type, ev.soft);

Also moving the existing code inside the switch, of course.

johannes
