From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: Re: [PATCH -next v2] unix stream: Fix use-after-free crashes
Date: Tue, 06 Sep 2011 12:33:00 -0700
Message-ID: <1315337580.2576.3066.camel@schen9-DESK>
References: <4E631032.6050606@intel.com>
	 <1315326326.2576.2980.camel@schen9-DESK>
	 <1315330805.2899.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1315335019.2576.3048.camel@schen9-DESK>
	 <1315335660.3400.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Yan, Zheng" <zheng.z.yan@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"jirislaby@gmail.com" <jirislaby@gmail.com>,
	"sedat.dilek@gmail.com" <sedat.dilek@gmail.com>, alex.shi@intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:53919 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754656Ab1IFTao (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Sep 2011 15:30:44 -0400
In-Reply-To: <1315335660.3400.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-09-06 at 21:01 +0200, Eric Dumazet wrote:

> > All the skbs put on the list does have proper reference on pid/scm.  In
> > the example you give, the first skb got the reference at this line:
> > 
> > err = unix_scm_to_skb(siocb->scm, skb, !fds_sent, fds_sent);
> 
> This is the current code. We know its buggy.
> 
> I was discussing of things after proposed patch, not current net-next.

I think we are on the same page.


> My approach would basically revert the 7361c36c commit too :(

I think so.  I was not fond of commit 7361c36c as it caused a 90%
regression in threaded case of hackbench that we noticed back in 2.6.36
days.  If there's some way to undo its evil, I'm all for it.

> 
> I am sorry, but the only way to avoid too many pid/cred references is to
> lock the socket [aka unix_state_lock(other);] for the whole send()
> duration.

Yes, I think locking the sendmsg for the entire duration of
unix_stream_sendmsg makes a lot of sense.  It simplifies the logic a lot
more.  I'll try to cook something up in the next couple of days.

> 
> This way, you can really increment the pid/cred reference on the last
> pushed skb, because no reader can 'catch first skb'
> 
> As soon as unix_state_unlock(other) is called, everything can happen, so
> skb must be self contained, as I stated in my earlier mail.
> 
> 
> 

Thanks.

Tim
