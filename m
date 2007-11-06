From: Roel Kluin <12o3l@tiscali.nl>
Subject: Re: [BUG] in inet6_create
Date: Tue, 06 Nov 2007 18:31:37 +0100
Message-ID: <4730A4F9.8050701@tiscali.nl>
References: <472A3218.20708@tiscali.nl> <472A41AF.2030704@tiscali.nl> <472AEAB0.5090709@openvz.org> <472B638C.1030001@tiscali.nl> <47302255.7060708@openvz.org> <47308BEC.1040302@tiscali.nl> <473090FF.7000707@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out3.tiscali.nl ([195.241.79.178]:41523 "EHLO
	smtp-out3.tiscali.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753268AbXKFRbj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2007 12:31:39 -0500
In-Reply-To: <473090FF.7000707@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelyanov wrote:
> Roel Kluin wrote:
>> Pavel Emelyanov wrote:
>>> Roel Kluin wrote:
>>>> Pavel Emelyanov wrote:
>>>>> Roel Kluin wrote:
>>>>>> Roel Kluin wrote:
>>>>>>> I got this bug recently, I am not sure whether this is related to any previously 
>>>>>>> reported ones. It was a recently pulled git kernel. Also I have been hacking my
>>>>>>> kernel a bit lately, but I think that I haven't got any changes in the currently
>>>>>>> running kernel.
>>>>>>>
>>>>>>> FYI: my network card was not running (module not loaded, and I just started 
>>>>>>> thunderbird)
>>>>>>>
>>>>>>> More information needed?
>>>>> Yes, please.
>>>>>
>>>>> Can you send us the disasm (objdump -dr) of your ipv6 module. 
>>>>> More precisely - I need the disassembled inet6_create() function to
>>>>> figure out where exactly this thing happened.
>>>> I was very lucky to still be able to produce this: When the bug hit me, I had just
>>>> recompiled a new kernel, however, since I had previously git-pulled, (but not yet
>>>> compiled) the old module was not overwritten.
>>>>
>>>> to answer the question in your other mail - whether I hacked this kernel - I am not
>>>> 100% certain, I am certain, however that I did not touch IPv6 code, and my changes
>>>> to net code were very trivial oneliner changes that I have previously posted, and
>>>> were generally accepted as fixes.
>>>> --
>>>> 000002f0 <inet6_create>:
>>> Hm... The oops says that the buggy place is <inet6_create>+0x5f, that is
>>> (according to this dump) 0x2f0 + 0x5f = 0x34f, but:
>>>
>>> 1. there's no instruction at this address (there are 0x34e and 0x355)
>>> 2. the codeline (... 1c <8b> 00 0f 18 ...) is not present here
>>>
>>> There's something wrong with this oops...
>> hmmm, I see my mistake:
>> I _was_ already running the 2.6.24-rc1 kernel. It even says so in the BUG report
> 
> Brrr... I'm completely confused. What was the kernel that oops-ed?
> 2.6.24-rc, net-2.6.24-rc1 or net-2.6.24-rc1-with-your-patches?

It was a git kernel, pulled from linus' tree:
git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
The version number on the bug was 2.6.24-rc1. I posted here because the bug mentioned
inet6_create and ipv6, which is net code.
 
>> Since the module is already overwritten, does it still help to make the objdump?
>>
>> Ok, I'll check for the address... yes it exists 
> 
> Yup. My first guess was correct - the inetsw6 list is broken - there's
> some NULL pointer in it. Looking at the code I see that this list
> is accessed for modifications under the spinlock and that it is properly
> initialized in the ->init callback before any code gets the access to this
> list. No ideas why this can happen... :(
> 
>> Sorry for my mistake, the objdump for this module is below. note however that the
>> module has been overwritten previously after kernel compilation.
>>
>>> Is this reproducible? If yes, can you try the non-patched net-2.6 kernel.
>> I'll try to reproduce it. I'll confirm it when it happens again.
> 
> Yes, please.

Ok, I tried but it did not work.

My kernel is very non-modular (which is also called monolithic?) one of the few
things that still was a module is my network card. ipv6 was another.

You may want to skip the next part: a lengthy explanation of the situation during
the bug.

In the original situation I had tried to build a kernel: I was trying an adapted
version of the profile-likely-unlikely-macros.patch, but due to an error in my code
kernel compilation failed,
I was using a stupid script which did:

make O=$BUILDDIR;
sudo make O=$BUILDDIR modules_install install

Note that I probably didn't run make mrproper beforehand.

Building failed, but modules were removed and I should have recompiled without the
error. I forgot that, so after rebooting my modules didn't work. the kernel booted
because all necessary code is compiled in.

My network card didn't function, however. So I decided to recompile with my
network card compiled in.

Then I was doing some other stuff, got bored, pressed Thunderbird - it's an
automatism - and right at that moment I got the oops.

So to try to reproduce this I compiled a new kernel, without compiling and
installing the modules. It did not reoccur, however.

Roel
