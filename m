From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 0/3] virtio/vringh: kill off ACCESS_ONCE()
Date: Fri, 25 Nov 2016 09:52:50 -0800
Message-ID: <CA+55aFwpUxwdgKdbwfSW59VzPCJojNg7aqBdWio5MM6RJnG5Uw@mail.gmail.com>
References: <1479983114-17190-1-git-send-email-mark.rutland@arm.com>
	<20161124222357-mutt-send-email-mst@kernel.org>
	<20161125112203.GA26611@leverpostej>
	<32dfca07-59f3-b75a-3154-cf6b6c8538f0@de.ibm.com>
	<20161125122356.GB26611@leverpostej>
	<20161125124044.GN3092@twins.programming.kicks-ass.net>
	<20161125124404.GI3174@twins.programming.kicks-ass.net>
	<20161125145512.GA4014@Boquns-MacBook-Pro.local>
	<CACT4Y+ZpzFhmSqOG+dG7QHSNObWatLOjPjNK2BznnRLeRQpF8A@mail.gmail.com>
	<20161125161004.GA30181@leverpostej>
	<20161125161709.GQ3092@twins.programming.kicks-ass.net>
	<CACT4Y+YJUUjU_FCR1FOcF2DmkkcjiRFpnU7Q4=yzbgvKv0VhyQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, Davidlohr Bueso <dave@stgolabs.net>,
	KVM list <kvm@vger.kernel.org>, "Michael S. Tsirkin" <mst@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>, netdev <netdev@vger.kernel.org>,
	Boqun Feng <boqun.feng@gmail.com>, Davidlohr Bueso <dbueso@suse.de>,
	LKML <linux-kernel@vger.kernel.org>,
	virtualization <virtualization@lists.linux-foundation.org>,
	Paul McKenney <paulmck@linux.vnet.ibm.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <CACT4Y+YJUUjU_FCR1FOcF2DmkkcjiRFpnU7Q4=yzbgvKv0VhyQ@mail.gmail.com>
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

On Fri, Nov 25, 2016 at 9:28 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
On Fri, Nov 25, 2016 at 5:17 PM, Peter Zijlstra <peterz@infradead.org> wrote:
>>
>> IE, they are strictly stronger than {READ,WRITE}_ONCE().

No, they are strictly bullshit.

Stop this idiocy. We went through this once already.

> Uh, so, READ/WRITE_ONCE are non-atomic now. I missed that.

No.

READ/WRITE_ONCE() are atomic *WHEN*THAT*IS*POSSIBLE*. So for something
that fits in a register, it will read it in one atomic access. For
something that fits in a register and is _possible_ to write
atomically, it will do so.

But sometimes it's not going to be atomic. We do not for a moment try
to make multi-word accesses be atomic. Not even if you could try to
use some magic cmpxchg16b thing. It's not "atomic" in that sense: it
will be doing multiple accesses.

Similarly, if you try to write a 8- or 16-bit word on alpha with
WRITE_ONCE() or you try to do other things, you have what's coming to
you.

And they just force some "copy to stable storage" when it isn't (ie a
"memcpy()" is not necessarily a single access and might be done as
multiple overlapping reads, but the end result is stable).

So trying to make anything else out of them is f*cking stupid.

READ_ONCE() and friends do the right thing. Trying to limit them is
*wrong*, because the restrictions would simply make them less useful.
And trying to make up something new is pointless and stupid.

So leave this code alone. Don't add some stupid "SINGLE_LOAD()" crap.
That's just moronic. READ_ONCE() is that, and so much more.

               Linus
