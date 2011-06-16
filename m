From: Connor Hansen <cmdkhh@gmail.com>
Subject: Re: rionet: NULL pointer dereference
Date: Thu, 16 Jun 2011 15:53:24 -0700
Message-ID: <BANLkTimwzbB9ZwbG3u=oRNAHSECioEJ3dQ@mail.gmail.com>
References: <alpine.LNX.2.00.1106162359560.8140@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Matt Porter <mporter@kernel.crashing.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Jesper Juhl <jj@chaosbits.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:39507 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754522Ab1FPWx0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2011 18:53:26 -0400
In-Reply-To: <alpine.LNX.2.00.1106162359560.8140@swampdragon.chaosbits.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 16, 2011 at 3:06 PM, Jesper Juhl <jj@chaosbits.net> wrote:
> Hi
>
> Just noticed that drivers/net/rionet.c::rionet_remove() can cause a N=
ULL
> deref when it calls unregister_netdev().
> It initializes local variable 'ndev' to NULL and nothing changes this
> before the call to unregister_netdev(ndev) - that functions then call=
s:
> unregister_netdevice > unregister_netdevice_queue > list_move_tail >
> __list_del_entry =A0which dereferences the pointer (which, being NULL=
, will
> end in tears).

unregister_netdevice(struct net_device *dev)
{
        unregister_netdevice_queue(dev, NULL);
}

 so unregister_netdevice_queue is being called with NULL,NULL

void unregister_netdevice_queue(struct net_device *dev, struct list_hea=
d *head)
{
        ASSERT_RTNL();

        if (head) {
                list_move_tail(&dev->unreg_list, head);
        } else {
                rollback_registered(dev);
                /* Finish processing unregister after unlock */
                net_set_todo(dev);
        }
}

if head is null, which it is from the call, then we call
rollback_registered, and not list_move_tail()

the else calls rollback_registered(NULL) then net_set_todo(NULL)

both of which dereference null when passed, so yes there is a null
dereference, just not in the code branch you thought.

static void rollback_registered(struct net_device *dev)
{
        LIST_HEAD(single);

        list_add(&dev->unreg_list, &single);    null dereference
        rollback_registered_many(&single);
        list_del(&single);
}

static void net_set_todo(struct net_device *dev)
{
        list_add_tail(&dev->todo_list, &net_todo_list);  null dereferen=
ce
}

Connor

>
> I won't claim to know this code nor what the proper fix is; just thou=
ght
> i'd report it so someone else with more knowledge of this could perha=
ps
> come up with a fix.
>
> Have a nice day.
>
> --
> Jesper Juhl <jj@chaosbits.net> =A0 =A0 =A0 http://www.chaosbits.net/
> Don't top-post http://www.catb.org/jargon/html/T/top-post.html
> Plain text mails only, please.
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
>
