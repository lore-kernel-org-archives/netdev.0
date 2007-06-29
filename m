From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: RFR: New e1000 driver (e1000new),
 was: Re: e1000: backport ich9 support from 7.5.5 ?
Date: Fri, 29 Jun 2007 16:38:31 -0700
Message-ID: <468597F7.2050700@linux.intel.com>
References: <1183138159.17243.16.camel@blaa>	<20070629175006.GB3917@falooley.org>	<468571C6.3090305@garzik.org>	<46857C08.4030303@intel.com>
	<20070629150350.414553d4.akpm@linux-foundation.org>
	<4685838D.9080108@garzik.org> <468594B7.6070309@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark McLoughlin <markmc@redhat.com>,
	Jeff Garzik <jeff@garzik.org>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, "Ronciak, John" <john.ronciak@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jason Lunz <lunz@reflexsecurity.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <468594B7.6070309@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Jeff Garzik wrote:
>> Andrew Morton wrote:
>>> On Fri, 29 Jun 2007 14:39:20 -0700
>>> "Kok, Auke" <auke-jan.h.kok@intel.com> wrote:
>>>
>>>> That's why we want to introduce a second e1000 driver (named 
>>>> differently, pick any name) that contains the new code base, 
>>>> side-by-side into the kernel with the current e1000.
>>> Sounds like a reasonable approach to me (it has plenty of 
>>> precedent).  But
>>> I forget what all the other issues were, so ignore me.
>>
>> Given past history with duplicate drivers and the problems that they 
>> cause -- I know, I've caused some of those problems :( -- I strongly 
>> recommend against when it can be avoided.
>>
>> Leaving e1000 with current hardware, and a new e1001 for newer 
>> hardware should be easier to manage for all involved, without the 
>> headaches that duplicate drivers cause.
>>

Jeff,

ok first you hate the old e1000 and now you don't want to get rid of it ;)

I appreciate the pain a temporary dual driver situation gives; it 
comes down to a few things that I can think of right now, if you see 
more please add to the list.

1) users who find a bug in the new one silently use the old one rather 
than reporting the bug; and only scream when the old one eventually 
goes away (see ALSA/OSS duplication)

2) users who enable both in KConfig may get a "random" one

3) distros really prefer only 1 driver per PCI ID for their 
infrastructure tools

4) there will be resistance against deleting the old one meaning it 
might not happen


While the pain won't be zero, I know there are some simple things that 
can be done to make it significantly less:

1) Make sure that the various feature-removal files and KConfig 
clearly mark the old one as "going away" early on, make the old one 
printk that it's the older driver and stick a hard date on it. This 
should at least ease [1] and [4] above

2) After a minimal amount of shake-out time (say one kernel release), 
make the old e1000 not export the PCI IDs in it's module, but make it 
a manual modprobe. This means people can still use the old one, but 
distro tools will pick the new one automatically
[and if there is any doubt about a specific PCI ID model temporarily, 
that one can be done the other way around]

3) Have a config option which does what you say; allow both drivers to 
be there but with non-overlapping PCI IDs; where exactly the new/old 
split is is up for discussion, and it can even move over time

4) Work with the distro maintainers to default their development 
snapshots as quickly as possible to the new driver so that it gets as 
much testing as possible quickly; yet at the same time for their 
security fixes and released updates they can use the 3) option

5) once there is some confidence in the new driver, put a patch into 
-mm that makes the old driver really hard to select in KConfig; this 
in preparation for removal later on (hey this worked for devfs ;)

6) put more or less a code freeze on the old driver; it should remain 
compiling but it's ok to be bug-to-bug compatible with what is there 
at the moment the new driver goes into the tree.


Personally I'm convinced this is a managable process with a reasonable 
assurance that the old driver really can go away after 2 kernel 
releases (as long as Auke and co are on top of bugreports about 
regressions, I don't see why not). What is needed of course is some 
level of strictness/determination to get rid of the old one after the 
reasonable time period.

if you have other concerns about temporarily having two drivers that 
are real showstoppers , please put them on the table; it might well be 
possible to find a reasonable way to solve/mitigate them.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
