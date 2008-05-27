From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: race in skb_splice_bits?
Date: Tue, 27 May 2008 15:01:44 +0400
Message-ID: <20080527110144.GA15141@2ka.mipt.ru>
References: <200805270325.24323.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:33384 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756740AbYE0LC0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2008 07:02:26 -0400
Content-Disposition: inline
In-Reply-To: <200805270325.24323.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 27, 2008 at 03:25:23AM +0300, Octavian Purdila (opurdila@ixiacom.com) wrote:
> 
> Hi,
> 
> The following socket lock dropping in skb_splice_bits seems to open a race 
> condition which causes an invalid kernel access:
> 
> >        if (spd.nr_pages) {
> >                int ret;
> >
> >                /*                                                                                                                            
> >                 * Drop the socket lock, otherwise we have reverse                                                                            
> >                 * locking dependencies between sk_lock and i_mutex                                                                           
> >                 * here as compared to sendfile(). We enter here                                                                              
> >                 * with the socket lock held, and splice_to_pipe() will                                                                       
> >                 * grab the pipe inode lock. For sendfile() emulation,                                                                        
> >                 * we call into ->sendpage() with the i_mutex lock held                                                                       
> >                 * and networking will grab the socket lock.                                                                                  
> >                 */

What about sock_hold() here?
It will prevent from socket freeing and read/write to it will
immediately return with error if socket was closed by another thread.

> >                release_sock(__skb->sk);                                                                                                    
> >                ret = splice_to_pipe(pipe, &spd);
> >                lock_sock(__skb->sk);

And appropriate sock_put(sk);

-- 
	Evgeniy Polyakov
