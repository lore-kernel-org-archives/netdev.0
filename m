From: "Holger Hoffstaette" <holger.hoffstaette@googlemail.com>
Subject: Re: Network hangs with 2.6.30.5
Date: Thu, 03 Sep 2009 21:20:44 +0200
Message-ID: <pan.2009.09.03.19.20.44.736875@googlemail.com>
References: <pan.2009.09.01.15.32.24.613750@googlemail.com> <20090903074610.GA6000@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:55253 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753109AbZICTVH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Sep 2009 15:21:07 -0400
Received: from list by lo.gmane.org with local (Exim 4.50)
	id 1MjHro-0001eB-PD
	for netdev@vger.kernel.org; Thu, 03 Sep 2009 21:21:08 +0200
Received: from port-87-234-135-12.dynamic.qsc.de ([87.234.135.12])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 03 Sep 2009 21:21:08 +0200
Received: from holger.hoffstaette by port-87-234-135-12.dynamic.qsc.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 03 Sep 2009 21:21:08 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Problem found! At least for me..

On Thu, 03 Sep 2009 07:46:10 +0000, Jarek Poplawski wrote:

> On 01-09-2009 17:32, Holger Hoffstaette wrote:
>> On Tue, 01 Sep 2009 16:17:08 +0200, Holger Hoffstaette wrote:
>> 
>> [network regressions in .30]
>> 
>>> I do have an older Intel Gbit card identified thusly: 00:0b.0 Ethernet
>>> controller: Intel Corporation 82545GM Gigabit Ethernet Controller (rev
>>> 04)
>>>
>>> and enabled all sorts of offloading:
>>>
>>> $ethtool -k eth0
>>> Offload parameters for eth0:
>>> rx-checksumming: on
>>> tx-checksumming: on
>>> scatter-gather: on
>>> tcp segmentation offload: on
>>> udp fragmentation offload: off
>>> generic segmentation offload: on
>>>
>>> Maybe that is the culprit, as Eric Dumazet suspected in his mail..I
>>> will try the latest .30 stable again without that, but in any case
>>> something is indeed very broken in there.
>> 
>> So I just tried .30.5 again. Indeed the offloading seems to play a role:
>> with everything enabled I cannot even reliably ssh into the machine
>> (only "sometimes"?); however without any offloading things get "a bit
>> better" and squid even serves up some pages..for a while. Then it seems
>> to hang, swallow requests or not finish them. The tested sites reliably
>> work for the Windows client when it bypasses squid, as does DNS (also
>> served from the box). It *seems* to affect incoming traffic more than
>> outgoing - e.g. mail or news polling seemed to kick off and finish just
>> fine. Rebooting back into .29 fixes everything. Last time I tried
>> .31rc-something (4 IIRC) it exhibited the same problems.
>> 
>> I'm open to suggestions and willing to help fix this but need this
>> machine for actual work. :/
> 
> It seems, you and Clifford, use e1000 so it would be interesting to find
> out if it matters. Does your friend with working .30 use another card? If
> you can't try with another NIC, we could probably try to revert most of
> the driver's changes after .29 (except maybe 3) to check this driver only.
> 
> Clifford, if it still doesn't work for you, could you try 2.6.29?

I got the git .30.y stable tree and reverted various e1000 commits that
seemed to coincide with the various .30-rc releases but nothing helped.
Also no relation to offloads etc.

However I did notice that the "stuck squid" problem seemed to magically
fix itself after a few seconds - then hang again, fix itself after
timeouts etc. So I suspected something TCP related and BINGO!

Turns out I had both tcp_tw_recycle and tcp_tw_reuse set to 1 for reasons
I don't want to explain. :)

I can now arbitrarily fix the hanging behaviour by setting
tcp_tw_recycle to 0, and cause hangs by setting it to 1 again. For obvious
reasons this seems to affect squid more than other tasks with more long-lived
connections. What is the right behaviour? beats me.

tcp_tw_reuse does not appear to play a role, so the real culprit at least
in my case seems to be tcp_tw_recycle. In previous releases this (and
tw_reuse) was necessary for various server tasks.

Nevertheless, something has changed between .29 and .30 that "broke" the
previous behaviour. Whether this is progress or an regression I cannot
say. Maybe someone else has an idea?

Holger


