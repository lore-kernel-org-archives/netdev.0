From: Guillaume Autran <gautran@mrv.com>
Subject: Re: Possible BUG in IPv4 TCP window handling, all recent 2.4.x/2.6.x
 kernels
Date: Fri, 02 Sep 2005 09:02:49 -0400
Message-ID: <43184D79.6040009@mrv.com>
References: <Pine.LNX.4.61.0509011713240.6083@guppy.limebrokerage.com> <20050901.154300.118239765.davem@davemloft.net> <Pine.LNX.4.61.0509011845040.6083@guppy.limebrokerage.com> <2d02c76a84655d212634a91002b3eccd@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ion Badulescu <lists@limebrokerage.com>,
	"David S. Miller" <davem@davemloft.net>, linux-net@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030450AbVIBNBm@vger.kernel.org>
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <2d02c76a84655d212634a91002b3eccd@psc.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I experienced the very same problem but with window size going all the 
way down to just a few bytes (14 bytes). dump files available upon 
requests :)
Ion, how were you able to reproduce the issue ? Can the same type of 
traffice always reproduce the issue or is it more intermittent ?

Best regards,
Guillaume.




John Heffner wrote:

> On Sep 1, 2005, at 6:53 PM, Ion Badulescu wrote:
>
>>
>> A few minutes later it has finally caught up to present time and it 
>> starts receiving smaller packets containing real-time data. The TCP 
>> window is still 16534 at this point.
>>
>> [tcpdump output removed]
>>
>> This is where things start going bad. The window starts shrinking 
>> from 15340 all the way down to 2355 over the course of 0.3 seconds. 
>> Notice the many duplicate acks that serve no purpose (there are no 
>> lost packets and the tcpdump is taken on the receiver so there is no 
>> packets/acks crossed in flight).
>
>
> I have an idea why this is going on.  Packets are pre-allocated by the 
> driver to be a max packet size, so when you send small packets, it 
> wastes a lot of memory.  Currently Linux uses the packets at the 
> beginning of a connection to make a guess at how best to advertise its 
> window so as not to overflow the socket's memory bounds.  Since you 
> start out with big segments then go to small ones, this is defeating 
> that mechanism.  It's actually documented in the comments in 
> tcp_input.c. :)
>
>  * The scheme does not work when sender sends good segments opening
>  * window and then starts to feed us spagetti. But it should work
>  * in common situations. Otherwise, we have to rely on queue collapsing.
>
> If you overflow the socket's memory bound, it ends up calling 
> tcp_clamp_window().  (I'm not sure this is really the right thing to 
> do here before trying to collapse the queue.)  If the receiving 
> application doesn't fall too far behind, it might help you to set a 
> much larger receiver buffer.
>
>   -John
>
> -
> To unsubscribe from this list: send the line "unsubscribe linux-net" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

-- 
=======================================
Guillaume Autran
Senior Software Engineer
MRV Communications, Inc.
Tel: (978) 952-4932 office
E-mail: gautran@mrv.com
======================================= 
