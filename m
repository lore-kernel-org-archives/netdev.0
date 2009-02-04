From: Patrick Ohly <patrick.ohly@intel.com>
Subject: Re: hardware time stamping with optional structs in data area
Date: Wed, 04 Feb 2009 14:02:31 +0100
Message-ID: <1233752551.15940.159.camel@ecld0pohly>
References: <1233069837.24438.54.camel@pohly-MOBL>
	 <20090128090821.GA15770@gondor.apana.org.au>
	 <20090201.001415.201448053.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-api@vger.kernel.org" <linux-api@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:8089 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759514AbZBDNCf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Feb 2009 08:02:35 -0500
In-Reply-To: <20090201.001415.201448053.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-02-01 at 08:14 +0000, David Miller wrote: 
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Wed, 28 Jan 2009 20:08:21 +1100
> > How big are the time stamps? If they're not that big, why don't
> > we put it into the shinfo structure itself? For the common case,
> > we have plenty of space due to kmalloc padding anyway.
> 
> I did some thinking about this, and for the time being
> I think we should stick all of these new pieces of
> timestamp information in the skb shared info structure
> and unconditionally.

Agreed. I have changed the code accordingly. As expected it became
considerably simpler.

I also fixed the 32 bit on 64 bit kernel issue with the SIOCSHWTSTAMP
ioctl.

> So you can therefore get rid of all of this conditional sizing and
> other complexity, which is distracting from what the patch is actually
> doing.  As a result I expect patch #2 to shrink to basically nothing :)

I kept the struct/union definition around because in some places the
information needs to be stored detached from skb_shared_info. I also
kept the accessor functions because that way the code using the
information is better separated from how the information is stored.

The only change in these accessors is that they are now guaranteed to
never return NULL; code using them was simplified accordingly.

> Other than that, I went over the patches again, and here is some other
> feedback:
> 
> 1) Please kill the SO_TIMESTAMPING/SCM_TIMESTAMPING/SIOCHWTSTAMP
>    fallback definition in linux/net_tstamp.h
> 
>    We don't do things like that.  The SIOCHWTSTAMP one was using
>    __kernel__ (lowercase) instead of __KERNEL__ so it wouldn't
>    work anyways :-)

Okay. I moved that into the timestamping.c example. Such a fallback is
needed in user space programs because the latest kernel's header files
might not be installed yet: net_tstamp.h is found, platform specific
asm-* files are not. Instead files from /usr/include are picked up.

> 2) Please fix up some coding style issues.  For example, when you have
>    a multiline conditional as you do in sock_recv_timestamp(), format
>    it like this:
> 
>         if (a ||
>             b ||
>             c)
> 
>    instead of the two tab thing you're doing on the lines after the
>    first one in the conditional.  There are many cases of this, so
>    please go over all of your patches and review for this.
> 
>    The sock_tx_timestamp() declaration has similar issues.  Make the
>    arguments on the subsequent lines start right after the openning
>    parenthesis on the first line.

I didn't find anything about this aspect of line continuation in the
CodingStyle, so I used the emacs configuration given there and relied on
it to do the formatting correctly. That's no excuse of course, just an
explanation. It looked wrong, but so does much of the other Linux kernel
code to my unaccustomed eyes ;-)

Does anyone have an improved version of the emacs macros or is this
something that has to be formatted manually? For now I'm fixing it
manually.

I hope I'm catching all of it; checkpatch.pl doesn't warn about it.

> Please don't use braces for a basic block composed of only one
>    line, it's just wasted space, for example:
> 
>         if (sock_flag(sk, SOCK_TIMESTAMPING_TX_HARDWARE)) {
>                 shtx->hardware = 1;
>         }

Right. I fixed some of those already, but missed that one.

I went through all patches and fixed all the checkstack.pl reports,
except for some warnings about long lines that I preferred not to split
(usually string constants).

> 4) Please get patches #9 and #11 on a fresh review on linux-kernel
>    with the timer maintainers CC:'d.  Once they ACK, get a figure on
>    how we can arrange the merge of these changes.
> 
>    Just like you I think we have to merge this in via the net tree
>    since the only user we have is this hwtstamp networking stuff.  So
>    please express that and try to get the timer folk's blessing on
>    that.

Okay.

> 5) Finally, try to put the driver patches at the end so that they
>    finish the patch series and the driver maintainer ACK'ing can
>    be handled seperately and won't hold up the infrastructure patches.

Okay. John Ronciak already expressed an interest in reviewing them. I'll
discuss with him and other Intel igb maintainers before posting the
patch series again.

> Otherwise this stuff looks good, please keep working on this stuff!

Glad to hear there. I'll do my best to finish this. It's quite an
experience ;-)

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.

