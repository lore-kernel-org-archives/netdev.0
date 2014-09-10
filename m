From: "Alexander Y. Fomichev" <git.user@gmail.com>
Subject: Re: Macvlan WARNiNGS about duplicate sysfs filenames (Was [GIT] Networking)
Date: Wed, 10 Sep 2014 09:56:19 +0400
Message-ID: <CAChDUfS5G8j8Td2QaNqcFvPwaO9FMcv=Sjd1jnCfP=h5ccZyGg@mail.gmail.com>
References: <20140907.164109.1944849896872238507.davem@davemloft.net>
	<20140908212514.GA2348@awork2.anarazel.de>
	<CAHA+R7NCwhMaWX0Mhr7AqHH4x5RZ6TEEiJB7906yVzQouXD3Lg@mail.gmail.com>
	<20140909234806.GG24649@awork2.anarazel.de>
	<20140909235534.GH24649@awork2.anarazel.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Cong Wang <cwang@twopensource.com>,
	David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andres Freund <andres@anarazel.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:60922 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbaIJF4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 01:56:21 -0400
In-Reply-To: <20140909235534.GH24649@awork2.anarazel.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 10, 2014 at 3:55 AM, Andres Freund <andres@anarazel.de> wrote:
> On 2014-09-10 01:48:06 +0200, Andres Freund wrote:
>> On 2014-09-09 15:43:55 -0700, Cong Wang wrote:
>> > On Mon, Sep 8, 2014 at 2:25 PM, Andres Freund <andres@anarazel.de> wrote:
>> > > Hi,
>> > >
>> > > (don't have netdev archived, thus answering here, sorry)
>> > >
>> > > On 2014-09-07 16:41:09 -0700, David Miller wrote:
>> > >> Alexander Y. Fomichev (1):
>> > >>       net: prevent of emerging cross-namespace symlinks
>> > >
>> >
>> > Since you are quoting this change, are you saying it causes
>> > the following kernel warning?
>>
>> I thought it might be a likely candidate; but I'm not sure at all. I'll
>> verify it as soon as I can reboot the machine a couple of times (end of
>> week-ish).
>>
>> > > I'm seeing WARNINGs like:
>> > > [ 1005.269134] ------------[ cut here ]------------
>> > > [ 1005.269148] WARNING: CPU: 6 PID: 4213 at fs/sysfs/dir.c:31 sysfs_warn_dup+0x64/0x80()
>> > > [ 1005.269150] sysfs: cannot create duplicate filename '/devices/pci0000:00/0000:00:1c.4/0000:03:00.0/net/eth0/upper_mv-eth0'
>> >
>> >
>> > Is there a network device named upper_mv-eth0 existed in your system
>> > before you created macvlan?
>>
>> No, there wasn't any. Afaics, the sequence is:
>> 1) macvlan mv-eth0 is created in global namespace
>> 2) mv-eth0 is moved (by systemd-nsspawn) into a new network
>>    namespace. Leaving a dangling symlink in the host namespace
>> /devices/pci0000:00/0000:00:1c.4/0000:03:00.0/net/eth0/upper_mv-eth0 pointing toward
>> ../mv-eth0
>> which doesn't exist in the external namespace. The new namespace seems
>> to have broken 'lower_bond0' symlink as well
>>
>> This seems to be the case (and probably the actual root cause) in
>> slightly earlier kernels as well.
>> What changed seems to be that:
>> 3) macvlan mv-eth0 is destroyed in the namespace (potentially while
>>    tearing it down)
>> 4) Now there's a broken symlink that doesn't make sense in any namespace
>> 5) mv-eth0 can't be created anew
>>
>> It seems that 3-5 didn't happen that way on older kernels. The most
>> recent where it's not persistently broken is 3.16.0-rc7-00007 -
>> 31dab719f. The oldest where I know it's reproducible is
>> 3.17.0-rc4-andres-00135-g35af256.
>
> I've reproduced the problem on another machine where it's perfectly
> reproducible (except being about mv-bond0). After reverting only the
> aforementioned 4c75431ac352063 it works again.
> As I said above, I'm not sure whether 4c75431ac352063 is the actual
> culprit, but it certainly made the problem visible. How are these
> upper_$if/lower_$if supposed to behave when the macvlan and the
> underlying device are in differing namespaces?

supposed to be destroyed before moving device into new net_ns
and created just after but only if both lower/upper devices has the same netns.
whether i understood you correctly that you see lowar_/upper_ links
just after new
container is up?

> Greetings,
>
> Andres Freund



-- 
Best regards.
       Alexander Y. Fomichev <git.user@gmail.com>
