From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: SKB paged fragment lifecycle on receive
Date: Fri, 24 Jun 2011 11:21:15 -0700
Message-ID: <4E04D59B.8060301@goop.org>
References: <1308930202.32717.144.camel@zakaz.uk.xensource.com>	
	<4E04C961.9010302@goop.org>
	<1308938183.2532.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>,
	xen-devel <xen-devel@lists.xensource.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <1308938183.2532.8.camel@edumazet-laptop>
List-Unsubscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

On 06/24/2011 10:56 AM, Eric Dumazet wrote:
> Le vendredi 24 juin 2011 =C3=A0 10:29 -0700, Jeremy Fitzhardinge a =C3=A9=
crit :
>> On 06/24/2011 08:43 AM, Ian Campbell wrote:
>>> We've previously looked into solutions using the skb destructor callb=
ack
>>> but that falls over if the skb is cloned since you also need to know
>>> when the clone is destroyed. Jeremy Fitzhardinge and I subsequently
>>> looked at the possibility of a no-clone skb flag (i.e. always forcing=
 a
>>> copy instead of a clone) but IIRC honouring it universally turned int=
o a
>>> very twisty maze with a number of nasty corner cases etc. It also see=
med
>>> that the proportion of SKBs which get cloned at least once appeared a=
s
>>> if it could be quite high which would presumably make the performance
>>> impact unacceptable when using the flag. Another issue with using the
>>> skb destructor is that functions such as __pskb_pull_tail will eat (a=
nd
>>> free) pages from the start of the frag array such that by the time th=
e
>>> skb destructor is called they are no longer there.
>>>
>>> AIUI Rusty Russell had previously looked into a per-page destructor i=
n
>>> the shinfo but found that it couldn't be made to work (I don't rememb=
er
>>> why, or if I even knew at the time). Could that be an approach worth
>>> reinvestigating?
>>>
>>> I can't really think of any other solution which doesn't involve some
>>> sort of driver callback at the time a page is free()d.
> This reminds me the packet mmap (tx path) games we play with pages.
>
> net/packet/af_packet.c : tpacket_destruct_skb(), poking
> TP_STATUS_AVAILABLE back to user to tell him he can reuse space...

Yes.  Its similar in the sense that its a tx from a page which isn't
being handed over entirely to the network stack, but has some other
longer-term lifetime.

>> One simple approach would be to simply make sure that we retain a page
>> reference on any granted pages so that the network stack's put pages
>> will never result in them being released back to the kernel.  We can
>> also install an skb destructor.  If it sees a page being released with=
 a
>> refcount of 1, then we know its our own reference and can free the pag=
e
>> immediately.  If the refcount is > 1 then we can add it to a queue of
>> pending pages, which can be periodically polled to free pages whose
>> other references have been dropped.
>>
>> However, the question is how large will this queue get?  If it remains
>> small then this scheme could be entirely practical.  But if almost eve=
ry
>> page ends up having transient stray references, it could become very
>> awkward.
>>
>> So it comes down to "how useful is an skb destructor callback as a
>> heuristic for page free"?
>>
> Dangerous I would say. You could have a skb1 page transferred to anothe=
r
> skb2, and call skb1 destructor way before page being released.

Under what circumstances would that happen?

> TCP stack could do that in tcp_collapse() [ it currently doesnt play
> with pages ]

Do you mean "dangerous" in the sense that many pages could end up being
tied up in the pending-release queue?  We'd always check the page
refcount, so it should never release pages prematurely.

Thanks,
    J
