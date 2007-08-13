From: Paul Clements <paul.clements@steeleye.com>
Subject: Re: [RFD] Layering: Use-Case Composers (was: DRBD - what is it,	anyways?
 [compare with e.g. NBD + MD raid])
Date: Sun, 12 Aug 2007 21:41:15 -0400
Message-ID: <46BFB6BB.80406@steeleye.com>
References: <200708121335.17267.a1426z@gawab.com> <Pine.LNX.4.64.0708121325170.28963@fbirervta.pbzchgretzou.qr> <Pine.LNX.4.64.0708120933210.19502@asgard.lang.hm> <Pine.LNX.4.64.0708121901290.28963@fbirervta.pbzchgretzou.qr> <20070812174549.GA2915@teal.hq.k1024.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Jan Engelhardt <jengelh@computergmbh.de>, david@lang.hm,
	Al Boldi <a1426z@gawab.com>, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
	linux-raid@v
Return-path: <linux-raid-owner@vger.kernel.org>
In-Reply-To: <20070812174549.GA2915@teal.hq.k1024.org>
Sender: linux-raid-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Iustin Pop wrote:
> On Sun, Aug 12, 2007 at 07:03:44PM +0200, Jan Engelhardt wrote:
>> On Aug 12 2007 09:39, david@lang.hm wrote:
>>> now, I am not an expert on either option, but three are a couple things that I
>>> would question about the DRDB+MD option
>>>
>>> 1. when the remote machine is down, how does MD deal with it for reads and
>>> writes?
>> I suppose it kicks the drive and you'd have to re-add it by hand unless done by
>> a cronjob.

Yes, and with a bitmap configured on the raid1, you just resync the 
blocks that have been written while the connection was down.


>>From my tests, since NBD doesn't have a timeout option, MD hangs in the
> write to that mirror indefinitely, somewhat like when dealing with a
> broken IDE driver/chipset/disk.

Well, if people would like to see a timeout option, I actually coded up 
a patch a couple of years ago to do just that, but I never got it into 
mainline because you can do almost as well by doing a check at 
user-level (I basically ping the nbd connection periodically and if it 
fails, I kill -9 the nbd-client).


>>> 2. MD over local drive will alternate reads between mirrors (or so I've been
>>> told), doing so over the network is wrong.
>> Certainly. In which case you set "write_mostly" (or even write_only, not sure
>> of its name) on the raid component that is nbd.
>>
>>> 3. when writing, will MD wait for the network I/O to get the data saved on the
>>> backup before returning from the syscall? or can it sync the data out lazily
>> Can't answer this one - ask Neil :)
> 
> MD has the write-mostly/write-behind options - which help in this case
> but only up to a certain amount.

You can configure write_behind (aka, asynchronous writes) to buffer as 
much data as you have RAM to hold. At a certain point, presumably, you'd 
want to just break the mirror and take the hit of doing a resync once 
your network leg falls too far behind.

--
Paul
