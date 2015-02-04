From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH v3 2/3] genetlink: disallow subscribing to unknown mcast groups
Date: Wed, 04 Feb 2015 12:55:36 +0100
Message-ID: <87egq5uc07.fsf@nemi.mork.no>
References: <1421404634-8973-1-git-send-email-johannes@sipsolutions.net>
	<1421404634-8973-2-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jeff Layton <jeff.layton@primarydata.com>,
	Sedat Dilek <sedat.dilek@gmail.com>,
	Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:49864 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933010AbbBDLzy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 06:55:54 -0500
In-Reply-To: <1421404634-8973-2-git-send-email-johannes@sipsolutions.net>
	(Johannes Berg's message of "Fri, 16 Jan 2015 11:37:13 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg <johannes@sipsolutions.net> writes:

> diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
> index 2e11061ef885..c18d3f5624b2 100644
> --- a/net/netlink/genetlink.c
> +++ b/net/netlink/genetlink.c
> @@ -985,7 +985,7 @@ static struct genl_multicast_group genl_ctrl_grou=
ps[] =3D {
> =20
>  static int genl_bind(struct net *net, int group)
>  {
> -	int i, err =3D 0;
> +	int i, err =3D -ENOENT;
> =20
>  	down_read(&cb_lock);
>  	for (i =3D 0; i < GENL_FAM_TAB_SIZE; i++) {

This change cause serious problems for acpid, as reported on
https://bugzilla.kernel.org/show_bug.cgi?id=3D92121

The end user visible result is that acpid fails to detect events like A=
C
power disconnect, battery alarms etc, which can be a bit of a problem i=
f
you trust a battery alarm to trigger an emergency hibernation.  As I
happen to do...

Given the timing, I request that this patch is reverted for v3.19.
Thanks.

Sample acpid debug output, tracing the socket calls, running on a plain
v3.19-rc7:

nemi:/tmp# strace -s 128 -e trace=3Dsocket,bind,sendmsg,recvmsg -f acpi=
d -l -d
socket(PF_LOCAL, SOCK_DGRAM|SOCK_CLOEXEC, 0) =3D 3
Deprecated /proc/acpi/event was not found.  Trying netlink and the inpu=
t layer...
input layer /dev/input/event0 (AT Translated Set 2 keyboard) opened suc=
cessfully, fd 4
input layer /dev/input/event1 (Lid Switch) opened successfully, fd 5
input layer /dev/input/event10 (HDA Intel Dock Headphone) opened succes=
sfully, fd 6
input layer /dev/input/event11 (HDA Intel Headphone) opened successfull=
y, fd 7
input layer /dev/input/event2 (Sleep Button) opened successfully, fd 8
input layer /dev/input/event3 (Power Button) opened successfully, fd 9
input layer /dev/input/event4 (ThinkPad Extra Buttons) opened successfu=
lly, fd 10
input layer /dev/input/event6 (Video Bus) opened successfully, fd 11
input layer /dev/input/event8 (HDA Intel Mic) opened successfully, fd 1=
2
input layer /dev/input/event9 (HDA Intel Dock Mic) opened successfully,=
 fd 13
inotify fd: 14
inotify wd: 1
socket(PF_NETLINK, SOCK_RAW|SOCK_CLOEXEC, NETLINK_GENERIC) =3D 15
bind(15, {sa_family=3DAF_NETLINK, pid=3D0, groups=3D00000000}, 12) =3D =
0
sendmsg(15, {msg_name(12)=3D{sa_family=3DAF_NETLINK, pid=3D0, groups=3D=
00000000}, msg_iov(1)=3D[{"$\0\0\0\20\0\5\0\21\10\322T\0\0\0\0\3\0\0\0\=
17\0\2\0acpi_event\0\0", 36}], msg_controllen=3D0, msg_flags=3D0}, 0) =3D=
 36
recvmsg(15, {msg_name(12)=3D{sa_family=3DAF_NETLINK, pid=3D0, groups=3D=
00000000}, msg_iov(1)=3D[{"h\0\0\0\20\0\0\0\21\10\322T\314l\0\0\1\2\0\0=
\17\0\2\0acpi_event\0\0\6\0\1\0\23\0\0\0\10\0\3\0\1\0\0\0\10\0\4\0\0\0\=
0\0\10\0\5\0\1\0\0\0$\0\7\0 \0\1\0\10\0\2\0\2\0\0\0\22\0\1\0acpi_mc_gro=
up\0\0\0", 16384}], msg_controllen=3D0, msg_flags=3DMSG_CMSG_CLOEXEC}, =
MSG_CMSG_CLOEXEC) =3D 104
socket(PF_NETLINK, SOCK_RAW|SOCK_CLOEXEC, NETLINK_GENERIC) =3D 15
bind(15, {sa_family=3DAF_NETLINK, pid=3D0, groups=3D00000002}, 12) =3D =
-1 ENOENT (No such file or directory)
Cannot bind netlink socket: No such file or directory
acpid: cannot open generic netlink socket
socket(PF_LOCAL, SOCK_STREAM|SOCK_CLOEXEC|SOCK_NONBLOCK, 0) =3D 16
bind(16, {sa_family=3DAF_LOCAL, sun_path=3D"/var/run/acpid.socket"}, 11=
0) =3D 0
acpid: starting up with netlink and the input layer
parsing conf file /etc/acpi/events/powerbtn-acpi-support
acpid: skipping non-file /etc/acpi/events/CVS
parsing conf file /etc/acpi/events/any
parsing conf file /etc/acpi/events/generic-hibernatebtn
parsing conf file /etc/acpi/events/low_battery
parsing conf file /etc/acpi/events/lidbtn
parsing conf file /etc/acpi/events/sleepbtn
acpid: 6 rules loaded
acpid: waiting for events: event logging is on



Bj=C3=B8rn
