From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: 3.3.0, 3.4-rc1 reproducible tun Oops
Date: Wed, 18 Apr 2012 15:32:27 +0400
Message-ID: <4F8EA64B.2050208@parallels.com>
References: <20120404220525.GD21505@hostway.ca> <1333593664.18626.577.camel@edumazet-glaptop> <20120417020852.GA18875@hostway.ca> <4F8D5FAD.10304@parallels.com> <20120417183528.GA32726@hostway.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Simon Kirby <sim@hostway.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:52891 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752524Ab2DRLcc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 07:32:32 -0400
In-Reply-To: <20120417183528.GA32726@hostway.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

17.04.2012 22:35, Simon Kirby =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Tue, Apr 17, 2012 at 04:18:53PM +0400, Stanislav Kinsbursky wrote:
>
>> 17.04.2012 06:08, Simon Kirby ??????????:
>>> On Thu, Apr 05, 2012 at 04:41:04AM +0200, Eric Dumazet wrote:
>>>
>>>> Hmm, is it happening if you remove the nvidia module ?
>>>>
>>>> If yes, please try to add slub_debug=3DFZPU
>>>
>>> Finally got annoyed enough at this to bisect it. It doesn't happen =
every
>>> time and I got a bit confused, but I finally tracked it down to:
>>>
>>> 1ab5ecb90cb6a3df1476e052f76a6e8f6511cb3d is the first bad commit
>>> commit 1ab5ecb90cb6a3df1476e052f76a6e8f6511cb3d
>>> Author: Stanislav Kinsbursky<skinsbursky@parallels.com>
>>> Date:   Mon Mar 12 02:59:41 2012 +0000
>>>
>>>      tun: don't hold network namespace by tun sockets
>>>
>>>      v3: added previously removed sock_put() to the tun_release() c=
allback, because
>>>      sk_release_kernel() doesn't drop the socket reference.
>>>
>>>      v2: sk_release_kernel() used for socket release. Dummy tun_rel=
ease() is
>>>      required for sk_release_kernel() --->   sock_release() --->   =
sock->ops->release()
>>>      call.
>>>
>>>      TUN was designed to destroy it's socket on network namesapce s=
hutdown. But this
>>>      will never happen for persistent device, because it's socket h=
olds network
>>>      namespace.
>>>      This patch removes of holding network namespace by TUN socket =
and replaces it
>>>      by creating socket in init_net and then changing it's net it t=
o desired one. On
>>>      shutdown socket is moved back to init_net prior to final put.
>>>
>>>      Signed-off-by: Stanislav Kinsbursky<skinsbursky@parallels.com>
>>>      Signed-off-by: David S. Miller<davem@davemloft.net>
>>>
>>> ...With this reverted on top of 3.4-rc3, I no longer see crashes wh=
en I
>>> keep making and breaking the SSH tunnel while running "vmstat 1" in=
 an
>>> SSH session over a socket that is running through that tunnel.
>>>
>>> Simon-
>>
>> Hi, Simon.
>> Could you please try to apply the patch below on top of your the
>> tree (with 1ab5ecb90cb6a3df1476e052f76a6e8f6511cb3d applied) and
>> check does it fix the problem:
>>
>> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
>> index bb8c72c..1fc4622 100644
>> --- a/drivers/net/tun.c
>> +++ b/drivers/net/tun.c
>> @@ -1540,13 +1540,10 @@ static int tun_chr_close(struct inode
>> *inode, struct file *file)
>>   			if (dev->reg_state =3D=3D NETREG_REGISTERED)
>>   				unregister_netdevice(dev);
>>   			rtnl_unlock();
>> -		}
>> +		} else
>> +			sock_put(tun->socket.sk);
>>   	}
>>
>> -	tun =3D tfile->tun;
>> -	if (tun)
>> -		sock_put(tun->socket.sk);
>> -
>>   	put_net(tfile->net);
>>   	kfree(tfile);
>
> (Whitespace-damaged patch, applied manually)
>
> Yes, I no longer see crashes with this applied. I haven't tried with
> kmemleak or similar, but it seems to work.
>
> Thanks,
>

This bug looks like double free, but I can't understand how does this c=
an happen...
Simon, would be really great, if you'll describe in details some simple=
 way, how=20
to reproduce the bug.

--=20
Best regards,
Stanislav Kinsbursky
