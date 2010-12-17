From: Mike Waychison <mikew@google.com>
Subject: Re: [PATCH v3 03/22] netconsole: Introduce 'enabled' state-machine
Date: Fri, 17 Dec 2010 13:20:30 -0800
Message-ID: <AANLkTikG-XepYDb3R9=T8NP5TWVgsKNK-QmXrznGDHUO@mail.gmail.com>
References: <20101214212846.17022.64836.stgit@mike.mtv.corp.google.com>
 <20101214212909.17022.96801.stgit@mike.mtv.corp.google.com> <20101217205238.GA8642@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: simon.kagstrom@netinsight.net, davem@davemloft.net,
	Matt Mackall <mpm@selenic.com>, adurbin@google.com,
	linux-kernel@vger.kernel.org, chavey@google.com,
	Greg KH <greg@kroah.com>, netdev@vger.kernel.org,
	=?ISO-8859-1?Q?Am=E9rico_Wang?= <xiyou.wangcong@gmail.com>,
	akpm@linux-foundation.org, linux-api@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:35446 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755351Ab0LQVUx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 16:20:53 -0500
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id oBHLKqXB009507
	for <netdev@vger.kernel.org>; Fri, 17 Dec 2010 13:20:52 -0800
Received: from pxi6 (pxi6.prod.google.com [10.243.27.6])
	by hpaq12.eem.corp.google.com with ESMTP id oBHLKHUH031471
	for <netdev@vger.kernel.org>; Fri, 17 Dec 2010 13:20:50 -0800
Received: by pxi6 with SMTP id 6so217058pxi.31
        for <netdev@vger.kernel.org>; Fri, 17 Dec 2010 13:20:50 -0800 (PST)
In-Reply-To: <20101217205238.GA8642@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 17, 2010 at 12:52 PM, Neil Horman <nhorman@tuxdriver.com> w=
rote:
> On Tue, Dec 14, 2010 at 01:29:10PM -0800, Mike Waychison wrote:

>> @@ -680,16 +699,17 @@ static int netconsole_netdev_event(struct noti=
fier_block *this,
>> =A0 =A0 =A0 struct net_device *dev =3D ptr;
>>
>> =A0 =A0 =A0 if (!(event =3D=3D NETDEV_CHANGENAME || event =3D=3D NET=
DEV_UNREGISTER ||
>> - =A0 =A0 =A0 =A0 =A0 event =3D=3D NETDEV_BONDING_DESLAVE || event =3D=
=3D NETDEV_GOING_DOWN))
>> + =A0 =A0 =A0 =A0 =A0 event =3D=3D NETDEV_BONDING_DESLAVE))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto done;
>>
>> =A0 =A0 =A0 spin_lock_irqsave(&target_list_lock, flags);
>> =A0 =A0 =A0 list_for_each_entry(nt, &target_list, list) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (nt->np.dev =3D=3D dev) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (nt->np_state =3D=3D NETPOLL_ENABLED &&=
 nt->np.dev =3D=3D dev) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (event) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 case NETDEV_CHANGENAME:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 strlcpy(=
nt->np.dev_name, dev->name, IFNAMSIZ);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 case NETDEV_BONDING_DESLAV=
E:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 case NETDEV_UNREGISTER:
> I don't follow what you're doing here. =A0Previously NETDEV_BONDING_D=
ESLAVE events
> simply caused the netconsole interface to get deactivated, and now we=
're doing a
> dev_put on the bonded interface bacause of the above move. =A0Given t=
hat
> NETDEV_BONDING_DESLAVE events are generated when a slave leaves the b=
ond, this
> doesn't seem right, or am I missing something

Ya, I did a poor job of explaining this bit.  Let me try now:

- NETDEV_GOING_DOWN is unneccesary because we will always see a
NETDEV_UNREGISTER event, which is why it is removed.
- I wasn't sure how to handle the NETDEV_BONDING_DESLAVE event in a
consistent way.  Originally we would disable the target, but this
actually leaks nt->np as it will never get cleaned up properly.  To
the user, it looks as if the target gets disabled.

I don't think you have any contention with the first comment above
(though I need to document it).

You are right in that with this patch, the target is left enabled,
when we should probably mark it as disabled.  I'd be happy to add the
transition from NETPOLL_ENABLED -> NETPOLL_DISABLED here if you'd
like, but it'd move again in the next patch anyway (which already
re-introduces the state transition in defer_netpoll_cleanup()).  Sorry
this is confusing :(   I'll make it clearer in the next series
version.
