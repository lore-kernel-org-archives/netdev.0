From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: Re: [PATCH] iwl4965: Enable checking of format strings
Date: Fri, 13 Feb 2015 11:39:40 +0100
Message-ID: <87y4o2xfgz.fsf@rasmusvillemoes.dk>
References: <1423695069-23436-1-git-send-email-linux@rasmusvillemoes.dk>
	<60178C37-F104-430E-92EB-B6DDFAEB2F99@intel.com>
	<87vbj7zb0e.fsf@rasmusvillemoes.dk> <54DDAE03.4000502@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Rustad\, Mark D" <mark.d.rustad@intel.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	"linux-wireless\@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Mark Rustad <mrustad@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54DDAE03.4000502@gmail.com> (Mark Rustad's message of "Thu, 12
	Feb 2015 23:55:47 -0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 13 2015, Mark Rustad <mrustad@gmail.com> wrote:

> On 2/12/15 2:20 AM, Rasmus Villemoes wrote:
>> Rather weak arguments, but I have three of them :-)
>
> Yes, weak. All three.
>
>> (1) If I'm reading some code and spot a non-constant format
>> argument, I sometimes track back to see how e.g. fmt_value is
>> defined. If I then see it's a macro, I immediately think "ok, the
>> compiler is doing type-checking". If it is a const char[], I have
>> to remember that gcc also does it in that case (as opposed to for
>> example const char*const).
>
> GCC should check in both cases. The case you are replacing was not
> const char * const, but only const char *. Still, the compiler really
> should check either form, even though theoretically the pointer in the
> latter case could be changed, but the initial const value should be a
> good indication of what the parameters are expected to be. No real
> reason for the compiler not to check it.

I agree with all of that - just wanted to point out what gcc currently
does and doesn't, and changing to const char[] would indeed enable
checking.

>> (2) The names of these variables themselves may end up wasting a
>> few bytes in the image.
>
> Maybe in a debug image, but they should be stripped from any normal
> image. Really not a factor.

Sure, that was by far the weakest, and let's ignore that.

>> (3) gcc/the linker doesn't merge identical const char[] arrays
>> across translation units. It also doesn't consider their tails for
>> merging with string literals. So although these specific strings
>> are unlikely to appear elsewhere, a string such as "%10u\n" or
>> "max\n" couldn't be merged with one of the above.
>
> I haven't checked, but there is no theoretical reason that const char
> [] items could not be merged exactly as the literals are. Considering
> the boundaries the compiler guys push on optimization, doing such
> merging would be tame by comparison (speculative stores make me crazy).

Well, probably the linker is allowed to overlap "anonymous" objects
(string literals) with whatever const char[] (or indeed any const)
object it finds containing the appropriate byte sequence. But I think
language lawyers would insist that for

const char foo[] = "a string";
const char bar[] = "a string";

foo and bar have different addresses, whether they are defined in the
same or different TUs. One could then argue that if their address is
never taken explicitly it should be ok, but since passing foo to a printf
function effectively makes the address of foo escape the TU (even though
one is formally passing pointer to first element), I can certainly see
why compiler people would be reluctant to do merging of such objects.

Rasmus
