From: Michal Ostrowski <mostrows@watson.ibm.com>
Subject: Re: [PATCH, untested] Support for PPPOE on SMP
Date: 25 Jun 2003 09:21:02 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1056547262.1945.1436.camel@brick.watson.ibm.com>
References: <20030625072602.529AF2C0B9@lists.samba.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, Paul MacKerras <paulus@samba.org>,
   netdev@oss.sgi.com, fcusack@samba.org,
   "David F. Skoll" <dfs@roaringpenguin.com>,
   James Carlson <carlson@workingcode.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Rusty Russell <rusty@rustcorp.com.au>
In-Reply-To: <20030625072602.529AF2C0B9@lists.samba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

First some background for those new to this discussion (I was going post
the original discussion that strted this to this list, but the summary
here should get everyone up to speed).

A user has observed a race condition where the last packet of PPPoE
discovery arrives just before the first payload packet.  The discovery
packet carries the session id and pppd needs to take this session id and
create a PPPoE socket which will then pick up all packets matching the
given session id.  The race is between the arrival of the first payload
packet and  pppd's creation of the socket that is to receive PPPoE
payload.  If the packet wins the race, the payload packet is lost.  This
problem was noticed only because the ISP in this case configured their
systems to use a longer, non-standard (but legal) retransmit timeout
thus causing noticeable delays in PPP negotiation.

About the patch:  Do we have any guarantees that no drivers will break
this?  From the few drivers I've looked at, this will not be a problem
since they lock to ensure that we can't have races in submitting packets
to netif_rx.  My concern here would be that it appears that there is no
explicit requirement that this be so; we may be safe in this regard only
by accident.  (I can think of a device and driver design where this need
not be so.) 

> +
> +static inline int net_proto_serialize(struct sk_buff *skb,
> +				      int this_cpu, 
> +				      int *ret)
> +{
> +	if (likely(skb->protocol != ETH_P_PPP_DISC 
> +		   && skb->protocol != ETH_P_PPP_SES))
> +		return 0;

I believe there are concerns with other protocols as well (SNA, spanning
tree - I'm just the messenger on this).  If this is so, then I have two
concerns:

  1.  Some protocols may have no in-kernel implementation, we'd have to
      ensure that raw sockets get packets in the right order (perhaps 
      even regardless of what packet type we hreceive).

  2.  There are two issues with PPPoE: there's the creation race
      described above which requires correct ordering of packets of two
      different packet types (discovery is 0x8863, payload is 0x8864),
      as well payload packets must be ordered to handle Paul's concerns 
      regarding compression.

The patch as is adequate to 2), but I'm concerned it would get ugly if
we need to do 1) (and in the process of doing 1) we may break 2) if we
can't synchronize between two different packet types).

I think we can fix the race condition I've described up top without such
core infrastructure changes (delay dropping unmatched payload packets,
give pppd a chance to make the socket).  This however doesn't solve the
other ordering problems.

-- 
Michal Ostrowski <mostrows@watson.ibm.com>
