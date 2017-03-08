From: Yaroslav Isakov <yaroslav.isakov@gmail.com>
Subject: tun offloads bug
Date: Wed, 8 Mar 2017 23:29:53 +0300
Message-ID: <CADS+iDW49e+oSw9p_MBOVk4Qojh+e00a5zix-sO8NQethn=pjg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=94eb2c131036f55a38054a3dfeeb
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:34868 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750770AbdCHUbM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 15:31:12 -0500
Received: by mail-wm0-f53.google.com with SMTP id v186so124204103wmd.0
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 12:30:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--94eb2c131036f55a38054a3dfeeb
Content-Type: text/plain; charset=UTF-8

Hello!
I've found a bug in TUN/TAP driver with offloads - when Qemu is trying
to set offloads on tap device, there is no error, but offloads are not
appied.

The cause of this is that udev in recent systemd is using ethtool to
disable offloads. So, udev is setting tun->dev->wanted_features via
ethtool ioctl to disable TSO, but when qemu is trying to set offloads,
it's using TUN/TAP ioctl which is not setting wanted_features, so
netdev_update_features will not see features qemu wants.

This can be easily reproduced - just run qemu with
guest_tso4=on,guest_tso6=on on systemd with systemd>=226 and after
booting the VM, ethtool -k tap0 will show that TSO4 is disabled and
TSO6 is enabled (systemd is not touching TSO6, that's why it's not
affected at all)
I've attached pretty trivial patch to fix this problem.

--94eb2c131036f55a38054a3dfeeb
Content-Type: text/x-patch; charset=US-ASCII; name="tun.patch"
Content-Disposition: attachment; filename="tun.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_j01f46or0

LS0tIHR1bi5jCTIwMTctMDMtMDggMjM6MTk6NDAuMTE3NjE1MjM1ICswMzAwCisrKyB0dW4uYy5u
ZXcJMjAxNy0wMy0wOCAyMzoyMDoxMi44ODY3NDkxOTUgKzAzMDAKQEAgLTE5MTksNiArMTkxOSw4
IEBACiAJCXJldHVybiAtRUlOVkFMOwogCiAJdHVuLT5zZXRfZmVhdHVyZXMgPSBmZWF0dXJlczsK
Kwl0dW4tPmRldi0+d2FudGVkX2ZlYXR1cmVzICY9IH5UVU5fVVNFUl9GRUFUVVJFUzsKKwl0dW4t
PmRldi0+d2FudGVkX2ZlYXR1cmVzIHw9IGZlYXR1cmVzOwogCW5ldGRldl91cGRhdGVfZmVhdHVy
ZXModHVuLT5kZXYpOwogCiAJcmV0dXJuIDA7Cg==
--94eb2c131036f55a38054a3dfeeb--
