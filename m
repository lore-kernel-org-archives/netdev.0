From: andrew hendry <andrew.hendry@gmail.com>
Subject: Re: [PATCH 8/8] x25: use limited socket backlog
Date: Wed, 3 Mar 2010 22:38:21 +1100
Message-ID: <d45a3acc1003030338m3102a95p1b06b7db1b24e58e@mail.gmail.com>
References: <1267598111-12503-1-git-send-email-yi.zhu@intel.com>
	 <1267598111-12503-2-git-send-email-yi.zhu@intel.com>
	 <1267598111-12503-3-git-send-email-yi.zhu@intel.com>
	 <1267598111-12503-4-git-send-email-yi.zhu@intel.com>
	 <1267598111-12503-5-git-send-email-yi.zhu@intel.com>
	 <1267598111-12503-6-git-send-email-yi.zhu@intel.com>
	 <1267598111-12503-7-git-send-email-yi.zhu@intel.com>
	 <1267598111-12503-8-git-send-email-yi.zhu@intel.com>
	 <1267600109.2839.101.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Zhu Yi <yi.zhu@intel.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f196.google.com ([209.85.223.196]:42302 "EHLO
	mail-iw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752269Ab0CCLiX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 06:38:23 -0500
Received: by iwn34 with SMTP id 34so1217173iwn.15
        for <netdev@vger.kernel.org>; Wed, 03 Mar 2010 03:38:21 -0800 (PST)
In-Reply-To: <1267600109.2839.101.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Will wait for the next spin and in the meantime think if there is way
to test it.
x25 with no loopback and being so slow probably cant generate the same
as your UDP case.

Andrew.

On Wed, Mar 3, 2010 at 6:08 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le mercredi 03 mars 2010 =E0 14:35 +0800, Zhu Yi a =E9crit :
>> Make x25 adapt to the limited socket backlog change.
>>
>> Cc: Andrew Hendry <andrew.hendry@gmail.com>
>> Signed-off-by: Zhu Yi <yi.zhu@intel.com>
>> ---
>> =A0net/x25/x25_dev.c | =A0 =A02 +-
>> =A01 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/net/x25/x25_dev.c b/net/x25/x25_dev.c
>> index 3e1efe5..5688123 100644
>> --- a/net/x25/x25_dev.c
>> +++ b/net/x25/x25_dev.c
>> @@ -53,7 +53,7 @@ static int x25_receive_data(struct sk_buff *skb, s=
truct x25_neigh *nb)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!sock_owned_by_user(sk)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 queued =3D x25_process_r=
x_frame(sk, skb);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sk_add_backlog(sk, skb);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __sk_add_backlog(sk, skb);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 bh_unlock_sock(sk);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 sock_put(sk);
>
> Please respin your patch the other way
>
> Ie: let sk_add_backlog(sk, skb) do its previous job (not leaking skbs=
,
> and returning a void status)
>
> Add a new function able to no limit backlog, and returns an error cod=
e,
> so that caller can free skb and increment SNMP counters accordingly.
>
> Callers MUST test return value, or use another helper that can free t=
he
> skb for them.
>
> Name it sk_move_backlog() for example
>
> This will permit you to split the work as you tried.
>
> sk_add_backlog() could be redefined as the helper :
>
> void sk_add_backlog(sk, skb)
> {
> =A0 =A0 =A0 =A0if (sk_move_backlog(sk, skb)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kfree_skb(skb);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0atomic_inc(&sk->sk_drops);
> =A0 =A0 =A0 =A0}
>
> }
>
> Thanks
>
>
>
