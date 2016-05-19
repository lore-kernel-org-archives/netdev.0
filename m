From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net] tuntap: correctly wake up process during uninit
Date: Thu, 19 May 2016 13:35:03 +0800
Message-ID: <573D5087.6070308@redhat.com>
References: <1463569097-3528-1-git-send-email-jasowang@redhat.com>
 <1463576494.18194.94.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Xi Wang <xii@google.com>,
	"Michael S . Tsirkin" <mst@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463576494.18194.94.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016=E5=B9=B405=E6=9C=8818=E6=97=A5 21:01, Eric Dumazet wrote:
> On Wed, 2016-05-18 at 18:58 +0800, Jason Wang wrote:
>> We used to check dev->reg_state against NETREG_REGISTERED after each
>> time we are woke up. But after commit 9e641bdcfa4e ("net-tun:
>> restructure tun_do_read for better sleep/wakeup efficiency"), it use=
s
>> skb_recv_datagram() which does not check dev->reg_state. This will
>> result if we delete a tun/tap device after a process is blocked in t=
he
>> reading. The device will wait for the reference count which was held
>> by that process for ever.
>>
>> Fixes this by using RCV_SHUTDOWN which will be checked during
>> sk_recv_datagram() before trying to wake up the process during unini=
t.
>>
>> Fixes: 9e641bdcfa4e ("net-tun: restructure tun_do_read for better
>> sleep/wakeup efficiency")
> <nit : no newline before Fixes: and other parts>

Ok.

> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Xi Wang <xii@google.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
> The patch is needed for -stable.
> ---
>   drivers/net/tun.c | 3 +++
>   1 file changed, 3 insertions(+)
>
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 425e983..752d849 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -580,11 +580,13 @@ static void tun_detach_all(struct net_device *d=
ev)
>   	for (i =3D 0; i < n; i++) {
>   		tfile =3D rtnl_dereference(tun->tfiles[i]);
>   		BUG_ON(!tfile);
> +		tfile->socket.sk->sk_shutdown =3D RCV_SHUTDOWN;
>   		tfile->socket.sk->sk_data_ready(tfile->socket.sk);
>   		RCU_INIT_POINTER(tfile->tun, NULL);
>   		--tun->numqueues;
>   	}
>   	list_for_each_entry(tfile, &tun->disabled, next) {
> +		tfile->socket.sk->sk_shutdown =3D RCV_SHUTDOWN;
>   		tfile->socket.sk->sk_data_ready(tfile->socket.sk);
>   		RCU_INIT_POINTER(tfile->tun, NULL);
>   	}
> @@ -641,6 +643,7 @@ static int tun_attach(struct tun_struct *tun, str=
uct file *file, bool skip_filte
>   			goto out;
>   	}
>   	tfile->queue_index =3D tun->numqueues;
> +	tfile->socket.sk->sk_shutdown &=3D ~RCV_SHUTDOWN;
>   	rcu_assign_pointer(tfile->tun, tun);
>   	rcu_assign_pointer(tun->tfiles[tun->numqueues], tfile);
>   	tun->numqueues++;
> Is the "if (tun->dev->reg_state !=3D NETREG_REGISTERED) return -EIO;"
> check still needed then ?
>
> Thanks.
>
>

No need since we've check tun before, will remove this in V2.

Thanks
