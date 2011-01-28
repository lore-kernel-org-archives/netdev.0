From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: Re: [PATCH] RFC: ipv4: share sysctl net/ipv4/conf/DEVNAME/ tables
Date: Fri, 28 Jan 2011 08:21:52 +0200
Message-ID: <AANLkTi=BtJRQm9bYerBhs-uW5j-ujVxvTDb3GRkAm-xF@mail.gmail.com>
References: <AANLkTikVDn_0c+Ob_XnUauEMBZhsYCh+42QF7FwM=Bey@mail.gmail.com> <20110115104139.GA4816@p183.telecom.by>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:48633 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754265Ab1A1GWN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jan 2011 01:22:13 -0500
Received: by iyj18 with SMTP id 18so2242389iyj.19
        for <netdev@vger.kernel.org>; Thu, 27 Jan 2011 22:22:12 -0800 (PST)
In-Reply-To: <20110115104139.GA4816@p183.telecom.by>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Resent to the list because the last reply got rejected because of HTML=
]


On Sat, Jan 15, 2011 at 12:41 PM, Alexey Dobriyan <adobriyan@gmail.com>=
 wrote:
> I wonder where interactions with device renaming are handled.

I did some digging and I'm pretty confident that this will not cause
problems with regards to device renaming.


On device rename these are the relevant call stacks:


RENAME
=E2=80=A2 dev_ioctl
  =E2=88=98 rtnl_lock();
  =E2=88=98 dev_ifsioc(net, &ifr, cmd);
    =E2=80=A3 dev_change_name
      =E2=80=A2 dev_get_valid_name
        =E2=88=98 strlcpy(dev->name, name, IFNAMSIZ)
      =E2=80=A2 call_netdevice_notifiers(NETDEV_CHANGENAME);
        =E2=88=98 inetdev_event
          =E2=80=A3 devinet_sysctl_unregister(in_dev)
            =E2=80=A2 unregister_sysctl_table(header)
              =E2=88=98 lock sysctl
              =E2=88=98 start_unregistering(header);
                =E2=80=A3 if (header->used) { unlock sysctl,
wait_for_completion; lock sysctl }
              =E2=88=98 unlock sysctl
          =E2=80=A3 devinet_sysctl_register(in_dev)
  =E2=88=98 rtnl_unlock();




HANDLER
=E2=80=A2 proc_sys_call_handler
  =E2=88=98 head =3D grab_header(inode)
    =E2=80=A3 sysctl_head_grab
      =E2=80=A2 lock sysctl
      =E2=80=A2 head->used++
      =E2=80=A2 unlock sysctl
  =E2=88=98 if (IS_ERR(head)) return err
  =E2=88=98 devinet_conf_handler
    =E2=80=A3 dev_get_by_name(dev, filp->f_path.dentry->d_parent->d_nam=
e.name)
  =E2=88=98 sysctl_head_finish(head)
    =E2=80=A3 lock sysctl
    =E2=80=A3 if (--head->used && unregistering) complete()
    =E2=80=A3 unlock sysctl


Compressed:
RENAME (under rtnl lock)
=E2=80=A2 R1: memcpy(dev->name, newname)
=E2=80=A2 R2: if the sysctl header is used wait until it's not used any=
 more,
      mark header as invalid

HANDLER:
=E2=80=A2 H1: get header, if header invalid, return error
=E2=80=A2 H2: dev_get_by_name
=E2=80=A2 H3: if there's someone waiting to unregister, complete it's a=
ction


Only one rename can be in progress at a time (because of the
rtnl_lock), so cases like A->B, C->A cannot run in parallel.  To
finish a device rename, we need to unregister the sysctl table header
first.


=E2=80=A2 R2 < H1: a RENAME runs before a HANDLER, then the HANDLER
           will fail at H1 (the sysctl header will be made invalid at R=
2).
=E2=80=A2 H1 < R2:
  =E2=88=98 HANDLER acquired the header
    =E2=80=A3 R1 < H2: dev_get_by_name will not find the device (becaus=
e R1 renamed it)
    =E2=80=A3 R1 > H2: dev_get_by_name will return the correct device
      	       (the name is still valid)



In conclusion, I don't see any race conditions and I don't see how we
could get the wrong device after a rename.

I've posted a new version of the patch with some improvements.


--=20
=C2=A0.
=2E.: Lucian
