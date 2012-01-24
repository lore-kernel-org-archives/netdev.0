From: =?UTF-8?Q?Sjur_Br=C3=A6ndeland?= <sjurbren@gmail.com>
Subject: Re: [PATCH] net: caif: Don't act on notification for non-caif devices
Date: Tue, 24 Jan 2012 11:52:27 +0100
Message-ID: <CAJK669acbPLTxTDrk_uqdB2FmewcSA+HF0qEFADgT8YdfNMcpQ@mail.gmail.com>
References: <1327390229-30170-1-git-send-email-levinsasha928@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, davej@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327390229-30170-1-git-send-email-levinsasha928@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sasha,

> Since the list of CAIF devices is stored in the net generic struct in=
 each
> net namespace, which is not initialized at that point, we see the fol=
lowing
> BUG():
>
> [ =C2=A0200.752016] kernel BUG at include/net/netns/generic.h:40!
=2E..
> [ =C2=A0200.752016] Call Trace:
> [ =C2=A0200.752016] =C2=A0[<ffffffff825c3cea>] ? get_cfcnfg+0x3a/0x18=
0
> [ =C2=A0200.752016] =C2=A0[<ffffffff821cf0b0>] ? lockdep_rtnl_is_held=
+0x10/0x20
> [ =C2=A0200.752016] =C2=A0[<ffffffff825c41be>] caif_device_notify+0x2=
e/0x530

Argh, my bad. This issue has been identified and fixed by David
Woodhouse earlier,
but was reintroduced again by me when adding support for CAIF over NCM.
The CAIF code is handling if net_generic() returns NULL, but I missed t=
hat
net_generic() does BUG_ON().

> Instead, we'll first check if the device in the notification is a CAI=
=46 device:
> =C2=A0- If it is - the net generic struct in that namespace must have=
 been already
> initialized.
> =C2=A0- If not - just ignore it as we don't care about other devices.
>
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>

Nack, we have to handle other device types than just ARPHDR_CAIF after
introducing
CAIF over USB/NCM. I'd rather fix this in netns by removing the BUG_ON
and return
NULL. How about this instead:

diff --git a/include/net/netns/generic.h b/include/net/netns/generic.h
index 3419bf5..0fc2eea 100644
--- a/include/net/netns/generic.h
+++ b/include/net/netns/generic.h
@@ -37,8 +37,10 @@ static inline void *net_generic(const struct net *ne=
t, int id

        rcu_read_lock();
        ng =3D rcu_dereference(net->gen);
-       BUG_ON(id =3D=3D 0 || id > ng->len);
-       ptr =3D ng->ptr[id - 1];
+       if (id =3D=3D 0 || id > ng->len)
+               ptr =3D NULL;
+       else
+               ptr =3D ng->ptr[id - 1];
        rcu_read_unlock();

        return ptr;

I'll post a patch for this soon.

Regards,
Sjur
