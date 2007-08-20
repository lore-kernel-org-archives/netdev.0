From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Tue, 21 Aug 2007 00:04:17 +0200
Message-ID: <417ebba299a7ad3c4b7a31c4f860a814@kernel.crashing.org>
References: <20070815234021.GA28775@gondor.apana.org.au> <3694fb2e4ed1e4d9bf873c0d050c911e@kernel.crashing.org> <46C3B50E.7010702@yahoo.com.au> <194369f4c96ea0e24decf8f9197d5bad@kernel.crashing.org> <46C505B2.6030704@yahoo.com.au> <18117.4848.695269.72976@cargo.ozlabs.ibm.com> <46C516BA.60700@yahoo.com.au> <alpine.LFD.0.999.0708162045150.30176@woody.linux-foundation.org> <20070817235912.GA24314@linux.vnet.ibm.com> <20070818000913.GA25585@gondor.apana.org.au> <20070818010818.GQ8464@linux.vnet.ibm.com> <Pine.LNX.4.64.0708171817050.15427@schroedinger.engr.sgi.com> <46C997B1.1010800@redhat.com>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <clameter@sgi.com>,
	Paul Mackerras <paulus@samba.org>, heiko.carstens@de.ibm.com,
	horms@verge.net.au, linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, ak@suse.de,
	netdev@vger.kernel.org, cfriesen@nortel.com,
	akpm@linux-foundation.org, rpjday@mindspring.com,
	Nick Piggin <nickpiggin@yahoo.com.au>,
	linux-arch@vger.kernel.org, jesper.juhl@gmail.com,
	satyam@infradead.org, zlynx@acm.org, schwidefsky@de.ibm.com,
	Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	Linus Torvalds <torvalds@linux-foundation.org>,
	wensong@linux-vs.org, wjiang@resilience.com
To: Chris Snook <csnook@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761444AbXHTWIS@vger.kernel.org>
In-Reply-To: <46C997B1.1010800@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> Right. ROTFL... volatile actually breaks atomic_t instead of making 
>> it safe. x++ becomes a register load, increment and a register store. 
>> Without volatile we can increment the memory directly. It seems that 
>> volatile requires that the variable is loaded into a register first 
>> and then operated upon. Understandable when you think about volatile 
>> being used to access memory mapped I/O registers where a RMW 
>> operation could be problematic.
>
> So, if we want consistent behavior, we're pretty much screwed unless 
> we use inline assembler everywhere?

Nah, this whole argument is flawed -- "without volatile" we still
*cannot* "increment the memory directly".  On x86, you need a lock
prefix; on other archs, some other mechanism to make the memory
increment an *atomic* memory increment.

And no, RMW on MMIO isn't "problematic" at all, either.

An RMW op is a read op, a modify op, and a write op, all rolled
into one opcode.  But three actual operations.


The advantages of asm code for atomic_{read,set} are:
1) all the other atomic ops are implemented that way already;
2) you have full control over the asm insns selected, in particular,
    you can guarantee you *do* get an atomic op;
3) you don't need to use "volatile <data>" which generates
    not-all-that-good code on archs like x86, and we want to get rid
    of it anyway since it is problematic in many ways;
4) you don't need to use *(volatile <type>*)&<data>, which a) doesn't
    exist in C; b) isn't documented or supported in GCC; c) has a recent
    history of bugginess; d) _still uses volatile objects_; e) _still_
    is problematic in almost all those same ways as in 3);
5) you can mix atomic and non-atomic accesses to the atomic_t, which
    you cannot with the other alternatives.

The only disadvantage I know of is potentially slightly worse
instruction scheduling.  This is a generic asm() problem: GCC
cannot see what actual insns are inside the asm() block.


Segher
