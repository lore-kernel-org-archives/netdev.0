From: Arkadiusz Miskiewicz <arekm@beep.pl>
Subject: iproute2 and 2.6.0-test9
Date: Mon, 27 Oct 2003 12:42:36 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310271236.58440.arekm@beep.pl>
Reply-To: admin@beep.pl
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Reply-to: admin@beep.pl
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I have problem with 2.6.0-test9. iproute hangs when flushing ie:

[root@mobarm arekm]# ip a
1: lo: <LOOPBACK,UP> mtu 16436 qdisc noqueue
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
    inet6 ff02::1/128 scope global
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,NOTRAILERS,UP> mtu 1500 qdisc pfifo_fast ql=
en=20
1000
    link/ether 00:a0:cc:da:d9:3c brd ff:ff:ff:ff:ff:ff
    inet 192.168.2.2/24 brd 192.168.2.255 scope global eth0
    inet6 fe80::2a0:ccff:feda:d93c/64 scope link
       valid_lft forever preferred_lft forever
    inet6 ff02::1:ffda:d93c/128 scope global
       valid_lft forever preferred_lft forever
    inet6 ff02::1/128 scope global
       valid_lft forever preferred_lft forever
3: irda0: <NOARP,UP> mtu 2048 qdisc pfifo_fast qlen 8
    link/irda
4: sit0: <NOARP> mtu 1480 qdisc noop
    link/sit 0.0.0.0 brd 0.0.0.0

[root@mobarm arekm]# ip link set eth0 down
[root@mobarm arekm]# ip a flush dev eth0
(hangs here but I can interrupt it with ctrl+c)

[arekm@mobarm arekm]$ ps aux | grep "ip a"
root     12479 93.9  0.1  1560  328 pts/3    R    12:33   0:18 ip a flush=
 dev=20
eth0
arekm    12513  0.0  0.2  2100  620 pts/5    S    12:33   0:00 grep ip a
[arekm@mobarm arekm]$ ps arx -O wchan | grep "ip a"
12479 -      R pts/3    00:00:57 ip a flush dev eth0

eats 93.9% cpu,

When doing the other way - first flush, then down everything is ok:
[root@mobarm arekm]# ip a flush dev eth0
[root@mobarm arekm]# ip link set eth0 down
[root@mobarm arekm]#=20

iproute2-2.4.7.ss020116

strace shows:
5525 recvmsg(3, {msg_name(12)=3D{sa_family=3DAF_NETLINK,=20
sa_data=3D"\0\0\0\0\0\0\0\0\0\0\0\0\0\0"}, msg_iov(1)=3D[{"@\0\0\0\24\0\2=
\
0\177\35\255?\245<\0\0\n\200\200\376\1\0"..., 8192}], msg_controllen=3D0,=
=20
msg_flags=3D0}, 0) =3D 192
15525 recvmsg(3, {msg_name(12)=3D{sa_family=3DAF_NETLINK,=20
sa_data=3D"\0\0\0\0\0\0\0\0\0\0\0\0\0\0"}, msg_iov(1)=3D[{"\24\0\0\0\3\0\=
2
\0\177\35\255?\245<\0\0\0\0\0\0\1\0\0\0"..., 8192}], msg_controllen=3D0,=20
msg_flags=3D0}, 0) =3D 20
15525 sendto(3, "@\0\0\0\25\0\1\0\200\35\255?\245<\0\0\n\200\200\0\2\0\0"=
...,=20
64, 0, {sa_family=3DAF_NETLINK, sa_data=3D"\0\0\0\
0\0\0\0\0\0\0\20\306\377\277"}, 12) =3D 64
15525 sendto(3, "\24\0\0\0\26\0\1\3\201\35\255?\0\0\0\0\0\365\377\277", 2=
0, 0,=20
{sa_family=3DAF_NETLINK, sa_data=3D"\0\0\0\0\0\0\
0\0\0\0\20\306\377\277"}, 12) =3D 20
15525 recvmsg(3, {msg_name(12)=3D{sa_family=3DAF_NETLINK,=20
sa_data=3D"\0\0\0\0\0\0\0\0\0\0\0\0\0\0"}, msg_iov(1)=3D[{"$\0\0\0\2\0\0\=
0
\200\35\255?\245<\0\0\235\377\377\377@\0"..., 8192}], msg_controllen=3D0,=
=20
msg_flags=3D0}, 0) =3D 36
15525 recvmsg(3, {msg_name(12)=3D{sa_family=3DAF_NETLINK,=20
sa_data=3D"\0\0\0\0\0\0\0\0\0\0\0\0\0\0"}, msg_iov(1)=3D[{"<\0\0\0\24\0\2=
\
0\201\35\255?\245<\0\0\2\10\200\376\1\0"..., 8192}], msg_controllen=3D0,=20
msg_flags=3D0}, 0) =3D 60
15525 recvmsg(3, {msg_name(12)=3D{sa_family=3DAF_NETLINK,=20
sa_data=3D"\0\0\0\0\0\0\0\0\0\0\0\0\0\0"}, msg_iov(1)=3D[{"@\0\0\0\24\0\2=
\
0\201\35\255?\245<\0\0\n\200\200\376\1\0"..., 8192}], msg_controllen=3D0,=
=20
msg_flags=3D0}, 0) =3D 192
15525 recvmsg(3, {msg_name(12)=3D{sa_family=3DAF_NETLINK,=20
sa_data=3D"\0\0\0\0\0\0\0\0\0\0\0\0\0\0"}, msg_iov(1)=3D[{"\24\0\0\0\3\0\=
2
\0\201\35\255?\245<\0\0\0\0\0\0\1\0\0\0"..., 8192}], msg_controllen=3D0,=20
msg_flags=3D0}, 0) =3D 20
15525 sendto(3, "@\0\0\0\25\0\1\0\202\35\255?\245<\0\0\n\200\200\0\2\0\0"=
...,=20
64, 0, {sa_family=3DAF_NETLINK, sa_data=3D"\0\0\0\
0\0\0\0\0\0\0\20\306\377\277"}, 12) =3D 64
15525 sendto(3, "\24\0\0\0\26\0\1\3\203\35\255?\0\0\0\0\0\365\377\277", 2=
0, 0,=20
{sa_family=3DAF_NETLINK, sa_data=3D"\0\0\0\0\0\0\
0\0\0\0\20\306\377\277"}, 12) =3D 20
15525 recvmsg(3, {msg_name(12)=3D{sa_family=3DAF_NETLINK,=20
sa_data=3D"\0\0\0\0\0\0\0\0\0\0\0\0\0\0"}, msg_iov(1)=3D[{"$\0\0\0\2\0\0\=
0
\202\35\255?\245<\0\0\235\377\377\377@\0"..., 8192}], msg_controllen=3D0,=
=20
msg_flags=3D0}, 0) =3D 36
15525 recvmsg(3, {msg_name(12)=3D{sa_family=3DAF_NETLINK,=20
sa_data=3D"\0\0\0\0\0\0\0\0\0\0\0\0\0\0"}, msg_iov(1)=3D[{"<\0\0\0\24\0\2=
\
0\203\35\255?\245<\0\0\2\10\200\376\1\0"..., 8192}], msg_controllen=3D0,=20
msg_flags=3D0}, 0) =3D 60
15525 recvmsg(3, {msg_name(12)=3D{sa_family=3DAF_NETLINK,=20
sa_data=3D"\0\0\0\0\0\0\0\0\0\0\0\0\0\0"}, msg_iov(1)=3D[{"@\0\0\0\24\0\2=
\
0\203\35\255?\245<\0\0\n\200\200\376\1\0"..., 8192}], msg_controllen=3D0,=
=20
msg_flags=3D0}, 0) =3D 192
15525 recvmsg(3, {msg_name(12)=3D{sa_family=3DAF_NETLINK,=20
sa_data=3D"\0\0\0\0\0\0\0\0\0\0\0\0\0\0"}, msg_iov(1)=3D[{"\24\0\0\0\3\0\=
2
\0\203\35\255?\245<\0\0\0\0\0\0\1\0\0\0"..., 8192}], msg_controllen=3D0,=20
msg_flags=3D0}, 0) =3D 20
15525 sendto(3, "@\0\0\0\25\0\1\0\204\35\255?\245<\0\0\n\200\200\0\2\0\0"=
...,=20
64, 0, {sa_family=3DAF_NETLINK, sa_data=3D"\0\0\0\
0\0\0\0\0\0\0\20\306\377\277"}, 12) =3D 64
15525 sendto(3, "\24\0\0\0\26\0\1\3\205\35\255?\0\0\0\0\0\365\377\277", 2=
0, 0,=20
{sa_family=3DAF_NETLINK, sa_data=3D"\0\0\0\0\0\0\
0\0\0\0\20\306\377\277"}, 12) =3D 20
15525 recvmsg(3, {msg_name(12)=3D{sa_family=3DAF_NETLINK,=20
sa_data=3D"\0\0\0\0\0\0\0\0\0\0\0\0\0\0"}, msg_iov(1)=3D[{"$\0\0\0\2\0\0\=
0
\204\35\255?\245<\0\0\235\377\377\377@\0"..., 8192}], msg_controllen=3D0,=
=20
msg_flags=3D0}, 0) =3D 36
15525 recvmsg(3, {msg_name(12)=3D{sa_family=3DAF_NETLINK,=20
sa_data=3D"\0\0\0\0\0\0\0\0\0\0\0\0\0\0"}, msg_iov(1)=3D[{"<\0\0\0\24\0\2=
\
0\205\35\255?\245<\0\0\2\10\200\376\1\0"..., 8192}], msg_controllen=3D0,=20
msg_flags=3D0}, 0) =3D 60
15525 recvmsg(3, {msg_name(12)=3D{sa_family=3DAF_NETLINK,=20
sa_data=3D"\0\0\0\0\0\0\0\0\0\0\0\0\0\0"}, msg_iov(1)=3D[{"@\0\0\0\24\0\2=
\
0\205\35\255?\245<\0\0\n\200\200\376\1\0"..., 8192}], msg_controllen=3D0,=
=20
msg_flags=3D0}, 0) =3D 192
15525 recvmsg(3, {msg_name(12)=3D{sa_family=3DAF_NETLINK,=20
sa_data=3D"\0\0\0\0\0\0\0\0\0\0\0\0\0\0"}, msg_iov(1)=3D[{"\24\0\0\0\3\0\=
2
\0\205\35\255?\245<\0\0\0\0\0\0\1\0\0\0"..., 8192}], msg_controllen=3D0,=20
msg_flags=3D0}, 0) =3D 20
15525 sendto(3, "@\0\0\0\25\0\1\0\206\35\255?\245<\0\0\n\200\200\0\2\0\0"=
...,=20
64, 0, {sa_family=3DAF_NETLINK, sa_data=3D"\0\0\0\
0\0\0\0\0\0\0\20\306\377\277"}, 12) =3D 64
15525 sendto(3, "\24\0\0\0\26\0\1\3\207\35\255?\0\0\0\0\0\365\377\277", 2=
0, 0,=20
{sa_family=3DAF_NETLINK, sa_data=3D"\0\0\0\0\0\0\
0\0\0\0\20\306\377\277"}, 12) =3D 20
15525 recvmsg(3, {msg_name(12)=3D{sa_family=3DAF_NETLINK,=20
sa_data=3D"\0\0\0\0\0\0\0\0\0\0\0\0\0\0"}, msg_iov(1)=3D[{"$\0\0\0\2\0\0\=
0
\206\35\255?\245<\0\0\235\377\377\377@\0"..., 8192}], msg_controllen=3D0,=
=20
msg_flags=3D0}, 0) =3D 36
15525 recvmsg(3, {msg_name(12)=3D{sa_family=3DAF_NETLINK,=20
sa_data=3D"\0\0\0\0\0\0\0\0\0\0\0\0\0\0"}, msg_iov(1)=3D[{"<\0\0\0\24\0\2=
\
0\207\35\255?\245<\0\0\2\10\200\376\1\0"..., 8192}], msg_controllen=3D0,=20
msg_flags=3D0}, 0) =3D 60
15525 recvmsg(3, {msg_name(12)=3D{sa_family=3DAF_NETLINK,=20
sa_data=3D"\0\0\0\0\0\0\0\0\0\0\0\0\0\0"}, msg_iov(1)=3D[{"@\0\0\0\24\0\2=
\
0\207\35\255?\245<\0\0\n\200\200\376\1\0"..., 8192}], msg_controllen=3D0,=
=20
msg_flags=3D0}, 0) =3D 192
15525 recvmsg(3, {msg_name(12)=3D{sa_family=3DAF_NETLINK,=20
sa_data=3D"\0\0\0\0\0\0\0\0\0\0\0\0\0\0"}, msg_iov(1)=3D[{"\24\0\0\0\3\0\=
2
\0\207\35\255?\245<\0\0\0\0\0\0\1\0\0\0"..., 8192}], msg_controllen=3D0,=20
msg_flags=3D0}, 0) =3D 20
15525 sendto(3, "@\0\0\0\25\0\1\0\210\35\255?\245<\0\0\n\200\200\0\2\0\0"=
...,=20
64, 0, {sa_family=3DAF_NETLINK, sa_data=3D"\0\0\0\
0\0\0\0\0\0\0\20\306\377\277"}, 12) =3D 64
15525 sendto(3, "\24\0\0\0\26\0\1\3\211\35\255?\0\0\0\0\0\365\377\277", 2=
0, 0,=20
{sa_family=3DAF_NETLINK, sa_data=3D"\0\0\0\0\0\0\
0\0\0\0\20\306\377\277"}, 12) =3D 20


ps. please cc me as I'm not subscribed
--=20
Arkadiusz Mi=B6kiewicz, Grupa BeeProvider - http://www.beep.pl/
