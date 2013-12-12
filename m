From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: [PATCH] net: make neigh_priv_len in struct net_device 16bit
 instead of 8bit
Date: Thu, 12 Dec 2013 14:56:16 -0300
Message-ID: <20131212175616.GD8164@ghostprotocols.net>
References: <1386839759-24042-1-git-send-email-bigeasy@linutronix.de>
 <20131212105720.63318aaf@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f41.google.com ([209.85.128.41]:40362 "EHLO
	mail-qe0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751018Ab3LLR4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 12:56:22 -0500
Received: by mail-qe0-f41.google.com with SMTP id gh4so651254qeb.0
        for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 09:56:22 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131212105720.63318aaf@gandalf.local.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Thu, Dec 12, 2013 at 10:57:20AM -0500, Steven Rostedt escreveu:
> On Thu, 12 Dec 2013 10:15:59 +0100
> Sebastian Andrzej Siewior <bigeasy@linutronix.de> wrote:
> 
> > neigh_priv_len is defined as u8. With all debug enabled struct
> > ipoib_neigh has 200 bytes. The largest part is sk_buff_head with 96
> > bytes and here the spinlock with 72 bytes.
> > The size value still fits in this u8 leaving some room for more.
> > 
> > On -RT struct ipoib_neigh put on weight and has 392 bytes. The main
> > reason is sk_buff_head with 288 and the fatty here is spinlock with 192
> > bytes. This does no longer fit into into neigh_priv_len and gcc
> > complains.
> > 
> > This patch changes neigh_priv_len from being 8bit to 16bit. Since the
> > following element (dev_id) is 16bit followed by a spinlock which is
> > aligned, the struct remains with a total size of 3200 (allmodconfig) /
> > 2048 (with as much debug off as possible) bytes on x86-64.
> > On x86-32 the struct is 1856 (allmodconfig) / 1216 (with as much debug
> > off as possible) bytes long. The numbers were gained with and without
> > the patch to prove that this change does not increase the size of the
> > struct.
> > 
> > Cc: Steven Rostedt <rostedt@goodmis.org>
> > Cc: Thomas Gleixner <tglx@linutronix.de>
> > Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> > ---
> >  include/linux/netdevice.h | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> > index 0ca8100..56da573 100644
> > --- a/include/linux/netdevice.h
> > +++ b/include/linux/netdevice.h
> > @@ -1255,7 +1255,7 @@ struct net_device {
> >  	unsigned char		perm_addr[MAX_ADDR_LEN]; /* permanent hw address */
> 
> MAX_ADDR_LEN is 32, thus it ends with proper alignment.
> 
> >  	unsigned char		addr_assign_type; /* hw address assignment type */
> >  	unsigned char		addr_len;	/* hardware address length	*/
> > -	unsigned char		neigh_priv_len;
> > +	unsigned short		neigh_priv_len;
> 
> That means the new change should not affect the structure at all, as
> the original structure has three chars followed by a short. This would
> produce a 1 byte hole.
> 
> I wonder if Arnaldo's pahole tools would show this?

Yes, it will, in a recent build here:

pahole -C net_device ../build/v3.13.0-rc1+/net/socket.o
<SNIP>
        unsigned char              perm_addr[32];        /*   532    32 */
        unsigned char              addr_assign_type;     /*   564     1 */
        unsigned char              addr_len;             /*   565     1 */
        unsigned char              neigh_priv_len;       /*   566     1 */

        /* XXX 1 byte hole, try to pack */

        short unsigned int         dev_id;               /*   568     2 */
<SNIP>

So, yeah, one can promote neigh_priv_len from 'unsigned char' to 'unsigned
short' and the result will have the same sizeof and layout, modulo that hole,
that will disappear.
 
> -- Steve
> 
> >  	unsigned short          dev_id;		/* Used to differentiate devices
> >  						 * that share the same link
> >  						 * layer address
