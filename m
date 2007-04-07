From: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Subject: Re: [BUG] 2.6.20.1-rt8 irnet + pppd recursive
	spinlock...
Date: Sat, 7 Apr 2007 03:59:26 +0300
Message-ID: <20070407005926.GE4177@sortiz.org>
References: <Pine.LNX.4.63.0704050846480.534@pcgl.dsa-ac.de>
	<Pine.LNX.4.63.0704051250170.534@pcgl.dsa-ac.de>
Reply-To: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, linux-rt-users-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Guennadi Liakhovetski <gl-o/hVf8ie6tKzQB+pC5nmwQ@public.gmane.org>
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.63.0704051250170.534-pjC7uWgG1yLsj6RlE8knwQ@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=irda-users>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Guennadi,

On Thu, Apr 05, 2007 at 12:59:40PM +0200, Guennadi Liakhovetski wrote:
> Ok, a simple analysis reveals the recursive spinlock:
> 
> On Thu, 5 Apr 2007, Guennadi Liakhovetski wrote:
> 
> > [<bf12b220>] (ppp_channel_push+0x0/0xc8 [ppp_generic]) from [<bf12bf98>] (ppp_output_wakeup+0x18/0x1c [ppp_generic])
> ===>		^^^^^^^^^^^^^^^^
> >  r7 = C38F42BC  r6 = C38F4200  r5 = C38F4200  r4 = 00000000
> 
> ===>	spin_lock_bh(&pch->downl);
> 
> > [<bf12bf80>] (ppp_output_wakeup+0x0/0x1c [ppp_generic]) from [<bf132c98>] (irnet_flow_indication+0x38/0x3c [irnet])
> > [<bf132c60>] (irnet_flow_indication+0x0/0x3c [irnet]) from [<bf104e4c>] (irttp_run_tx_queue+0x1c0/0x1d4 [irda])
> > [<bf104c8c>] (irttp_run_tx_queue+0x0/0x1d4 [irda]) from [<bf104f88>] (irttp_data_request+0x128/0x4f8 [irda])
> >  r8 = BF121560  r7 = 00000002  r6 = C38F4200  r5 = C21418B8
> >  r4 = C21418B8 
> > [<bf104e60>] (irttp_data_request+0x0/0x4f8 [irda]) from [<bf1321bc>] (ppp_irnet_send+0x134/0x238 [irnet])
> > [<bf132088>] (ppp_irnet_send+0x0/0x238 [irnet]) from [<bf12a600>] (ppp_push+0x80/0xb8 [ppp_generic])
> >  r7 = C3A436E0  r6 = 00000000  r5 = C21418B8  r4 = C1489600
> > [<bf12a580>] (ppp_push+0x0/0xb8 [ppp_generic]) from [<bf12a8d8>] (ppp_xmit_process+0x34/0x50c [ppp_generic])
> ===>		^^^^^^^^
> >  r7 = 00000021  r6 = C21418B8  r5 = C1489600  r4 = 00000000
> 
> ===>		spin_lock_bh(&pch->downl);
> 
> > [<bf12a8a4>] (ppp_xmit_process+0x0/0x50c [ppp_generic]) from [<bf12aed8>] (ppp_start_xmit+0x128/0x254 [ppp_generic])
> > [<bf12adb0>] (ppp_start_xmit+0x0/0x254 [ppp_generic]) from [<c0186fa4>] (dev_hard_start_xmit+0x170/0x268)
> > [<c0186e34>] (dev_hard_start_xmit+0x0/0x268) from [<c01979b8>] (__qdisc_run+0x60/0x270)
> >  r8 = C1BBC914  r7 = C21418B8  r6 = 00000000  r5 = C21418B8
> >  r4 = C1BBC800 
> > [<c0197958>] (__qdisc_run+0x0/0x270) from [<c0187250>] (dev_queue_xmit+0x1b4/0x25c)
> 
> Now, does anyone have an idea how best to fix it?
> 
> 1. Should re-entrance in ppp_channel_push() be prevented, and if yes - at 
> which level? Or
> 
> 2. Should re-entrance be allowed and only recursive spin_lock_bh() 
> avoided?
IMHO, irnet_flow_indication() should be called asynchronously by
irttp_run_tx_queue(), through some bottom-half mechanism. That would fix your
locking issues, and that would reduce the time we spend in the IrDA code with
this lock taken.

I will try to come up with some patches for you later this weekend.

Cheers,
Samuel.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
