From: Darrel Goeddel <dgoeddel@trustedcs.com>
Subject: Re: Multiple end-points behind same NAT
Date: Mon, 04 Dec 2006 09:52:51 -0600
Message-ID: <45744453.6020606@trustedcs.com>
References: <E1GqLUW-0006hZ-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Venkat Yekkirala <vyekkirala@trustedcs.com>,
	netdev@vger.kernel.org, chanson@trustedcs.com, bphan@trustedcs.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:10975 "EHLO
	tcsfw4.tcs-sec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937038AbWLDPyV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 10:54:21 -0500
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1GqLUW-0006hZ-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Venkat Yekkirala <vyekkirala@trustedcs.com> wrote:
> 
>>I am wondering if 26sec supports NAT-Traversal for multiple
>>endpoints behind the same NAT. In looking at xfrm_tmpl it's
>>not obvious to me that it's supported, at least going by the
>>following from the setkey man page:
>>
>>            When NAT-T is enabled in the kernel, policy matching for ESP over
>>            UDP packets may be done on endpoint addresses and port (this
>>            depends on the system.  System that do not perform the port check
>>            cannot support multiple endpoints behind the same NAT).  When
>>            using ESP over UDP, you can specify port numbers in the endpoint
>>            addresses to get the correct matching.  Here is an example:
>>
>>            spdadd 10.0.11.0/24[any] 10.0.11.33/32[any] any -P out ipsec
>>                esp/tunnel/192.168.0.1[4500]-192.168.1.2[30000]/require ;
>>
>>Or is this to be accomplished in a different way?
> 
> 
> It depends on whether it's transport mode or tunnel mode.  In tunnel
> mode it should work just fine.  Transport mode on the other hand
> has fundamental problems with NAT-T that go beyond the Linux
> implementation.

We are experiencing problem when using tunnel mode.

Consider the example where the responder is 10.1.0.100 and there are two
clients (192.16.8.0.100 and 192.168.0.101) behind a single NAT.  The translated
address is 10.1.0.200.  We are having the IKE daemon (racoon) generate policy
based on the initiators policy.

When 192.168.0.100 initiates a connection to 10.1.0.100, racoon creates and
inserts the following SAs:

	10.1.0.100[4500] -> 10.1.0.200[4500]
	10.1.0.200[4500] -> 10.1.0.100[4500]

4500 is the NAT-T encapsulation ports on the dst and src passed in through
the SADB_X_EXT_NAT_T*PORT messages.

Policy is then generated of the form (omitting fwd policies):

	192.168.1.100[any] 10.1.0.100[any] any in prio def ipsec
		esp/tunnel/10.1.0.200-10.1.0.100/require
	10.1.0.100[any] 192.168.1.100[any] any out prio def ipsec
		esp/tunnel/10.1.0.100-10.1.0.200/require

Everything works fine at this point :)

When the other client behind the NAT initiates a connection, the following
SAs and SPD are created and inserted.

	10.1.0.100[1024] -> 10.1.0.200[4500]
	10.1.0.200[4500] -> 10.1.0.100[1024]

	192.168.1.101[any] 10.1.0.100[any] any in prio def ipsec
		esp/tunnel/10.1.0.200-10.1.0.100/require
	10.1.0.100[any] 192.168.1.101[any] any out prio def ipsec
		esp/tunnel/10.1.0.100-10.1.0.200/require

This is where things break down :(  If the first client sends a message
to the responder, the response gets sent to the second client.  In fact
if you add more clients, responses to *all* of the clients will use the
last outbound SA generated and therefore go to the last connected client
because it will be using that encapsulation port.

I believe (I'll be confirming in a bit) that racoon is sending the encap port
info in the SPD, but that info is never used by the kernel.  It would seem
that information must be retained with the xfrm_tmpl, and used in the SA
selection process (compared with the encap info in the xfrm_state) for multiple
clients to work.

Does the above scenario seem to have the SAs and SPDs set up correctly (we've
already made some slight changes to racoon to get it work properly on Linux...)?
What is the mechanism that would tie the SPD to particular SAs and allow it to
use the SA with the appropriate encap information when the tunnel endpoint
address are the same (clients behind the same NAT)?

I something isn't clear in my explanation of the behavior that we are
experiencing, please ask (I hope I got it all right).

Thanks,
Darrel
