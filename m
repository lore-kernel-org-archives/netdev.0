From: Helge Deller <deller@gmx.de>
Subject: Re: [PATCH] enhance usability of /proc/sys/net/ipv4/ip_local_reserved_ports
 (v3)
Date: Fri, 16 Mar 2012 00:35:26 +0100
Message-ID: <4F627CBE.8030609@gmx.de>
References: <4F5BE563.9050506@gmx.de> <4F5FAF28.5030205@gmx.de> <4F611835.4080904@gmx.de> <m14ntqbym2.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Octavian Purdila <octavian.purdila@intel.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Frank Danapfel <fdanapfe@redhat.com>,
	Laszlo Ersek <lersek@redhat.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.22]:49893 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1031246Ab2COXgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Mar 2012 19:36:07 -0400
In-Reply-To: <m14ntqbym2.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/14/2012 11:34 PM, Eric W. Biederman wrote:
> Helge Deller<deller@gmx.de>  writes:
>
>> When writing to the ip_local_reserved_ports proc file it will currently clear
>> all previously reserved ports and update the current list with the one given
>> in the input.
>>
>> This behaviour makes it's usage quite hard, for example:
>> a) The generic proc filesystem limitation of only handle up to PAGE_SIZE-1
>>     characters at maximum may not be sufficient to provide all your wished-to-
>>     be-reserved ports at once.
>
> Fundamentally this need to be fixed first or else you will not be able
> to display the bitmap through sysctl.

Not necessarily.
Reading more than 4K from /proc/sys/net/ipv4/ip_local_reserved_ports
is possible today already (everything depends on how much chars you
read-at-once). Just try using "dd bs=1M". Writing is the major limiting factor.

>> b) There is no easy way to disable specific given ports, you always need to
>>     give the full port list at once. This makes shell scripting hard, since
>>     you need to parse everything yourself.
>
>> c) There is no easy way to just add specific ports or port ranges. Again,
>>     this would be useful for shell scripts.
>
> Arguably b and c call for user space tools for better tools for dealing
> with text ranges not a magic parser in /proc.  We already have tools
> like seq, dshbak, and pdsh.  What is the difficulty of writing a little
> shell utility instead of modifying /proc?

I'm not modifying /proc. I'm just extending it to provide an alternative
method to modify values for the large bitmap case only.
The basic existing behaviour to just read/write values is still functional.

If for example the current value of ip_local_reserved_ports is:
300,400-500,600....
then I like the idea of just
	echo "release 420-480" > ...
much more than
	cat ip_local_reserved_ports | do_complicated_shell_string_scripting_to_remove_420-480_without_getting_above_4K > ip_local_reserved_ports
BTW, in this case the range 400-500 gets split up and the output should become
300,400-419,481-500,600....

>> The following patch solves this problem by simply extending the parser
>> in proc_do_large_bitmap() to accept the keywords "add" and "release" in front
>> of given ports or port ranges and to either add or drop the given ports
>> from the already existing list.
>>
>> Here is an example:
>> $ echo "1000-2000,5000">  /proc/sys/net/ipv4/ip_local_reserved_ports
>> $ cat /proc/sys/net/ipv4/ip_local_reserved_ports
>> 1000-2000,5000   (works as before, current port list is replaced by new one)
>>
>> $ echo "add 3000-4000">  /proc/sys/net/ipv4/ip_local_reserved_ports
>> $ cat /proc/sys/net/ipv4/ip_local_reserved_ports
>> 1000-2000,3000-4000,5000   (new ports added)
>>
>> $ echo "release 1500-3500">  /proc/sys/net/ipv4/ip_local_reserved_ports
>> $ cat /proc/sys/net/ipv4/ip_local_reserved_ports
>> 1000-1499,3501-4000,5000   (given ports were dropped from the list)
>>
>> My main motivation for this patch is because of a huge commercial application
>> which by default may use lots of ports. The full port list which I would have
>> needed to echo to the /proc/sys/net/ipv4/ip_local_reserved_ports file was
>> around 30K, and in this case all ports were already combined to regions where
>> possible. With this patch it's now easy to split up the port ranges into
>> single pieces and to implement everything in simple bootup shell scripts.
>> Furthermore adding new or removing unneeded ports dynamically at runtime is
>> now easily possible.
>
> You are breaking concept that the bitmap is a single value in /proc/sys
> which I don't like at all.

Please keep in mind that this is a 65535 bit (port) bitmap, not just a "simple"
single value.
And the basic concept is still there.

> And ultimately this is a lot of code to avoid fixing a 4K limit of
> sysctl reads and writes.

I would love if the 4K problem gets fixed.
But it seems that this will lead to a major redesign and rewrite of
the whole /proc interface which I won't be able to drive.
I'm not even sure if this could be done in short time without
breaking existing compatibility. Other people here on the list can
surely comment on that better than me.

So, my patch is at least a "balanced" solution which can make the
current ip_local_reserved_ports interface useable to existing
applications. In it's current form, the usage of ip_local_reserved_ports
isfull of limitations.

>If I understand this correctly after this
> patch is applied you can not read the result you write in with your
> commercial application.  That just seems wrong.

As mentioned above: reading is possible. And with my patch
applied you usually probably won't need to read the values since you
don't care which other ports have been configured and just add/release
the ones you are interested in.

Regarding the commercial application: The idea is to provide an additional
shell-based system initscript which fills the ip_local_reserved_ports
list with initial values based on the product which the customer
installed. After the values have been set during bootup, further (dynamic)
changes of this port list won't happen unless the administrator
manually wants to add/release other ports. So, no magic in here...

> Can you please attack the fundamental issue first?

You mean the 4K/PAGE_SIZE limitation? As said above, that's probably
above my possibilities / time capatibilities. Sorry.

But of course I'm open for all kind of other ideas how and API for
the large bitmap case could be done better. Sadly the seq_file interface
doesn't seem to support reading yet...?

Helge
