From: Michal Ostrowski <mostrows@watson.ibm.com>
Subject: Re: [PATCH, untested] Support for PPPOE on SMP
Date: 26 Jun 2003 07:37:16 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1056627436.27295.42.camel@brick.watson.ibm.com>
References: <20030626035824.D68B62C147@lists.samba.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, Paul MacKerras <paulus@samba.org>,
   netdev@oss.sgi.com, fcusack@samba.org, carlson@workingcode.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rusty Russell <rusty@rustcorp.com.au>
In-Reply-To: <20030626035824.D68B62C147@lists.samba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2003-06-25 at 23:57, Rusty Russell wrote:
> In message <20030625.143334.85380461.davem@redhat.com> you write:
> > 
> > Why don't you just queue the payload packets in a "resolution queue"
> > until the socket is created?  Just make the resolution queue packets
> > timeout using a value that will easily exceed any reasonable PPP
> > negotiation time.
> 
> Sure, that works in this case, where you know when you get the packet
> that it's out of order.  But I wanted to see how ugly it got to do it
> generally: a protocol where you can't tell until later that things
> were in the wrong order can't use this technique.  Paul tells me that
> multilink PPP assumes this (moral: don't do multilink PPPoE).
> 
> Anyway, my patch is fundamentally flawed: you can't do
> cpu_raise_softirq() on another CPU, it's racy (*bad* *bad* interface).
> 
> > All this ordered packet arrival shit is just beyond stupid.
> 
> I want to know how often this is happening (Michal?), because if
> protocols need ordering and can't tell, it becomes effectively a
> packet drop somewhere down in the protocol.  If it's 1 in a million,
> OK.  If it's 1 in a thousand, that's bad.
> 
> Frankly, I'm amazed anyone sees reordering in real life...



I have observed (very, very rarely) a situation where interrupt
sequences for two CPUs allowed this to happen (but not that it did
necessarily happen).  When these races do occur, it probably hits TCP
traffic which deals with it, otherwise any hiccups it causes are
probably lost in the noise.

For PPPoE (non multilink) the worst case scenario would appear to be a
packet drop with a retransmit delay imposed on or by higher-level
protocols.  That being said, I don't think PPPoE provides any
justification for any modifications to the core networking code to deal
with this.

Continuing on with PPPoE, I would like to get people's opinions on
whether or not mechanisms should be put in (as outlined in David's
suggestion above) to handle races between payload packets and socket
creation.   These races are, I think, quite rare and at worst may impose
a delay of a couple of seconds on session creation.  I'm not entirely
comfortable with the idea of saving incoming packets that I can't match
to existing sessions in case a matching session comes into existence in
the near future (DOS), especially if not handling this case is
non-fatal.  I'd like to get a consensus on this "policy" issue.

-- 
Michal Ostrowski <mostrows@watson.ibm.com>
