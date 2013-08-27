From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [PATCH 0/5] netfilter: SYNPROXY target v3
Date: Tue, 27 Aug 2013 10:35:56 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1308270951520.25216@ask.diku.dk>
References: <1377586216-7024-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, mph@one.com, jesper.brouer@gmail.com,
	as@one.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:54282 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752780Ab3H0IgH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Aug 2013 04:36:07 -0400
In-Reply-To: <1377586216-7024-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 27 Aug 2013, Patrick McHardy wrote:

> The following patches contain the latest version of the SYNPROXY target.
>
> The SYNPROXY operates by marking the initial SYN from the client as UNTRACKED
> and directing it to the SYNPROXY target. The target responds with a SYN/ACK
> containing a cookie and encodes options such as window scaling factor, SACK
> perm etc. into the timestamp, if timestamps are used (similar to TCP). The
> window size is set to zero. The response is also sent as untracked packet.
>
> When the final ACK is received the cookie is validated, the original options
> extracted and a SYN to the original destination is generated. The SYN to the
> original destination uses the avertised window from the final ACK and the
> options from the initial SYN packet. The SYN is not sent as untracked, so
> from a connection tracking POV it will look like the original packet from
> the client and instantiate a new connection. When the server responds with
> a SYN/ACK a final ACK for the server is generated and a window update with
> the window size announced by the server is sent to the client. At this
> point the connection is handed of to conntrack and the only thing the
> target is still involved in is timestamp translation through the registerd
> hooks.
>
> Since the SYN proxy can't know the options the server supports, they have
> to be specified as parameters to the SYNPROXY target. The assumption is that
> these options are constant as long as you don't change settings on the
> server.

Future extention idea: Perhaps we could auto detect the options the server 
supports, after the first connection have been created?
I know this is problematic/difficult for the iptables framework, because 
it would require the module to keep an internal dynamic state, which 
iptables module does not handle well (due to how the entires ruleset is 
reloaded on rule changes).
Guess, the easiest thing to implement, would be to give a warning,
if the options (the server supports) does not match the modules config.



> Since the SYN proxy can't know the initial sequence number and
> timestamp values the server will use, both have to be translated in the
> direction server->client. Sequence number translation is done using the
> standard sequence number translation mechanisms originally only used for
> NAT, timestamps are translated in a hook registered by the SYNPROXY target.
>
> Usage is as follows:
>
> iptables -t raw -A PREROUTING -i eth0 -p tcp --dport 80 --syn -j NOTRACK
> iptables -A INPUT -i eth0 -p tcp --dport 80 -m state UNTRACKED,INVALID \
>        -j SYNPROXY --sack-perm --timestamp --mss 1480 --wscale 7 --ecn
>
> echo 0 > /proc/sys/net/netfilter/nf_conntrack_tcp_loose
>
> The second rule catches untracked packets and directs them to the target.
> The purpose of disabling loose tracking is to have the final ACK from the
> client not be picked up by conntrack, so it won't create a new conntrack
> entry and will be marked INVALID and also get directed to the target.
>
> We did some extensive testing on Monday and it verified all retransmit
> bugs have been fixed. With 1.4Mpps SYNs the load on a 16 way Xeon L6530
> 2.13 Ghz machine was between 3% and 6%.

It was a Xeon L5630 ;-)

We tested both SYN and ACK flood-attacks, while running ab (Apache 
Benchmark). The 1.4Mpps comes from limitations on the generator host 
(which used trafgen).  We also did some short tests with a modified 
pktgen.  And Martin wrote a test tool, that would delay conn 
establishment, to test retransmits.  And Patritck tested in (simulated) 
drop situations.


> There's one single change since v2:
>
> Reopened TCP connections while the conntrack is in CLOSE state weren't
> handled properly. The sequence number and timestamp adjustments need
> to be reset in this case. Another counter has been introduced for this.
>
> From my POV, these patches are ready for merging now.

Yes, Martin and Patrick (and I) have done some good testing of the module. 
And we have flushed out and solved several bugs in this process.


Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
