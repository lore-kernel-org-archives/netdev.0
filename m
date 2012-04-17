From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: 3.3.0, 3.4-rc1 reproducible tun Oops
Date: Tue, 17 Apr 2012 16:18:53 +0400
Message-ID: <4F8D5FAD.10304@parallels.com>
References: <20120404220525.GD21505@hostway.ca> <1333593664.18626.577.camel@edumazet-glaptop> <20120417020852.GA18875@hostway.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Simon Kirby <sim@hostway.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:48398 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755821Ab2DQMS4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 08:18:56 -0400
In-Reply-To: <20120417020852.GA18875@hostway.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

17.04.2012 06:08, Simon Kirby =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Thu, Apr 05, 2012 at 04:41:04AM +0200, Eric Dumazet wrote:
>
>> Hmm, is it happening if you remove the nvidia module ?
>>
>> If yes, please try to add slub_debug=3DFZPU
>
> Finally got annoyed enough at this to bisect it. It doesn't happen ev=
ery
> time and I got a bit confused, but I finally tracked it down to:
>
> 1ab5ecb90cb6a3df1476e052f76a6e8f6511cb3d is the first bad commit
> commit 1ab5ecb90cb6a3df1476e052f76a6e8f6511cb3d
> Author: Stanislav Kinsbursky<skinsbursky@parallels.com>
> Date:   Mon Mar 12 02:59:41 2012 +0000
>
>      tun: don't hold network namespace by tun sockets
>
>      v3: added previously removed sock_put() to the tun_release() cal=
lback, because
>      sk_release_kernel() doesn't drop the socket reference.
>
>      v2: sk_release_kernel() used for socket release. Dummy tun_relea=
se() is
>      required for sk_release_kernel() --->  sock_release() --->  sock=
->ops->release()
>      call.
>
>      TUN was designed to destroy it's socket on network namesapce shu=
tdown. But this
>      will never happen for persistent device, because it's socket hol=
ds network
>      namespace.
>      This patch removes of holding network namespace by TUN socket an=
d replaces it
>      by creating socket in init_net and then changing it's net it to =
desired one. On
>      shutdown socket is moved back to init_net prior to final put.
>
>      Signed-off-by: Stanislav Kinsbursky<skinsbursky@parallels.com>
>      Signed-off-by: David S. Miller<davem@davemloft.net>
>
> ...With this reverted on top of 3.4-rc3, I no longer see crashes when=
 I
> keep making and breaking the SSH tunnel while running "vmstat 1" in a=
n
> SSH session over a socket that is running through that tunnel.
>
> Simon-

Hi, Simon.
Could you please try to apply the patch below on top of your the tree (=
with=20
1ab5ecb90cb6a3df1476e052f76a6e8f6511cb3d applied) and check does it fix=
 the problem:

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index bb8c72c..1fc4622 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1540,13 +1540,10 @@ static int tun_chr_close(struct inode *inode, s=
truct=20
file *file)
  			if (dev->reg_state =3D=3D NETREG_REGISTERED)
  				unregister_netdevice(dev);
  			rtnl_unlock();
-		}
+		} else
+			sock_put(tun->socket.sk);
  	}

-	tun =3D tfile->tun;
-	if (tun)
-		sock_put(tun->socket.sk);
-
  	put_net(tfile->net);
  	kfree(tfile);
