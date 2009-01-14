From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: RFC: Latency reducing TCP modifications for thin-stream interactive
 applications
Date: Wed, 14 Jan 2009 17:32:32 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0901121705010.1889@wrl-59.cs.helsinki.fi>
References: <496B59B7.3010302@simula.no>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-767947407-1231772791=:1889"
Cc: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>,
	linux-net@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	linux-rt-users@vger.kernel.org, mdavem@davemloft.net,
	jgarzik@pobox.com, kohari@novell.com, peterz@infradead.org,
	jzemlin@linux-foundation.org, mrexx@linux-foundation.org,
	tytso@mit.edu, mingo@elte.hu, kristrev@simula.no, griff@simula.no,
	paalh@ifi.uio.no, Netdev <netdev@vger.kernel.org>,
	shemminger@vyatta.com
To: Andreas Petlund <apetlund@simula.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35732 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754477AbZANPcf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 10:32:35 -0500
In-Reply-To: <496B59B7.3010302@simula.no>
Content-ID: <Pine.LNX.4.64.0901141704490.1889@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-767947407-1231772791=:1889
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0901121707071.1889@wrl-59.cs.helsinki.fi>

On Mon, 12 Jan 2009, Andreas Petlund wrote:

> Thank you for comprehensive feedback. We're sorry it took so long to reply.
> We will begin the work on a patch set against the net-next tree now and 
> try to follow your formatting and functional advice.

Sadly it will be quite a lot of work (I know, many changes have happened).

> Ilpo Järvinen wrote:
> > linux-net is users list, use netdev instead on matters relating
> > development...
> 
> Bad case of typo :)

Also you could have had a bit less exhaustive cc list, IMHO :-).

> > Please make sure that it's based on net-next tree next time since there
> > are lots of changes already in the areas you're touching.
> 
> We will do that for the updated patch set.

Thanks, that will greatly help review when I don't have to apply into some 
very oldish kernel version (-p style patch would have helped to show the 
context better). 

> >> This will also give us time to integrate any ideas that may arise from
> >> the discussions here.
> >>
> >> We are happy for all feedback regarding this:
> >> Is something like this viable to introduce into the kernel?
> >>
> > No idea in general. But it has to be (nearly) minimal and clean if such
> > thing is ever to be considered. The one below is definately not even close
> > minimal in many areas...
> 
> We will clean up the noise, redo the formatting and divide it into logical 
> segments for the new patch set.

I hope you get more feedback on viability then, my comments were mainly 
on technical side.

> >> Is the scheme for thin-stream detection mechanism acceptable.
> >
> > Does reduncancy happen in the initial slow start as well (depends on
> > write pattern)? Why it is so in case the stream is to become thick
> > right after initial rtts?

This is probably partially my misunderstanding as well, I just assumed 
tcp_stream_is_thin() is used everywhere without reading too carefully
all those (a && b || (c || (!e && d))) mess.

But in general the problem is still there, ie., if even if some magic 
would claim that stream is "thin" we cannot apply that to the streams 
which, after the initial slow-start, will no longer match to that magic. 
Otherwise stating that we only apply this and this to thin streams won't 
be valid.

> If the window is halved, (but still not at less than 4 segment), the 
> mechanisms will be turned off (due to the < 4 packets in flight limit). 

I'm sorry, this makes not sense to me...

> If the stream backs off to a minimal window, the mechanisms will be 
> turned on.
> 
> The bundling mechanism (if activated) will stay active since it relies on
> the packet sizes and interarrival time, not on number of packets in flight.

Likewise, maybe you're talking of some other version of the patch since
I cannot find such parts that do what you describe (or the patch is just 
too messy :-)).

> > ...In general this function should be split, having a separate skb
> > (non-TCP) function(s) and tcp-side would be ideal.
> >
> > It's misnamed as well, it won't merge but duplicates?
> >
> > Also, this approach is extremely intrusive and adding non-linear seqno
> > things into write queue will require _you_ to do _full audit_ over every
> > single place to verify that seqno leaps backwards won't break anything
> > (and you'll still probably miss some cases). I wonder if you realize
> > how easily this kind of change manifests itself as a silent data
> > corruption on stream level and have taken appropriate actions to validate
> > that not a single one of scenario leads to data coming as different out as
> > was sent in (every single byte, it's not enough to declare that
> > application worked which could well happen with corrupted data too). TCP
> > is very coreish and such bugs will definately hit people hard.
> 
> We have to admit we don't quite see the problem. Since a page can never 
> be removed before all owners have decleared that they no longer needs 
> it, all data will be correctly present. Also, since the packets are 
> placed linearly on the queue and we don't support when SACK is enabled, 
> no gaps will occur. But maybe we have misunderstood your comment, please 
> let us know if that is the case.

Yes, the problems _may_ arise because you create afaict:
skb->end_seq > next_skb->seq situations which is something that certainly 
needs an audit over every single seqno operation to see that they don't 
implicitly assume otherwise (ie., omit redundant compares)! There are 
certainly places I know of already which will break... I'm afraid 
that using the approach you've select you'll end up having very many 
places needing some extra tweaking, that's why I suggested the alternative 
approach to just construct the redundant things on-the-fly while keeping 
the write queue as is.

> >> + if(TCP_SKB_CB(skb)->seq <= (TCP_SKB_CB(prev_skb)->end_seq - ua_data)){
> >
> > So ua_data must be prev_skb->len or this fails? Why ua_data needs such
> > complex setup above?
> >
> 
> >
> > Does this thing of youes depend on skb being not cloned?
> >
> 
> We will look into making the calculation ua_data easier and also the 
> cloning requirement.

> The check is there to avoid duplicate data in the case when a previous 
> packet has been bundled with later ones. 

Ah, this is the already bundled check... Then it would be simpler to do 
just: if (before(TCP_SKB_CB(skb)->seq, TCP_SKB_CB(prev_skb)->end_seq)), 
wouldn't it?

> However, when we think about it, this might not be neccessary since 
> bundling on retransmission is not allowed to bundle with packets that 
> are yet to be sent. Thank you for pointing this out.

I guess you must still have some way to protect against duplication on 
in tcp_trans_merge_prev() on successive send calls.

> >> +
> >> + if(skb_shinfo(skb)->frag_list || skb_shinfo(skb)->frag_list){
> >
> > If it wasn't cloned, why you do this check?
> 
> Good question, oversight by us, thank you for pointing it out.

Funny, it seems to be even buggy for the original purpose (if that ever 
was valid) as it is not (x || y) but (x || x) :-D.

> > I suppose this function was effectively:
> >
> > {
> > tcp_write_queue_walk_safe(...) {
> > ...checks...
> > if (tcp_trim_head(...))
> > break;
> > tcp_collapse_retrans(...);
> > }
> > }
> 
> Correct, except we dont collapse but bundle, will be modified and 
> simplified in the next version of the patch.  

Ah, I misunderstood this part, so my next comment is not valid:

> > It's sort of counter-intuitive that first you use redundancy but now in
> > here when the path _has shown problems_ you now remove the redundancy if
> > I understand you correctly? The logic is...?
> >
> 
> Even though the path has problems (as shown by the need for 
> retransmission), we still bundle as many packets as possible. If you are 
> still not sure, please let us know what part of the code that is 
> confusing.

...see above.

Though there is not another question, why send them as small at all here 
but instead just combining two together and sending twice??? I somewhat 
can understand why including from the previous skb is necessary at the 
first time sending since the previous is already out but in here we don't
have such obstacle.

> > It seems very intrusive solution in general. I doubt you succeed in
> > pulling it off as is without breaking something. To me it seems rather
> > fragile approach to make write queue seqno backleaps you're proposing. It
> > also leads to troubles in the truesize as you have noticed. Why not just
> > building those redundancy containing segments at the write time in case
> > the stream is thin, then all other parts would not have to bother about
> > dealing these things? Number of sysctls should be minimized, if they're
> > to be added at all. Skb work functions should be separated from tcp layer
> > things.
> >
> > If you depend on non-changing sysctl value to select right branch, you're
> > asking for trouble as the userspave is allowed to change it during the
> > flow as well and even during the ack processing.
> >
> 
> As far as we understand this comment, you want us to do it on the 
> application layer instead? Do you mean as a middleware, 
> application-specific solution or something similar? Also, we believe 
> doing it on the application layer will lead to the same delays that we 
> try to prevent, since sent data will be delayed on the transport layer 
> in case of loss.

No but at the time we're supposed to actually send an skb to the lower 
layer and keeping the rest intact.


-- 
 i.
---696208474-767947407-1231772791=:1889--
