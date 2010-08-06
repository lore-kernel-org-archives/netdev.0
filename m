From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: [PATCH 2/2] netfilter: xt_condition: change the value from
 boolean to u32
Date: Fri, 06 Aug 2010 13:34:32 +0300
Message-ID: <1281090872.32491.2.camel@chilepepper>
References: <1281019269-30985-1-git-send-email-luciano.coelho@nokia.com>
	 <1281019269-30985-3-git-send-email-luciano.coelho@nokia.com>
	 <alpine.LSU.2.01.1008051705320.1104@obet.zrqbmnf.qr>
	 <1281081606.1586.28.camel@powerslave>
	 <alpine.LSU.2.01.1008061044270.8895@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"sameo@linux.intel.com" <sameo@linux.intel.com>
To: ext Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1008061044270.8895@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2010-08-06 at 10:52 +0200, ext Jan Engelhardt wrote:
> On Friday 2010-08-06 10:00, Luciano Coelho wrote:
> >> >+	buf[length - 1] = '\0';
> >> >+
> >> >+	if (strict_strtoull(buf, 0, &value) != 0)
> >> >+		return -EINVAL;
> >> >+
> >> >+	if (value > (u32) value)
> >> >+		return -EINVAL;
> >> 
> >> Is it possible to use just strict_strtoul?
> >
> >Not easily.  I found that there is a bug in strtoul (and strtoull for
> >that matter) that causes the long to overflow if there are valid digits
> >after the maximum possible digits for the base.  For example if you try
> >to strtoul 0xfffffffff (with 9 f's) the strtoul will overflow and come
> >up with a bogus result.
> 
> I see. Strange that no one has adressed this yet - I mean, writing
> a just-too-large value into a procfs/sysfs file and thus effectively
> causing a bogus value to be actually written isn't quite so thrilling
> as things go haywire.

Yes, I was really surprised to see this happening when I was testing the
limits.  And I was even more surprised when I checked the strtoull code
and saw that it is broken.


> >I can't easily truncate the string to avoid
> >this problem, because with decimal or octal, the same valid value would
> >take more spaces.  I could do some magic here, checking whether it's a
> >hex, dec or oct and truncate appropriately, but that would be very ugly.
> >
> >So the simplest way I came up with was to use strtoull and return
> >-EINVAL if the value exceeds 32 bits. ;)
> 
> If I read strtoul(3) right, ERANGE is used for "out of range".

Yes, libc's strtoul returns ERANGE in that case.  strict_strtoul() in
the kernel code doesn't.  I'll change my code to return -ERANGE here
too, for consistency.


> >> Since the condition value (cdmark) was thought of an nfmark-style thing, 
> >> would it perhaps make sense to model it after it
> >> 
> >> 	return (var->value & ~info->mask) ^ info->value;
> >> 
> >> Other opinions?
> >
> >I think it's nicer to have it as a normal equals here for now and then
> >extend the match with more operations.  We can later add, for example,
> >an --and option to the condition match in order to do other kinds of
> >binary operations.  It would be more flexible this way because we could
> >use several different types of comparisons, wouldn't it? And in the
> >target we could have several different types of operations.
> 
> Indeed.


-- 
Cheers,
Luca.

