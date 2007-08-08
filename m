From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH] make atomic_t volatile on all architectures
Date: Wed, 08 Aug 2007 19:31:27 -0400
Message-ID: <46BA524F.2070803@redhat.com>
References: <20070808230733.GA17270@shell.boston.redhat.com> <9a8748490708081618p43cdcdfdn5de6f292247def5b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org,
	ak@suse.de, heiko.carstens@de.ibm.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org
To: Jesper Juhl <jesper.juhl@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54994 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755644AbXHHXcD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Aug 2007 19:32:03 -0400
In-Reply-To: <9a8748490708081618p43cdcdfdn5de6f292247def5b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesper Juhl wrote:
> On 09/08/2007, Chris Snook <csnook@redhat.com> wrote:
>> From: Chris Snook <csnook@redhat.com>
>>
>> Some architectures currently do not declare the contents of an atomic_t to be
>> volatile.  This causes confusion since atomic_read() might not actually read
>> anything if an optimizing compiler re-uses a value stored in a register, which
>> can break code that loops until something external changes the value of an
>> atomic_t.  Avoiding such bugs requires using barrier(), which causes re-loads
>> of all registers used in the loop, thus hurting performance instead of helping
>> it, particularly on architectures where it's unnecessary.  Since we generally
>> want to re-read the contents of an atomic variable on every access anyway,
>> let's standardize the behavior across all architectures and avoid the
>> performance and correctness problems of requiring the use of barrier() in
>> loops that expect atomic_t variables to change externally.  This is relevant
>> even on non-smp architectures, since drivers may use atomic operations in
>> interrupt handlers.
>>
>> Signed-off-by: Chris Snook <csnook@redhat.com>
>>
> 
> Hmm, I thought we were trying to move away from volatile since it is
> very weakly defined and towards explicit barriers and locks...
> Points to --> Documentation/volatile-considered-harmful.txt

This is a special case.  Usually, the use of volatile is just lazy.  In 
this case, it's probably necessary on at least some architectures, so we 
can't remove it everywhere unless we want to rewrite atomic.h completely 
in inline assembler for several architectures, and painstakingly verify 
all that work.  I would hope it's obvious that having consistent 
behavior on all architectures, or even at all compiler optimization 
levels within an architecture, can be agreed to be good.  Additionally, 
atomic_t variables are a rare exception, in that we pretty much always 
want to work with the latest value in RAM on every access.  Making this 
atomic will allow us to remove a bunch of barriers which do nothing but 
slow things down on most architectures.

I agree that the use of atomic_t in .c files is generally bad, but in 
certain special cases, hiding it inside defined data types may be worth 
the slight impurity, just as we sometimes tolerate lines longer than 80 
columns when "fixing" it makes things unreadable.

	-- Chris
