From: "Jim Nisbet" <niz@vencraft.com>
Subject: kernel bug fix: entered/exited promiscuous mode flip/flop error
Date: Mon, 30 Jun 2003 14:06:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C2E3E72093950249A1ED5534473788D7054911@baltic.tablus.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: <linux-net@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Re: bug in entering/exiting promiscuous read mode

A number of people have mentioned that they get a weird situation where w=
hen
they *start* a program that does promiscuous network reads (with, say,
=91tcpdump =96i eth0=92). They then get a kernel message =93left promiscu=
ous mode=94
when the program starts and the message =93entered promiscuous mode=94 wh=
en it
exits =96 the exact opposite of what should happen.=A0 I=92ve tracked thi=
s problem
down and fixed it in the 2.4.20 kernel sources.=A0 I have also verified t=
hat
the problem still exists in the latest dev sources (2.5.73).=A0 The patch=
 file
is at the end of this email.
=A0
The problem comes when the interface is =93downed=94 the dev->promiscuity=
 count
gets incorrectly decremented by 2.=A0 This happens because the
dev_change_flags routine calls dev_mc_upload which decrements the count a=
nd
the count gets decremented a 2nd time when dev_change_flags calls dev_clo=
se
which calls
notifier_call_chain->packet_notifier->packet_dev_mclist->packet_dev_mc.=A0=
 The
logic in dev_set_promiscuity is to test if dev->promiscuity =3D=3D 0.=A0 =
What
happens is the count is now set to -1.=A0 When a new caller increments th=
e
count by 1 to enter promisc mode but that means that the count is now set=
 to
0 which means exit promisc; when the caller exits the count is decremente=
d
and is once again set to -1 which means re-enter promisc mode (since the
count is not =3D=3D 0).
=A0
There is a similar problem when the interface is enabled when there is
already a promisc reader.=A0 The count is incremented twice.=A0=20
=A0
I=92ve fixed the problem and verified the fix by running tcpdump and then
doing various combinations of ifconfig..up/down.=A0 I also added one new
diagnostic message and changed the code so that it will not do the invers=
e
logic thing if the count should ever be wrong again in the future.
=A0
=A0
My solution involves minor changes to net/core/dev.c and
net/packet/af_packet.c.=A0 The patch file is attached to this email.=A0 T=
he
changes are:
=A0
1.=A0 Don=92t increment/decrement the promisc count if the interface is n=
ot up
in packet_dev_mc routine.=A0 Note: the request to be in promisc mode is s=
till
stored on the multicast (mc) list so when the interface is enabled the
interface will be put back in promisc mode by dev_mc_upload as it should =
be.
=A0
2.=A0 In packet_notifier call packet_dev_mclist to remove multicast/promi=
sc
mode when the interface is GOING_DOWN not DOWN.=A0 Since if it is =93DOWN=
=94 the
request would now be ignored.
=A0
3.=A0 Change dev_set_promiscuity routine to check for a count of <=3D 0 a=
nd then
set the count to 0 and unset promisc mode.=A0 What this means is that if =
the
count is ever wrong the interface will go out of promisc mode =93too earl=
y=94.=A0
But a new program could still be started and it would enter promisc mode
again.=A0 It will never invert the logic.
=A0
4.=A0 Write a kernel info message whenever the use count is
incremented/decremented instead of *just* when promisc is turned on/off.=A0=
 If
a 2nd caller uses setsockopt to put the interface in promisc mode, a mess=
age
would be generated:
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 Jun 29 16:57:08 tabby kernel: =
device eth1 still in
promiscuous mode (use count now 2)
=A0
and when one of the existing callers closes the socket connection then th=
e
message would be:
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 Jun 29 16:57:20 tabby kernel: =
device eth1 still in
promiscuous mode (use count now 1)
=A0
=A0
I hope these changes or something like it can get incorporated in some
future release.=A0 For those who don=92t want to patch the kernel, I=92d =
say stay
away from ifconfig up/down if you have a promisc read operation going.
=A0
Best,
/j


=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D here is the =
diff -u for the changes
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

diff -ruN linux-2.4.20-18.8/net/core/dev.c
linux-2.4.20-18.8-tablus/net/core/dev.c
--- linux-2.4.20-18.8/net/core/dev.c	2003-05-29 03:46:18.000000000 -0700
+++ linux-2.4.20-18.8-tablus/net/core/dev.c	2003-06-29
16:59:45.000000000 -0700
@@ -1949,8 +1949,10 @@
 	unsigned short old_flags =3D dev->flags;
=20
 	dev->flags |=3D IFF_PROMISC;
-	if ((dev->promiscuity +=3D inc) =3D=3D 0)
+	if ((dev->promiscuity +=3D inc) <=3D 0) {
+	        dev->promiscuity =3D 0;
 		dev->flags &=3D ~IFF_PROMISC;
+	}
 	if (dev->flags^old_flags) {
 #ifdef CONFIG_NET_FASTROUTE
 		if (dev->flags&IFF_PROMISC) {
@@ -1963,6 +1965,12 @@
 		printk(KERN_INFO "device %s %s promiscuous mode\n",
 		       dev->name, (dev->flags&IFF_PROMISC) ? "entered" :
"left");
 	}
+	else {
+	        if (dev->flags&IFF_PROMISC)
+                        printk(KERN_INFO "device %s still in promiscuous
mode"
+		               " (use count now %d)\n",=20
+      		               dev->name, dev->promiscuity);
+	}
 }
=20
 /**
diff -ruN linux-2.4.20-18.8/net/packet/af_packet.c
linux-2.4.20-18.8-tablus/net/packet/af_packet.c
--- linux-2.4.20-18.8/net/packet/af_packet.c	2003-05-29
03:47:00.000000000 -0700
+++ linux-2.4.20-18.8-tablus/net/packet/af_packet.c	2003-06-29
15:02:22.000000000 -0700
@@ -1146,6 +1146,9 @@
 #ifdef CONFIG_PACKET_MULTICAST
 static void packet_dev_mc(struct net_device *dev, struct packet_mclist *=
i,
int what)
 {
+        if (!(dev->flags & IFF_UP))
+                return;
+
 	switch (i->type) {
 	case PACKET_MR_MULTICAST:
 		if (what > 0)
@@ -1396,6 +1399,8 @@
 				}
 				spin_unlock(&po->bind_lock);
 			}
+			break;
+		case NETDEV_GOING_DOWN:
 #ifdef CONFIG_PACKET_MULTICAST
 			if (po->mclist)
 				packet_dev_mclist(dev, po->mclist, -1);
