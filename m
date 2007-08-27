From: David Acker <dacker@roinet.com>
Subject: Re: [PATCH] fix e100 rx path on ARM (was [PATCH] e100
 rx: or s and el bits)
Date: Mon, 27 Aug 2007 14:32:54 -0400
Message-ID: <46D318D6.5060004@roinet.com>
References: <200705011124.l41BOEG4007662@sullivan.realtime.net>
	<4638F2B2.2000103@roinet.com> <463BA906.30205@roinet.com>
	<85f07fc58d5ed2147d5214d0f0b4fe32@bga.com>
	<4648A9DF.6030001@roinet.com> <464D074F.20400@pobox.com>
	<464D21B6.2000208@intel.com> <464DB336.2030003@roinet.com>
	<464DB619.3070900@roinet.com> <464DC676.90504@intel.com>
	<464DCA97.3070405@roinet.com> <464DCD5E.50003@intel.com>
	<464DDE3E.9010400@roinet.com>
	<e3819b7a866b1117fd5a69e6a85e0784@bga.com>
	<4651DAC1.7050604@intel.com>
	<53c44b6f03973eb1b28f221859d3002c@bga.com>
	<465369AF.8080508@roinet.com>
	<f83441453b1233771c5bda869912aeca@bga.com>
	<4654B2E4.9010308@roinet.com>
	<039d8ee49a8dfcbff8695b19d0a1a5c4@bga.com>
	<a4fae96e1c8c7b594207bf77fcb6b38f@bga.com>
	<465C4DBE.6000205@roinet.com>
	<94c8ff9069a77568513a9a1d1e60012d@bga.com>
	<4660856E.80403@roinet.com>
	<fac4512e243d821a94e8ee7304240981@bga.com>
	<4665664D.30906@roinet.com>
	<f2baf1c4eb6d0eff237e6f252ce671c7@bga.com>
	<46D30B0D.5020605@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Milton Miller <miltonm@bga.com>, Scott Feldman <sfeldma@pobox.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jeff Garzik <jgarzik@pobox.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <46D30B0D.5020605@intel.com>
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
> Milton Miller wrote:
>> On Jun 5, 2007, at 8:34 AM, David Acker wrote:
> 
> David, Milton,
> 
> This was the last communication on-topic for the proposed changes to fix 
> e100 on ARM. We're holding our breath here waiting for more, and would 
> love to hear that this issue and fixes hasn't died off.
> 
> Thanks,
> 
> Auke

I am sorry folks, this is my fault.  I got pulled onto a fire on one of 
our other products.  I have only recently come back to working on our 
product that uses the e100 on ARM.  Based on my current time available 
to finish cleaning up this patch, I should have a new version available 
by the end of this week.
-Ack


> 
> 
> 
>>> Milton Miller wrote:
>>>> On Jun 1, 2007, at 3:45 PM, David Acker wrote:
>>>>> Ok, I took a stab at coding and testing these ideas.  Below is a 
>>>>> patch against 2.6.22-rc3.
>>>>> Let me know what you think.
>>>> I think you got most of the ideas.   As Auke noted, your coding 
>>>> style is showing again.   And your mailer again munged whitespace 
>>>> (fixed by s/^<space><space>/<space>/ s/^$/<space>/).
>>> Sorry about the coding style.  I instinctively followed what was 
>>> there instead of kernel coding convention.  I will look into how 
>>> whitespace is getting screwed up.
>>
>> I have to watch my coding style too (I like to indent the closing brace).
>>
>> At least the white space damage seems to be reversable.  More than I 
>> can say for this mailer.
>>
>>>>> Find a buffer that is complete with rx->el not set and rx->s0 set.
>>>>>     It appears that hardware can read the rfd's el-bit, then 
>>>>> software can clear the rfd el-bit and set the rfd size, and then 
>>>>> hardware can come in and read the size.
>>>> Yes, since the size is after the EL flag in the descriptor, this can 
>>>> happen since the pci read is not atomic.
>>>>> I am reading the status back, although I don't think that I have to 
>>>>> in this instance.
>>>> Actually, you are reading it when the rfd still has EL set.  Since 
>>>> the cpu will never encounter that case, the if condition is never 
>>>> satisfied.
>>> In my tests, every time I found a completed rfd with the el-bit set, 
>>> the receiver was in the out of resources state.
>>
>> Yes, if the EL was set, it would be a real hard race to find the 
>> completed packet with EL but not RNR.   I was trying to refer to where 
>> you find a completed packet and then check for EL in the RFD.  That is 
>> what I was claiming can not be observed by the cpu (unless the card 
>> writes the EL bit back, and not just the status u16).
>>
>> If the unless ... above is true, then please put a comment that the 
>> device can write RFD->EL back to 1 if we raced.
>>
>>
>>>> How about creating a state unknown, for when we think we should 
>>>> check the device if its running.
>>>> If we are in this state and then encounter a received packet without 
>>>> s0 set, we can set it back
>>>> to running.   We set it when we rx a packet with s0 set.
>>>> We then move both io_status reads to the caller.
>>> I can look into that as I clean this up.
>>>
>>>
>>>>> I am testing a version of this code patched against 2.6.18.4 on my 
>>>>> PXA 255 based system.  I will let you all know how it goes.
>>> The testing I did so far did well.  I will try to get some more going 
>>> tonight, hopefully on a cleaned up patch.
>>
>> Good to hear our expectiations match reality.
>>
>>>
>>>> I'm assuming this is why the cleanup of the receiver start to always 
>>>> start on rx_to_clean got dropped again. :-)
>>> Yep.  I will get that in the next patch.
>>
>> Ok.
>>
>>>> Also, I would like a few sentences in the Driver Operation section 
>>>> IV Receive big comment.  Something like
>>>> In order to keep updates to the RFD link field from colliding with 
>>>> hardware writes to mark packets complete, we use the feature that 
>>>> hardware will not write to a size 0 descriptor and mark the previous 
>>>> packet as end-of-list (EL).   After updating the link, we remove EL 
>>>> and only then restore the size such that hardware may use the 
>>>> previous-to-end RFD.
>>>> at the end of the first paragraph, and insert software before "no 
>>>> locking is required" in the second.
>>> Sounds good to me.
>>>
>>> I will see if I can get into a cleaned up patch today and get it out 
>>> by tomorrow.  Thanks for dealing with me...I have been around kernel 
>>> code for awhile but posting official patches to linux is new to me.
>>> -Ack
>>
>> I've just learned by watching the lists over the last several years.  
>> Well, and actually writing the odd patch here and there.
>>
>> It occurs to me that I have been focusing on the code and not the 
>> changelog.   I'll send a seperate reply on that thread shortly.
>>
>> One more thing I'll state here ... as per the perfect patch 
>> guidelines, it is preferred that the meta-discussion about the patch 
>> and its history go after the change log, seperated from it by a line 
>> of "--- " so that the patch application scripts can just extract the 
>> email subject as the title and through the firsst line of --- as the 
>> commit log.  (This saves some manual editing).
>>
>> [1] http://kernelnewbies.org/UpstreamMerge
>>
>> milton
>>
>> -
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
