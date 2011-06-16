From: Jesper Juhl <jj@chaosbits.net>
Subject: Re: rionet: NULL pointer dereference
Date: Fri, 17 Jun 2011 00:51:59 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1106170050180.8140@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1106162359560.8140@swampdragon.chaosbits.net> <BANLkTimwzbB9ZwbG3u=oRNAHSECioEJ3dQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1758555876-1308264719=:8140"
Cc: linux-kernel@vger.kernel.org,
	Matt Porter <mporter@kernel.crashing.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Connor Hansen <cmdkhh@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swampdragon.chaosbits.net ([90.184.90.115]:16081 "EHLO
	swampdragon.chaosbits.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756064Ab1FPXAg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2011 19:00:36 -0400
In-Reply-To: <BANLkTimwzbB9ZwbG3u=oRNAHSECioEJ3dQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-1758555876-1308264719=:8140
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Thu, 16 Jun 2011, Connor Hansen wrote:

> On Thu, Jun 16, 2011 at 3:06 PM, Jesper Juhl <jj@chaosbits.net> wrote:
> > Hi
> >
> > Just noticed that drivers/net/rionet.c::rionet_remove() can cause a NULL
> > deref when it calls unregister_netdev().
> > It initializes local variable 'ndev' to NULL and nothing changes this
> > before the call to unregister_netdev(ndev) - that functions then calls:
> > unregister_netdevice > unregister_netdevice_queue > list_move_tail >
> > __list_del_entry  which dereferences the pointer (which, being NULL, will
> > end in tears).
> 
> unregister_netdevice(struct net_device *dev)
> {
>         unregister_netdevice_queue(dev, NULL);
> }
> 
>  so unregister_netdevice_queue is being called with NULL,NULL
> 
> void unregister_netdevice_queue(struct net_device *dev, struct list_head *head)
> {
>         ASSERT_RTNL();
> 
>         if (head) {
>                 list_move_tail(&dev->unreg_list, head);
>         } else {
>                 rollback_registered(dev);
>                 /* Finish processing unregister after unlock */
>                 net_set_todo(dev);
>         }
> }
> 
> if head is null, which it is from the call, then we call
> rollback_registered, and not list_move_tail()
> 
> the else calls rollback_registered(NULL) then net_set_todo(NULL)
> 
> both of which dereference null when passed, so yes there is a null
> dereference, just not in the code branch you thought.
> 

Ahh crap, you are right. Too much coffee and too late to be reading kernel 
code is my only excuse ;-)
Thanks for taking the time to look and correct me.


In any case, there's still a problem that needs to be fixed.

-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.

--8323328-1758555876-1308264719=:8140--
