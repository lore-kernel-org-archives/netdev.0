From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: [PATCH 2/2] netfilter: xt_condition: change the value from
 boolean to u32
Date: Fri, 06 Aug 2010 11:00:06 +0300
Message-ID: <1281081606.1586.28.camel@powerslave>
References: <1281019269-30985-1-git-send-email-luciano.coelho@nokia.com>
	 <1281019269-30985-3-git-send-email-luciano.coelho@nokia.com>
	 <alpine.LSU.2.01.1008051705320.1104@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"sameo@linux.intel.com" <sameo@linux.intel.com>
To: ext Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1008051705320.1104@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-08-05 at 17:12 +0200, ext Jan Engelhardt wrote:
> On Thursday 2010-08-05 16:41, luciano.coelho@nokia.com wrote:
> 
> > struct xt_condition_mtinfo {
> >-	char name[31];
> >+	char name[27];
> > 	__u8 invert;
> >+	__u32 value;
> 
> Please also bump the .revision field to 2 with this patch so that
> testing can always proceed without an ABI clash.
> (rev 2 would then remain over the course of the remaining patches 
> you submit.)
> (rev 0 = ipt_condition/pom-ng; rev 1 = xt_condition from Xt-a)

Oh, did I forget that? I thought I had bumped it up in my previous patch
after your comment, but apparently I didn't.  I'll fix it.


> >+	char buf[14];
> 
> 	char buf[sizeof("4294967296")];
> 
> seems more intuitive :-)

I'm using base 0 in the strtoull call, so I need at least 14 chars to
accommodate octals.  In octal MAX_UINT takes 11 digits, plus the leading
0 that marks it as an octal, plus the optional + sign (not sure if this
one makes sense, though), plus the null-terminator (or actually the \n
when writing to procfs) leads to 14.  But I'm not sure whether:

char buf[sizeof("+037777777777")]; 

Would be very intuitive? Surely I don't like the magic number, so I
should probably change it anyway.

> >+	unsigned long long value;
> >+
> >+	if (length == 0)
> >+		return 0;
> >+
> >+	if (length > sizeof(buf))
> >+		return -EINVAL;
> >+
> >+	if (copy_from_user(buf, input, length) != 0)
> >+		return -EFAULT;
> >+
> >+	buf[length - 1] = '\0';
> >+
> >+	if (strict_strtoull(buf, 0, &value) != 0)
> >+		return -EINVAL;
> >+
> >+	if (value > (u32) value)
> >+		return -EINVAL;
> 
> Is it possible to use just strict_strtoul?

Not easily.  I found that there is a bug in strtoul (and strtoull for
that matter) that causes the long to overflow if there are valid digits
after the maximum possible digits for the base.  For example if you try
to strtoul 0xfffffffff (with 9 f's) the strtoul will overflow and come
up with a bogus result.  I can't easily truncate the string to avoid
this problem, because with decimal or octal, the same valid value would
take more spaces.  I could do some magic here, checking whether it's a
hex, dec or oct and truncate appropriately, but that would be very ugly.

So the simplest way I came up with was to use strtoull and return
-EINVAL if the value exceeds 32 bits. ;)


> >-	return var->enabled ^ info->invert;
> >+	return (var->value == info->value) ^ info->invert;
> 
> Since the condition value (cdmark) was thought of an nfmark-style thing, 
> would it perhaps make sense to model it after it
> 
> 	return (var->value & ~info->mask) ^ info->value;
> 
> Other opinions?

I think it's nicer to have it as a normal equals here for now and then
extend the match with more operations.  We can later add, for example,
an --and option to the condition match in order to do other kinds of
binary operations.  It would be more flexible this way because we could
use several different types of comparisons, wouldn't it? And in the
target we could have several different types of operations.


-- 
Cheers,
Luca.

