From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: Re: [PATCH] RFC: ipv4: share sysctl net/ipv4/conf/DEVNAME/ tables
Date: Sat, 15 Jan 2011 13:09:43 +0200
Message-ID: <AANLkTi=S7eNeR9OPNh9Ox3Oa8fOHGy5vaF4ooc5CpTw7@mail.gmail.com>
References: <AANLkTikVDn_0c+Ob_XnUauEMBZhsYCh+42QF7FwM=Bey@mail.gmail.com> <20110115104139.GA4816@p183.telecom.by>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Nick Piggin <npiggin@kernel.dk>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Christoph Hellwig <hch@lst.de>,
	Dave Chinner <dchinner@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Octavian Purdila <opurdila@ixiacom.com>,
	Vlad Dogaru <ddvlad@rosedu.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:63064 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752189Ab1AOLKE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Jan 2011 06:10:04 -0500
Received: by iyj18 with SMTP id 18so3250895iyj.19
        for <netdev@vger.kernel.org>; Sat, 15 Jan 2011 03:10:04 -0800 (PST)
In-Reply-To: <20110115104139.GA4816@p183.telecom.by>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 15, 2011 at 12:41 PM, Alexey Dobriyan <adobriyan@gmail.com>=
 wrote:
> On Sat, Jan 15, 2011 at 04:46:11AM +0200, Lucian Adrian Grijincu wrot=
e:
>> To gain access to the name of the directory above a file, sysctl
>> handlers are passed an extra argument: the 'struct file*'
>> corresponding to the file. From the file we walk up one level to fin=
d
>> the name of the device. None of the other handlers were changed to
>> receive this extra parameter, but due to C's calling convention they
>> shouldn't care.
>
> We don't do creepy stuff like that.


I did this this way to not waste time changing all the handlers in the
tree and then get this patch struck down as uninterested, ugly-hack or
being suggested another more sensible, yet completely different
approach.


> I wonder where interactions with device renaming are handled.


I took two things taken into consideration:
* the .procname of the device directory has it's own copy of the device=
 name
  This was inherited from the previous version

* when looking for a "struct net_device*" we might not find any:

+		/* the device could have been renamed (SIOCSIFADDR) or
+		 * deleted since we started accessing it's proc sysctl */
+		dev =3D dev_get_by_name(net, dev_name);
+		if (dev =3D=3D NULL)
+			return -ENOENT;


I'm not sure (will look into it later) whether
   filp->f_path.dentry->d_parent->d_name.name;
is still valid if a rename is running concurrently.


On device rename we run this

net/ipv4/devinet.c:
static int inetdev_event(struct notifier_block *this, unsigned long eve=
nt,
			 void *ptr)
=2E...
	case NETDEV_CHANGENAME:
		/* Do not notify about label change, this event is
		 * not interesting to applications using netlink.
		 */
		inetdev_changename(dev, in_dev);

		devinet_sysctl_unregister(in_dev);
		devinet_sysctl_register(in_dev);


I'm not sure whether this code can run in parallel with the
proc_handlers and if it can if it will invalidate
   filp->f_path.dentry->d_parent->d_name.name;


but I'll look into it.

Is there anything else that I should check regarding net device renamin=
g?

--=20
=C2=A0.
=2E.: Lucian
