From: Alessandro Suardi <alessandro.suardi@gmail.com>
Subject: Re: inbound connection problems when "netlink: test for all flags of
 the NLM_F_DUMP composite" commit applied
Date: Tue, 18 Jan 2011 19:10:35 +0100
Message-ID: <AANLkTikUPRfYupw1-Py5mHeN+pFv-zMKhmK3DKixxsH4@mail.gmail.com>
References: <20110118172340.GB1843@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jamal <hadi@cyberus.ca>, David Miller <davem@davemloft.net>,
	pablo@netfilter.org, arthur.marsh@internode.on.net,
	jengelh@medozas.de, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:61793 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751032Ab1ARSKg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 13:10:36 -0500
Received: by qwa26 with SMTP id 26so6164233qwa.19
        for <netdev@vger.kernel.org>; Tue, 18 Jan 2011 10:10:36 -0800 (PST)
In-Reply-To: <20110118172340.GB1843@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 18, 2011 at 6:23 PM, Jarek Poplawski <jarkao2@gmail.com> wr=
ote:
> [PATCH] netlink: Fix possible NLM_F_DUMP misuse in genetlink
>
> NLM_F_DUMP flags should be applied to GET requests only, eg. rtnetlin=
k
> tests message type to verify this. Since genetlink can't do the same
> use "practical" test for ops->dumpit (assuming NEW request won't be
> mixed with GET).
>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> Cc: Jan Engelhardt <jengelh@medozas.de>
> Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> Cc: Jamal Hadi Salim <hadi@cyberus.ca>
> ---
> Not for stable before testing!
>
> diff -Nurp a/net/netlink/genetlink.c b/net/netlink/genetlink.c
> --- a/net/netlink/genetlink.c =A0 2011-01-18 16:58:16.000000000 +0100
> +++ b/net/netlink/genetlink.c =A0 2011-01-18 17:08:43.000000000 +0100
> @@ -519,15 +519,16 @@ static int genl_rcv_msg(struct sk_buff *
> =A0 =A0 =A0 =A0 =A0 =A0security_netlink_recv(skb, CAP_NET_ADMIN))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EPERM;
>
> - =A0 =A0 =A0 if (nlh->nlmsg_flags & NLM_F_DUMP) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ops->dumpit =3D=3D NULL)
> + =A0 =A0 =A0 if (ops->dumpit) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (nlh->nlmsg_flags & NLM_F_DUMP) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 genl_unlock();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D netlink_dump_st=
art(net->genl_sock, skb, nlh,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0ops->dumpit, ops->done);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 genl_lock();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EOPNOTSUPP;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 genl_unlock();
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D netlink_dump_start(net->genl_so=
ck, skb, nlh,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0ops->dumpit, ops->done);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 genl_lock();
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0if (ops->doit =3D=3D NULL)
>

2.6.37-git18 + netlink revert + this patch
 - fixes Avahi
 - breaks acpid

Upon startup I have:

Starting acpi daemon: RTNETLINK1 answers: Operation not supported
acpid: error talking to the kernel via netlink




=46rom strace output:

open("/dev/input/event6", O_RDONLY|O_NONBLOCK) =3D 8
fcntl(8, F_SETFD, FD_CLOEXEC)           =3D 0
ioctl(8, 0x80604520, 0x7fffb3418550)    =3D 8
ioctl(8, 0x80604521, 0x7fffb34185b0)    =3D 96
open("/dev/input/event8", O_RDONLY|O_NONBLOCK) =3D 9
fcntl(9, F_SETFD, FD_CLOEXEC)           =3D 0
ioctl(9, 0x80604520, 0x7fffb3418550)    =3D 8
ioctl(9, 0x80604532, 0x7fffb3418c10)    =3D 8
close(9)                                =3D 0
inotify_init()                          =3D 9
inotify_add_watch(9, "/dev/input", IN_CREATE) =3D 1
socket(PF_NETLINK, SOCK_RAW, 16)        =3D 10
setsockopt(10, SOL_SOCKET, SO_SNDBUF, [32768], 4) =3D 0
setsockopt(10, SOL_SOCKET, SO_RCVBUF, [32768], 4) =3D 0
bind(10, {sa_family=3DAF_NETLINK, pid=3D0, groups=3D00000000}, 12) =3D =
0
getsockname(10, {sa_family=3DAF_NETLINK, pid=3D4298, groups=3D00000000}=
, [12]) =3D 0
sendmsg(10, {msg_name(12)=3D{sa_family=3DAF_NETLINK, pid=3D0,
groups=3D00000000},
msg_iov(1)=3D[{"$\0\0\0\20\0\5\0\346\3265M\0\0\0\0\3\0\0\0\17\0\2\0acpi=
_eve"...,
36}], msg_controllen=3D0, msg_flags=3D0}, 0) =3D 36
recvmsg(10, {msg_name(12)=3D{sa_family=3DAF_NETLINK, pid=3D0,
groups=3D00000000},
msg_iov(1)=3D[{"8\0\0\0\2\0\0\0\346\3265M\312\20\0\0\241\377\377\377$\0=
\0\0\20\0\5\0\346\3265M"...,
16384}], msg_controllen=3D0, msg_flags=3D0}, 0) =3D 56
dup(2)                                  =3D 11
fcntl(11, F_GETFL)                      =3D 0x1 (flags O_WRONLY)
close(11)                               =3D 0
write(2, "RTNETLINK1 answers: Operation no"..., 44RTNETLINK1 answers:
Operation not supported
) =3D 44
write(2, "acpid: error talking to the kern"..., 47acpid: error talking
to the kernel via netlink
) =3D 47
close(10)                               =3D 0
socket(PF_NETLINK, SOCK_RAW, 16)        =3D 10
setsockopt(10, SOL_SOCKET, SO_SNDBUF, [32768], 4) =3D 0
setsockopt(10, SOL_SOCKET, SO_RCVBUF, [32768], 4) =3D 0
bind(10, {sa_family=3DAF_NETLINK, pid=3D0, groups=3D00000000}, 12) =3D =
0
getsockname(10, {sa_family=3DAF_NETLINK, pid=3D4298, groups=3D00000000}=
, [12]) =3D 0
unlink("/var/run/acpid.socket")         =3D 0
socket(PF_FILE, SOCK_STREAM, 0)         =3D 11
bind(11, {sa_family=3DAF_FILE, path=3D"/var/run/acpid.socket"}, 110) =3D=
 0
listen(11, 10)                          =3D 0



If more debugging/testing is needed, do ping me. Thanks,

--alessandro

=A0"There's always a siren singing you to shipwreck"

=A0=A0 (Radiohead, "There There")
