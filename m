From: Ben Greear <greearb@candelatech.com>
Subject: Re: PATCH Re: udp weirdness
Date: Tue, 01 Oct 2002 09:42:09 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D99D061.1090208@candelatech.com>
References: <200210011531.TAA19943@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chris Friesen <cfriesen@nortelnetworks.com>, hadi@cyberus.CA,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

kuznet@ms2.inr.ac.ru wrote:
> Hello!
> 
> 
>>>Feel free to implement. :-)
>>
>>I may have to poke around...if nothing else I'll learn more about the 
>>networking code...
> 
> 
> It is difficult task, if possible at all.
> 
> The main obstacle is that we must not block after select() succeeded,
> otherwise applications will lockup. Taking into account nature of datagram
> services (and generally of networking services, where routes change et al.)
> you do not know at time of select(), where the datagram will go.
> So, blocking can be made only based on a criterium not depending on this.
> 
> We use sndbuf (like all the OSes). Actually, the problem with silent
> losses is solved by tuning SO_SNDBUF. Though it is not a complete
> solution (failing whith lots of senders), it solves all those bullshit
> problems with silent losses. People just do not care about this, so
> they get the thing which they deserve.

Changing the size of the sending buffer will make you able to drop fewer
packets in bursty behaviour, but it does not guarantee you anything, does
it?  For those of us wanting to write programs with very little slop in
their behaviour, 'most of the time' is not good enough.

I have not yet looked at the UDP code in detail, but it does appear we
can know if a NIC accepts the packet for transmit or not.  If it does
not, then just don't dequeue off of the send list, retry it next time.

I cannot see any logical reason that we cannot ensure that a packet is
not at least given to the driver when accepted by sendto.  As soon as I
get my pktgen and send-to-self code cleaned up, I am planning to start
working on making UDP reliably send packets, or return an error to
the calling code.  I will, of course, keep you informed if I actually
get something working...

Enjoy,
Ben


> 
> 
> 
>>dropped when there is congestion.  If IP_RECVERR is turned on, would 
>>sendto() then return -1 so I know to try and read the error messages? 
> 
> 
> Yes.
> 
> 
> 
>>I'm assuming I get ENOBUFS back in the ee_code field?  Or can I get away 
>>with reading errno and ignoring the error queue?
> 
> 
> No, error queue should be read. But not all the errors are queued,
> only those which are supported asynchronously. ENOBUFS is still not.
> F.e. when packet is dropped lately (some qdiscs do this, dropping already
> queued packets to give place for another ones) ENOBUFS is not sent back.
> 
> 
> 
>>			     there doesn't seem to be a lot of 
>>documentation about it.
> 
> 
> Damn! (I'm sorry) It is documented _very_ well, thanks to Andi.
> I really hate this mode when people do not worrying even to look to manpages
> before pronouncing such statements.
> 
> man recvmsg
> man ip
> 
> Alexey
> 


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
