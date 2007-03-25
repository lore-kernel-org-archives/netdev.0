From: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Subject: Re: [2.6.20-rt8] "Neighbour table overflow."
Date: Mon, 26 Mar 2007 02:50:59 +0300
Message-ID: <20070325235058.GA3715@sortiz.org>
References: <FuqKSqqx.1174476366.8345250.samuel@sortiz.org>
	<Pine.LNX.4.63.0703211235220.534@pcgl.dsa-ac.de>
	<Pine.LNX.4.63.0703231309170.534@pcgl.dsa-ac.de>
	<20070324.221034.45741983.davem@davemloft.net>
Reply-To: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: gl-o/hVf8ie6tKzQB+pC5nmwQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org,
	irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070324.221034.45741983.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

On Sat, Mar 24, 2007 at 10:10:34PM -0700, David Miller wrote:
> From: Guennadi Liakhovetski <gl-o/hVf8ie6tKzQB+pC5nmwQ@public.gmane.org>
> Date: Fri, 23 Mar 2007 13:14:43 +0100 (CET)
> 
> > On Wed, 21 Mar 2007, Guennadi Liakhovetski wrote:
> > 
> > > On Wed, 21 Mar 2007, Samuel Ortiz wrote:
> > >
> > >> I'm quite sure the leak is in the IrDA code rather than in the ppp or
> > >> ipv4 one, hence the need for full irda debug...
> > 
> > Well, looks like you were wrong, Samuel. Below is a patch that fixes ONE 
> > sk_buff leak (maintainer added to cc: hi, Paul:-)). Still investigating if 
> > there are more there.
> 
> This is strange.
> 
> The PPP generic layer seems to be very careful about it's handling of
> the ->xmit_pending packet.
> 
> When a packet is added to ->xmit_pending, immediately ppp_push() is
> called, and ppp_push() gives the packet to the channels xmit function,
> and unless the xmit function returns zero the ->xmit_pending is reset
> to NULL because non-zero return from the channel xmit functions means
> that the driver took the packet.
> 
> Now I checked irnet_ppp.c, which is the driver under scrutiny here,
> and it never ever returns zero, under any circumstance, it always
> return one.
> 
> So the ->xmit_pending should always be NULL'd out by ppp_push().
> 
> There is some funny BLOCK_WHEN_CONNECT code, which will return
> 0 in certain cases, but that define it never set during the
> build.
> 
> Nevermind... that code does get enabled. :(
It is enabled, yes, from net/irda/irnet/irnet.h
It seems Jean added this option to make the connectdelay 0 pppd option
working.

 
> This looks like it might be a bug, perhaps you can only return zero
> from the transmit function when your queue really is full and you plan
> to wake things up properly when space appears (via
> ppp_output_wakeup()).  You can't return 0 because of an event which
> might never occur, that's what makes ->xmit_pending get stuck and
> leak.
I still think Guennadi's fix is correct even if you return 0 from the TX
function only when you're running out of space. If we unregister the ppp
interface before we get a chance to call ppp_output_wake(), then we'll leak
an xmit_pending skb.

I guess Paul will decide here. If he rejects Guennadi's patch, I'll come
up with some IrDA patch so that we free our pending skb from the irnet code,
or try somehow not to block the PPP tx queue while connecting.

Cheers,
Samuel.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
