From: Alexei Starovoitov via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [RFC PATCH net-next 3/5] bpf/verifier: feed
 pointer-to-unknown-scalar casts into scalar ALU path
Date: Thu, 8 Jun 2017 14:17:17 -0700
Message-ID: <20170608211716.ddtyqzo4ka23wf6f@ast-mbp.dhcp.thefacebook.com>
References: <92db9689-af6a-e172-ba57-195e588f9cc0@solarflare.com>
	<47ecf6ca-ae89-7fc3-3cd5-a47009b6ede9@solarflare.com>
	<20170608023540.5ecmmobhl2rtgrg5@ast-mbp>
	<2363ab5f-c344-900b-78ee-41e2eb0dd40f@solarflare.com>
	<20170608165004.n5jc33pocxlytuvf@ast-mbp.dhcp.thefacebook.com>
	<3cca425f-5794-dddd-18a8-af5e36bb3597@solarflare.com>
	<20170608184108.52tlp5apo44jte2t@ast-mbp.dhcp.thefacebook.com>
	<05371ef3-f10a-21b0-def0-1cbdfe458171@solarflare.com>
Reply-To: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <05371ef3-f10a-21b0-def0-1cbdfe458171-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 08, 2017 at 08:07:53PM +0100, Edward Cree wrote:
> On 08/06/17 19:41, Alexei Starovoitov wrote:
> > On Thu, Jun 08, 2017 at 06:12:39PM +0100, Edward Cree wrote:
> >> On 08/06/17 17:50, Alexei Starovoitov wrote:
> >>> On Thu, Jun 08, 2017 at 04:25:39PM +0100, Edward Cree wrote:
> >>>> On 08/06/17 03:35, Alexei Starovoitov wrote:
> >>>>> such large back and forth move doesn't help reviewing.
> >>>>> may be just merge it into previous patch?
> >>>>> Or keep that function in the right place in patch 2 already?
> >>>> I think 'diff' got a bit confused, and maybe with different options I could
> >>>>  have got it to produce something more readable.  But I think I will just
> >>>>  merge this into patch 2; it's only separate because it started out as an
> >>>>  experiment.
> >>> after sleeping on it I'm not sure we should be allowing such pointer
> >>> arithmetic. In normal C code people do fancy tricks with lower 3 bits
> >>> of the pointer, but in bpf code I cannot see such use case.
> >>> What kind of realistic code will be doing ptr & 0x40 ?
> >> Well, I didn't support it because I saw a use case.  I supported it because
> >>  it seemed easy to do and the code came out reasonably elegant-looking.
> >> Since this is guarded by env->allow_ptr_leaks, I can't see any reason _not_
> >>  to let people try fancy tricks with the low bits of pointers.
> >> I agree ptr & 0x40 is a crazy thing with no imaginable use case, but...
> >> "Unix was not designed to stop its users from doing stupid things, as that
> >>  would also stop them from doing clever things." ;-)
> > well, I agree with the philosophy :) but I also see few reasons not to allow it:
> > 1. it immediately becomes uapi and if later we find out that it's preventing us
> > to do something we actually really need we'll be stuck looking for workaround
> What could it prevent us from doing, though?  It's basically equivalent to giving
>  BPF an opcode that casts a pointer to a u64, which of course is only allowed if
>  allow_ptr_leaks is true.  And since we don't feed any knowledge about the pointer
>  into the verifier, it's just like any other way of filling a register with
>  arbitrary, unknown bits.
> I can fully appreciate why you're being cautious, what with uapi and all.  But I
>  don't think there's any actual problem here.  Open to being convinced, though.

The leaking is not a concern. It's if we started accepting a certain
class of programs we need to keep accepting them in the future.
Another reason is 'ptr & mask' could have been simply a bug and rejecting it
suppose to help users find issues sooner...
but I don't have a strong opinion here.

> > 2. it's the same pruning concern. probably doesn't fully apply here, but
> > the reason we don't track 'if (reg == 1) ...'
> Don't we though?
> http://elixir.free-electrons.com/linux/v4.12-rc4/source/kernel/bpf/verifier.c#L2127
> > is if we mark that
> > register as known const_imm in the true branch, it will screw up
> > pruning quite badly. It's trivial to track and may seem useful,
> > but hurts instead.
> (Thinking out loud...)
> 
> What would be really nice is a way to propagate limits backwards as well as
>  forwards, so that the verifier can say "when I tested this branch, I used
>  this part of the state, I read four bytes past this pointer".  Then when it
>  wants to prune, it can say "well, the state this time isn't as strong, but
>  it still satisfies everything I actually used".
> But that sounds like it would be very hard indeed to do.

that's more or less what i'm trying to do. liveness info per basic block
will trim the state.

> Maybe with the basic-block DAG stuff David's been talking about, we could
>  find all the paths that reach a block, and take the union of their states,
>  and then run through the block feeding it that combined state.  But that
>  could reject code that relies on correlation of the state (i.e. if r1 != 0
>  then r2 is valid ptr I can access, etc) so would still need the 'walk with
>  each individual state' as a fallback.  Though at least you'd have all the
>  states at once so you could find out which ones were subsumed, instead of
>  hoping you get to them in the right order.

I think it's important to optimize verification speed for good programs.
If bad program takes slightly longer, not a big deal. Right now we have
global lock which needs to go away, but that's a minor fix.
In that sense I see that combining the state can help find bad programs
sooner, but I don't see it's helping good programs.
Also we already have programs like:
if (...) {
  var1 = ptr
  var2 = size
} else {
  var1 = different ptr
  var2 = different size
}
call_helper(...var1, var2)
So the state needs to be considered together. Cannot just mix and match.
Initially I was thinking to build Use/Def chains for all operands
of loads, stores and calls and follow them from Use spot to all Defs
recursively to determine validity, but above use case breaks that.
