From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 01/11] netlink: add reference of module in netlink_dump_start
Date: Wed, 26 Sep 2012 14:05:58 +0800
Message-ID: <50629B46.5070502@cn.fujitsu.com>
References: <1348635140-20225-1-git-send-email-gaofeng@cn.fujitsu.com> <20120926054102.GD4221@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org,
	linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jengelh-9+2X+4sQBs8@public.gmane.org,
	stephen.hemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org
To: Steffen Klassert <steffen.klassert-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120926054102.GD4221-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2012=E5=B9=B409=E6=9C=8826=E6=97=A5 13:41, Steffen Klassert =E5=
=86=99=E9=81=93:
> On Wed, Sep 26, 2012 at 12:52:10PM +0800, Gao feng wrote:
>> +
>>  int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
>>  		       const struct nlmsghdr *nlh,
>>  		       struct netlink_dump_control *control)
>> @@ -1786,6 +1794,7 @@ int netlink_dump_start(struct sock *ssk, struc=
t sk_buff *skb,
>>  	cb->done =3D control->done;
>>  	cb->nlh =3D nlh;
>>  	cb->data =3D control->data;
>> +	cb->module =3D control->module;
>>  	cb->min_dump_alloc =3D control->min_dump_alloc;
>>  	atomic_inc(&skb->users);
>>  	cb->skb =3D skb;
>> @@ -1796,19 +1805,27 @@ int netlink_dump_start(struct sock *ssk, str=
uct sk_buff *skb,
>>  		return -ECONNREFUSED;
>>  	}
>>  	nlk =3D nlk_sk(sk);
>> -	/* A dump is in progress... */
>> +
>>  	mutex_lock(nlk->cb_mutex);
>> +	/* A dump is in progress... */
>>  	if (nlk->cb) {
>>  		mutex_unlock(nlk->cb_mutex);
>>  		netlink_destroy_callback(cb);
>> -		sock_put(sk);
>> -		return -EBUSY;
>> +		ret =3D -EBUSY;
>> +		goto out;
>> +	}
>> +	/* add reference of module witch cb->dump belone to */
>> +	if (cb->module && !try_module_get(cb->module)) {
>> +		mutex_unlock(nlk->cb_mutex);
>> +		ret =3D -EPROTONOSUPPORT;
>> +		goto out;
>=20
> Looks like you leak the allocated netlink_callback here.
> You should call netlink_destroy_callback() before you exit.
>=20

oops, I will fix it,thanks very much!
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
