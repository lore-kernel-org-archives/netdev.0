From: Mike Waychison <mikew@google.com>
Subject: Re: [PATCH v3 02/22] netconsole: Introduce locking over the netpoll fields
Date: Tue, 14 Dec 2010 15:30:24 -0800
Message-ID: <AANLkTinVHrkLOMBkH3cauQndL03C_mnAJDJNYHa14ysZ@mail.gmail.com>
References: <20101214212846.17022.64836.stgit@mike.mtv.corp.google.com>
 <20101214212904.17022.16604.stgit@mike.mtv.corp.google.com> <AANLkTi=reqRMrv4k5EZKdj7pmsomApw9=Kwh9nxfKCuJ@mail.gmail.com>
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
In-Reply-To: <AANLkTi=reqRMrv4k5EZKdj7pmsomApw9=Kwh9nxfKCuJ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2010/12/14 Micha=C5=82 Miros=C5=82aw <mirqus@gmail.com>:
> 2010/12/14 Mike Waychison <mikew@google.com>:
>> The netconsole driver currently doesn't do any locking over its
>> configuration fields. =C2=A0This can cause problems if we were to ev=
er have
>> concurrent writing to fields while somebody is enabling the service.
>>
>> For simplicity, this patch extends targets_list_lock to cover all
>> configuration fields within the targets. =C2=A0Macros are also added=
 here to
>> wrap accessors so that we check whether the target has been enabled =
with
>> locking handled.
>>
>> Signed-off-by: Mike Waychison <mikew@google.com>
>> Acked-by: Matt Mackall <mpm@selenic.com>
>> ---
>> =C2=A0drivers/net/netconsole.c | =C2=A0114 +++++++++++++++++++++++++=
+--------------------
>> =C2=A01 files changed, 64 insertions(+), 50 deletions(-)
>>
>> diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
>> index c87a49e..6e16888 100644
>> --- a/drivers/net/netconsole.c
>> +++ b/drivers/net/netconsole.c
>> @@ -327,6 +327,7 @@ static ssize_t store_enabled(struct netconsole_t=
arget *nt,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 const char *buf,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 size_t count)
>> =C2=A0{
>> + =C2=A0 =C2=A0 =C2=A0 unsigned long flags;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0int err;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0long enabled;
>>
>> @@ -335,6 +336,10 @@ static ssize_t store_enabled(struct netconsole_=
target *nt,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return enable=
d;
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (enabled) { =C2=A0/* 1 */
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_lock_irqsave=
(&target_list_lock, flags);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (nt->enabled)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 goto busy;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_unlock_irqre=
store(&target_list_lock, flags);
>>
>
> This looks wrong. Unless there is another lock or mutex covering this
> function, at this point (after spin_unlock_irqrestore()) another
> thread might set nt->enabled =3D 1.
>

Agreed that this looks wrong :)

It is fixed in the next patch where a state machine is introduced to
replace the binary flag nt->enabled.  The code before this patch had
the a very similar problem in that a target could be enabled twice.
store_enabled() would call netpoll_setup() the second time without
checking to see if it was already enabled.
