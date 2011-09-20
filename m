From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH v4 1/8] SUNRPC: introduce helpers for reference counted
 rpcbind clients
Date: Tue, 20 Sep 2011 21:26:45 +0400
Message-ID: <4E78CCD5.9080704@parallels.com>
References: <20110920101031.9861.18444.stgit@localhost6.localdomain6> <20110920101341.9861.51453.stgit@localhost6.localdomain6> <4E788F8C.20103@netapp.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B47FD10@SACMVEXC2-PRD.hq.netapp.com> <4E789679.1060601@parallels.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B47FD22@SACMVEXC2-PRD.hq.netapp.com> <4E78A4AF.1020303@parallels.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B47FD2B@SACMVEXC2-PRD.hq.netapp.com> <4E78BD5B.8090507@parallels.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B47FE1E@SACMVEXC2-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Pavel Emelianov <xemul@parallels.com>,
	"neilb@suse.de" <neilb@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"bfields@fieldses.org" <bfields@fieldses.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B47FE1E@SACMVEXC2-PRD.hq.netapp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

20.09.2011 21:13, Myklebust, Trond =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>> -----Original Message-----
>> From: Stanislav Kinsbursky [mailto:skinsbursky@parallels.com]
>> Sent: Tuesday, September 20, 2011 12:21 PM
>> To: Myklebust, Trond
>> Cc: Schumaker, Bryan; linux-nfs@vger.kernel.org; Pavel Emelianov;
>> neilb@suse.de; netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
>> bfields@fieldses.org; davem@davemloft.net
>> Subject: Re: [PATCH v4 1/8] SUNRPC: introduce helpers for reference
>> counted rpcbind clients
>>
>> 20.09.2011 18:38, Myklebust, Trond =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>>> -----Original Message-----
>>>> From: Stanislav Kinsbursky [mailto:skinsbursky@parallels.com]
>>>> Sent: Tuesday, September 20, 2011 10:35 AM
>>>> To: Myklebust, Trond
>>>> Cc: Schumaker, Bryan; linux-nfs@vger.kernel.org; Pavel Emelianov;
>>>> neilb@suse.de; netdev@vger.kernel.org; linux-kernel@vger.kernel.or=
g;
>>>> bfields@fieldses.org; davem@davemloft.net
>>>> Subject: Re: [PATCH v4 1/8] SUNRPC: introduce helpers for referenc=
e
>>>> counted rpcbind clients
>>>>
>>>> 20.09.2011 18:14, Myklebust, Trond =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>>>
>>>>>>>
>>>>>>> Doesn't it  need to be protected by rpcb_clnt_lock too?
>>>>>>>
>>>>>>
>>>>>> Nope from my pow. It's protected by rpcb_create_local_mutex. I.e=
=2E
>>>>>> no one will change rpcb_users since it's zero. If it's non zero =
-
>>>>>> we willn't get to rpcb_set_local().
>>>>>
>>>>> OK, so you are saying that the rpcb_users++ below could be replac=
ed
>>>>> by
>>>> rpcb_users=3D1?
>>>>>
>>>>
>>>> Yes, you right.
>>>>
>>>>> In that case, don't you need a smp_wmb() between the setting of
>>>> rpcb_local_clnt/4 and the setting of rpcb_users? Otherwise, how do
>>>> you guarantee that rpcb_users !=3D 0 implies rpbc_local_clnt/4 !=3D=
 NULL?
>>>>>
>>>>
>>>> We check rpcb_users under spinlock. Gain spinlock forces memory
>>>> barrier, doesn't it?
>>>
>>> Yes, and so you don't need an smp_rmb() on the reader side. However=
,
>> you still need to ensure that the processor which _sets_ the rpcb_us=
ers and
>> rpcb_local_clnt/4 actually writes them in the correct order.
>>>
>>
>> Trond, I've thought again and realized, that even if these writes (r=
pcb_users
>> and rpbc_local_clnt/4) will be done in reversed order, then no barri=
er
>> required here.
>> Because if we have another process trying to create those clients (i=
t can't use
>> them since it's not started yet) on other CPU, than it's waiting on =
creation
>> mutex. When it will gain the mutex, we will have required memory bar=
rier
>> for us.
>>
>> Or I missed something in your explanation?
>
> You need to ensure that if someone calls rpcb_get_local() and gets a =
positive result, then they can rely on rpcb_local_clnt/4 being non-zero=
=2E Without the write barrier, that is not the case.
>

In current context we can be sure, that between rpcb_get_local() and fi=
rst=20
dereference of rpcb_local_clnt/4 we have at least one spinlock=20
(svc_xprt_class_lock in svc_create_xprt).
But I understand, that we can't relay on it since this code can be chan=
ged in=20
future.
So I'll add barrier there.

> Without that guarantee, you can't really ensure that rpcb_put_local()=
 will work as expected either, since it will be possible to trigger the=
 --rpcb_users =3D=3D 0 case without shutting down rpcb_local_clnt/4 (be=
cause clnt/clnt4 =3D=3D 0).
>

Yes, you right. But it doesn't mean, that we require barrier here, beca=
use we=20
don't need this garantee you are talking about.
We can be sure, that we always see right rpcb_users value. It means tha=
t, if we=20
set this value to zero, then no other running services left and no refe=
rences to=20
those clients can occur.
And even if we have another process which is going to create new servic=
e right=20
now on another CPU, then this process will see that no rpcbind users pr=
esent and=20
will create new clients and assign them to global variables prior to an=
y use of=20
this clients can occur.
And this assign will be done with barrier as we agreed earlier.

> Cheers
>    Trond
>


--=20
Best regards,
Stanislav Kinsbursky
