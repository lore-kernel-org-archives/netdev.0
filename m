From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: iproute2: iplink_ stuff cleanup
Date: Mon, 19 Mar 2012 23:22:59 +0100
Message-ID: <CAGm1_kvbqOtArw4dUpnzTRB1JtfBCaAAeyFYCPrcaGYUF10NSg@mail.gmail.com>
References: <CAGm1_kuHYCRuoUEfBeV6GbjypUJgr1_058f-e4AhojHP1fTJWg@mail.gmail.com>
 <20120315091857.2114cb48@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:63043 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757687Ab2CSWXU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2012 18:23:20 -0400
Received: by yenl12 with SMTP id l12so5905093yen.19
        for <netdev@vger.kernel.org>; Mon, 19 Mar 2012 15:23:19 -0700 (PDT)
In-Reply-To: <20120315091857.2114cb48@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> I'm still struggling to get ip/iplink_* routines to show up in
>> Android's ip binary
>> (https://groups.google.com/d/topic/android-building/yjV4iYnT1Zc/disc=
ussion).
>> I've looked at the algorithm that is used to access those functions
>> (like can_parse_opt, vlan_parse_opt etc.)
>>
>> =C2=A0snprintf(buf, sizeof(buf), LIBDIR "/ip/link_%s.so", id);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 dlh =3D dlopen(buf, RTLD_LAZY);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (dlh =3D=3D NULL) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* look in c=
urrent binary, only open once */
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dlh =3D BODY=
;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (dlh =3D=3D=
 NULL) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 dlh =3D BODY =3D dlopen(NULL, RTLD_LAZY);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 if (dlh =3D=3D NULL)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return NULL;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 snprintf(buf, sizeof(buf), "%s_link_util=
", id);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 l =3D dlsym(dlh, buf);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (l =3D=3D NULL)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return NULL;
>>
>> as far as I can see from the ip/Makefile there are no dynamic libs
>> like /ip/link_%s.so. Wouldn't it be simpler to let all iplink_*
>> objects to export their interfaces via header files and just make a
>> table in ip/iplink.c to hold protocol ID and pointer at link_utils
>> struct.
>>
>> struct link_util can_link_util =3D {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 .id =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =3D "can",
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 .maxattr =C2=A0 =C2=A0 =C2=A0 =C2=A0=3D =
IFLA_CAN_MAX,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 .parse_opt =C2=A0 =C2=A0 =C2=A0=3D can_p=
arse_opt,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 .print_opt =C2=A0 =C2=A0 =C2=A0=3D can_p=
rint_opt,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 .print_xstats =C2=A0 =3D can_print_xstat=
s,
>> };
>>
>> Am I missing something?
>>
>> Regards,
>> Yegor
>
> Ip utilities have dynamic extensibility, it is possible for someone
> to add shared libraries for new functionality. This is a cool feature
> but isn't used directly by the standard code. It does use it indirect=
ly
> by using dlopen() to find functions locally.
>
> Think of it as introspection in C.
>
> I won't take it out of the standard version, but you may have to find
> another way to handle it on the Android universe.

The solution turned out to be simple:
https://android-review.googlesource.com/#/c/34240/.
-Wl,--no-gc-sections did the job.

Can you suggest some more pro arguments for dynamic method of
exporting API routines?

Regards,
Yegor
