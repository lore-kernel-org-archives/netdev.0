From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH RFC] TCPCT part 1d: generate Responder Cookie
Date: Wed, 04 Nov 2009 00:03:21 +0100
Message-ID: <4AF0B6B9.2030707@gmail.com>
References: <4AEAC763.4070200@gmail.com> <4AED86AD.6010906@gmail.com> <4AEDCD7C.2010403@gmail.com> <4AF0B0D2.4030905@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751529AbZKCXDT@vger.kernel.org>
In-Reply-To: <4AF0B0D2.4030905@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

William Allen Simpson a =E9crit :
> Eric Dumazet wrote:
>> This patch looks fine, but I dont see how this new function is used.
>>
>> Some points :
>>
>> 1) We are working hard to remove rwlocks from network stack, so plea=
se
>> dont
>> add a new one. You probably can use a seqlock or RCU, or a server
>> handling 10.000 connections request per second on many NIC will hit
>> this rwlock.
>>
> This is my attempt at using RCU, as seqlock didn't seem to apply (and=
 is
> missing any Documentation.)
>=20

That seems very good, thanks, we can sort out details later, when full =
picture
is available.

> After the discussion about context, one question that I have is the n=
eed
> for the _bh suffix?
>=20
> +        rcu_read_lock_bh();
> +        memcpy(&xvp->cookie_bakery[0],
> +               &rcu_dereference(tcp_secret_generating)->secrets[0],
> +               sizeof(tcp_secret_generating->secrets));
> +        rcu_read_unlock_bh();
>=20

Well, you dont need to disable BH in this code running in softirq conte=
xt only.

Just use rcu_read_lock() (like you use spin_lock() in same function/con=
text)


>=20
> Documentation/RCU/checklist.txt #7 says:
>=20
>   One exception to this rule: rcu_read_lock() and rcu_read_unlock()
>   may be substituted for rcu_read_lock_bh() and rcu_read_unlock_bh()
>   in cases where local bottom halves are already known to be
>   disabled, for example, in irq or softirq context.  Commenting
>   such cases is a must, of course!  And the jury is still out on
>   whether the increased speed is worth it.
>=20
