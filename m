From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] net: Fix ns_capable check in sock_diag_put_filterinfo
Date: Thu, 17 Apr 2014 11:17:23 +0200
Message-ID: <534F9C23.4090407@6wind.com>
References: <1360f6acc2064d49a41f2d993d05cdcf8a40fc06.1397709384.git.luto@amacapital.net> <87r44w73nu.fsf@x220.int.ebiederm.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, stable@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	Andy Lutomirski <luto@amacapital.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <87r44w73nu.fsf@x220.int.ebiederm.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 17/04/2014 10:37, Eric W. Biederman a =C3=A9crit :
> Andy Lutomirski <luto@amacapital.net> writes:
>
>> The caller needs capabilities on the namespace being queried, not on
>> their own namespace.  This is a security bug, although it likely has
>> only a minor impact.
>
> Hmm.  Thinking this through.
>
> It would likely help to rename sk_user_ns to sk_opener_user_ns to mak=
e
> things clearer.
>
> As I read net/core/sock_diag.c anyone is allowed to open a diag socke=
t
> and send messages to the kernel.
>
> Which means the code as written is definitely wrong as checking if we
> have CAP_NET_ADMIN in the user namespace in which we opened the netli=
nk
> socket is meaningless.  We could very easily have unshared the user
> namespace and have no permissions whatsoever over the network namespa=
ce
> we are querrying.
>
> I see three possibilities here.
> 1) We simply don't care who gets to read the bpf filter of a socket.
> 2) We consider reading the bpf filter of a socket an information leak
>     about the socket and the opener of the socket.
> 3) We consider reading the bpf filter of a socket something we should
>     only let the administrator of a network namespace do.
>
> I honestly don't know the intent of the check, and what we are trying=
 to
> protect against so I don't know why having permissions to protect the
> bpf filter is important.
>
> If we simply don't care we should just delete this permission check.
>
> If we want to protect the opener of the socket we probably want
> something looks a lot like ptrace_may_access(..., PTRACE_MODE_READ)
> applied to the creds of the socket.  Call it
>
> 	ns_capable((sock_opener_user_ns(sk), CAP_NET_ADMIN)
>
> for short.
>
>
> And if this is something we just want to limit to administrators
> of network stacks the check should be
>
> 	ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN)
>
> As Andy has coded below.
>
> Nicolas what was the intent of having a capability check to protect t=
he
> bpf filter?  What were you trying to protect against with a capabilit=
y
> check on the bpf filter?
Option 3 was the initial intention. BFP filter contains sensible inform=
ations
and thus we only want to disclose them to the admin.

Nicolas
>
> Eric
>
>
>> Cc: stable@vger.kernel.org
>> Signed-off-by: Andy Lutomirski <luto@amacapital.net>
>> ---
>>
>> Someone should check that I'm right.  I had trouble getting 'ss -b' =
to
>> work, even with plain old sudo.
>>
>>   include/linux/sock_diag.h | 2 +-
>>   net/core/sock_diag.c      | 4 ++--
>>   net/packet/diag.c         | 2 +-
>>   3 files changed, 4 insertions(+), 4 deletions(-)
>>
>> diff --git a/include/linux/sock_diag.h b/include/linux/sock_diag.h
>> index 54f91d3..302ab80 100644
>> --- a/include/linux/sock_diag.h
>> +++ b/include/linux/sock_diag.h
>> @@ -23,7 +23,7 @@ int sock_diag_check_cookie(void *sk, __u32 *cookie=
);
>>   void sock_diag_save_cookie(void *sk, __u32 *cookie);
>>
>>   int sock_diag_put_meminfo(struct sock *sk, struct sk_buff *skb, in=
t attr);
>> -int sock_diag_put_filterinfo(struct user_namespace *user_ns, struct=
 sock *sk,
>> +int sock_diag_put_filterinfo(struct sock *sk,
>>   			     struct sk_buff *skb, int attrtype);
>>
>>   #endif
>> diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
>> index a0e9cf6..6a7fae2 100644
>> --- a/net/core/sock_diag.c
>> +++ b/net/core/sock_diag.c
>> @@ -49,7 +49,7 @@ int sock_diag_put_meminfo(struct sock *sk, struct =
sk_buff *skb, int attrtype)
>>   }
>>   EXPORT_SYMBOL_GPL(sock_diag_put_meminfo);
>>
>> -int sock_diag_put_filterinfo(struct user_namespace *user_ns, struct=
 sock *sk,
>> +int sock_diag_put_filterinfo(struct sock *sk,
>>   			     struct sk_buff *skb, int attrtype)
>>   {
>>   	struct nlattr *attr;
>> @@ -57,7 +57,7 @@ int sock_diag_put_filterinfo(struct user_namespace=
 *user_ns, struct sock *sk,
>>   	unsigned int len;
>>   	int err =3D 0;
>>
>> -	if (!ns_capable(user_ns, CAP_NET_ADMIN)) {
>> +	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN)) {
>>   		nla_reserve(skb, attrtype, 0);
>>   		return 0;
>>   	}
>> diff --git a/net/packet/diag.c b/net/packet/diag.c
>> index 533ce4f..435ff99 100644
>> --- a/net/packet/diag.c
>> +++ b/net/packet/diag.c
>> @@ -172,7 +172,7 @@ static int sk_diag_fill(struct sock *sk, struct =
sk_buff *skb,
>>   		goto out_nlmsg_trim;
>>
>>   	if ((req->pdiag_show & PACKET_SHOW_FILTER) &&
>> -	    sock_diag_put_filterinfo(user_ns, sk, skb, PACKET_DIAG_FILTER)=
)
>> +	    sock_diag_put_filterinfo(sk, skb, PACKET_DIAG_FILTER))
>>   		goto out_nlmsg_trim;
>>
>>   	return nlmsg_end(skb, nlh);

--=20
Nicolas DICHTEL
6WIND
R&D Engineer

Tel: +33 1 39 30 92 41
=46ax: +33 1 39 30 92 11
nicolas.dichtel@6wind.com
http://www.6wind.com
http://www.6windblog.com
http://twitter.com/6windsoftware

Ce courriel ainsi que toutes les pi=C3=A8ces jointes, est uniquement de=
stin=C3=A9 =C3=A0 son ou=20
ses destinataires. Il contient des informations confidentielles qui son=
t la=20
propri=C3=A9t=C3=A9 de 6WIND. Toute r=C3=A9v=C3=A9lation, distribution =
ou copie des informations=20
qu'il contient est strictement interdite. Si vous avez re=C3=A7u ce mes=
sage par=20
erreur, veuillez imm=C3=A9diatement le signaler =C3=A0 l'=C3=A9metteur =
et d=C3=A9truire toutes les=20
donn=C3=A9es re=C3=A7ues.

This e-mail message, including any attachments, is for the sole use of =
the=20
intended recipient(s) and contains information that is confidential and=
=20
proprietary to 6WIND. All unauthorized review, use, disclosure or distr=
ibution=20
is prohibited. If you are not the intended recipient, please contact th=
e sender=20
by reply e-mail and destroy all copies of the original message.
