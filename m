From: Alexander Aring <alex.aring@gmail.com>
Subject: IEEE 802.15.4 6LoWPAN need to change netdev type UAPI - How we can
 do it right now?
Date: Sun, 2 Nov 2014 13:41:13 +0100
Message-ID: <20141102124111.GA10216@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-wpan@vger.kernel.org, linux-bluetooth@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:52597 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752466AbaKBMlX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Nov 2014 07:41:23 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The IEEE 802.15.4 with 6LoWPAN has a big problem. We have two interfaces
one "wpan" interface which belongs the IEEE 802.15.4 subsystem and the
"lowpan" interface for IEEE 802.15.4 6LoWPAN layer.

The big problem is that "wpan" and "lowpan" interfaces use the same
ARPHRD type. This is "ARPHRD_IEEE802154".

In kernelspace we can't decide if I handle now a "wpan" interface or
"lowpan" interface and there exist two problems which I know.

These are:

1. Freeing resources

If we create a "wpan" interface we allocate some private data, etc.
which the "lowpan" doesn't allocate. If we free/unregister a wpan
interface over netlink we will free these private resources. Now if
we call the netlink with an "lowpan" interface we try to freeing the
same resources. Of course this will fail because on allocation we don't
allocate the "wpan" resources. We can't decide at netlink interface if
it's a "wpan" or "lowpan" interface. On a "lowpan" interface we could
return -EINVAL then, but we can't decide that.

Possible hacking solution would be to remember the ifindex of all "wpan"
registrated interfaces and check if it fits. I don't know if this
solution could be 100% save.

2. Confusing userspace applications

Userspace applications can't also decide between "wpan" and "lowpan"
interfaces. Currently applications like "wireshark" will decode all
"packets" on "lowpan" as IEEE 802.15.4 frames by default. Correct
should be IPv6 packets decoding. Changing wireshark to decode
ARPHRD_IEEE802154 as IPv6 by default will occur that a "wpan" interface
will have a wrong default decoding.

Possible hacking solution would here to try to create a IPv6 socket if
it's fail it's an wpan interface, if succesful we have a lowpan interface.


In my opinion we need to change this behaviour, but it's an UAPI change
and I will do it right the first time. Possible types we could change to
is "ARPHRD_6LOWPAN" which is also used by bluetooth.


Two solutions:

- Changing type to "ARPHRD_6LOWPAN":

Furthermore we need to make "small" runtime decisions in IPv6. The
ARPHRD_6LOWPAN is used by bluetooth and maybe possible IEEE 802.15.4.
These "small" runtime decisions needs L2 informations from bluetooth or
IEEE 802.15.4. If we change now to "ARPHRD_6LOWPAN" we have a much
similar issue that we can't decide between a 6LoWPAN bluetooth interface
or 6LoWPAN 802.15.4 interface. At userspace this should make no
difference. It's only to decide interface types inside upper layers
inside kernelspace.

Possible solution could be to introduce a ARPHRD_SUBTYPE and place it to
the beginning of netdev_priv(dev) structure. This structure could look
like:

struct lowpan_netdev_priv {
	/* subtype of ARPHRD_6LOWPAN */
	enum lowpan_subtype subtype;
	/* private data of L2 subtype */
	void *priv;
};

In upper layers like IPv6 we could first check if it's a ARPHRD_6LOWPAN
type. After that and we need really L2 different handling we can check
on the lowpan_subtype subtype which is placed in netdev_priv.

This solution require that all ARPHRD_6LOWPAN interfaces use the
lowpan_netdev_priv structure in netdev_priv. I am also not 100% sure if
we need such information in userspace, maybe we can introduce also a
subtype netlink type to get the ARPHRD_6LOWPAN subtype.


- introduce new ARPHRD "ARPHRD_6LOWPAN_IEEE802154"

Just add another type without complicated subtype mechanism.



I hope it's clear that I run into several issues because "wpan" and
"lowpan" uses the same ARPHRD. This code is already 4 years old and
there exists already userspace software which checks on
ARPHRD_IEEE802154 for lowpan interfaces. I need some help how we can
deal now with this "just change the dev->type?". If yes, to which type?

- Alex
