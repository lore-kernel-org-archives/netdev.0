From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: [PATCH 0/3] virtio/vringh: kill off ACCESS_ONCE()
Date: Fri, 25 Nov 2016 19:46:28 +0100
Message-ID: <f637aad6-284f-6d3f-0eed-e108bbfa08a7@de.ibm.com>
References: <20161125112203.GA26611@leverpostej>
	<32dfca07-59f3-b75a-3154-cf6b6c8538f0@de.ibm.com>
	<20161125122356.GB26611@leverpostej>
	<20161125124044.GN3092@twins.programming.kicks-ass.net>
	<20161125124404.GI3174@twins.programming.kicks-ass.net>
	<20161125145512.GA4014@Boquns-MacBook-Pro.local>
	<CACT4Y+ZpzFhmSqOG+dG7QHSNObWatLOjPjNK2BznnRLeRQpF8A@mail.gmail.com>
	<20161125161004.GA30181@leverpostej>
	<20161125161709.GQ3092@twins.programming.kicks-ass.net>
	<d7f3740b-e343-68fc-4996-f712dd8c07f3@de.ibm.com>
	<20161125172624.GA30811@leverpostej>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Davidlohr Bueso <dave@stgolabs.net>, KVM list <kvm@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>, netdev <netdev@vger.kernel.org>,
	Boqun Feng <boqun.feng@gmail.com>, dbueso@suse.de,
	LKML <linux-kernel@vger.kernel.org>,
	virtualization@lists.linux-foundation.org,
	Paul McKenney <paulmck@linux.vnet.ibm.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Dmitry Vyukov <dvyukov@google.com>
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20161125172624.GA30811@leverpostej>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 11/25/2016 06:28 PM, Mark Rutland wrote:
> On Fri, Nov 25, 2016 at 05:49:45PM +0100, Christian Borntraeger wrote:
>> On 11/25/2016 05:17 PM, Peter Zijlstra wrote:
>>> On Fri, Nov 25, 2016 at 04:10:04PM +0000, Mark Rutland wrote:
>>>> On Fri, Nov 25, 2016 at 04:21:39PM +0100, Dmitry Vyukov wrote:
>>>
>>>>> What are use cases for such primitive that won't be OK with "read once
>>>>> _and_ atomically"?
>>>>
>>>> I have none to hand.
>>>
>>> Whatever triggers the __builtin_memcpy() paths, and even the size==8
>>> paths on 32bit.
>>>
>>> You could put a WARN in there to easily find them.
>>
>> There were several cases that I found during writing the *ONCE stuff.
>> For example there are some 32bit ppc variants with 64bit PTEs. Some for
>> others (I think sparc).
> 
> We have similar on 32-bit ARM w/ LPAE. LPAE implies that a naturally
> aligned 64-bit access is single-copy atomic, which is what makes that
> ok.
> 
>> And the mm/ code is perfectly fine with these PTE accesses being done
>> NOT atomic.
> 
> That strikes me as surprising. Is there some mutual exclusion that
> prevents writes from occuring wherever a READ_ONCE() happens to a PTE?

See for example mm/memory.c handle_pte_fault.

---snip----

                /*
                 * some architectures can have larger ptes than wordsize,
                 * e.g.ppc44x-defconfig has CONFIG_PTE_64BIT=y and
                 * CONFIG_32BIT=y, so READ_ONCE or ACCESS_ONCE cannot guarantee
                 * atomic accesses.  The code below just needs a consistent
                 * view for the ifs and we later double check anyway with the
                 * ptl lock held. So here a barrier will do.
                 */
---snip---

The trick is that the code only does a specific check, but all other accesses are under
the pte lock.
