From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG UNIX: Poison overwritten with 2.6.31-rc6-00223-g6c30c53
Date: Tue, 08 Sep 2009 09:38:16 +0200
Message-ID: <4AA609E8.3060408@gmail.com>
References: <alpine.DEB.2.00.0909072323350.3940@parag-desktop> <df9815e70909072151l2686231en76773418aaf9deeb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Parag Warudkar <parag.lkml@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jike Song <albcamus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:43902 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753782AbZIHHiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2009 03:38:16 -0400
In-Reply-To: <df9815e70909072151l2686231en76773418aaf9deeb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jike Song a =C3=A9crit :
> On Tue, Sep 8, 2009 at 11:56 AM, Parag Warudkar<parag.lkml@gmail.com>=
 wrote:
>> On Thu, Aug 27, 2009 at 4:45 PM, Jike Song<albcamus@gmail.com> wrote=
:
>>>> hi, I hit this with vnc. Below is part of dmesg :
>>> Still producible in 2.6.31-rc9, anybody helps?
>> How does one go about reproducing this? You said VNC triggers this b=
ut
>> what VNC version, server or client? What distro and what needs to be=
 done
>> with VNC to trigger this problem? I ask since I use VNC myself and t=
est -git kernels
>> and have not encountered this issue.
>>
>> Parag
>>
>>
> Thanks for your attention,  CC netdev this time.
>=20
> VNC server: tigervnc-server-0.0.91-0.11.fc11.x86_64
> VNC client:  TurboVNC Viewer version 0.5 for Solaris
> Distro       : Fedora 11, x86-64
>=20
> I specify gnome-init in xstartup, below is my xstartup file, with thi=
s
> file one only need to run vncviewer from the client to produce this
> bug:
>=20
> #!/bin/sh
>=20
> unset LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES
> unset LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT
> unset LC_IDENTIFICATION LC_ALL LANG LANGUAGE PAGER
> LANG=3Dzh_CN.UTF-8
> export LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES
> export LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT
> export LC_IDENTIFICATION LC_ALL LANG LANGUAGE PAGER
> export G_FILENAME_ENCODING=3D@locale
> XMODIFIERS=3D"@im=3DSCIM"
> GTK_IM_MODULE=3D"scim"
> export XMODIFIERS GTK_IM_MODULE
> if type scim &> /dev/null ; then
> 	scim -d &
> fi
>=20
> vncconfig -iconic &
> unset SESSION_MANAGER
> unset DBUS_SESSION_BUS_ADDRESS
> OS=3D`uname -s`
> if [ $OS =3D 'Linux' ]; then
>   case "$WINDOWMANAGER" in
>     *gnome*)
>       if [ -e /etc/SuSE-release ]; then
>         PATH=3D$PATH:/opt/gnome/bin
>         export PATH
>       fi
>       ;;
>   esac
> fi
> if [ -x /etc/X11/xinit/xinitrc ]; then
>   exec /etc/X11/xinit/xinitrc
> fi
> if [ -f /etc/X11/xinit/xinitrc ]; then
>   exec sh /etc/X11/xinit/xinitrc
> fi
> [ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
> xsetroot -solid grey
> xterm -geometry 1024x768 -ls -title "$VNCDESKTOP Desktop" &
> gnome-init &
>=20
>=20
>=20

We decrement a refcnt while object already freed.

(SLUB DEBUG poisons the zone with 0x6B pattern)

You might add this patch to trigger a WARN_ON when refcnt >=3D 0x600000=
00U
in sk_free() : We'll see the path trying to delete an already freed soc=
k

diff --git a/net/core/sock.c b/net/core/sock.c
index 7633422..1cb85ff 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1058,6 +1058,7 @@ static void __sk_free(struct sock *sk)

 void sk_free(struct sock *sk)
 {
+	WARN_ON(atomic_read(&sk->sk_wmem_alloc) >=3D 0x60000000U);
 	/*
 	 * We substract one from sk_wmem_alloc and can know if
 	* some packets are still in some tx queue.

