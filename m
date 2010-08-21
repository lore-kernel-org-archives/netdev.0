From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: About unix_autobind()
Date: Sat, 21 Aug 2010 20:34:18 +0800
Message-ID: <AANLkTi=oWoHUmm_3xkRY7UzoXTuptKvUHzn0gK2WDiSa@mail.gmail.com>
References: <201008212101.IJG87048.QMOHFtSOVOLFFJ@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:49173 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751363Ab0HUMek convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Aug 2010 08:34:40 -0400
Received: by wwi17 with SMTP id 17so5532735wwi.1
        for <netdev@vger.kernel.org>; Sat, 21 Aug 2010 05:34:38 -0700 (PDT)
In-Reply-To: <201008212101.IJG87048.QMOHFtSOVOLFFJ@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 21, 2010 at 8:01 PM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
> I was browsing unix_autobind() and wondered what happens if all names=
 in
> Unix domain socket's abstract namespace were in use.
>
> Below part is unix_autobind() from linux-2.6.36-rc1/net/unix/af_unix.=
c
>
> 710 retry:
> 711 =A0 =A0 =A0 =A0 addr->len =3D sprintf(addr->name->sun_path+1, "%0=
5x", ordernum) + 1 + sizeof(short);
> 712 =A0 =A0 =A0 =A0 addr->hash =3D unix_hash_fold(csum_partial(addr->=
name, addr->len, 0));
> 713
> 714 =A0 =A0 =A0 =A0 spin_lock(&unix_table_lock);
> 715 =A0 =A0 =A0 =A0 ordernum =3D (ordernum+1)&0xFFFFF;
> 716
> 717 =A0 =A0 =A0 =A0 if (__unix_find_socket_byname(net, addr->name, ad=
dr->len, sock->type,
> 718 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 addr->hash)) {
> 719 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&unix_table_lock);
> 720 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Sanity yield. It is unusual ca=
se, but yet... */
> 721 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!(ordernum&0xFF))
> 722 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 yield();
> 723 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto retry;
> 724 =A0 =A0 =A0 =A0 }
>
> We can see that unix_autobind() allows 1048576 names.
>
> A machine with 256MB RAM:
>
> =A0# cat /proc/sys/fs/file-max
> =A024109
> =A0# cat /proc/sys/fs/file-nr
> =A0608 0 24109
>
> A machine with 1736MB RAM:
>
> =A0# cat /proc/sys/fs/file-max
> =A0174347
> =A0# cat /proc/sys/fs/file-nr
> =A096 0 174347
>
> /proc/sys/fs/file-max seems to be proportional to the amount of RAM.
> I don't have access to a machine with 10GB RAM (where /proc/sys/fs/fi=
le-max
> becomes larger than 1048576 by default). So, I manually set
>
> =A0# echo 1050000 > /proc/sys/fs/file-max
>
> and executed below program as non-root user.
>
> ---------- Test program start ----------
> #include <sys/socket.h>
> #include <sys/un.h>
> #include <unistd.h>
>
> int main(int argc, char *argv[])
> {
> =A0 =A0 =A0 =A0int i;
> =A0 =A0 =A0 =A0for (i =3D 0; i < 1030; i++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0switch (fork()) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case 0:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sleep(5);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0close(0);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0close(1);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0close(2);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0for (i =3D 0; i < 1024=
; i++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct=
 sockaddr_un addr;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int fd=
 =3D socket(PF_UNIX, SOCK_DGRAM, 0);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0addr.s=
un_family =3D AF_UNIX;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bind(f=
d, (struct sockaddr *) &addr, sizeof(addr.sun_family));
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0while (1)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sleep(=
1000);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case -1:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0write(1, "fork() faile=
d\n", 14);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 1;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0return 0;
> }
> ---------- Test program end ----------
>
> If there is not enough memory, OOM killer was invoked. OOM killer kil=
led
> /usr/sbin/httpd process rather than above test program. (Oops. Non-ro=
ot user
> was able to terminate other user's processes via OOM killer.)
>
> If there is enough memory (I can't test it), OOM killer will not be i=
nvoked.
> But if all names were occupied, I guess subsequent unix_autobind() by=
 other
> users will loop forever because it loops until a name becomes availab=
le.
> (I had to type "killall a.out" before above program occupies all name=
s, for
> the machine became very dull due to unix_autobind().)
>
> Maybe some safeguard is wanted.

You can add a counter of the names, and check it before allocating a ne=
w name.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
