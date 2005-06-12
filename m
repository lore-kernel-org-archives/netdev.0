From: Thomas Graf <tgraf@suug.ch>
Subject: Re: testing techniques to confirm the effectiveness of changes made to sch_gred.c
Date: Sun, 12 Jun 2005 12:46:28 +0200
Message-ID: <20050612104628.GA22463@postel.suug.ch>
References: <4532f3170506101739702e31ad@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, netdev@vger.kernel.org, lartc-request@mailman.ds9a.nl,
        diffserv-general@lists.sourceforge.net, linux.kernel@googlegroups.com
Return-path: <netdev-bounce@oss.sgi.com>
To: rahul.hari@cse06.itbhu.org
Content-Disposition: inline
In-Reply-To: <4532f3170506101739702e31ad@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Rahul Hari <4532f3170506101739702e31ad@mail.gmail.com> 2005-06-11 06:09
> I have made some changes to the file sch_gred.c to modify the GRED
> queueing discipline to support the following features:
> 1) The first virtual queue should get absolute priority while
> dequeueing (not caring if the others get starved)
> 2) While in equalise mode and with RIO mode enabled, the packets in
> the first virtual queue should not be counted for calculating the
> qave.

You do not need to modify gred to achieve this, use a prio qdisc
with 2 bands, band 1 covers your "first virtual queue" with a single
red attached, band 2 covers the rest and uses a gred.

> 1) Since the  process deals with dequeueing, i have to make changes to
> gred_dequeue only. If t->tab[0] != 0 then  we dequeue the packet
> otherwise do not dequeue it.

What you describe above is: only dequeue when DP 0 is configured,
probably not what you want. The only way to prioritize within gred
the way you want is to modify dequeue() that it iterates through
sch->q looking for a skb with tcindex==DP0 and use it instead of
the skb at the queue head.

> 2)  
> if (t->eqp && t->grio) {
> 
>          for (i=0;i<t->DPs;i++) {
> 			if ((!t->tab[i]) || (i==q->DP) || (i==0))	
> 				continue; 
> 				
> 			if ((t->tab[i] != q) && (PSCHED_IS_PASTPERFECT(t->tab[i]->qidlestart)))
> 				qave +=t->tab[i]->qave;
> 		     }

You no longer consider the priority so it won't be wred anymore,
also if (i == q->DP) continue makes a check t->tab[i] != q
unnecessary.
