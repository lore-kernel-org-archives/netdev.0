From: Patrick McHardy <kaber@trash.net>
Subject: Re: IPsec xfrm resolution
Date: Fri, 18 Feb 2005 00:26:57 +0100
Message-ID: <42152841.5000707@trash.net>
References: <20050209085251.GA9030@gondor.apana.org.au> <420B9DF1.3020704@trash.net> <20050210202810.GA1609@gondor.apana.org.au> <42144C3F.2060501@trash.net> <20050217091137.GA9476@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Maillist netdev <netdev@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050217091137.GA9476@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

>On Thu, Feb 17, 2005 at 08:48:15AM +0100, Patrick McHardy wrote:
>
>>sorry for the delay, I haven't made much progress yet. The old patch was
>>crap, I started over again. So far I've been mostly looking into a better
>>wake-up mechanism for SADB changes than the brute-force approach currently
>>taken with km_waitq. All incomplete bundles are waiting on exactly one
>>SA at a time. Keying daemons need to specify the sequence number for SAs
>>installed in response to an acquire request, finding everything waiting
>>on this SA is easy. But it could also be added manually by the user, in
>>which case the larval state SA continues to exist. I'm not sure if we need
>>to cover this case. A different problem is finding everything waiting on a
>>SA when SAs turn invalid to send back an ICMP error without waiting for a
>>timeout. Adding a wait list to larval state SAs would be ok (if useful),
>>but adding a list to every state would be a big mess. So it seems we can't
>>do much better than km_waitq. SPD changes are fortunately pretty easy,
>>when policies are inserted we do nothing, packets should always use the
>>policy that was active for them at the time of the first lookup. When the
>>policy that was selected is removed we simply drop the packets.
>>I appreciate any comments you might have, I'll try to come up with some code
>>in the next days.
>>
>
>Thanks for the update.  I think there's another aspect of the problem
>that we can tackle first.
>
>To me there are two parts to the puzzle.  We've got packets whose flow
>resolves to an incomplete bundle and we've got sockets whose dst is an
>incomplete bundle.
>
>Whatever solution we come up with needs to resolve both problems.
>
>First of all the sockets shouldn't wait for the larval states to
>materialise.  The reason is that the information they need from
>the bundle (such as the MTU) is either already available or
>can be provided through a best-effort guess such that the socket
>can handle a change later on when the larval state is filled in.
>
>To do this we need to be able to generate xfrm_dst bundles with
>larval states.  This shouldn't be difficult.
>
Yes, this part is simple. There's one thing I think we need to do
slightly different from what you describe. The current behaviour is
to resolve one SA at a time, we should keep it this way because we
may need an early SA in the bundle for a different policy to resolve
a follow-up SA for nested tunnels with different peers where the
second peer is only reachable through a tunnel to the first peer.
I'm not sure if this actually works, but it also saves traffic when
resolving a SA fails. So in addition to larval state SAs we also add
XFRM_STATE_VOID SAs initialized to the parameters contained in the
template to the bundle.

I'm not sure yet how to deal with optional SAs. We shouldn't add
incomplete optional tunnel mode SAs to the bundle because then we
can't determine the output device, but if we don't nothing will
trigger resolving of optional SAs following a non-optional SA that
needs to be resolved.

>If we apply the same strategy to the packets (by giving them bundles
>with larval states in them) then we can defer the waiting from the
>route loop-up stage to the dst output stage.  There the packet can
>be placed on a queue similar to arp_queue.
>
>At this point we can come back and revisit the problem that you've
>pointed out.  I haven't thought about it very much so this might
>sound silly: We could either key the packets by the larval SA so that
>when that larval SA is updated through UPDATESA or GETSPI/UPDATESA
>we process the packets.  Or we could key the packets by its flow so
>that the creation of any SA matching that flow causes them to be
>processed.
>
I thought about adding the queue to the xfrm_dst and adding a dummy
xfrm_state with a selector that matches only the current flow. This
allows us to cache incomplete bundles, more easily find all packets
affected by SADB changes and only resolve the bundle once for the
entire queue. The downside is that we could potentially get a lot of
bundles.

Finding all queues affected by ADDSA/UPDATESA is not easy. A SA
installed in response to an acquire request doesn't need to match
the one requested, so theoretically states waiting on different
larval states SAs might be able to use it. I don't think we have
much choice other than looking at all incomplete bundles (or
one per flow) on SADB changes.

>Feel free to move the discussion to netdev so that others can voice
>their thoughts.
>
Thanks for your input.

Regards
Patrick
