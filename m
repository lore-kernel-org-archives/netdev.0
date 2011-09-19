From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH v3 04/11] SUNRPC: parametrize svc creation calls with
 portmapper flag
Date: Mon, 19 Sep 2011 19:42:12 +0400
Message-ID: <4E7762D4.7090404@parallels.com>
References: <20110913180953.3961.69217.stgit@localhost6.localdomain6>	<20110913181351.3961.70207.stgit@localhost6.localdomain6>	<20110919100811.0eaa39fe@tlielax.poochiereds.net>	<4E7756F3.4080601@parallels.com> <20110919110729.33a876ca@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Pavel Emelianov <xemul@parallels.com>,
	"neilb@suse.de" <neilb@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"bfields@fieldses.org" <bfields@fieldses.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110919110729.33a876ca@tlielax.poochiereds.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

19.09.2011 19:07, Jeff Layton =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Mon, 19 Sep 2011 18:51:31 +0400
> Stanislav Kinsbursky<skinsbursky@parallels.com>  wrote:
>
>> 19.09.2011 18:08, Jeff Layton =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>> On Tue, 13 Sep 2011 22:13:51 +0400
>>> Stanislav Kinsbursky<skinsbursky@parallels.com>   wrote:
>>>
>>>> This new flag ("setup_rpcbind) will be used to detect, that new se=
rvice will
>>>> send portmapper register calls. For such services we will create r=
pcbind
>>>> clients and remove all stale portmap registrations.
>>>> Also, svc_rpcb_cleanup() will be set as sv_shutdown callback for s=
uch services
>>>> in case of this field wasn't initialized earlier. This will allow =
to destroy
>>>> rpcbind clients when no other users of them left.
>>>>
>>>> Signed-off-by: Stanislav Kinsbursky<skinsbursky@parallels.com>
>>>>
>>>> ---
>>>>    include/linux/sunrpc/svc.h |    2 ++
>>>>    net/sunrpc/svc.c           |   21 ++++++++++++++-------
>>>>    2 files changed, 16 insertions(+), 7 deletions(-)
>>>>
>>>> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc=
=2Eh
>>>> index 223588a..528952a 100644
>>>> --- a/include/linux/sunrpc/svc.h
>>>> +++ b/include/linux/sunrpc/svc.h
>>>> @@ -402,11 +402,13 @@ struct svc_procedure {
>>>>     * Function prototypes.
>>>>     */
>>>>    struct svc_serv *svc_create(struct svc_program *, unsigned int,
>>>> +			    int setup_rpcbind,
>>> 				^^^
>>> 			Instead of adding this parameter, why not
>>> 			base this on the vs_hidden flag in the
>>> 			svc_version? IOW, have a function that looks at
>>> 			all the svc_versions for a particular
>>> 			svc_program, and returns "true" if any of them
>>> 			have vs_hidden unset? The mechanism you're
>>> 			proposing here has the potential to be out of
>>> 			sync with the vs_hidden flag.
>>>
>>
>> Could you, please, clarify me this vs_hidden flag?
>> I understand, that it's used to avoid portmap registration.
>> But as I see, it's set only for nfs_callback_version1. But this svc_=
version is a
>> part of nfs4_callback_program with nfs_callback_version4, which is n=
ot hidden.
>> Does this flag is missed here? If not, how we can return "true" from=
 your
>> proposed function if any of them have vs_hidden unset?
>>
>> Also sockets for this program are created with SVC_SOCK_ANONYMOUS fl=
ag and we
>> will not register any of this program versions with portmapper.
>> Thus, from my pow, this vs_hidden flag affects only svc_unregister. =
And only
>> nfs_callback_version1. This looks really strange.
>>
>> I.e. if we use this flag only for passing through this versions duri=
ng
>> svc_(un)register, and we actually also want to pass through
>> nfs_callback_version4 as well (but just missed this vs_hidden flag f=
or it), then
>> with current patch-set we can move this flag from (vs_hidden) svc_ve=
rsion to
>> svc_program and check it during svc_create instead of my home-brew
>> "setup_rpcbind" variable.
>>
>
> Agreed. The current situation is a mess, which is why I suggested a
> cleanup and overhaul before you do this...
>
> The vs_hidden flag is intended to show that a particular program
> version should not be registered with (or unregistered from) the
> portmapper. Unfortunately, nothing looks at vs_hidden during
> registration time, only when unregistering (as you mention).
>
> It's quite possible that several svc_versions declared in the kernel =
do
> not have this set correctly. One thing that would be good is to audit
> each of those.
>
> We currently rely on SVC_SOCK_ANONYMOUS for registration, but that
> wasn't its original intent. It's was just convenient to use it there
> too.
>
> SVC_SOCK_ANONYMOUS was (as best I can tell) originally intended for u=
se
> on temporary sockets that we establish on receive. So for
> instance...when a client connects to nfsd, we need to create a new
> socket for nfsd, but obviously we don't want to register that socket
> with the portmapper (since nfsd should already be registered there).
> SVC_SOCK_ANONYMOUS ensures that that socket is not registered.
>
> The whole scheme could probably use a fundamental re-think. I'm not
> sure I have a great idea to propose in lieu of it, but I think adding
> yet another flag here is probably not the best way to go.
>

Ok, thank you, Jeff.
It looks like no mentions about portmapper are present in RFC's for NFS=
 versions=20
4.* after a brief look.
This SVC_SOCK_ANONYMOUS is understandable and can't be removed with thi=
s=20
patch-set from my pow.
But now I strongly believe, that we can move this vs_hidden flag from=20
svc_version to svc_program structure and set it for both NFSv4.* progra=
ms.
Hope, someone else will confirm of refute this statement.




--=20
Best regards,
Stanislav Kinsbursky
