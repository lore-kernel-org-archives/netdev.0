From: Rasmus Villemoes <linux-qQsb+v5E8BnlAoU/VqSP6n9LOBIZ5rWg@public.gmane.org>
Subject: Re: [PATCH v2 3/3] lib/string_helpers.c: Change semantics of string_escape_mem
Date: Sat, 31 Jan 2015 00:39:22 +0100
Message-ID: <87pp9vhm8l.fsf@rasmusvillemoes.dk>
References: <1422451543-12401-1-git-send-email-linux@rasmusvillemoes.dk>
	<1422525801-26560-1-git-send-email-linux@rasmusvillemoes.dk>
	<1422525801-26560-4-git-send-email-linux@rasmusvillemoes.dk>
	<1422538178.31903.325.camel@linux.intel.com>
	<87oaphbqym.fsf@rasmusvillemoes.dk>
	<1422613655.31903.351.camel@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Andy Shevchenko <andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1422613655.31903.351.camel-VuQAYsv1563Yd54FQh9/CA@public.gmane.org> (Andy Shevchenko's
	message of "Fri, 30 Jan 2015 12:27:35 +0200")
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 30 2015, Andy Shevchenko <andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org> wrote:

> On Thu, 2015-01-29 at 15:29 +0100, Rasmus Villemoes wrote:
>> On Thu, Jan 29 2015, Andy Shevchenko <andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org> wrote:
>> 
>> >>   *
>> >>   * Return:
>> >> - * The amount of the characters processed to the destination buffer, or
>> >> - * %-ENOMEM if the size of buffer is not enough to put an escaped character is
>> >> - * returned.
>> >> - *
>> >> - * Even in the case of error @dst pointer will be updated to point to the byte
>> >> - * after the last processed character.
>> >> + * The total size of the escaped output that would be generated for
>> >> + * the given input and flags. To check whether the output was
>> >> + * truncated, compare the return value to osz. There is room left in
>> >> + * dst for a '\0' terminator if and only if ret < osz.
>> >>   */
>> >> -int string_escape_mem(const char *src, size_t isz, char **dst, size_t osz,
>> >> -		      unsigned int flags, const char *esc)
>> >> +size_t string_escape_mem(const char *src, size_t isz, char *dst, size_t osz,
>> >> +			 unsigned int flags, const char *esc)
>> >
>> > I prefer to leave the prototype the same. int for return is okay. dst
>> > should be updated accordingly.
>> 
>> Please explain exactly what you think the return value should be, and
>> what *dst should be set to.
>
> Return value like you proposed, *dst is incremented by it.

The more I think about it, the less I like having dst being char**.

(1) It is unlike most other functions taking buffer+size arguments.
(2) It is inconvenient. Callers doing

  char escaped[SOME_SIZE];

or

  char *escaped = kmalloc(likely_big_enough);

can't just pass &escaped; they would need to use an extra dummy variable.

(3) With the return value telling the size of the would-be generated
output, it is redundant.

In fact, I dislike it so much that I'm not going to sign off on a patch
where dst is still char**.

>> > Could it be a part of nomem test still?
>> 
>> What nomem test? string_escape_mem with snprintf-like semantics cannot
>> return an error; that has to be checked by the caller. 
>
> Make this code a separate test, which actually still nomem, since you
> have not enough memory in the destination buffer. What the problem to
> check for proper return value and the last couple of characters written
> to the destination buffer?

Sure, it could go into a separate helper. Anyway, the semantics of
string_escape_mem needs to be decided before it makes sense to update
the tests.

> When your series will be ready (and actually I recommend to push first
> patch apart from the rest since it's not related) 

I agree on that part. Andrew, could you take 1/3
(http://thread.gmane.org/gmane.linux.kernel/1876841/focus=348404), and
then we'll see when the %pE case gets sorted out.

Rasmus
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
