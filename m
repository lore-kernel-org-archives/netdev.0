From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH] xen/netback: calculate correctly the SKB slots.
Date: Thu, 24 May 2012 12:12:58 +0100
Message-ID: <1337857978.7229.27.camel@zakaz.uk.xensource.com>
References: <1337621793-12486-1-git-send-email-konrad.wilk@oracle.com>
	 <1337627640.2979.33.camel@bwh-desktop.uk.solarflarecom.com>
	 <1337678512.10118.40.camel@zakaz.uk.xensource.com>
	 <20120522180901.GC22488@phenom.dumpdata.com> <4FBBE7D2.9040105@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Adnan Misherfi <adnan.misherfi@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4FBBE7D2.9040105@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-05-22 at 20:24 +0100, Adnan Misherfi wrote:
> 
> Konrad Rzeszutek Wilk wrote:
> >>>> wrong, which caused the RX ring to be erroneously declared full,
> >>>> and the receive queue to be stopped. The problem shows up when two
> >>>> guest running on the same server tries to communicates using large
> >>>>         
> > .. snip..
> >   
> >>> The function name is xen_netbk_count_skb_slots() in net-next.  This
> >>> appears to depend on the series in
> >>> <http://lists.xen.org/archives/html/xen-devel/2012-01/msg00982.html>.
> >>>       
> >> Yes, I don't think that patchset was intended for prime time just yet.
> >> Can this issue be reproduced without it?
> >>     
> >
> > It was based on 3.4, but the bug and work to fix this was  done on top of
> > a 3.4 version of netback backported in a 3.0 kernel. Let me double check
> > whether there were some missing patches.
> >
> >   
> >>>>  	int i, copy_off;
> >>>>  
> >>>>  	count = DIV_ROUND_UP(
> >>>> -			offset_in_page(skb->data)+skb_headlen(skb), PAGE_SIZE);
> >>>> +			offset_in_page(skb->data + skb_headlen(skb)), PAGE_SIZE);
> >>>>         
> >>> The new version would be equivalent to:
> >>> 	count = offset_in_page(skb->data + skb_headlen(skb)) != 0;
> >>> which is not right, as netbk_gop_skb() will use one slot per page.
> >>>       
> >> Just outside the context of this patch we separately count the frag
> >> pages.
> >>
> >> However I think you are right if skb->data covers > 1 page, since the
> >> new version can only ever return 0 or 1. I expect this patch papers over
> >> the underlying issue by not stopping often enough, rather than actually
> >> fixing the underlying issue.
> >>     
> >
> > Ah, any thoughts? Have you guys seen this behavior as well?
> >   
> >>> The real problem is likely that you're not using the same condition to
> >>> stop and wake the queue.
> >>>       
> >> Agreed, it would be useful to see the argument for this patch presented
> >> in that light. In particular the relationship between
> >> xenvif_rx_schedulable() (used to wake queue) and
> >> xen_netbk_must_stop_queue() (used to stop queue).
> >>     
> >
> > Do you have any debug patches to ... do open-heart surgery on the
> > rings of netback as its hitting the issues Adnan has found?
> >
> >   
> >> As it stands the description describes a setup which can repro the
> >> problem but doesn't really analyse what actually happens, nor justify
> >> the correctness of the fix.
> >>     
> >
> > Hm, Adnan - you dug in to this and you got tons of notes. Could you
> > describe what you saw that caused this?
> >   
> The problem is that the function xen_netbk_count_skb_slots() returns two 
> different counts for same type packets of same size (ICMP,3991). At the 
> start of the test
> the count is one, later on the count changes to two, soon after the 
> counts becomes two, the condition ring full becomes true, and queue get 
> stopped, and never gets
> started again.There are few point to make here:
> 1- It takes less that 128 ping packets to reproduce this
> 2- What is interesting here is that it works correct for many packet 
> sizes including 1500,400,500 9000, (3990, but not 3991)
> 3- The inconsistent count for the same packet size and type
> 4- I do not believe the ring was actually full when it was declared 
> full, I think the consumer pointer was wrong. (vif->rx_req_cons_peek in 
> function xenvif_start_xmit())
> 5- After changing the code the count returned from 
> xen_netbk_count_skb_slots() was always consistent, and worked just fine, 
> I let it runs for at least 12 hours.

That doesn't really explain why you think your fix is correct though,
which is what I was asking for.

In any case, does Simon's patch also fix things for you? As far as I can
tell that is the right fix.

Ian.
