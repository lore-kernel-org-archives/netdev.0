From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] SCTP: fix race between sctp_bind_addr_free() and
 sctp_bind_addr_conflict()
Date: Wed, 18 May 2011 09:48:05 +0200
Message-ID: <1305704885.2983.4.camel@edumazet-laptop>
References: <BANLkTikeWzuE-384uT6RhZR6Wn=DBK+CNQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Vlad Yasevich <vladislav.yasevich@hp.com>
To: Jacek Luczak <difrost.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:43973 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754379Ab1ERHsI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 03:48:08 -0400
Received: by bwz15 with SMTP id 15so1179734bwz.19
        for <netdev@vger.kernel.org>; Wed, 18 May 2011 00:48:07 -0700 (PDT)
In-Reply-To: <BANLkTikeWzuE-384uT6RhZR6Wn=DBK+CNQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 18 mai 2011 =C3=A0 09:01 +0200, Jacek Luczak a =C3=A9crit :
> During the sctp_close() call, we do not use rcu primitives to
> destroy the address list attached to the endpoint.  At the same
> time, we do the removal of addresses from this list before
> attempting to remove the socket from the port hash
>=20
> As a result, it is possible for another process to find the socket
> in the port hash that is in the process of being closed.  It then
> proceeds to traverse the address list to find the conflict, only
> to have that address list suddenly disappear without rcu() critical
> section.
>=20
> This can result in a kernel crash with general protection fault or
> kernel NULL pointer dereference.
>=20
> Fix issue by closing address list removal inside RCU critical
> section.
>=20
> Signed-off-by: Jacek Luczak <luczak.jacek@gmail.com>
> Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>
>=20
> ---
>  bind_addr.c |   12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
> index faf71d1..19d1329 100644
> --- a/net/sctp/bind_addr.c
> +++ b/net/sctp/bind_addr.c
> @@ -155,8 +155,16 @@ static void sctp_bind_addr_clean(struct sctp_bin=
d_addr *bp)
>  /* Dispose of an SCTP_bind_addr structure  */
>  void sctp_bind_addr_free(struct sctp_bind_addr *bp)
>  {
> -       /* Empty the bind address list. */
> -       sctp_bind_addr_clean(bp);
> +       struct sctp_sockaddr_entry *addr;
> +
> +       /* Empty the bind address list inside RCU section. */
> +       rcu_read_lock();
> +       list_for_each_entry_rcu(addr, &bp->address_list, list) {
> +               list_del_rcu(&addr->list);
> +               call_rcu(&addr->rcu, sctp_local_addr_free);
> +               SCTP_DBG_OBJCNT_DEC(addr);
> +       }
> +       rcu_read_unlock();
>=20

Sorry this looks odd.

If you're removing items from this list, you must be a writer here, wit=
h
exclusive access. So rcu_read_lock()/rcu_read_unlock() is not necessary=
=2E

Therefore, I guess following code is better :

list_for_each_entry(addr, &bp->address_list, list) {
	list_del_rcu(&addr->list);
	call_rcu(&addr->rcu, sctp_local_addr_free);
	SCTP_DBG_OBJCNT_DEC(addr);
}

Then, why dont you fix sctp_bind_addr_clean() instead ?

if 'struct sctp_sockaddr_entry' is recu protected, then all frees shoul=
d
be protected as well.



