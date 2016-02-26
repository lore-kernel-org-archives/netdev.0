From: Jouni Malinen <j@w1.fi>
Subject: Re: [PATCHv2 08/10] rfkill: Use switch to demux userspace operations
Date: Fri, 26 Feb 2016 19:59:25 +0200
Message-ID: <20160226175925.GA9331@w1.fi>
References: <1456159001-20307-1-git-send-email-jprvita@endlessm.com>
 <1456159001-20307-9-git-send-email-jprvita@endlessm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Darren Hart <dvhart-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	platform-driver-x86-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-6IF/jdPJHihWk0Htik3J/w@public.gmane.org,
	=?utf-8?B?Sm/Do28=?= Paulo Rechi Vita <jprvita-6IF/jdPJHihWk0Htik3J/w@public.gmane.org>
To: =?utf-8?B?Sm/Do28=?= Paulo Rechi Vita <jprvita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1456159001-20307-9-git-send-email-jprvita-6IF/jdPJHihWk0Htik3J/w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 22, 2016 at 11:36:39AM -0500, Jo=C3=A3o Paulo Rechi Vita wr=
ote:
> Using a switch to handle different ev.op values in rfkill_fop_write()
> makes the code easier to extend, as out-of-range values can always be
> handled by the default case.

This breaks rfkill.. There are automated test scripts for testing this
area (and most of Wi-Fi for that matter. It would be nice if these were
used for changes before they get contributed upstream..

http://buildbot.w1.fi/hwsim/

This specific commit broke all the rfkill_* test cases because of
following:

> diff --git a/net/rfkill/core.c b/net/rfkill/core.c
> @@ -1199,29 +1200,32 @@ static ssize_t rfkill_fop_write(struct file *=
file, const char __user *buf,
> -	list_for_each_entry(rfkill, &rfkill_list, node) {
> -		if (rfkill->idx !=3D ev.idx && ev.op !=3D RFKILL_OP_CHANGE_ALL)
> -			continue;
> -
> -		if (rfkill->type !=3D ev.type && ev.type !=3D RFKILL_TYPE_ALL)
> -			continue;

Note that RFKILL_TYPE_ALL here..

> +		list_for_each_entry(rfkill, &rfkill_list, node)
> +			if (rfkill->type =3D=3D ev.type ||
> +			    ev.type =3D=3D RFKILL_TYPE_ALL)
> +				rfkill_set_block(rfkill, ev.soft);

It was included for RFKILL_OP_CHANGE_ALL.

> +	case RFKILL_OP_CHANGE:
> +		list_for_each_entry(rfkill, &rfkill_list, node)
> +			if (rfkill->idx =3D=3D ev.idx && rfkill->type =3D=3D ev.type)
> +				rfkill_set_block(rfkill, ev.soft);

but not for RFKILL_OP_CHANGE..

This needs following to work:


diff --git a/net/rfkill/core.c b/net/rfkill/core.c
index 59ff92d..c4bbd19 100644
--- a/net/rfkill/core.c
+++ b/net/rfkill/core.c
@@ -1239,7 +1239,9 @@ static ssize_t rfkill_fop_write(struct file *file=
, const char __user *buf,
 		break;
 	case RFKILL_OP_CHANGE:
 		list_for_each_entry(rfkill, &rfkill_list, node)
-			if (rfkill->idx =3D=3D ev.idx && rfkill->type =3D=3D ev.type)
+			if (rfkill->idx =3D=3D ev.idx &&
+			    (rfkill->type =3D=3D ev.type ||
+			     ev.type =3D=3D RFKILL_TYPE_ALL))
 				rfkill_set_block(rfkill, ev.soft);
 		ret =3D 0;
 		break;
=20
--=20
Jouni Malinen                                            PGP id EFC895F=
A
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
