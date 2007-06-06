From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] fix e100 rx path on ARM (was [PATCH] e100
 rx: or s and el bits)
Date: Tue, 05 Jun 2007 19:26:42 -0700
Message-ID: <46661B62.4070209@intel.com>
References: <4654B2E4.9010308@roinet.com>
	<039d8ee49a8dfcbff8695b19d0a1a5c4@bga.com>
	<a4fae96e1c8c7b594207bf77fcb6b38f@bga.com>
	<465C4DBE.6000205@roinet.com>
	<94c8ff9069a77568513a9a1d1e60012d@bga.com>
	<4660856E.80403@roinet.com>
	<fac4512e243d821a94e8ee7304240981@bga.com>
	<4665664D.30906@roinet.com>
	<b2809ae38545c6104771af3c3a8b2250@bga.com>
	<46659CF7.2070003@intel.com> <20070605173904.GP31565@havoc.gtf.org>
	<4665A0B6.6020902@intel.com>
	<4112397f218a0744ebf8656c81acf850@bga.com>
	<4665F2B8.3070805@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Milton Miller <miltonm@bga.com>, Scott Feldman <sfeldma@pobox.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Acker <dacker@roinet.com>
To: Jeff Garzik <jeff@garzik.org>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <4665F2B8.3070805@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Milton Miller wrote:
>> On Jun 5, 2007, at 12:43 PM, Kok, Auke wrote:
>>
>>> Jeff Garzik wrote:
>>>> On Tue, Jun 05, 2007 at 10:27:19AM -0700, Kok, Auke wrote:
>>>>> We need to make sure that now that we're getting closer to 2.6.22 we 
>>>>> don't end up killing e100 in it. Should we drop the current fixes in 
>>>>> it to be on the safe side and aim for 2.6.23? I would hate to see an 
>>>>> untested codepath breaking e100 on something like ppc or mips... 
>>>>> that will be very painful
>>>> I certainly agree with this assessment...
>>>> I've been wondering if, based on all this recent work, we should 
>>>> revert
>>>> the s-bit stuff and wait for 2.6.23.
>>> Yes, that's my point. If Milton and David agree I think we should do 
>>> so immediately.
>> We definitely need something other than what is in now.
>>
>>
>>> If so, do you want me to write a revert-patch or do you have some 
>>> magic to do that for me?
>>>
>> The simple git revert won't work because there have been other changes 
>> (ioread for instance) that conflict.
> 
> Hmm git-revert seems to do the job right. I checked it with git-show | patch -p1 
> -R and the results look OK. The two patches on top of the one we want to revert 
> are unrelated enough to apply (manually it shows some fuzz, but otherwise it's OK).
> 
> Jeff, please `git-revert d52df4a35af569071fda3f4eb08e47cc7023f094` to revert the 
> following patch for now:
> 
> ---
> commit  d52df4a35af569071fda3f4eb08e47cc7023f094
> Author: Scott Feldman <sfeldma@pobox.com>
> Date:   Wed Nov 9 02:18:52 2005 -0500
> 
>      [netdrvr e100] experiment with doing RX in a similar manner to eepro100
> 
>      I was going to say that eepro100's speedo_rx_link() does the same DMA
>      abuse as e100, but then I noticed one little detail: eepro100 sets  both
>      EL (end of list) and S (suspend) bits in the RFD as it chains it  to the
>      RFD list.  e100 was only setting the EL bit.  Hmmm, that's  interesting.
>      That means that if HW reads a RFD with the S-bit set,  it'll process
>      that RFD and then suspend the receive unit.  The  receive unit will
>      resume when SW clears the S-bit.  There is no need  for SW to restart
>      the receive unit.  Which means a lot of the receive  unit state tracking
>      code in the driver goes away.
> 
>      So here's a patch against 2.6.14.  (Sorry for inlining it; the mailer
>      I'm using now will mess with the word wrap).  I can't test this on
>      XScale (unless someone has an e100 module for Gumstix :) .  It should
>      be doing exactly what eepro100 does with RFDs.  I don't believe this
>      change will introduce a performance hit because the S-bit and EL-bit  go
>      hand-in-hand meaning if we're going to suspend because of the S- bit,
>      we're on the last resource anyway, so we'll have to wait for SW  to
>      replenish.
>      (cherry picked from 29e79da9495261119e3b2e4e7c72507348e75976 commit)
> ---
> 

A little bit more is needed to explain why we're reverting it for now. Jeff, 
please insert this into the revert commit.

Auke

--
This patch attempted to fix e100 for non-cache coherent memory architectures by 
using the cb style code that eepro100 had and using the EL and s bits from the 
RFD list. Unfortunately the hardware doesn't work exactly like this and 
therefore this patch actually breaks e100 on those systems. Reverting the change 
brings it back to the previously known good state for 2.6.22. The pending 
rewrite in progress to this code can then be safely merged later.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
