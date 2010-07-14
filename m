From: Ed W <lists@wildgooses.com>
Subject: Re: Raise initial congestion window size / speedup slow start?
Date: Wed, 14 Jul 2010 23:52:02 +0100
Message-ID: <4C3E3F92.2090506@wildgooses.com>
References: <4C3E0684.5060409@wildgooses.com> <4C3E1B54.40604@hp.com> <20100714203919.GD6682@nuttenaction> <20100714.145547.102555471.davem@davemloft.net> <20100714221301.GI6682@nuttenaction>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	davidsen@tmr.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100714221301.GI6682@nuttenaction>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>> Although section 3 of RFC 5681 is a great text, it does not say at all
>> that increasing the initial CWND would lead to fairness issues.
>>      
> Because it is only one side of the medal, probing conservative the available
> link capacity in conjunction with n simultaneous probing TCP/SCTP/DCCP
> instances is another.
>    

So lets define the problem more succinctly:
- New TCP connections are assumed to have no knowledge of current 
network conditions (bah)
- We desire the connection to consume the maximum amount of bandwidth 
possible, but staying ever so fractionally under the maximum link bandwidth

> Currently I know no working link capacity probing approach, without active
> network feedback, to conservatively probing the available link capacity with a
> high CWND. I am curious about any future trends.
>    

Sounds like smarter people than I have played this game, but just to 
chuck out one idea: How about attacking the idea that we have no 
knowledge of network conditions?  After all we have a bunch of 
information about:

1) very good information about the size of the link to the first hop (eg 
the modem/network card reported rate)
2) often a reasonably good idea about the bandwidth to the first 
"restrictive" router along our default path (ie usually the situation is 
there is a pool of high speed network locally, then a more limited 
connectivity between our network and other networks.  We can look at the 
maximum flows through our network device to outside our subnet and infer 
an approximate link speed from that)
3) often moderate quality information about the size of the link between 
us and a specific destination IP

So here goes: the heuristic could be to examine current flows through 
our interface, use this to offer hints to the remote end during SYN 
handshake as to a recommended starting size, and additionally the client 
side can examine the implied RTT of the SYN/ACK to further fine tune the 
initial cwnd?

In practice this could be implemented in other ways such as examining 
recent TCP congestion windows and using some heuristic to start "near" 
those.  Or remembering congestion windows recently used for popular 
destinations?  Also we can benefit the receiver of our data - if we see 
some app open up 16 http connections to some poor server then some of 
those connections will NOT be given large initial cwnd.

Essentially perhaps we can refine our initial cwnd heuristic somewhat if 
we assume better than zero knowledge about the network link?


Out of curiousity, why has it taken so long for active feedback to 
appear?  If every router simply added a hint to the packet as to the max 
bandwidth it can offer then we would appear to be able to make massively 
better decisions on window sizes.  Furthermore routers have the ability 
to put backpressure on classes of traffic as appropriate.  I guess the 
speed at which ECN has been adopted answers the question of why nothing 
more exotic has appeared?

>> But for all we know this side discussion about initial CWND settings
>> could have nothing to do with the issue being reported at the start of
>> this thread. :-)
>>      

Actually the original question was mine and it was literally - can I 
adjust the initial cwnd for users of my very specific satellite network 
which has a high RTT.  I believe Stephen Hemminger has been kind enough 
to recently add the facility to experiment with this to the ip utility 
and so I am now in a position to go do some testing - thanks Stephen


Cheers

Ed W
