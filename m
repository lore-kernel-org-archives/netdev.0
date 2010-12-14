From: Mike Waychison <mikew@google.com>
Subject: Re: [PATCH v3 03/22] netconsole: Introduce 'enabled' state-machine
Date: Tue, 14 Dec 2010 15:33:03 -0800
Message-ID: <AANLkTin3JoNQ4_A3eXBAW148kEqWSxr06rY5h8yH+BGb@mail.gmail.com>
References: <20101214212846.17022.64836.stgit@mike.mtv.corp.google.com>
 <20101214212909.17022.96801.stgit@mike.mtv.corp.google.com> <AANLkTik8wzDPPtMM+YPoOSojiW_Nev-KDkAg8dtDV=g1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: simon.kagstrom@netinsight.net, davem@davemloft.net,
	nhorman@tuxdriver.com, Matt Mackall <mpm@selenic.com>,
	adurbin@google.com, linux-kernel@vger.kernel.org,
	chavey@google.com, Greg KH <greg@kroah.com>,
	netdev@vger.kernel.org,
	=?ISO-8859-1?Q?Am=E9rico_Wang?= <xiyou.wangcong@gmail.com>,
	akpm@linux-foundation.org, linux-api@vger.kernel.org
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTik8wzDPPtMM+YPoOSojiW_Nev-KDkAg8dtDV=g1@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2010/12/14 Micha=C5=82 Miros=C5=82aw <mirqus@gmail.com>:
> 2010/12/14 Mike Waychison <mikew@google.com>:
>> Representing the internal state within netconsole isn't really a boo=
lean
>> value, but rather a state machine with transitions.
> [...]
>> diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
>> index 6e16888..288a025 100644
>> --- a/drivers/net/netconsole.c
>> +++ b/drivers/net/netconsole.c
> [...]
>> @@ -350,9 +362,9 @@ static ssize_t store_enabled(struct netconsole_t=
arget *nt,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0err =3D netpo=
ll_setup(&nt->np);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock_irq=
save(&target_list_lock, flags);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (err)
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 nt->enabled =3D 0;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 nt->np_state =3D NETPOLL_DISABLED;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0else
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 nt->enabled =3D 1;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 nt->np_state =3D NETPOLL_ENABLED;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock_i=
rqrestore(&target_list_lock, flags);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (err)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0return err;
> [...]
>
> Since the spinlock protects only nt->np_state setting, you might be
> able to remove it altogether and use cmpxchg() where nt->np_state
> transitions from enabled or disabled state.
>
> Maybe the locking scheme just needs more thought altogether?

The target_list_lock protects the list, as well as the state
transitions.  This makes iterating through the list and getting a
consistent view of the targets a lot easier when it comes time to
transmitting packets we are guaranteed that nobody is changing the
target state underneath us if nt->np_state =3D=3D NETPOLL_ENABLED while=
 we
hold the lock.
