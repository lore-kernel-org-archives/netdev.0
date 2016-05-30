From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] veth: delay peer link configuration after interfaces are
 tied
Date: Mon, 30 May 2016 17:47:33 +0200
Message-ID: <574C6095.9050804@6wind.com>
References: <1464520637-19784-1-git-send-email-vincent@bernat.im>
 <574C0697.6060506@6wind.com> <878tyr4zzc.fsf@zoro.exoscale.ch>
 <574C59F1.80403@6wind.com> <87fusz36tg.fsf@zoro.exoscale.ch>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Vijay Pandurangan <vijayp@vijayp.ca>,
	Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org
To: Vincent Bernat <vincent@bernat.im>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:34393 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161419AbcE3Prg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 May 2016 11:47:36 -0400
Received: by mail-wm0-f46.google.com with SMTP id z87so16794355wmh.1
        for <netdev@vger.kernel.org>; Mon, 30 May 2016 08:47:36 -0700 (PDT)
In-Reply-To: <87fusz36tg.fsf@zoro.exoscale.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 30/05/2016 17:26, Vincent Bernat a =C3=A9crit :
>  =E2=9D=A6 30 mai 2016 17:19 CEST, Nicolas Dichtel <nicolas.dichtel@6=
wind.com> :
>=20
>>>>>  	priv =3D netdev_priv(peer);
>>>>>  	rcu_assign_pointer(priv->peer, dev);
>>>>> +
>>>>> +	err =3D rtnl_configure_link(peer, ifmp);
>>>>> +	if (err < 0)
>>>>> +		goto err_configure_peer;
>>>
>>>> You should fix the error path. 'unregister_netdevice(dev)' is miss=
ing.
>>>
>>> I am sending another patch to fix that. I am quite unsure if I do t=
he
>>> right thing here.
>>>
>> A less intrusive fix is to call 'rtmsg_ifinfo(RTM_NEWLINK, peer, ~0U=
,
>> GFP_KERNEL);' a the end of veth_newlink().
>=20
> I did that at first. Maybe this would make more sense to do
> that. Otherwise, the first message contains an iflink value that we
> cannot resolve with just the received netlink messages (since the
> information is in the next netlink message). "ip monitor" seems to be
> able to get the info, but I suppose it does an additional
> lookup.
>=20
Yes, it's a chicken and egg problem ;-)
I think that the first message with an iflink set to '0' is not a probl=
em if a
second one update this value. Daemons that listen to those rtnl message=
s must
always update their caches. When the peer is put in another netns, its =
ifindex
may change again.
