From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: Re: [PATCH] iwl4965: Enable checking of format strings
Date: Thu, 12 Feb 2015 11:20:49 +0100
Message-ID: <87vbj7zb0e.fsf@rasmusvillemoes.dk>
References: <1423695069-23436-1-git-send-email-linux@rasmusvillemoes.dk>
	<60178C37-F104-430E-92EB-B6DDFAEB2F99@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Stanislaw Gruszka <sgruszka@redhat.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	"linux-wireless\@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Rustad\, Mark D" <mark.d.rustad@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <60178C37-F104-430E-92EB-B6DDFAEB2F99@intel.com> (Mark
	D. Rustad's message of "Thu, 12 Feb 2015 00:41:39 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 12 2015, "Rustad, Mark D" <mark.d.rustad@intel.com> wrote:

> On Feb 11, 2015, at 2:51 PM, Rasmus Villemoes <linux@rasmusvillemoes.dk> wrote:
>
>> Since these fmt_* variables are just const char*, and not const
>> char[], gcc (and smatch) doesn't to type checking of the arguments to
>> the printf functions. Since the linker knows perfectly well to merge
>> identical string constants, there's no point in having three static
>> pointers waste memory and give an extra level of indirection.
>> 
>> This removes over 100 "non-constant format argument" warnings from
>> smatch, accounting for about 20% of all such warnings in an
>> allmodconfig.
>> 
>> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
>> ---
>> drivers/net/wireless/iwlegacy/4965-debug.c | 7 +++----
>> 1 file changed, 3 insertions(+), 4 deletions(-)
>> 
>> diff --git a/drivers/net/wireless/iwlegacy/4965-debug.c b/drivers/net/wireless/iwlegacy/4965-debug.c
>> index e0597bfdddb8..18855325cc1c 100644
>> --- a/drivers/net/wireless/iwlegacy/4965-debug.c
>> +++ b/drivers/net/wireless/iwlegacy/4965-debug.c
>> @@ -28,10 +28,9 @@
>> #include "common.h"
>> #include "4965.h"
>> 
>> -static const char *fmt_value = "  %-30s %10u\n";
>> -static const char *fmt_table = "  %-30s %10u  %10u  %10u  %10u\n";
>> -static const char *fmt_header =
>> -    "%-32s    current  cumulative       delta         max\n";
>
> Why not change these to:
> static const char fmt_value[] = "  %-30s %10u\n";
> static const char fmt_table[] = "  %-30s %10u  %10u  %10u  %10u\n";
> static const char fmt_header[] =
>     "%-32s    current  cumulative       delta         max\n";
>
> I think that is better than the macros and avoids the extra pointers that I agree are useless.

Rather weak arguments, but I have three of them :-)

(1) If I'm reading some code and spot a non-constant format argument, I
sometimes track back to see how e.g. fmt_value is defined. If I then see
it's a macro, I immediately think "ok, the compiler is doing
type-checking". If it is a const char[], I have to remember that gcc
also does it in that case (as opposed to for example const char*const).

(2) The names of these variables themselves may end up wasting a few
bytes in the image.

(3) gcc/the linker doesn't merge identical const char[] arrays across
translation units. It also doesn't consider their tails for merging with
string literals. So although these specific strings are unlikely to
appear elsewhere, a string such as "%10u\n" or "max\n" couldn't be
merged with one of the above.

Rasmus
