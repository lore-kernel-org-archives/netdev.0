From: Alex Sidorenko <alexandre.sidorenko@hp.com>
Subject: Re: SWS for rcvbuf < MTU
Date: Mon, 5 Mar 2007 11:52:27 -0500
Message-ID: <200703051152.27780.alexandre.sidorenko@hp.com>
References: <200703021521.58821.alexandre.sidorenko@hp.com> <20070302.133839.17868570.davem@davemloft.net> <45EA075C.5010406@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: John Heffner <jheffner@psc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:52217 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751602AbXCEQwT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2007 11:52:19 -0500
In-Reply-To: <45EA075C.5010406@psc.edu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On March 3, 2007 06:40:12 pm John Heffner wrote:
> David Miller wrote:
> > From: John Heffner <jheffner@psc.edu>
> > Date: Fri, 02 Mar 2007 16:16:39 -0500
> >
> >> Please don't apply the patch I sent.  I've been thinking about this a
> >> bit harder, and it may not fix this particular problem.  (Hard to say
> >> without knowing exactly what it is.)  As the comment above
> >> __tcp_select_window() states, we do not do full receive-side SWS
> >> avoidance because of header prediction.
> >>
> >> Alex, you're right I missed that special zero-window case.  I'm still
> >> not quite sure I'm completely happy with this patch.  I'd like to think
> >> about this a little bit harder...
> >
> > Ok
>
> Alright, I've thought about it a bit more, and I think the patch I sent
> should work.  Alex, any opinion?  Any way you can test this out?

Here are the values from live kernel (obtained with 'crash') when the host was 
in SWS state:

full_space=708		full_space/2=354
free_space=393
window=76

In this case the test from my original fix, (window < full_space/2),  
succeeds. But John's test

free_space > window + full_space/2
393          430

does not. So I suspect that the new fix will not always work. From tcpdump 
traces we can see that both hosts exchange with 76-byte packets for a long 
time. From customer's application log we see that it continues to read 
76-byte chunks per each read() call - even though more than that is available 
in the receive buffer. Technically it's OK for read() to return even after 
reading one byte, so if sk->receive_queue contains multiple 76-byte skbuffs 
we may return after processing just one skbuff (but we we don't understand 
the details of why this happens on customer's system).

Are there any particular reasons why you want to postpone window update until 
free_space becomes > window + full_space/2 and not as soon as 
free_space > full_space/2? As the only real-life occurance of SWS shows 
free_space oscillating slightly above full_space/2, I created the fix 
specifically to match this phenomena as seen on customer's host. We reach the 
modified section only when (free_space > full_space/2) so it should be OK to 
update the window at this point if mss==full_space. 

So yes, we can test John's fix on customer's host but I doubt it will work for 
the reasons mentioned above, in brief:

'window = free_space' instead of 'window=full_space/2' is OK,
but the test 'free_space > window + full_space/2' is not for the specific 
pattern customer sees on his hosts.

Thanks,
Alex


-- 
------------------------------------------------------------------
Alexandre Sidorenko             email: alexs@hplinux.canada.hp.com
Global Solutions Engineering:   Unix Networking
Hewlett-Packard (Canada)
------------------------------------------------------------------
